import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/models/unified_models.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardMetrics();
  }

  Future<void> _loadDashboardMetrics() async {
    setState(() => _isLoading = true);
    
    try {
      // Load key metrics from Firestore
      final storesSnapshot = await FirebaseFirestore.instance.collection('stores').get();
      final posSnapshot = await FirebaseFirestore.instance.collection('pos_transactions').get();
      final inventorySnapshot = await FirebaseFirestore.instance.collection('inventory').get();
      final customersSnapshot = await FirebaseFirestore.instance.collection('customers').get();
      final ordersSnapshot = await FirebaseFirestore.instance.collection('customer_orders').get();

      final totalStores = storesSnapshot.docs.length;
      final totalTransactions = posSnapshot.docs.length;
      final totalProducts = inventorySnapshot.docs.length;
      final totalCustomers = customersSnapshot.docs.length;
      final totalOrders = ordersSnapshot.docs.length;

      // Calculate revenue
      double totalRevenue = 0;
      for (var doc in posSnapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] as num?)?.toDouble() ?? 0;
      }

      // Calculate low stock items
      int lowStockItems = 0;
      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        final currentStock = (data['currentStock'] as num?)?.toInt() ?? 0;
        final minStock = (data['minStockLevel'] as num?)?.toInt() ?? 10;
        if (currentStock <= minStock) {
          lowStockItems++;
        }
      }

      setState(() {
        _metrics = {
          'totalStores': totalStores,
          'totalTransactions': totalTransactions,
          'totalProducts': totalProducts,
          'totalCustomers': totalCustomers,
          'totalOrders': totalOrders,
          'totalRevenue': totalRevenue,
          'lowStockItems': lowStockItems,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard metrics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced ERP Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardMetrics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dashboard, color: Colors.white, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ravali ERP Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Real-time business insights across ${_metrics['totalStores'] ?? 0} stores',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Key Metrics Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricCard(
                        'Total Revenue',
                        '₹${(_metrics['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                        Icons.monetization_on,
                        Colors.green,
                      ),
                      _buildMetricCard(
                        'Total Orders',
                        '${_metrics['totalOrders'] ?? 0}',
                        Icons.shopping_cart,
                        Colors.blue,
                      ),
                      _buildMetricCard(
                        'Active Stores',
                        '${_metrics['totalStores'] ?? 0}',
                        Icons.store,
                        Colors.purple,
                      ),
                      _buildMetricCard(
                        'Low Stock Alerts',
                        '${_metrics['lowStockItems'] ?? 0}',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Charts Section
                  Row(
                    children: [
                      // Sales Chart
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sales Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          const FlSpot(0, 3),
                                          const FlSpot(1, 4),
                                          const FlSpot(2, 3.5),
                                          const FlSpot(3, 5),
                                          const FlSpot(4, 4),
                                          const FlSpot(5, 6),
                                        ],
                                        isCurved: true,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blue.withOpacity(0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Quick Actions
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildQuickActionButton(
                                'New Transaction',
                                Icons.add_shopping_cart,
                                Colors.green,
                                () => _navigateToModule('pos'),
                              ),
                              const SizedBox(height: 8),
                              _buildQuickActionButton(
                                'Add Product',
                                Icons.inventory,
                                Colors.blue,
                                () => _navigateToModule('inventory'),
                              ),
                              const SizedBox(height: 8),
                              _buildQuickActionButton(
                                'View Reports',
                                Icons.analytics,
                                Colors.purple,
                                () => _navigateToModule('analytics'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'New order received',
                          'Order #1234 from customer John Doe',
                          '2 minutes ago',
                          Icons.shopping_bag,
                          Colors.green,
                        ),
                        _buildActivityItem(
                          'Low stock alert',
                          'Product ABC123 running low in Store HYD001',
                          '5 minutes ago',
                          Icons.warning,
                          Colors.orange,
                        ),
                        _buildActivityItem(
                          'Payment processed',
                          'Transaction #5678 completed successfully',
                          '10 minutes ago',
                          Icons.payment,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToModule(String module) {
    // Placeholder for navigation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $module module...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
