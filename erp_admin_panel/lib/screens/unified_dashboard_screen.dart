import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app_services.dart';
import '../providers/app_state_provider.dart';
import '../modules/inventory_management/screens/inventory_management_screen.dart';
import '../modules/purchase_order_management/screens/purchase_order_module_screen.dart';
import '../modules/customer_order_management/screens/customer_order_module_screen.dart';
import 'customer_app_screen.dart'; // Add customer app screen
import '../core/tracked_navigation.dart';
import '../core/activity_tracker.dart';
import '../widgets/cross_module_integration_demo.dart';
// Removed imports for moved legacy screens

/// A central command center for the ERP system, providing a comprehensive overview of all modules.
class UnifiedDashboardScreen extends ConsumerWidget {
  const UnifiedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track navigation to dashboard
    ActivityTracker().trackNavigation(
      screenName: 'UnifiedDashboard',
      routeName: '/dashboard',
      relatedFiles: FileMapping.getFilesForScreen('UnifiedDashboard'),
    );

    final appState = ref.watch(appStateProvider);
    // Watch one of the primary streams to handle the initial loading/error state for the whole dashboard.
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Unified Dashboard'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Invalidate all stream providers to trigger a data refresh.
              ref.invalidate(productsStreamProvider);
              ref.invalidate(inventoryStreamProvider);
              ref.invalidate(customerOrderStreamProvider);
              ref.invalidate(purchaseOrderStreamProvider);
              ref.invalidate(customerProfileStreamProvider);
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Placeholder for notifications screen
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (_) {
          // Once the initial stream has data, watch the aggregator provider.
          final dashboardData = ref.watch(dashboardDataProvider);
          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1400 ? 4 : (constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, appState),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildDashboardGrid(context, dashboardData, crossAxisCount),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${appState.userProfile?.displayName ?? 'User'}!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your business overview for today, ${DateFormat.yMMMMd().format(DateTime.now())}.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _QuickActionButton(
          label: 'Customer App', 
          icon: Icons.smartphone, 
          onPressed: () => _navigateToScreen(context, const CustomerAppScreen(), 'CustomerApp'),
          color: Colors.blue,
        ),
        _QuickActionButton(
          label: 'Bridge Demo', 
          icon: Icons.hub, 
          onPressed: () => _showCrossModuleDemo(context),
          color: Colors.purple,
        ),
        _QuickActionButton(label: 'New Order', icon: Icons.add_shopping_cart, onPressed: () {/* TODO: Navigate to new order screen */}),
        _QuickActionButton(label: 'New Product', icon: Icons.add_box_outlined, onPressed: () {/* TODO: Navigate to new product screen */}),
        _QuickActionButton(label: 'New PO', icon: Icons.receipt_long_outlined, onPressed: () {/* TODO: Navigate to new PO screen */}),
        _QuickActionButton(label: 'Run Report', icon: Icons.analytics_outlined, onPressed: () {/* TODO: Navigate to reports screen */}),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context, DashboardData dashboardData, int crossAxisCount) {
    final totalInventory = dashboardData.totalProducts;
    final inStockCount = totalInventory - dashboardData.lowStockItems;

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        // KPI Cards
        _SummaryKpiCard(
          title: 'Total Revenue',
          value: NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(dashboardData.totalRevenue),
          icon: Icons.trending_up,
          color: Colors.green,
          onTap: () => _navigateToScreen(context, const CustomerOrderModuleScreen(), 'CustomerOrderModule'),
        ),
        _SummaryKpiCard(
          title: 'Pending Orders',
          value: dashboardData.pendingOrders.toString(),
          icon: Icons.hourglass_top,
          color: Colors.orange,
          onTap: () => _navigateToScreen(context, const CustomerOrderModuleScreen(), 'CustomerOrderModule'),
        ),
        _SummaryKpiCard(
          title: 'Low Stock Items',
          value: dashboardData.lowStockItems.toString(),
          icon: Icons.warning_amber_rounded,
          color: Colors.red,
          onTap: () => _navigateToScreen(context, const InventoryManagementScreen(), 'InventoryManagement'),
        ),
        _SummaryKpiCard(
          title: 'Pending POs',
          value: dashboardData.pendingPurchaseOrders.toString(),
          icon: Icons.receipt,
          color: Colors.blue,
          onTap: () => _navigateToScreen(context, const PurchaseOrderModuleScreen(), 'PurchaseOrderModule'),
        ),

        // Chart Cards
        _DashboardCard(
          title: 'Purchase Order Pipeline',
          child: _PurchaseOrderStatusChart(statusCounts: dashboardData.poStatusCounts),
          width: crossAxisCount > 2 ? (1400 / 2) - 36 : double.infinity,
          height: 350,
        ),
        _DashboardCard(
          title: 'Inventory Status',
          child: _InventoryStatusPieChart(
            lowStock: dashboardData.lowStockItems,
            inStock: inStockCount,
          ),
          width: crossAxisCount > 2 ? (1400 / 2) - 36 : double.infinity,
          height: 350,
        ),
        _DashboardCard(
          title: 'Customer Segments',
          child: _CustomerSegmentsChart(segmentCounts: dashboardData.customerSegments),
          width: crossAxisCount > 2 ? (1400 / 2) - 36 : double.infinity,
          height: 350,
        ),
        _DashboardCard(
          title: 'System Alerts',
          child: _AlertsPanel(),
          width: crossAxisCount > 2 ? (1400 / 2) - 36 : double.infinity,
          height: 350,
        ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen, String screenName) {
    TrackedNavigator.push(
      context,
      screen: screen,
      screenName: screenName,
      relatedFiles: FileMapping.getFilesForScreen(screenName),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    // Legacy method - determine screen name from widget type
    String screenName = screen.runtimeType.toString();
    _navigateToScreen(context, screen, screenName);
  }

  void _showCrossModuleDemo(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: const CrossModuleIntegrationDemo(),
          ),
        );
      },
    );
  }
}

// --- Individual Dashboard Widgets ---

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? width;
  final double? height;

  const _DashboardCard({required this.title, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SummaryKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryStatusPieChart extends StatelessWidget {
  final int inStock;
  final int lowStock;

  const _InventoryStatusPieChart({required this.inStock, required this.lowStock});

  @override
  Widget build(BuildContext context) {
    final total = inStock + lowStock;
    if (total == 0) {
      return const Center(child: Text("No inventory data."));
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: inStock.toDouble(),
            title: '${(inStock / total * 100).toStringAsFixed(0)}%',
            color: Colors.green,
            radius: 80,
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: lowStock.toDouble(),
            title: '${(lowStock / total * 100).toStringAsFixed(0)}%',
            color: Colors.orange,
            radius: 80,
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 40,
      ),
    );
  }
}

class _PurchaseOrderStatusChart extends StatelessWidget {
  final Map<String, int> statusCounts;

  const _PurchaseOrderStatusChart({required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    if (statusCounts.isEmpty) {
      return const Center(child: Text("No purchase order data."));
    }

    final barGroups = statusCounts.entries.toList().asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: Colors.purple,
            width: 16,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(statusCounts.keys.elementAt(value.toInt()), style: const TextStyle(fontSize: 10)),
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _CustomerSegmentsChart extends StatelessWidget {
  final Map<String, int> segmentCounts;

  const _CustomerSegmentsChart({required this.segmentCounts});

  @override
  Widget build(BuildContext context) {
    if (segmentCounts.isEmpty) {
      return const Center(child: Text("No customer data."));
    }

    final barGroups = segmentCounts.entries.toList().asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: Colors.teal,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(segmentCounts.keys.elementAt(value.toInt()), style: const TextStyle(fontSize: 12)),
              reservedSize: 20,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _AlertsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);

    return inventoryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (inventoryItems) {
        final lowStockItems = inventoryItems
            .where((item) => item.currentStock <= item.minStockLevel && item.currentStock > 0)
            .toList();

        if (lowStockItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                SizedBox(height: 8),
                Text("No critical alerts.", style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        return productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (products) {
            final productMap = {for (var p in products) p.productId: p};
            return ListView.builder(
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                final product = productMap[item.productId];
                return ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(product?.productName ?? 'Unknown Product'),
                  subtitle: Text('Stock: ${item.currentStock} (Min: ${item.minStockLevel})'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to create a PO for this item
                    },
                    child: const Text('Reorder'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _QuickActionButton({required this.label, required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
