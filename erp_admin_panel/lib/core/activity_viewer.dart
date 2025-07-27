import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'activity_tracker.dart';

/// Activity Viewer Widget - Shows real-time activity tracking
class ActivityViewerWidget extends StatefulWidget {
  const ActivityViewerWidget({Key? key}) : super(key: key);

  @override
  _ActivityViewerWidgetState createState() => _ActivityViewerWidgetState();
}

class _ActivityViewerWidgetState extends State<ActivityViewerWidget> {
  final ActivityTracker _tracker = ActivityTracker();
  bool _isExpanded = false;
  String _selectedFilter = 'All';
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade50,
      elevation: 4,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.track_changes, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Activity Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Enable/Disable Toggle
                Switch(
                  value: ActivityTracker().isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _tracker.setEnabled(value);
                    });
                  },
                  activeColor: Colors.white,
                ),
                const SizedBox(width: 8),
                // Terminal Logging Toggle
                IconButton(
                  icon: Icon(
                    _tracker.terminalLoggingEnabled ? Icons.terminal : Icons.stop,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _tracker.setTerminalLogging(!_tracker.terminalLoggingEnabled);
                    });
                  },
                  tooltip: _tracker.terminalLoggingEnabled ? 'Disable Terminal Logging' : 'Enable Terminal Logging',
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            child: _buildSummary(),
          ),
          
          // Expanded content
          if (_isExpanded) ...[
            _buildFilters(),
            _buildActivityList(),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final summary = _tracker.getCurrentSessionSummary();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem('Activities', summary.totalActivities.toString(), Icons.list),
        _buildSummaryItem('Screens', summary.uniqueScreensVisited.toString(), Icons.screen_share),
        _buildSummaryItem('Files', summary.totalFilesUsed.toString(), Icons.folder),
        _buildSummaryItem('Errors', summary.errorCount.toString(), Icons.error),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedFilter,
            items: [
              'All',
              'Navigation',
              'Interaction',
              'Data Operation',
              'Error',
            ].map((filter) => DropdownMenuItem(
              value: filter,
              child: Text(filter),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    List<ActivityRecord> activities = _tracker.getActivities();
    
    if (_selectedFilter != 'All') {
      final filterType = ActivityType.values.firstWhere(
        (type) => type.name.toLowerCase() == _selectedFilter.toLowerCase().replaceAll(' ', ''),
        orElse: () => ActivityType.navigation,
      );
      activities = activities.where((a) => a.type == filterType).toList();
    }
    
    // Show most recent first
    activities = activities.reversed.take(10).toList();
    
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityItem(activity);
        },
      ),
    );
  }

  Widget _buildActivityItem(ActivityRecord activity) {
    IconData icon;
    Color color;
    
    switch (activity.type) {
      case ActivityType.navigation:
        icon = Icons.navigation;
        color = Colors.blue;
        break;
      case ActivityType.interaction:
        icon = Icons.touch_app;
        color = Colors.green;
        break;
      case ActivityType.dataOperation:
        icon = Icons.storage;
        color = Colors.orange;
        break;
      case ActivityType.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case ActivityType.screenExit:
        icon = Icons.exit_to_app;
        color = Colors.grey;
        break;
    }
    
    return ExpansionTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        '${activity.type.name}: ${activity.screen}',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${activity.timestamp.hour}:${activity.timestamp.minute.toString().padLeft(2, '0')}:${activity.timestamp.second.toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activity.action != null)
                _buildDetailRow('Action', activity.action!),
              if (activity.route != null)
                _buildDetailRow('Route', activity.route!),
              if (activity.operation != null)
                _buildDetailRow('Operation', activity.operation!),
              if (activity.error != null)
                _buildDetailRow('Error', activity.error!, isError: true),
              if (activity.relatedFiles != null && activity.relatedFiles!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Related Files:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                ...activity.relatedFiles!.map((file) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: GestureDetector(
                    onTap: () => _copyToClipboard(file),
                    child: Text(
                      file,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                )),
              ],
              if (activity.details != null && activity.details!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                ...activity.details!.entries.map((entry) => 
                  _buildDetailRow(entry.key, entry.value.toString())),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isError ? Colors.red.shade700 : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: isError ? Colors.red.shade600 : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // First row of buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFileMapping(),
                  icon: Icon(Icons.folder_open, size: 16),
                  label: Text('File Mapping'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _logSessionSummary(),
                  icon: Icon(Icons.summarize, size: 16),
                  label: Text('Log Summary'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Second row of buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportActivityLog(),
                  icon: Icon(Icons.download, size: 16),
                  label: Text('Export Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _clearActivities(),
                  icon: Icon(Icons.clear, size: 16),
                  label: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFileMapping() {
    final navigationStats = _tracker.getNavigationStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Screen → File Mapping'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            children: navigationStats.entries.map((entry) {
              final screenName = entry.key;
              final visitCount = entry.value;
              final files = _tracker.getFilesForScreen(screenName);
              
              return ExpansionTile(
                title: Text('$screenName ($visitCount visits)'),
                children: files.map((file) => ListTile(
                  dense: true,
                  leading: Icon(Icons.insert_drive_file, size: 16),
                  title: Text(
                    file,
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () => _copyToClipboard(file),
                )).toList(),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logSessionSummary() {
    ActivityTracker.instance.logSessionSummary();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📊 Session summary logged to terminal'),
          backgroundColor: Colors.purple.shade600,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _exportActivityLog() {
    final json = _tracker.exportToJson();
    _copyToClipboard(json);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activity log copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearActivities() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Activity Log'),
        content: Text('Are you sure you want to clear all activity data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _tracker.clear();
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Activity log cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
