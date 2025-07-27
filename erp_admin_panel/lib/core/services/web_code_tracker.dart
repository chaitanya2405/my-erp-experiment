import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Web-compatible code activity tracking system
class WebCodeTracker {
  static final WebCodeTracker _instance = WebCodeTracker._internal();
  factory WebCodeTracker() => _instance;
  WebCodeTracker._internal();

  final List<CodeActivity> _activities = [];
  final Map<String, FileTrackingInfo> _fileTracking = {};
  bool _isInitialized = false;

  /// Public getter for activities (for simulator access)
  List<CodeActivity> get activities => _activities;

  /// Public method for file tracking (for simulator access)
  void updateFileTracking(String filePath, CodeActivity activity) {
    _updateFileTracking(filePath, activity);
  }

  /// Initialize the web tracker
  Future<void> initialize({String? projectRoot}) async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    print('🌐 Web Code Tracker initialized successfully');
    
    // Add initial activity
    await trackActivity(
      ActivityType.system,
      'web_tracker_init.dart',
      'Web Code Tracker initialized',
      details: {'project_root': projectRoot ?? 'web_app', 'platform': 'web'},
    );
  }

  /// Track a code activity
  Future<void> trackActivity(
    ActivityType type,
    String filePath,
    String description, {
    Map<String, dynamic>? details,
    List<String>? tags,
  }) async {
    if (!_isInitialized) return;

    final activity = CodeActivity(
      id: _generateId(),
      type: type,
      filePath: filePath,
      description: description,
      timestamp: DateTime.now(),
      details: details ?? {},
      tags: tags ?? [],
    );

    _activities.add(activity);
    _updateFileTracking(filePath, activity);

    // Keep only last 1000 activities for memory management
    if (_activities.length > 1000) {
      _activities.removeRange(0, _activities.length - 1000);
    }

    // Enhanced terminal logging with timestamp and details (UTF-8 safe)
    final timeStr = DateTime.now().toString().substring(11, 19);
    print('');
    print('ACTIVITY [$timeStr] ${type.name.toUpperCase()} -> $description');
    if (details != null && details.isNotEmpty) {
      print('   Details: ${details.toString()}');
    }
    print('   File: ${_getFileName(filePath)}');
    print('');
  }

  /// Track file creation
  Future<void> trackFileCreated(String filePath, {Map<String, dynamic>? details}) async {
    await trackActivity(
      ActivityType.create,
      filePath,
      'File created',
      details: details,
      tags: ['file_creation'],
    );
  }

  /// Track file modification
  Future<void> trackFileModified(String filePath, {Map<String, dynamic>? details}) async {
    await trackActivity(
      ActivityType.edit,
      filePath,
      'File modified',
      details: details,
      tags: ['file_modification'],
    );
  }

  /// Track file deletion
  Future<void> trackFileDeleted(String filePath, {Map<String, dynamic>? details}) async {
    await trackActivity(
      ActivityType.delete,
      filePath,
      'File deleted',
      details: details,
      tags: ['file_deletion'],
    );
  }

  /// Track navigation
  Future<void> trackNavigation(String screenName, String routeName, {List<String>? relatedFiles}) async {
    await trackActivity(
      ActivityType.navigation,
      routeName,
      'Navigated to $screenName',
      details: {
        'screen_name': screenName,
        'route_name': routeName,
        'related_files': relatedFiles ?? [],
      },
      tags: ['navigation', 'screen_change'],
    );
  }

  /// Track user interaction
  Future<void> trackInteraction(String element, String action, {Map<String, dynamic>? context}) async {
    await trackActivity(
      ActivityType.interaction,
      'user_interface',
      '$action on $element',
      details: {
        'element': element,
        'action': action,
        'context': context ?? {},
      },
      tags: ['interaction', 'ui'],
    );
  }

  /// Get recent activities
  List<CodeActivity> getRecentActivities({int limit = 50}) {
    final sorted = List<CodeActivity>.from(_activities)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  /// Get activities by type
  List<CodeActivity> getActivitiesByType(ActivityType type) {
    return _activities.where((a) => a.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get activities by date range
  List<CodeActivity> getActivitiesByDateRange(DateTime start, DateTime end) {
    return _activities.where((a) => 
      a.timestamp.isAfter(start) && a.timestamp.isBefore(end)
    ).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get file statistics
  Map<String, dynamic> getFileStatistics() {
    final stats = <String, int>{};
    for (final activity in _activities) {
      final fileName = _getFileName(activity.filePath);
      stats[fileName] = (stats[fileName] ?? 0) + 1;
    }

    final sortedStats = Map.fromEntries(
      stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );

    return {
      'total_activities': _activities.length,
      'unique_files': stats.length,
      'most_active_files': sortedStats.entries.take(10).map((e) => {
        'file': e.key,
        'activities': e.value,
      }).toList(),
      'activity_types': _getActivityTypeStats(),
    };
  }

  /// Get activity statistics
  Map<String, dynamic> getActivityStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    return {
      'total_activities': _activities.length,
      'today_activities': _activities.where((a) => a.timestamp.isAfter(today)).length,
      'yesterday_activities': _activities.where((a) => 
        a.timestamp.isAfter(yesterday) && a.timestamp.isBefore(today)
      ).length,
      'week_activities': _activities.where((a) => a.timestamp.isAfter(thisWeek)).length,
      'activity_types': _getActivityTypeStats(),
      'hourly_distribution': _getHourlyDistribution(),
    };
  }

  /// Generate daily summary (web-compatible)
  String generateDailySummary({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final dayStart = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayActivities = _activities.where((a) => 
      a.timestamp.isAfter(dayStart) && a.timestamp.isBefore(dayEnd)
    ).toList();

    return _generateSummaryMarkdown(dayActivities, targetDate);
  }

  /// Export activities as JSON
  String exportActivitiesAsJson() {
    return jsonEncode(_activities.map((a) => a.toJson()).toList());
  }

  /// Clear all activities
  void clearActivities() {
    _activities.clear();
    _fileTracking.clear();
    print('🧹 All activities cleared');
  }

  // Private helper methods
  void _updateFileTracking(String filePath, CodeActivity activity) {
    if (!_fileTracking.containsKey(filePath)) {
      _fileTracking[filePath] = FileTrackingInfo(
        filePath: filePath,
        firstAccess: activity.timestamp,
        lastAccess: activity.timestamp,
        accessCount: 0,
        activities: [],
      );
    }

    final tracking = _fileTracking[filePath]!;
    tracking.lastAccess = activity.timestamp;
    tracking.accessCount++;
    tracking.activities.add(activity);
  }

  Map<String, int> _getActivityTypeStats() {
    final stats = <String, int>{};
    for (final activity in _activities) {
      stats[activity.type.name] = (stats[activity.type.name] ?? 0) + 1;
    }
    return stats;
  }

  List<Map<String, dynamic>> _getHourlyDistribution() {
    final hourlyStats = <int, int>{};
    for (final activity in _activities) {
      final hour = activity.timestamp.hour;
      hourlyStats[hour] = (hourlyStats[hour] ?? 0) + 1;
    }

    return List.generate(24, (hour) => {
      'hour': hour,
      'activities': hourlyStats[hour] ?? 0,
    });
  }

  String _generateSummaryMarkdown(List<CodeActivity> activities, DateTime date) {
    final buffer = StringBuffer();
    buffer.writeln('# Daily Development Summary');
    buffer.writeln('**Date:** ${_formatDate(date)}');
    buffer.writeln('**Total Activities:** ${activities.length}');
    buffer.writeln();

    // Group by type
    final byType = <ActivityType, List<CodeActivity>>{};
    for (final activity in activities) {
      byType.putIfAbsent(activity.type, () => []).add(activity);
    }

    buffer.writeln('## Activity Breakdown');
    for (final type in ActivityType.values) {
      final typeActivities = byType[type] ?? [];
      if (typeActivities.isNotEmpty) {
        buffer.writeln('- **${type.name}**: ${typeActivities.length} activities');
      }
    }

    buffer.writeln();
    buffer.writeln('## Recent Activities');
    final recent = activities.take(10);
    for (final activity in recent) {
      buffer.writeln('- ${_formatTime(activity.timestamp)} - ${activity.description}');
    }

    return buffer.toString();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _getFileName(String filePath) {
    if (filePath.contains('/')) {
      return filePath.split('/').last;
    }
    if (filePath.contains('\\')) {
      return filePath.split('\\').last;
    }
    return filePath;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get activity type name for terminal display (UTF-8 safe)
  String _getActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.navigation:
        return 'NAVIGATION';
      case ActivityType.interaction:
        return 'INTERACTION';
      case ActivityType.build:
        return 'BUILD';
      case ActivityType.test:
        return 'TEST';
      case ActivityType.debug:
        return 'DEBUG';
      case ActivityType.create:
        return 'CREATE';
      case ActivityType.edit:
        return 'EDIT';
      case ActivityType.delete:
        return 'DELETE';
      case ActivityType.refactor:
        return 'REFACTOR';
      case ActivityType.system:
        return 'SYSTEM';
    }
  }

  /// Get icon for activity type
  String _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.navigation:
        return '🧭';
      case ActivityType.interaction:
        return '👆';
      case ActivityType.build:
        return '�';
      case ActivityType.test:
        return '🧪';
      case ActivityType.debug:
        return '🐛';
      case ActivityType.create:
        return '📝';
      case ActivityType.edit:
        return '✏️';
      case ActivityType.delete:
        return '🗑️';
      case ActivityType.refactor:
        return '🔧';
      case ActivityType.system:
        return '⚙️';
    }
  }
}

/// Activity types for tracking - Updated with proper name getter
enum ActivityType {
  create,
  edit,
  delete,
  navigation,
  interaction,
  build,
  test,
  debug,
  refactor,
  system;

  /// Get the name of the activity type
  String get name {
    switch (this) {
      case ActivityType.create:
        return 'create';
      case ActivityType.edit:
        return 'edit';
      case ActivityType.delete:
        return 'delete';
      case ActivityType.navigation:
        return 'navigation';
      case ActivityType.interaction:
        return 'interaction';
      case ActivityType.build:
        return 'build';
      case ActivityType.test:
        return 'test';
      case ActivityType.debug:
        return 'debug';
      case ActivityType.refactor:
        return 'refactor';
      case ActivityType.system:
        return 'system';
    }
  }

  /// Get a display-friendly name
  String get displayName {
    switch (this) {
      case ActivityType.create:
        return 'Create';
      case ActivityType.edit:
        return 'Edit';
      case ActivityType.delete:
        return 'Delete';
      case ActivityType.navigation:
        return 'Navigation';
      case ActivityType.interaction:
        return 'Interaction';
      case ActivityType.build:
        return 'Build';
      case ActivityType.test:
        return 'Test';
      case ActivityType.debug:
        return 'Debug';
      case ActivityType.refactor:
        return 'Refactor';
      case ActivityType.system:
        return 'System';
    }
  }
}

/// Represents a single code activity
class CodeActivity {
  final String id;
  final ActivityType type;
  final String filePath;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> details;
  final List<String> tags;

  CodeActivity({
    required this.id,
    required this.type,
    required this.filePath,
    required this.description,
    required this.timestamp,
    required this.details,
    required this.tags,
  });

  /// Get filename from the full path
  String get fileName => filePath.split('/').last;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'filePath': filePath,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
      'tags': tags,
    };
  }

  factory CodeActivity.fromJson(Map<String, dynamic> json) {
    return CodeActivity(
      id: json['id'],
      type: ActivityType.values.firstWhere((e) => e.name == json['type']),
      filePath: json['filePath'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      details: Map<String, dynamic>.from(json['details']),
      tags: List<String>.from(json['tags']),
    );
  }
}

/// File tracking information
class FileTrackingInfo {
  final String filePath;
  final DateTime firstAccess;
  DateTime lastAccess;
  int accessCount;
  final List<CodeActivity> activities;

  FileTrackingInfo({
    required this.filePath,
    required this.firstAccess,
    required this.lastAccess,
    required this.accessCount,
    required this.activities,
  });
}
