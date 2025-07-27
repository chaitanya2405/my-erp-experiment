import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'code_activity_tracker.dart';

/// Automatic file change detection and tracking service
class AutoCodeTracker {
  static final AutoCodeTracker _instance = AutoCodeTracker._internal();
  factory AutoCodeTracker() => _instance;
  AutoCodeTracker._internal();

  late final CodeActivityTracker _tracker;
  final Map<String, FileSnapshot> _fileSnapshots = {};
  bool _isInitialized = false;

  /// Initialize the auto tracker
  Future<void> initialize({String? projectRoot}) async {
    if (_isInitialized) return;
    
    _tracker = CodeActivityTracker();
    await _tracker.initialize(projectRoot: projectRoot);
    
    // Skip file system operations in web environment
    if (kIsWeb) {
      print('🌐 Auto Code Tracker: Web mode - File monitoring disabled');
      print('🤖 Auto Code Tracker initialized for web environment');
    } else {
      // Take initial snapshots of existing files (desktop/mobile only)
      await _takeInitialSnapshots(projectRoot ?? Directory.current.path);
      print('🤖 Auto Code Tracker initialized and monitoring file changes');
    }
    
    _isInitialized = true;
  }

  /// Monitor a specific file for changes
  Future<void> monitorFile(String filePath) async {
    if (!_isInitialized) {
      throw Exception('AutoCodeTracker not initialized. Call initialize() first.');
    }

    if (kIsWeb) {
      print('🌐 Web mode: File monitoring not available for $filePath');
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      print('⚠️ File does not exist: $filePath');
      return;
    }

    await _createSnapshot(filePath);
    print('👁️ Now monitoring: ${path.basename(filePath)}');
  }

  /// Check for file changes and log them
  Future<void> checkForChanges(String filePath) async {
    if (!_isInitialized) return;

    if (kIsWeb) {
      // In web mode, we can't monitor file changes automatically
      // but we can still manually track operations
      return;
    }

    final file = File(filePath);
    
    // Check if file was deleted
    if (!await file.exists()) {
      if (_fileSnapshots.containsKey(filePath)) {
        await _tracker.trackFileDeleted(filePath, description: 'File was deleted');
        _fileSnapshots.remove(filePath);
      }
      return;
    }

    final oldSnapshot = _fileSnapshots[filePath];
    final newSnapshot = await _createSnapshot(filePath);

    // New file
    if (oldSnapshot == null) {
      await _tracker.trackFileCreated(
        filePath, 
        newSnapshot.content,
        description: 'New file detected by auto-tracker',
      );
      return;
    }

    // File modified
    if (oldSnapshot.content != newSnapshot.content) {
      await _tracker.trackFileModified(
        filePath,
        oldContent: oldSnapshot.content,
        newContent: newSnapshot.content,
        description: 'Auto-detected file modification',
      );
    }
  }

  /// Track manual code operations
  Future<void> trackManualOperation(String operationType, String filePath, {
    String? description,
    Map<String, dynamic>? details,
  }) async {
    if (!_isInitialized) return;

    switch (operationType.toLowerCase()) {
      case 'create':
        final file = File(filePath);
        if (await file.exists()) {
          final content = await file.readAsString();
          await _tracker.trackFileCreated(filePath, content, description: description);
          await _createSnapshot(filePath);
        }
        break;
        
      case 'edit':
      case 'modify':
        await checkForChanges(filePath);
        break;
        
      case 'delete':
        await _tracker.trackFileDeleted(filePath, description: description);
        _fileSnapshots.remove(filePath);
        break;
        
      case 'refactor':
        await _tracker.trackRefactoring(
          filePath, 
          details?['refactoring_type'] ?? 'unknown',
          description: description,
          details: details,
        );
        break;
        
      case 'bugfix':
        await _tracker.trackBugFix(
          filePath,
          description ?? 'Bug fix',
          solution: details?['solution'],
          severity: details?['severity'],
        );
        break;
        
      case 'feature':
        await _tracker.trackFeatureImplemented(
          filePath,
          details?['feature_name'] ?? 'New feature',
          description: description,
          components: details?['components'],
        );
        break;
    }
  }

  /// Monitor entire directory for changes
  Future<void> monitorDirectory(String directoryPath, {
    List<String> includeExtensions = const ['.dart', '.yaml', '.json', '.md'],
    List<String> excludePatterns = const ['build/', '.dart_tool/', 'ios/', 'android/', 'web/', 'windows/', 'linux/', 'macos/'],
  }) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: directoryPath);
        
        // Skip excluded patterns
        if (excludePatterns.any((pattern) => relativePath.contains(pattern))) {
          continue;
        }
        
        // Include only specified extensions
        if (includeExtensions.isNotEmpty && 
            !includeExtensions.contains(path.extension(entity.path))) {
          continue;
        }
        
        await monitorFile(entity.path);
      }
    }
  }

  /// Get activity summary for current session
  Map<String, dynamic> getSessionSummary() {
    if (!_isInitialized) return {};
    return _tracker.getProjectStats();
  }

  /// Generate development report
  Future<void> generateDevelopmentReport() async {
    if (!_isInitialized) return;
    await _tracker.generateDailySummary();
    print('📊 Development report generated');
  }

  /// Get file change history
  List<CodeActivity> getFileHistory(String filePath) {
    if (!_isInitialized) return [];
    return _tracker.getFileActivities(filePath);
  }

  /// Helper method to track code completion/AI assistance
  Future<void> trackAIAssistance(String filePath, String assistanceType, {
    String? description,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) return;

    await _tracker.trackFeatureImplemented(
      filePath,
      'AI Assistance: $assistanceType',
      description: description ?? 'Code generated/modified with AI assistance',
      components: ['ai-assistance', assistanceType.toLowerCase()],
    );
  }

  // Private methods

  Future<void> _takeInitialSnapshots(String projectRoot) async {
    final dartFiles = await _findDartFiles(projectRoot);
    print('📸 Taking initial snapshots of ${dartFiles.length} files...');
    
    for (final filePath in dartFiles) {
      await _createSnapshot(filePath);
    }
  }

  Future<FileSnapshot> _createSnapshot(String filePath) async {
    final file = File(filePath);
    final stat = await file.stat();
    final content = await file.readAsString();
    
    final snapshot = FileSnapshot(
      filePath: filePath,
      lastModified: stat.modified,
      size: stat.size,
      content: content,
      contentHash: content.hashCode,
    );
    
    _fileSnapshots[filePath] = snapshot;
    return snapshot;
  }

  Future<List<String>> _findDartFiles(String projectRoot) async {
    final files = <String>[];
    final dir = Directory(projectRoot);
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final relativePath = path.relative(entity.path, from: projectRoot);
        
        // Skip build directories and generated files
        if (!relativePath.contains('build/') && 
            !relativePath.contains('.dart_tool/') &&
            !relativePath.contains('ios/') &&
            !relativePath.contains('android/') &&
            !relativePath.contains('web/') &&
            !relativePath.contains('windows/') &&
            !relativePath.contains('linux/') &&
            !relativePath.contains('macos/')) {
          files.add(entity.path);
        }
      }
    }
    
    return files;
  }
}

/// File snapshot for change detection
class FileSnapshot {
  final String filePath;
  final DateTime lastModified;
  final int size;
  final String content;
  final int contentHash;

  FileSnapshot({
    required this.filePath,
    required this.lastModified,
    required this.size,
    required this.content,
    required this.contentHash,
  });
}
