import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/web_code_tracker.dart';
import '../../core/services/development_activity_simulator.dart';

class DeveloperDashboard extends ConsumerStatefulWidget {
  const DeveloperDashboard({super.key});

  @override
  ConsumerState<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends ConsumerState<DeveloperDashboard> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DevelopmentActivitySimulator _simulator;
  final WebCodeTracker _tracker = WebCodeTracker(); // This gets the singleton instance

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _simulator = DevelopmentActivitySimulator();
    
    // Initialize with some activities if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tracker.activities.isEmpty) {
        _simulator.generateTestActivities(count: 5);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP Development Tracker'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[100],
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.list), text: 'Activity'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
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
    final stats = _simulator.getSimulationStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ERP Ecosystem Development Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Status Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatusCard(
                'Total Activities',
                '${stats['total_activities']}',
                Icons.code,
                Colors.blue,
              ),
              _buildStatusCard(
                'Active Modules',
                '${stats['modules_active']}',
                Icons.widgets,
                Colors.green,
              ),
              _buildStatusCard(
                'Simulation',
                stats['simulation_running'] ? 'Running' : 'Paused',
                stats['simulation_running'] ? Icons.play_circle : Icons.pause_circle,
                stats['simulation_running'] ? Colors.green : Colors.orange,
              ),
              _buildStatusCard(
                'Last Activity',
                'Just now',
                Icons.schedule,
                Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Module List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ERP Modules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._simulator.getAvailableModules().take(6).map((module) =>
                    ListTile(
                      leading: Icon(_getModuleIcon(module), color: _getModuleColor(module)),
                      title: Text(module),
                      subtitle: const Text('Development in progress'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _simulator.generateModuleActivities(module, count: 2);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    final activities = _tracker.activities;
    
    return Column(
      children: [
        // Activity Generation Controls
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _simulator.generateTestActivities(count: 3);
                  setState(() {});
                },
                child: const Text('Generate Activities'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  _simulator.toggleSimulation();
                  setState(() {});
                },
                child: Text(_simulator.getSimulationStats()['simulation_running'] 
                    ? 'Pause Simulation' : 'Start Simulation'),
              ),
            ],
          ),
        ),
        
        // Activities List
        Expanded(
          child: activities.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No activities yet', style: TextStyle(fontSize: 18)),
                      Text('Generate some activities to get started'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[activities.length - 1 - index];
                    return _buildActivityTile(activity);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    final stats = _simulator.getSimulationStats();
    final moduleBreakdown = stats['module_breakdown'] as Map<String, int>;
    final typeBreakdown = stats['activity_type_breakdown'] as Map<String, int>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ERP Ecosystem Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Module Activity Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity by Module',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (moduleBreakdown.isEmpty)
                    const Text('No module activities yet')
                  else
                    ...moduleBreakdown.entries.map((entry) => 
                      _buildModuleActivityRow(entry.key, entry.value, stats['total_activities']),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // Activity Type Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (typeBreakdown.isEmpty)
                    const Text('No activity types yet')
                  else
                    ...typeBreakdown.entries.map((entry) => 
                      _buildActivityTypeRow(entry.key, entry.value),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Developer Tools Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_graph),
                  title: const Text('Auto-generate activities'),
                  subtitle: const Text('Simulate development activity automatically'),
                  trailing: Switch(
                    value: _simulator.getSimulationStats()['simulation_running'],
                    onChanged: (value) {
                      _simulator.toggleSimulation();
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('Clear all activities'),
                  subtitle: const Text('Remove all tracked activities'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _clearActivities,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export data'),
                  subtitle: const Text('Export activity data to file'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _exportData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(activity) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          _getActivityIcon(activity.type.name),
          color: _getActivityColor(activity.type.name),
        ),
        title: Text(_getFileName(activity.filePath)),
        subtitle: Text(activity.description),
        trailing: Text(
          _formatTime(activity.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildModuleActivityRow(String module, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(module, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getModuleColor(module)),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count (${percentage.toStringAsFixed(1)}%)', 
               style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActivityTypeRow(String type, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_getActivityIcon(type), size: 16, color: _getActivityColor(type)),
          const SizedBox(width: 8),
          Expanded(child: Text(type.toUpperCase())),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'pos management': return Icons.point_of_sale;
      case 'inventory': return Icons.inventory;
      case 'accounting': return Icons.account_balance;
      case 'customer management': return Icons.people;
      case 'supplier management': return Icons.business;
      case 'purchase management': return Icons.shopping_cart;
      case 'sales management': return Icons.trending_up;
      case 'reports & analytics': return Icons.analytics;
      case 'user management': return Icons.admin_panel_settings;
      case 'hr management': return Icons.person;
      case 'production management': return Icons.precision_manufacturing;
      case 'quality control': return Icons.verified;
      case 'warehouse management': return Icons.warehouse;
      case 'communication hub': return Icons.chat;
      case 'settings & config': return Icons.settings;
      default: return Icons.apps;
    }
  }

  Color _getModuleColor(String module) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red,
      Colors.teal, Colors.indigo, Colors.pink, Colors.cyan, Colors.amber,
    ];
    return colors[module.hashCode % colors.length];
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'create': return Icons.add;
      case 'edit': return Icons.edit;
      case 'delete': return Icons.delete;
      case 'refactor': return Icons.refresh;
      case 'test': return Icons.bug_report;
      case 'navigation': return Icons.navigation;
      case 'interaction': return Icons.touch_app;
      default: return Icons.code;
    }
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'create': return Colors.green;
      case 'edit': return Colors.blue;
      case 'delete': return Colors.red;
      case 'refactor': return Colors.orange;
      case 'test': return Colors.purple;
      case 'navigation': return Colors.teal;
      case 'interaction': return Colors.pink;
      default: return Colors.grey;
    }
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _clearActivities() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Activities'),
        content: const Text('Are you sure you want to clear all activities?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _tracker.activities.clear();
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activities cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }
}
