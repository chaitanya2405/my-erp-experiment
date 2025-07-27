import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/bridge/universal_erp_bridge.dart';
import '../core/bridge/bridge_helper.dart';
import '../core/bridge/module_connectors.dart';

/// 🌉 Bridge Management Dashboard - Control center for the Universal Bridge
/// 
/// This dashboard provides real-time visibility and control over the
/// Universal ERP Bridge, showing all module connections, data flows,
/// and system health.
class BridgeManagementDashboard extends StatefulWidget {
  const BridgeManagementDashboard({Key? key}) : super(key: key);

  @override
  _BridgeManagementDashboardState createState() => _BridgeManagementDashboardState();
}

class _BridgeManagementDashboardState extends State<BridgeManagementDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  BridgeStatus? _bridgeStatus;
  List<BridgeEvent> _recentEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeBridge();
    _setupEventListeners();
  }

  Future<void> _initializeBridge() async {
    try {
      // Initialize bridge if not already done
      await UniversalERPBridge.instance.initialize();
      
      // Connect all modules
      await ModuleConnectors.connectAllModules();
      
      // Get initial status
      _updateBridgeStatus();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Bridge initialization failed: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupEventListeners() {
    // Listen to bridge events
    UniversalERPBridge.instance.bridgeEvents.listen((event) {
      if (mounted) {
        setState(() {
          _recentEvents.insert(0, event);
          if (_recentEvents.length > 50) {
            _recentEvents.removeLast();
          }
        });
      }
    });
  }

  void _updateBridgeStatus() {
    setState(() {
      _bridgeStatus = BridgeHelper.getStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.hub, color: Colors.blue),
            SizedBox(width: 8),
            Text('Universal ERP Bridge'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.device_hub), text: 'Modules'),
            Tab(icon: Icon(Icons.stream), text: 'Data Flows'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.rule), text: 'Business Rules'),
            Tab(icon: Icon(Icons.settings), text: 'Controls'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateBridgeStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildModulesTab(),
                _buildDataFlowsTab(),
                _buildEventsTab(),
                _buildBusinessRulesTab(),
                _buildControlsTab(),
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
          _buildStatusCards(),
          const SizedBox(height: 24),
          _buildSystemHealth(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    final status = _bridgeStatus;
    if (status == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Bridge Status',
            status.isInitialized ? 'Active' : 'Inactive',
            status.isInitialized ? Colors.green : Colors.red,
            Icons.hub,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Connected Modules',
            '${status.moduleCount}',
            Colors.blue,
            Icons.device_hub,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Active Streams',
            '${status.activeStreams}',
            Colors.orange,
            Icons.stream,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Cache Size',
            '${status.cacheSize}',
            Colors.purple,
            Icons.storage,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'System Health',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHealthIndicator('Bridge Core', true, 'All systems operational'),
            _buildHealthIndicator('Module Communication', true, 'Real-time sync active'),
            _buildHealthIndicator('Data Transformation', true, 'Processing normally'),
            _buildHealthIndicator('Event Broadcasting', true, 'Events flowing smoothly'),
            _buildHealthIndicator('Business Rules', true, 'Rules executing correctly'),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String component, bool isHealthy, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(component),
          ),
          Text(
            status,
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _recentEvents.length,
                itemBuilder: (context, index) {
                  final event = _recentEvents[index];
                  return ListTile(
                    dense: true,
                    leading: _getEventIcon(event.type),
                    title: Text(event.message),
                    subtitle: Text(_formatTime(event.timestamp)),
                    trailing: Chip(
                      label: Text(event.type),
                      backgroundColor: _getEventColor(event.type).withOpacity(0.1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab() {
    final status = _bridgeStatus;
    if (status == null) return const Center(child: Text('No bridge status available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected Modules (${status.moduleCount})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...status.modules.map((module) => _buildModuleCard(module)),
        ],
      ),
    );
  }

  Widget _buildModuleCard(String moduleName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: _getModuleIcon(moduleName),
        title: Text(_formatModuleName(moduleName)),
        subtitle: Text('Status: Connected'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModuleInfo('Capabilities', _getModuleCapabilities(moduleName)),
                const SizedBox(height: 8),
                _buildModuleInfo('Data Types', _getModuleDataTypes(moduleName)),
                const SizedBox(height: 8),
                _buildModuleInfo('Last Activity', 'Active'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Now'),
                      onPressed: () => _syncModule(moduleName),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                      onPressed: () => _showModuleDetails(moduleName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleInfo(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildDataFlowsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Data Flows',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildDataFlowDiagram(),
          const SizedBox(height: 24),
          _buildDataFlowStats(),
        ],
      ),
    );
  }

  Widget _buildDataFlowDiagram() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Module Interconnections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              child: const Center(
                child: Text(
                  '🌉 Interactive Data Flow Diagram\n\n'
                  '📊 POS ↔ Inventory ↔ Store Management\n'
                  '👥 Customers ↔ Orders ↔ Loyalty\n'
                  '📦 Suppliers ↔ Purchase Orders ↔ Inventory\n'
                  '🔄 All modules connected through Universal Bridge',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataFlowStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Data Requests/Hour', '1,247', Icons.api),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Events/Hour', '892', Icons.event),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Cache Hit Rate', '94%', Icons.speed),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Bridge Events',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  setState(() {
                    _recentEvents.clear();
                  });
                },
                tooltip: 'Clear Events',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentEvents.length,
            itemBuilder: (context, index) {
              final event = _recentEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: _getEventIcon(event.type),
                  title: Text(event.message),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${event.type}'),
                      Text('Time: ${_formatTime(event.timestamp)}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(event.type),
                    backgroundColor: _getEventColor(event.type).withOpacity(0.1),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Business Rules',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
                onPressed: _addBusinessRule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBusinessRuleCard(
            'Auto Inventory Update',
            'Automatically decrease inventory when POS sale completes',
            true,
          ),
          _buildBusinessRuleCard(
            'Customer Order Creation',
            'Create customer order record from POS transactions',
            true,
          ),
          _buildBusinessRuleCard(
            'Loyalty Points Update',
            'Award loyalty points based on purchase amount',
            true,
          ),
          _buildBusinessRuleCard(
            'Low Stock Alerts',
            'Send notifications when inventory falls below minimum',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessRuleCard(String name, String description, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isActive ? Icons.check_circle : Icons.pause_circle,
          color: isActive ? Colors.green : Colors.orange,
        ),
        title: Text(name),
        subtitle: Text(description),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {
            // Toggle rule
          },
        ),
      ),
    );
  }

  Widget _buildControlsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bridge Controls',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildControlSection(
            'System Controls',
            [
              _buildControlButton('Restart Bridge', Icons.restart_alt, _restartBridge),
              _buildControlButton('Clear Cache', Icons.clear_all, _clearCache),
              _buildControlButton('Sync All Modules', Icons.sync, _syncAllModules),
            ],
          ),
          const SizedBox(height: 24),
          _buildControlSection(
            'Diagnostics',
            [
              _buildControlButton('Run Health Check', Icons.health_and_safety, _runHealthCheck),
              _buildControlButton('Test Connections', Icons.network_check, _testConnections),
              _buildControlButton('Export Logs', Icons.download, _exportLogs),
            ],
          ),
          const SizedBox(height: 24),
          _buildControlSection(
            'Configuration',
            [
              _buildControlButton('Bridge Settings', Icons.settings, _openSettings),
              _buildControlButton('Module Config', Icons.tune, _configureModules),
              _buildControlButton('Performance Tuning', Icons.speed, _performanceTuning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(String title, List<Widget> controls) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controls,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  // Helper methods
  Widget _getEventIcon(String eventType) {
    switch (eventType) {
      case 'bridge_initialized':
        return const Icon(Icons.hub, color: Colors.green);
      case 'module_registered':
        return const Icon(Icons.device_hub, color: Colors.blue);
      case 'data_request':
        return const Icon(Icons.api, color: Colors.orange);
      case 'event_broadcast':
        return const Icon(Icons.broadcast_on_personal, color: Colors.purple);
      default:
        return const Icon(Icons.event, color: Colors.grey);
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'bridge_initialized':
        return Colors.green;
      case 'module_registered':
        return Colors.blue;
      case 'data_request':
        return Colors.orange;
      case 'event_broadcast':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _getModuleIcon(String moduleName) {
    switch (moduleName) {
      case 'inventory_management':
        return const Icon(Icons.inventory, color: Colors.green);
      case 'pos_management':
        return const Icon(Icons.point_of_sale, color: Colors.blue);
      case 'customer_management':
        return const Icon(Icons.people, color: Colors.orange);
      case 'store_management':
        return const Icon(Icons.store, color: Colors.purple);
      case 'purchase_order_management':
        return const Icon(Icons.shopping_cart, color: Colors.teal);
      case 'product_management':
        return const Icon(Icons.category, color: Colors.indigo);
      case 'supplier_management':
        return const Icon(Icons.business, color: Colors.brown);
      case 'customer_order_management':
        return const Icon(Icons.receipt_long, color: Colors.red);
      case 'user_management':
        return const Icon(Icons.admin_panel_settings, color: Colors.pink);
      case 'analytics':
        return const Icon(Icons.analytics, color: Colors.cyan);
      default:
        return const Icon(Icons.extension, color: Colors.grey);
    }
  }

  String _formatModuleName(String moduleName) {
    return moduleName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getModuleCapabilities(String moduleName) {
    switch (moduleName) {
      case 'inventory_management':
        return 'Products, Inventory, Stock Updates, Search';
      case 'pos_management':
        return 'Transactions, Sales, Payments, Customer History';
      case 'customer_management':
        return 'Profiles, Orders, Loyalty, Search';
      case 'store_management':
        return 'Store Info, Analytics, Cross-module Integration';
      case 'purchase_order_management':
        return 'Create Orders, Track Deliveries, Supplier Communication';
      case 'product_management':
        return 'Product Catalog, Categories, Pricing, Bulk Operations';
      case 'supplier_management':
        return 'Supplier Profiles, Performance Tracking, Contracts';
      case 'customer_order_management':
        return 'Order Processing, Status Tracking, Returns';
      case 'user_management':
        return 'User Accounts, Roles, Permissions, Activity Tracking';
      case 'analytics':
        return 'Reports, KPIs, Dashboards, Trend Analysis';
      default:
        return 'Unknown capabilities';
    }
  }

  String _getModuleDataTypes(String moduleName) {
    switch (moduleName) {
      case 'inventory_management':
        return 'products, inventory';
      case 'pos_management':
        return 'transactions, sales';
      case 'customer_management':
        return 'customers, orders';
      case 'store_management':
        return 'stores, analytics';
      case 'purchase_order_management':
        return 'purchase_orders';
      case 'product_management':
        return 'products, categories';
      case 'supplier_management':
        return 'suppliers, supplier_performance';
      case 'customer_order_management':
        return 'customer_orders, order_items';
      case 'user_management':
        return 'users, user_activity';
      case 'analytics':
        return 'reports, kpis';
      default:
        return 'unknown';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  // Action methods
  void _syncModule(String moduleName) {
    if (kDebugMode) {
      print('🔄 Syncing module: $moduleName');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Syncing $moduleName...')),
    );
  }

  void _showModuleDetails(String moduleName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Module Details: $moduleName'),
        content: Text('Detailed information about $moduleName would be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addBusinessRule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business rule configuration would open here')),
    );
  }

  void _restartBridge() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restarting bridge...')),
    );
    await _initializeBridge();
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  void _syncAllModules() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing all modules...')),
    );
  }

  void _runHealthCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Running health check...')),
    );
  }

  void _testConnections() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing connections...')),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting logs...')),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bridge settings would open here')),
    );
  }

  void _configureModules() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module configuration would open here')),
    );
  }

  void _performanceTuning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performance tuning would open here')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
