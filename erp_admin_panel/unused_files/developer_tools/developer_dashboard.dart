import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/code_activity_tracker.dart';
import '../../core/services/auto_code_tracker.dart';

/// Developer dashboard for viewing code activity and development statistics
class DeveloperDashboard extends ConsumerStatefulWidget {
  const DeveloperDashboard({super.key});

  @override
  ConsumerState<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends ConsumerState<DeveloperDashboard> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CodeActivityTracker _tracker = CodeActivityTracker();
  final AutoCodeTracker _autoTracker = AutoCodeTracker();
  
  Map<String, dynamic> _projectStats = {};
  List<CodeActivity> _recentActivities = [];
  Map<String, dynamic> _sessionSummary = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      _projectStats = _tracker.getProjectStats();
      _recentActivities = _tracker.getRecentActivities(limit: 20);
      _sessionSummary = _autoTracker.getSessionSummary();
      setState(() {});
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Dashboard'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.timeline), text: 'Activity'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _tracker.generateDailySummary(),
            tooltip: 'Generate Report',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildActivityTab(),
          _buildAnalyticsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Activities',
                '${_projectStats['totalActivities'] ?? 0}',
                Icons.analytics,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Files Tracked',
                '${_projectStats['uniqueFiles'] ?? 0}',
                Icons.folder,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Today\'s Changes',
                '${_projectStats['todayActivities'] ?? 0}',
                Icons.today,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Bug Fixes',
                '${_projectStats['bugFixes'] ?? 0}',
                Icons.bug_report,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivities.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final activity = _recentActivities[index];
              return ListTile(
                leading: _getActivityIcon(activity.type),
                title: Text(activity.description ?? 'No description'),
                subtitle: Text(
                  '${activity.fileName} • ${_formatTime(activity.timestamp)}',
                ),
                trailing: Chip(
                  label: Text(
                    activity.type.toString().split('.').last,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getActivityColor(activity.type),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              'Track Bug Fix',
              Icons.bug_report,
              Colors.red,
              () => _showTrackingDialog(ActivityType.bugFix),
            ),
            _buildActionButton(
              'Track Feature',
              Icons.new_releases,
              Colors.green,
              () => _showTrackingDialog(ActivityType.featureImplemented),
            ),
            _buildActionButton(
              'Track Refactor',
              Icons.transform,
              Colors.purple,
              () => _showTrackingDialog(ActivityType.refactoring),
            ),
            _buildActionButton(
              'Generate Report',
              Icons.assessment,
              Colors.blue,
              () => _tracker.generateDailySummary(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: _getActivityIcon(activity.type),
            title: Text(activity.description ?? 'No description'),
            subtitle: Text(
              '${activity.fileName} • ${_formatTime(activity.timestamp)}',
            ),
            trailing: Chip(
              label: Text(
                activity.type.toString().split('.').last,
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getActivityColor(activity.type),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activity.details.isNotEmpty) ...[
                      const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...activity.details.entries.map(
                        (entry) => Text('${entry.key}: ${entry.value}'),
                      ),
                    ],
                    if (activity.changeStats.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Change Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...activity.changeStats.entries.map(
                        (entry) => Text('${entry.key}: ${entry.value}'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Development Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildActivityTypeChart(),
          const SizedBox(height: 20),
          _buildMostActiveFiles(),
        ],
      ),
    );
  }

  Widget _buildActivityTypeChart() {
    final activityCounts = <String, int>{};
    for (final activity in _recentActivities) {
      final type = activity.type.toString().split('.').last;
      activityCounts[type] = (activityCounts[type] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...activityCounts.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostActiveFiles() {
    final fileCounts = <String, int>{};
    for (final activity in _recentActivities) {
      fileCounts[activity.fileName] = (fileCounts[activity.fileName] ?? 0) + 1;
    }

    final sortedFiles = fileCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Active Files',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sortedFiles.take(10).map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-track file changes'),
                  subtitle: const Text('Automatically detect and log file modifications'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement auto-tracking toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('Generate daily reports'),
                  subtitle: const Text('Automatically generate development summaries'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement daily report toggle
                  },
                ),
                ListTile(
                  title: const Text('Export data'),
                  subtitle: const Text('Export tracking data to JSON'),
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    // TODO: Implement data export
                  },
                ),
                ListTile(
                  title: const Text('Clear all data'),
                  subtitle: const Text('Remove all tracking history'),
                  trailing: const Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    // TODO: Implement data clearing
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.fileCreated:
        return const Icon(Icons.add_circle, color: Colors.green);
      case ActivityType.fileModified:
        return const Icon(Icons.edit, color: Colors.blue);
      case ActivityType.fileDeleted:
        return const Icon(Icons.delete, color: Colors.red);
      case ActivityType.refactoring:
        return const Icon(Icons.transform, color: Colors.purple);
      case ActivityType.bugFix:
        return const Icon(Icons.bug_report, color: Colors.orange);
      case ActivityType.featureImplemented:
        return const Icon(Icons.new_releases, color: Colors.green);
      default:
        return const Icon(Icons.code, color: Colors.grey);
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.fileCreated:
        return Colors.green.withOpacity(0.2);
      case ActivityType.fileModified:
        return Colors.blue.withOpacity(0.2);
      case ActivityType.fileDeleted:
        return Colors.red.withOpacity(0.2);
      case ActivityType.refactoring:
        return Colors.purple.withOpacity(0.2);
      case ActivityType.bugFix:
        return Colors.orange.withOpacity(0.2);
      case ActivityType.featureImplemented:
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _showTrackingDialog(ActivityType type) async {
    final descriptionController = TextEditingController();
    final filePathController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track ${type.toString().split('.').last}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: filePathController,
              decoration: const InputDecoration(
                labelText: 'File Path',
                hintText: 'lib/modules/...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What was changed?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final filePath = filePathController.text.trim();
              final description = descriptionController.text.trim();
              
              if (filePath.isNotEmpty && description.isNotEmpty) {
                await _autoTracker.trackManualOperation(
                  type.toString().split('.').last,
                  filePath,
                  description: description,
                );
                await _loadData();
              }
              
              Navigator.pop(context);
            },
            child: const Text('Track'),
          ),
        ],
      ),
    );
  }
}
