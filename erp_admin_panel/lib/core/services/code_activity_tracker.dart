import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Advanced code activity tracking system for development workflow
class CodeActivityTracker {
  static final CodeActivityTracker _instance = CodeActivityTracker._internal();
  factory CodeActivityTracker() => _instance;
  CodeActivityTracker._internal();

  static const String _logFileName = 'code_activity_log.json';
  static const String _summaryFileName = 'daily_code_summary.md';
  late final String _logFilePath;
  late final String _summaryFilePath;
  
  List<CodeActivity> _activities = [];
  Map<String, FileTrackingInfo> _fileTracking = {};

  /// Initialize the tracker with project root path
  Future<void> initialize({String? projectRoot}) async {
    if (kIsWeb) {
      // Web mode - use memory-only tracking
      _logFilePath = 'web_activity_log.json';
      _summaryFilePath = 'web_activity_summary.md';
      print('🌐 Code Activity Tracker: Web mode - Memory-only tracking');
    } else {
      // Desktop/Mobile mode - use file system
      final rootPath = projectRoot ?? Directory.current.path;
      final logsDir = path.join(rootPath, 'logs', 'development');
      
      // Ensure logs directory exists
      await Directory(logsDir).create(recursive: true);
      
      _logFilePath = path.join(logsDir, _logFileName);
      _summaryFilePath = path.join(logsDir, _summaryFileName);
    }
    
    // Load existing activities
    await _loadExistingActivities();
    
    print('🔍 Code Activity Tracker initialized');
    print('📁 Log file: $_logFilePath');
    print('📄 Summary file: $_summaryFilePath');
  }

  /// Track file creation
  Future<void> trackFileCreated(String filePath, String content, {
    String? description,
    List<String>? tags,
  }) async {
    final activity = CodeActivity(
      type: ActivityType.fileCreated,
      filePath: filePath,
      timestamp: DateTime.now(),
      description: description ?? 'Created new file',
      details: {
        'content_length': content.length,
        'lines_added': content.split('\n').length,
        'file_extension': path.extension(filePath),
        'file_size_bytes': utf8.encode(content).length,
      },
      tags: tags ?? _inferTags(filePath, content),
    );
    
    _updateFileTracking(filePath, activity);
    await _logActivity(activity);
  }

  /// Track file modification
  Future<void> trackFileModified(String filePath, {
    String? oldContent,
    String? newContent,
    String? description,
    List<String>? tags,
  }) async {
    final changes = _calculateChanges(oldContent, newContent);
    
    final activity = CodeActivity(
      type: ActivityType.fileModified,
      filePath: filePath,
      timestamp: DateTime.now(),
      description: description ?? 'Modified file',
      details: {
        'lines_added': changes['linesAdded'],
        'lines_deleted': changes['linesDeleted'],
        'lines_modified': changes['linesModified'],
        'change_percentage': changes['changePercentage'],
        'modification_type': _getModificationType(changes),
      },
      tags: tags ?? _inferTags(filePath, newContent ?? ''),
      changeStats: changes,
    );
    
    _updateFileTracking(filePath, activity);
    await _logActivity(activity);
  }

  /// Track file deletion
  Future<void> trackFileDeleted(String filePath, {
    String? description,
    String? reason,
  }) async {
    final activity = CodeActivity(
      type: ActivityType.fileDeleted,
      filePath: filePath,
      timestamp: DateTime.now(),
      description: description ?? 'Deleted file',
      details: {
        'deletion_reason': reason ?? 'Not specified',
        'file_extension': path.extension(filePath),
      },
      tags: ['deletion', path.extension(filePath).replaceAll('.', '')],
    );
    
    _updateFileTracking(filePath, activity);
    await _logActivity(activity);
  }

  /// Track code refactoring
  Future<void> trackRefactoring(String filePath, String refactoringType, {
    String? description,
    Map<String, dynamic>? details,
  }) async {
    final activity = CodeActivity(
      type: ActivityType.refactoring,
      filePath: filePath,
      timestamp: DateTime.now(),
      description: description ?? 'Refactored code',
      details: {
        'refactoring_type': refactoringType,
        ...?details,
      },
      tags: ['refactoring', refactoringType.toLowerCase()],
    );
    
    _updateFileTracking(filePath, activity);
    await _logActivity(activity);
  }

  /// Track bug fixes
  Future<void> trackBugFix(String filePath, String bugDescription, {
    String? solution,
    String? severity,
  }) async {
    final activity = CodeActivity(
      type: ActivityType.bugFix,
      filePath: filePath,
      timestamp: DateTime.now(),
      description: 'Fixed bug: $bugDescription',
      details: {
        'bug_description': bugDescription,
        'solution': solution ?? 'Not specified',
        'severity': severity ?? 'medium',
      },
      tags: ['bugfix', severity ?? 'medium'],
    );
    
    _updateFileTracking(filePath, activity);
    await _logActivity(activity);
  }

  /// Track feature implementation
  Future<void> trackFeatureImplemented(String filePath, String featureName, {
    String? description,
    List<String>? components,
  }) async {
    final activity = CodeActivity(
      type: ActivityType.featureImplemented,
      filePath: filePath,
      timestamp: DateTime.now(),
      description: 'Implemented feature: $featureName',
      details: {
        'feature_name': featureName,
        'components': components ?? [],
        'implementation_details': description,
      },
      tags: ['feature', ...?components?.map((c) => c.toLowerCase())],
    );
    
    _updateFileTracking(filePath, activity);
    await _logActivity(activity);
  }

  /// Get activities for a specific file
  List<CodeActivity> getFileActivities(String filePath) {
    return _activities.where((a) => a.filePath == filePath).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get activities by type
  List<CodeActivity> getActivitiesByType(ActivityType type) {
    return _activities.where((a) => a.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get recent activities
  List<CodeActivity> getRecentActivities({int limit = 50}) {
    final sorted = List<CodeActivity>.from(_activities)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  /// Generate daily summary
  Future<void> generateDailySummary({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final dayStart = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    
    final dayActivities = _activities.where((a) => 
      a.timestamp.isAfter(dayStart) && a.timestamp.isBefore(dayEnd)
    ).toList();
    
    final summary = _generateSummaryMarkdown(dayActivities, targetDate);
    
    if (kIsWeb) {
      // In web mode, just store in memory or print to console
      print('📊 Daily Summary (Web Mode):');
      print(summary);
    } else {
      await File(_summaryFilePath).writeAsString(summary);
      print('📊 Daily summary generated: $_summaryFilePath');
    }
  }

  /// Get file statistics
  Map<String, dynamic> getFileStats(String filePath) {
    final activities = getFileActivities(filePath);
    final tracking = _fileTracking[filePath];
    
    return {
      'total_activities': activities.length,
      'last_modified': tracking?.lastModified?.toIso8601String(),
      'creation_date': tracking?.creationDate?.toIso8601String(),
      'modification_count': activities.where((a) => a.type == ActivityType.fileModified).length,
      'total_lines_added': activities.fold<int>(0, (sum, a) => sum + (a.changeStats?['linesAdded'] ?? 0)),
      'total_lines_deleted': activities.fold<int>(0, (sum, a) => sum + (a.changeStats?['linesDeleted'] ?? 0)),
      'activity_types': activities.map((a) => a.type.name).toSet().toList(),
      'tags': activities.expand((a) => a.tags).toSet().toList(),
    };
  }

  /// Get project statistics
  Map<String, dynamic> getProjectStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: now.weekday - 1));
    
    return {
      'total_activities': _activities.length,
      'total_files_tracked': _fileTracking.length,
      'activities_today': _activities.where((a) => a.timestamp.isAfter(today)).length,
      'activities_this_week': _activities.where((a) => a.timestamp.isAfter(thisWeek)).length,
      'activity_types_distribution': _getActivityTypeDistribution(),
      'most_active_files': _getMostActiveFiles(),
      'recent_tags': _getRecentTags(),
    };
  }

  // Private methods

  Future<void> _loadExistingActivities() async {
    try {
      if (kIsWeb) {
        // In web mode, start with empty activities
        print('🌐 Web mode: Starting with empty activity log');
        return;
      }
      
      final file = File(_logFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _activities = jsonList.map((json) => CodeActivity.fromJson(json)).toList();
        
        // Rebuild file tracking
        for (final activity in _activities) {
          _updateFileTracking(activity.filePath, activity, saveToFile: false);
        }
        
        print('📚 Loaded ${_activities.length} existing activities');
      }
    } catch (e) {
      print('⚠️ Error loading existing activities: $e');
    }
  }

  Future<void> _logActivity(CodeActivity activity) async {
    _activities.add(activity);
    
    // Keep only last 10000 activities to prevent file from growing too large
    if (_activities.length > 10000) {
      _activities = _activities.skip(_activities.length - 10000).toList();
    }
    
    try {
      if (kIsWeb) {
        // In web mode, just keep activities in memory
        print('📝 ${activity.type.name}: ${path.basename(activity.filePath)} - ${activity.description}');
      } else {
        final jsonList = _activities.map((a) => a.toJson()).toList();
        await File(_logFilePath).writeAsString(jsonEncode(jsonList));
        
        print('📝 ${activity.type.name}: ${path.basename(activity.filePath)} - ${activity.description}');
      }
    } catch (e) {
      print('⚠️ Error saving activity log: $e');
    }
  }

  void _updateFileTracking(String filePath, CodeActivity activity, {bool saveToFile = true}) {
    if (!_fileTracking.containsKey(filePath)) {
      _fileTracking[filePath] = FileTrackingInfo(
        filePath: filePath,
        creationDate: activity.timestamp,
        lastModified: activity.timestamp,
      );
    } else {
      _fileTracking[filePath]!.lastModified = activity.timestamp;
    }
    
    _fileTracking[filePath]!.activityCount++;
  }

  List<String> _inferTags(String filePath, String content) {
    final tags = <String>[];
    final extension = path.extension(filePath).replaceAll('.', '');
    
    if (extension.isNotEmpty) tags.add(extension);
    
    // Infer from path
    if (filePath.contains('screens/')) tags.add('ui');
    if (filePath.contains('providers/')) tags.add('state-management');
    if (filePath.contains('models/')) tags.add('data-model');
    if (filePath.contains('services/')) tags.add('service');
    if (filePath.contains('utils/')) tags.add('utility');
    if (filePath.contains('test/')) tags.add('testing');
    
    // Infer from content
    if (content.contains('class ') && content.contains('extends StatefulWidget')) tags.add('stateful-widget');
    if (content.contains('class ') && content.contains('extends StatelessWidget')) tags.add('stateless-widget');
    if (content.contains('Provider') || content.contains('Riverpod')) tags.add('provider');
    if (content.contains('Firebase') || content.contains('Firestore')) tags.add('firebase');
    if (content.contains('async') && content.contains('await')) tags.add('async');
    
    return tags;
  }

  Map<String, int> _calculateChanges(String? oldContent, String? newContent) {
    if (oldContent == null || newContent == null) {
      return {
        'linesAdded': newContent?.split('\n').length ?? 0,
        'linesDeleted': oldContent?.split('\n').length ?? 0,
        'linesModified': 0,
        'changePercentage': 100,
      };
    }
    
    final oldLines = oldContent.split('\n');
    final newLines = newContent.split('\n');
    
    // Simple diff calculation (could be enhanced with proper diff algorithm)
    final maxLines = [oldLines.length, newLines.length].reduce((a, b) => a > b ? a : b);
    final minLines = [oldLines.length, newLines.length].reduce((a, b) => a < b ? a : b);
    
    final linesAdded = newLines.length - oldLines.length;
    final linesDeleted = linesAdded < 0 ? -linesAdded : 0;
    final actualLinesAdded = linesAdded > 0 ? linesAdded : 0;
    
    // Calculate modified lines (simplified)
    int modifiedLines = 0;
    for (int i = 0; i < minLines; i++) {
      if (i < oldLines.length && i < newLines.length && oldLines[i] != newLines[i]) {
        modifiedLines++;
      }
    }
    
    final changePercentage = maxLines > 0 ? 
      ((actualLinesAdded + linesDeleted + modifiedLines) / maxLines * 100).round() : 0;
    
    return {
      'linesAdded': actualLinesAdded,
      'linesDeleted': linesDeleted,
      'linesModified': modifiedLines,
      'changePercentage': changePercentage,
    };
  }

  String _getModificationType(Map<String, int> changes) {
    final added = changes['linesAdded'] ?? 0;
    final deleted = changes['linesDeleted'] ?? 0;
    final modified = changes['linesModified'] ?? 0;
    
    if (added > deleted && added > modified) return 'expansion';
    if (deleted > added && deleted > modified) return 'reduction';
    if (modified > added && modified > deleted) return 'refactoring';
    if (added == deleted && added > 0) return 'replacement';
    return 'minor-edit';
  }

  Map<String, int> _getActivityTypeDistribution() {
    final distribution = <String, int>{};
    for (final activity in _activities) {
      distribution[activity.type.name] = (distribution[activity.type.name] ?? 0) + 1;
    }
    return distribution;
  }

  List<Map<String, dynamic>> _getMostActiveFiles({int limit = 10}) {
    final fileCounts = <String, int>{};
    for (final activity in _activities) {
      fileCounts[activity.filePath] = (fileCounts[activity.filePath] ?? 0) + 1;
    }
    
    final sortedFiles = fileCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedFiles.take(limit).map((entry) => {
      'file': path.basename(entry.key),
      'full_path': entry.key,
      'activity_count': entry.value,
    }).toList();
  }

  List<String> _getRecentTags({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recentTags = _activities
      .where((a) => a.timestamp.isAfter(cutoff))
      .expand((a) => a.tags)
      .toSet()
      .toList();
    return recentTags;
  }

  String _generateSummaryMarkdown(List<CodeActivity> activities, DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final buffer = StringBuffer();
    buffer.writeln('# Code Activity Summary - $dateStr');
    buffer.writeln();
    buffer.writeln('## Overview');
    buffer.writeln('- **Total Activities**: ${activities.length}');
    buffer.writeln('- **Files Modified**: ${activities.map((a) => a.filePath).toSet().length}');
    buffer.writeln();
    
    // Activity breakdown
    final typeBreakdown = <String, int>{};
    for (final activity in activities) {
      typeBreakdown[activity.type.name] = (typeBreakdown[activity.type.name] ?? 0) + 1;
    }
    
    buffer.writeln('## Activity Breakdown');
    for (final entry in typeBreakdown.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value}');
    }
    buffer.writeln();
    
    // Recent activities
    buffer.writeln('## Recent Activities');
    for (final activity in activities.take(20)) {
      final time = '${activity.timestamp.hour.toString().padLeft(2, '0')}:${activity.timestamp.minute.toString().padLeft(2, '0')}';
      buffer.writeln('- `$time` **${activity.type.name}** - ${path.basename(activity.filePath)}: ${activity.description}');
    }
    
    return buffer.toString();
  }
}

/// Represents a single code activity
class CodeActivity {
  final ActivityType type;
  final String filePath;
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> details;
  final List<String> tags;
  final Map<String, int>? changeStats;

  CodeActivity({
    required this.type,
    required this.filePath,
    required this.timestamp,
    required this.description,
    this.details = const {},
    this.tags = const [],
    this.changeStats,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'filePath': filePath,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
    'details': details,
    'tags': tags,
    'changeStats': changeStats,
  };

  factory CodeActivity.fromJson(Map<String, dynamic> json) => CodeActivity(
    type: ActivityType.values.firstWhere((t) => t.name == json['type']),
    filePath: json['filePath'],
    timestamp: DateTime.parse(json['timestamp']),
    description: json['description'],
    details: Map<String, dynamic>.from(json['details'] ?? {}),
    tags: List<String>.from(json['tags'] ?? []),
    changeStats: json['changeStats'] != null ? Map<String, int>.from(json['changeStats']) : null,
  );
}

/// Types of code activities
enum ActivityType {
  fileCreated,
  fileModified,
  fileDeleted,
  refactoring,
  bugFix,
  featureImplemented,
  testAdded,
  documentationUpdated,
  dependencyAdded,
  configurationChanged,
}

/// File tracking information
class FileTrackingInfo {
  final String filePath;
  final DateTime creationDate;
  DateTime lastModified;
  int activityCount = 0;

  FileTrackingInfo({
    required this.filePath,
    required this.creationDate,
    required this.lastModified,
  });
}
