import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Activity tracking system to record navigation, file usage, and user interactions
class ActivityTracker {
  static final ActivityTracker _instance = ActivityTracker._internal();
  factory ActivityTracker() => _instance;
  ActivityTracker._internal();

  final List<ActivityRecord> _activities = [];
  final List<String> _filesUsed = [];
  final Map<String, int> _navigationCounts = {};
  final Map<String, List<String>> _screenFileMapping = {};
  
  bool _isEnabled = true;
  bool _terminalLoggingEnabled = true;
  String? _currentScreen;
  DateTime? _screenStartTime;

  // Public getters for activity viewer
  bool get isEnabled => _isEnabled;
  bool get terminalLoggingEnabled => _terminalLoggingEnabled;
  static ActivityTracker get instance => _instance;

  /// Enable or disable activity tracking
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      _logToTerminal('\u{1F50D} Activity Tracker: ENABLED');
    } else {
      _logToTerminal('\u{1F50D} Activity Tracker: DISABLED');
    }
  }

  /// Enable or disable terminal logging
  void setTerminalLogging(bool enabled) {
    _terminalLoggingEnabled = enabled;
    _logToTerminal('\u{1F4FA} Terminal Logging: ${enabled ? 'ENABLED' : 'DISABLED'}');
  }

  /// Log activity to terminal with formatting
  void _logToTerminal(String message) {
    if (_terminalLoggingEnabled) {
      final timestamp = DateTime.now();
      final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${(timestamp.millisecond / 100).floor()}';
      debugPrint('[$timeStr] $message');
    }
  }

  /// Track navigation to a new screen
  void trackNavigation({
    required String screenName,
    required String routeName,
    Map<String, dynamic>? parameters,
    List<String>? relatedFiles,
  }) {
    if (!_isEnabled) return;

    // End previous screen session
    if (_currentScreen != null && _screenStartTime != null) {
      final duration = DateTime.now().difference(_screenStartTime!);
      _recordActivity(ActivityRecord(
        type: ActivityType.screenExit,
        screen: _currentScreen!,
        timestamp: DateTime.now(),
        duration: duration,
        details: {'timeSpent': '${duration.inSeconds}s'},
      ));
      
      // Terminal logging for screen exit
      _logToTerminal('\u{1F44B} SCREEN EXIT \u{2190} $_currentScreen (${duration.inSeconds}s spent)');
    }

    // Start new screen session
    _currentScreen = screenName;
    _screenStartTime = DateTime.now();
    _navigationCounts[screenName] = (_navigationCounts[screenName] ?? 0) + 1;

    // Record related files
    if (relatedFiles != null) {
      _screenFileMapping[screenName] = relatedFiles;
      _filesUsed.addAll(relatedFiles);
    }

    _recordActivity(ActivityRecord(
      type: ActivityType.navigation,
      screen: screenName,
      route: routeName,
      timestamp: DateTime.now(),
      parameters: parameters,
      relatedFiles: relatedFiles,
      visitCount: _navigationCounts[screenName]!,
    ));

    // Enhanced terminal logging
    _logToTerminal('\u{1F9ED} NAVIGATION \u{2192} $screenName (Visit #${_navigationCounts[screenName]})');
    if (routeName != null) {
      _logToTerminal('   \u{1F4CD} Route: $routeName');
    }
    if (parameters != null && parameters.isNotEmpty) {
      _logToTerminal('   \u{1F4CB} Parameters: ${parameters.entries.map((e) => '${e.key}=${e.value}').join(', ')}');
    }
    if (relatedFiles != null && relatedFiles.isNotEmpty) {
      _logToTerminal('   \u{1F4C1} Files (${relatedFiles.length}):');
      for (final file in relatedFiles.take(3)) {
        _logToTerminal('      \u{2022} ${file.split('/').last}');
      }
      if (relatedFiles.length > 3) {
        _logToTerminal('      \u{2022} ... and ${relatedFiles.length - 3} more files');
      }
    }
  }

  /// Track user interactions (button clicks, form submissions, etc.)
  void trackInteraction({
    required String action,
    String? element,
    Map<String, dynamic>? data,
    List<String>? filesInvolved,
  }) {
    if (!_isEnabled) return;

    if (filesInvolved != null) {
      _filesUsed.addAll(filesInvolved);
    }

    _recordActivity(ActivityRecord(
      type: ActivityType.interaction,
      screen: _currentScreen ?? 'Unknown',
      action: action,
      element: element,
      timestamp: DateTime.now(),
      details: data,
      relatedFiles: filesInvolved,
    ));

    // Enhanced terminal logging
    _logToTerminal('\u{1F446} INTERACTION \u{2192} $action${element != null ? ' on $element' : ''}');
    if (_currentScreen != null) {
      _logToTerminal('   \u{1F4F1} Screen: $_currentScreen');
    }
    if (data != null && data.isNotEmpty) {
      _logToTerminal('   \u{1F4CA} Data: ${data.entries.map((e) => '${e.key}=${e.value}').take(3).join(', ')}${data.length > 3 ? '...' : ''}');
    }
    if (filesInvolved != null && filesInvolved.isNotEmpty) {
      _logToTerminal('   \u{1F4C1} Files involved (${filesInvolved.length}):');
      for (final file in filesInvolved.take(2)) {
        _logToTerminal('      \u{2022} ${file.split('/').last}');
      }
      if (filesInvolved.length > 2) {
        _logToTerminal('      \u{2022} ... and ${filesInvolved.length - 2} more');
      }
    }
  }

  /// Track API calls or data operations
  void trackDataOperation({
    required String operation,
    String? collection,
    String? documentId,
    Map<String, dynamic>? queryParams,
    List<String>? serviceFiles,
  }) {
    if (!_isEnabled) return;

    if (serviceFiles != null) {
      _filesUsed.addAll(serviceFiles);
    }

    _recordActivity(ActivityRecord(
      type: ActivityType.dataOperation,
      screen: _currentScreen ?? 'Unknown',
      operation: operation,
      timestamp: DateTime.now(),
      details: {
        'collection': collection,
        'documentId': documentId,
        'queryParams': queryParams,
      },
      relatedFiles: serviceFiles,
    ));

    // Enhanced terminal logging
    _logToTerminal('\u{1F4BE} DATA OPERATION \u{2192} $operation${collection != null ? ' on $collection' : ''}');
    if (_currentScreen != null) {
      _logToTerminal('   \u{1F4F1} Screen: $_currentScreen');
    }
    if (documentId != null) {
      _logToTerminal('   \u{1F194} Document: $documentId');
    }
    if (queryParams != null && queryParams.isNotEmpty) {
      _logToTerminal('   \u{1F50D} Query: ${queryParams.entries.map((e) => '${e.key}=${e.value}').take(2).join(', ')}${queryParams.length > 2 ? '...' : ''}');
    }
    if (serviceFiles != null && serviceFiles.isNotEmpty) {
      _logToTerminal('   \u{1F4C1} Service files (${serviceFiles.length}):');
      for (final file in serviceFiles.take(2)) {
        _logToTerminal('      \u{2022} ${file.split('/').last}');
      }
      if (serviceFiles.length > 2) {
        _logToTerminal('      \u{2022} ... and ${serviceFiles.length - 2} more');
      }
    }
  }

  /// Track errors or exceptions
  void trackError({
    required String error,
    String? stackTrace,
    List<String>? affectedFiles,
  }) {
    if (!_isEnabled) return;

    _recordActivity(ActivityRecord(
      type: ActivityType.error,
      screen: _currentScreen ?? 'Unknown',
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      relatedFiles: affectedFiles,
    ));

    // Enhanced terminal logging with error highlighting
    _logToTerminal('\u{274C} ERROR \u{2192} $error');
    if (_currentScreen != null) {
      _logToTerminal('   \u{1F4F1} Screen: $_currentScreen');
    }
    if (affectedFiles != null && affectedFiles.isNotEmpty) {
      _logToTerminal('   \u{26A0} Affected files (${affectedFiles.length}):');
      for (final file in affectedFiles.take(3)) {
        _logToTerminal('      \u{2022} ${file.split('/').last}');
      }
      if (affectedFiles.length > 3) {
        _logToTerminal('      \u{2022} ... and ${affectedFiles.length - 3} more');
      }
    }
    if (stackTrace != null && stackTrace.isNotEmpty) {
      final lines = stackTrace.split('\n').take(2).toList();
      _logToTerminal('   \u{1F4CB} Stack trace (first 2 lines):');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          _logToTerminal('      $line');
        }
      }
    }
  }

  /// Record activity internally
  void _recordActivity(ActivityRecord record) {
    _activities.add(record);
    
    // Keep only last 1000 activities to prevent memory issues
    if (_activities.length > 1000) {
      _activities.removeAt(0);
    }
  }

  /// Get all activities
  List<ActivityRecord> getActivities() => List.unmodifiable(_activities);

  /// Get activities for a specific screen
  List<ActivityRecord> getActivitiesForScreen(String screenName) {
    return _activities.where((a) => a.screen == screenName).toList();
  }

  /// Get all unique files used
  List<String> getUniqueFilesUsed() => _filesUsed.toSet().toList();

  /// Get files associated with a specific screen
  List<String> getFilesForScreen(String screenName) {
    return _screenFileMapping[screenName] ?? [];
  }

  /// Get navigation statistics
  Map<String, int> getNavigationStats() => Map.unmodifiable(_navigationCounts);

  /// Get current session summary
  ActivitySummary getCurrentSessionSummary() {
    final now = DateTime.now();
    final sessionActivities = _activities.where((a) => 
      now.difference(a.timestamp).inHours < 24
    ).toList();

    return ActivitySummary(
      totalActivities: sessionActivities.length,
      uniqueScreensVisited: sessionActivities.map((a) => a.screen).toSet().length,
      totalFilesUsed: getUniqueFilesUsed().length,
      navigationCount: sessionActivities.where((a) => a.type == ActivityType.navigation).length,
      interactionCount: sessionActivities.where((a) => a.type == ActivityType.interaction).length,
      errorCount: sessionActivities.where((a) => a.type == ActivityType.error).length,
      sessionDuration: sessionActivities.isNotEmpty 
        ? now.difference(sessionActivities.first.timestamp)
        : Duration.zero,
      mostVisitedScreen: _navigationCounts.isNotEmpty 
        ? _navigationCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null,
    );
  }

  /// Export activity log to JSON
  String exportToJson() {
    final export = {
      'metadata': {
        'exportTime': DateTime.now().toIso8601String(),
        'totalActivities': _activities.length,
        'uniqueFiles': getUniqueFilesUsed().length,
      },
      'activities': _activities.map((a) => a.toJson()).toList(),
      'fileMapping': _screenFileMapping,
      'navigationStats': _navigationCounts,
      'uniqueFiles': getUniqueFilesUsed(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Save activity log to file
  Future<void> saveToFile([String? filename]) async {
    if (kIsWeb) {
      debugPrint('\u{1F50D} File saving not supported on web platform');
      return;
    }

    final fileName = filename ?? 'activity_log_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(fileName);
    
    try {
      await file.writeAsString(exportToJson());
      debugPrint('\u{1F50D} Activity log saved to: ${file.path}');
    } catch (e) {
      debugPrint('\u{1F50D} Error saving activity log: $e');
    }
  }

  /// Clear all activity data
  void clear() {
    _activities.clear();
    _filesUsed.clear();
    _navigationCounts.clear();
    _screenFileMapping.clear();
    _currentScreen = null;
    _screenStartTime = null;
    _logToTerminal('\u{1F9F9} Activity tracker data cleared');
  }

  /// Log current session summary to terminal
  void logSessionSummary() {
    final summary = getCurrentSessionSummary();
    _logToTerminal('\u{1F4CA} === SESSION SUMMARY ===');
    _logToTerminal('   \u{1F3AF} Total Activities: ${summary.totalActivities}');
    _logToTerminal('   \u{1F4F1} Screens Visited: ${summary.uniqueScreensVisited}');
    _logToTerminal('   \u{1F4C1} Files Used: ${summary.totalFilesUsed}');
    _logToTerminal('   \u{1F9ED} Navigation Events: ${summary.navigationCount}');
    _logToTerminal('   \u{1F446} Interactions: ${summary.interactionCount}');
    _logToTerminal('   \u{1F4BE} Data Operations: ${summary.totalActivities - summary.navigationCount - summary.interactionCount - summary.errorCount}');
    _logToTerminal('   \u{274C} Errors: ${summary.errorCount}');
    _logToTerminal('   \u{23F1} Session Duration: ${summary.sessionDuration.inMinutes}m ${summary.sessionDuration.inSeconds % 60}s');
    if (summary.mostVisitedScreen != null) {
      _logToTerminal('   \u{1F525} Most Visited: ${summary.mostVisitedScreen} (${_navigationCounts[summary.mostVisitedScreen!]} visits)');
    }
    _logToTerminal('\u{1F4CA} ========================');
  }

  /// Get real-time activity widget for debugging
  Widget buildActivityDebugWidget() {
    return ActivityDebugWidget();
  }
}

/// Types of activities to track
enum ActivityType {
  navigation,
  interaction,
  dataOperation,
  error,
  screenExit,
}

/// Individual activity record
class ActivityRecord {
  final ActivityType type;
  final String screen;
  final String? route;
  final String? action;
  final String? element;
  final String? operation;
  final String? error;
  final String? stackTrace;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic>? parameters;
  final Map<String, dynamic>? details;
  final List<String>? relatedFiles;
  final int? visitCount;

  ActivityRecord({
    required this.type,
    required this.screen,
    required this.timestamp,
    this.route,
    this.action,
    this.element,
    this.operation,
    this.error,
    this.stackTrace,
    this.duration,
    this.parameters,
    this.details,
    this.relatedFiles,
    this.visitCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'screen': screen,
      'route': route,
      'action': action,
      'element': element,
      'operation': operation,
      'error': error,
      'stackTrace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'parameters': parameters,
      'details': details,
      'relatedFiles': relatedFiles,
      'visitCount': visitCount,
    };
  }
}

/// Activity session summary
class ActivitySummary {
  final int totalActivities;
  final int uniqueScreensVisited;
  final int totalFilesUsed;
  final int navigationCount;
  final int interactionCount;
  final int errorCount;
  final Duration sessionDuration;
  final String? mostVisitedScreen;

  ActivitySummary({
    required this.totalActivities,
    required this.uniqueScreensVisited,
    required this.totalFilesUsed,
    required this.navigationCount,
    required this.interactionCount,
    required this.errorCount,
    required this.sessionDuration,
    this.mostVisitedScreen,
  });
}

/// Debug widget to show real-time activity
class ActivityDebugWidget extends StatefulWidget {
  @override
  _ActivityDebugWidgetState createState() => _ActivityDebugWidgetState();
}

class _ActivityDebugWidgetState extends State<ActivityDebugWidget> {
  @override
  Widget build(BuildContext context) {
    final tracker = ActivityTracker();
    final summary = tracker.getCurrentSessionSummary();
    final recentActivities = tracker.getActivities().take(5).toList();

    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\u{1F50D} Activity Tracker',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Session: ${summary.totalActivities} activities, ${summary.uniqueScreensVisited} screens',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Files: ${summary.totalFilesUsed} | Errors: ${summary.errorCount}',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (summary.mostVisitedScreen != null)
              Text(
                'Most visited: ${summary.mostVisitedScreen}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            SizedBox(height: 8),
            ...recentActivities.map((activity) => Text(
              '${activity.type.name}: ${activity.screen}',
              style: TextStyle(color: Colors.white60, fontSize: 10),
            )),
          ],
        ),
      ),
    );
  }
}
