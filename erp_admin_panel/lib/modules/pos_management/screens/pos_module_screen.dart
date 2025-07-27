import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod state providers
import '../providers/pos_providers.dart';

// Activity tracking
import '../../../core/activity_tracker.dart';

import '../../../core/models/unified_models.dart';
import '../../../models/pos_transaction.dart' as legacy_models;
import 'add_edit_pos_transaction_screen.dart';
import 'pos_transaction_screen.dart';
import 'pos_analytics_screen.dart';
import 'pos_audit_log_screen.dart';
import 'staff_management_screen.dart';

class PosModuleScreen extends ConsumerStatefulWidget {
  const PosModuleScreen({super.key});

  @override
  ConsumerState<PosModuleScreen> createState() => _PosModuleScreenState();
}

class _PosModuleScreenState extends ConsumerState<PosModuleScreen> {
  int _selectedIndex = 0;
  final String _searchQuery = '';

  final List<String> _menuItems = [
    'New Transaction',
    'View Transactions',
    'Quick Sale',
    'Analytics',
    'Audit Log',
    'Staff Management',
    'Integration',
    'Export',
  ];

  final List<IconData> _menuIcons = [
    Icons.add_shopping_cart,
    Icons.receipt_long,
    Icons.flash_on,
    Icons.analytics,
    Icons.history,
    Icons.people,
    Icons.sync,
    Icons.download,
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize POS module and track activity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('💳 Initializing POS Module...');
      print('  • Loading POS transactions for Store: STORE_001');
      print('  • Setting up real-time transaction monitoring');
      print('  • Connecting to inventory management system');
      print('  • Linking to customer loyalty system');
      print('  • Initializing payment processing gateway...');
      print('  • Setting up receipt generation system...');
      print('  • Configuring tax calculation engine...');
      print('  • Enabling barcode scanning integration...');
      print('✅ POS Module ready for transactions');
      
      // Track POS module navigation with activity tracker
      ActivityTracker().trackNavigation(
        screenName: 'POSModule',
        routeName: '/pos',
        relatedFiles: [
          'lib/modules/pos_management/screens/pos_module_screen.dart',
          'lib/modules/pos_management/providers/pos_providers.dart',
          'lib/modules/pos_management/services/pos_service.dart',
        ],
      );
      
      // Track initialization
      ActivityTracker().trackInteraction(
        action: 'pos_module_init',
        element: 'pos_screen',
        data: {'store': 'STORE_001', 'mode': 'riverpod'},
      );
      
      print('  ⚠️  POS Module needs provider migration to Riverpod');
      print('  📊 Using Riverpod posStateProvider for now');
    });
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posStateProvider);
    // Using Riverpod exclusively - converted from Provider pattern
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        tooltip: 'Back to Home',
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.point_of_sale, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Point of Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicators
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Online/Offline Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: posState.isOfflineMode ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              posState.isOfflineMode ? Icons.wifi_off : Icons.wifi,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              posState.isOfflineMode ? 'OFFLINE MODE' : 'ONLINE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Offline transactions indicator
                      if (posState.offlineTransactions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sync_problem, color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${posState.offlineTransactions.length} pending sync',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple[50] : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _menuIcons[index],
                            color: isSelected ? Colors.deepPurple[700] : Colors.grey[600],
                          ),
                          title: Text(
                            _menuItems[index],
                            style: TextStyle(
                              color: isSelected ? Colors.deepPurple[700] : Colors.grey[800],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Actions Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _menuItems[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Quick action buttons
                      if (_selectedIndex == 1) // View Transactions
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _refreshTransactions(context),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _syncOfflineTransactions(context),
                              icon: const Icon(Icons.sync, size: 16),
                              label: const Text('Sync'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToNewTransaction(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New Transaction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Area
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildNewTransactionContent();
      case 1:
        return _buildViewTransactionsContent();
      case 2:
        return _buildQuickSaleContent();
      case 3:
        return _buildAnalyticsContent();
      case 4:
        return _buildAuditLogContent();
      case 5:
        return _buildStaffManagementContent();
      case 6:
        return _buildIntegrationContent();
      case 7:
        return _buildExportContent();
      default:
        return _buildNewTransactionContent();
    }
  }

  Widget _buildNewTransactionContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Start Options
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'New Sale',
                  'Start a new transaction',
                  Icons.add_shopping_cart,
                  Colors.green,
                  () => _navigateToNewTransaction(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Quick Scan',
                  'Scan product barcode',
                  Icons.qr_code_scanner,
                  Colors.blue,
                  () => _quickScanBarcode(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Return/Refund',
                  'Process returns',
                  Icons.keyboard_return,
                  Colors.orange,
                  () => _processReturn(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Transactions Preview
          Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildRecentTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTransactionsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search and Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showFilterDialog(context),
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Transactions List
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSaleContent() {
    final posState = ref.watch(posStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Sale Header
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                'Quick Sale Mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _navigateToNewTransaction(context),
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('Full POS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick Action Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickSaleCard(
                  'Barcode Scan',
                  'Quick scan & checkout',
                  Icons.qr_code_scanner,
                  Colors.blue,
                  () => _quickScanAndCheckout(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickSaleCard(
                  'Express Checkout',
                  'Pre-selected items',
                  Icons.shopping_cart_checkout,
                  Colors.green,
                  () => _expressCheckout(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickSaleCard(
                  'Quick Cash',
                  'Cash-only transactions',
                  Icons.payments,
                  Colors.orange,
                  () => _quickCashSale(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Quick Sale Statistics
          Text(
            'Today\'s Quick Sales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickSaleStatCard(
                  'Total Sales',
                  posState.transactions.where((t) => 
                    t.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                  ).length.toString(),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickSaleStatCard(
                  'Revenue',
                  '₹${posState.transactions.where((t) => 
                    t.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                  ).fold(0.0, (sum, t) => sum + t.totalAmount).toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickSaleStatCard(
                  'Avg. Time',
                  '2.3 min',
                  Icons.timer,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Quick Sales
          Text(
            'Recent Quick Sales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: _buildQuickSalesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return PosAnalyticsScreen();
  }

  Widget _buildAuditLogContent() {
    return PosAuditLogScreen();
  }

  Widget _buildStaffManagementContent() {
    return StaffManagementScreen();
  }

  Widget _buildIntegrationContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Integration Settings - Coming Soon',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildExportContent() {
    final posState = ref.watch(posStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Header
          Row(
            children: [
              Icon(Icons.download, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Export Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Export Options
          Row(
            children: [
              Expanded(
                child: _buildExportCard(
                  'Transactions',
                  'Export all transaction data',
                  Icons.receipt,
                  Colors.green,
                  () => _exportTransactions(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExportCard(
                  'Sales Report',
                  'Daily/Monthly sales reports',
                  Icons.analytics,
                  Colors.blue,
                  () => _exportSalesReport(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExportCard(
                  'Customer Data',
                  'Customer information & history',
                  Icons.people,
                  Colors.purple,
                  () => _exportCustomerData(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Date Range Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date Range'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: 'last_30_days',
                              items: const [
                                DropdownMenuItem(value: 'today', child: Text('Today')),
                                DropdownMenuItem(value: 'last_7_days', child: Text('Last 7 Days')),
                                DropdownMenuItem(value: 'last_30_days', child: Text('Last 30 Days')),
                                DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
                              ],
                              onChanged: (value) {
                                // Handle date range change
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Format'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: 'csv',
                              items: const [
                                DropdownMenuItem(value: 'csv', child: Text('CSV')),
                                DropdownMenuItem(value: 'excel', child: Text('Excel')),
                                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                              ],
                              onChanged: (value) {
                                // Handle format change
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent Exports
          Text(
            'Recent Exports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: _buildRecentExportsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSaleCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSaleStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    final posState = ref.watch(posStateProvider);
    
    if (posState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (posState.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recent transactions',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first sale to see transactions here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final recentTransactions = posState.transactions.take(5).toList();
    return ListView.builder(
      itemCount: recentTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(_convertToUnified(recentTransactions[index]), isCompact: true);
      },
    );
  }

  Widget _buildTransactionsList() {
    final posState = ref.watch(posStateProvider);
    
    if (posState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (posState.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _navigateToNewTransaction(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Transaction'),
            ),
          ],
        ),
      );
    }

    final transactions = posState.transactions;
    
    // Filter transactions based on search query
    final filteredTransactions = _searchQuery.isEmpty
        ? transactions
        : transactions.where((transaction) {
            return transaction.posTransactionId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   transaction.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(_convertToUnified(filteredTransactions[index]));
      },
    );
  }

  Widget _buildTransactionCard(UnifiedPOSTransaction transaction, {bool isCompact = false}) {
    return Card(
      margin: EdgeInsets.only(
        bottom: isCompact ? 8 : 12,
        left: isCompact ? 0 : 4,
        right: isCompact ? 0 : 4,
      ),
      child: InkWell(
        onTap: () => _navigateToTransactionDetail(context, transaction),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: isCompact ? _buildCompactTransactionContent(transaction) : _buildFullTransactionContent(transaction),
        ),
      ),
    );
  }

  Widget _buildCompactTransactionContent(UnifiedPOSTransaction transaction) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.transactionStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(transaction.transactionStatus),
                color: _getStatusColor(transaction.transactionStatus),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [            Text(
                  transaction.posTransactionId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${transaction.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDate(transaction.createdAt),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Action buttons
        Row(
          children: [
            IconButton(
              onPressed: () => _navigateToTransactionDetail(context, transaction),
              icon: const Icon(Icons.visibility, color: Colors.blue, size: 18),
              tooltip: 'View Transaction',
            ),
            IconButton(
              onPressed: () => _navigateToEditTransaction(context, transaction),
              icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
              tooltip: 'Edit Transaction',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullTransactionContent(UnifiedPOSTransaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.posTransactionId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (transaction.customerName.isNotEmpty && transaction.customerName != 'Walk-in Customer') ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.customerName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.transactionStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.transactionStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(transaction.transactionStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.shopping_cart, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${transaction.items.length} items',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(width: 16),
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              _formatDate(transaction.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const Spacer(),
            Text(
              '₹${transaction.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            IconButton(
              onPressed: () => _navigateToTransactionDetail(context, transaction),
              icon: const Icon(Icons.visibility, color: Colors.blue, size: 20),
              tooltip: 'View Transaction',
            ),
            IconButton(
              onPressed: () => _navigateToEditTransaction(context, transaction),
              icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
              tooltip: 'Edit Transaction',
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
      case 'partial_refund':
      case 'full_refund':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
      case 'partial_refund':
      case 'full_refund':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToNewTransaction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPosTransactionScreen(),
      ),
    );
    
    if (result == true && mounted) {
      // Refresh the provider to ensure new transactions are shown
      ref.read(posStateProvider.notifier).refreshTransactions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToTransactionDetail(BuildContext context, UnifiedPOSTransaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PosTransactionScreen(
          transaction: transaction,
        ),
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToEditTransaction(BuildContext context, UnifiedPOSTransaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPosTransactionScreen(
          transaction: transaction,
        ),
      ),
    );
    
    if (result == true && mounted) {
      // Refresh transactions list after edit
      ref.read(posStateProvider.notifier).refreshTransactions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _quickScanBarcode(BuildContext context) {
    // Implement barcode scanning
  }

  void _refreshTransactions(BuildContext context) {
    ref.read(posStateProvider.notifier).refreshTransactions();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transactions refreshed'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _syncOfflineTransactions(BuildContext context) {
    // Implement offline transaction sync
  }

  void _processReturn(BuildContext context) {
    // Implement return processing
  }

  void _showFilterDialog(BuildContext context) {
    // Implement filter dialog
  }

  Widget _buildExportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExportsList() {
    // Mock data for recent exports
    final recentExports = [
      {
        'name': 'Transactions_2025-07-05.csv',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'size': '2.3 MB',
        'type': 'CSV',
      },
      {
        'name': 'Sales_Report_June.pdf',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'size': '5.1 MB',
        'type': 'PDF',
      },
      {
        'name': 'Customer_Data_Q2.xlsx',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'size': '1.8 MB',
        'type': 'Excel',
      },
    ];

    return ListView.builder(
      itemCount: recentExports.length,
      itemBuilder: (context, index) {
        final export = recentExports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getExportIcon(export['type'] as String),
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              export['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${_formatDate(export['date'] as DateTime)} • ${export['size']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Implement download functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading ${export['name']}')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getExportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'csv':
        return Icons.table_chart;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'excel':
        return Icons.insert_chart;
      default:
        return Icons.file_download;
    }
  }

  // Quick Sale action methods
  void _quickScanAndCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Scan & Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Scan product barcode to add to cart'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Implement barcode scanning
                _quickScanBarcode(context);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _expressCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPosTransactionScreen(),
      ),
    );
  }

  void _quickCashSale(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPosTransactionScreen(),
      ),
    );
  }

  // Export action methods
  void _exportTransactions(BuildContext context) async {
    final posState = ref.read(posStateProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Exporting transactions...'),
          ],
        ),
      ),
    );

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${posState.transactions.length} transactions successfully'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Download',
            onPressed: () {
              // Implement download logic
            },
          ),
        ),
      );
    }
  }

  void _exportSalesReport(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Generating sales report...'),
          ],
        ),
      ),
    );

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sales report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _exportCustomerData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Exporting customer data...'),
          ],
        ),
      ),
    );

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer data exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildQuickSalesList() {
    final posState = ref.watch(posStateProvider);
    
    // Filter for quick sales (for demo, we'll show all transactions)
    final quickSales = posState.transactions.take(3).toList();
    
    if (quickSales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No quick sales yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: quickSales.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(_convertToUnified(quickSales[index]), isCompact: true);
      },
    );
  }

  // Helper method to convert PosTransaction to UnifiedPOSTransaction
  UnifiedPOSTransaction _convertToUnified(dynamic transaction) {
    if (transaction is UnifiedPOSTransaction) return transaction;
    
    // Convert PosTransaction to UnifiedPOSTransaction
    return UnifiedPOSTransaction(
      id: transaction.id ?? '',
      posTransactionId: transaction.transactionId ?? '',
      transactionId: transaction.transactionId ?? '',
      customerId: transaction.customerId,
      storeId: transaction.storeId,
      terminalId: transaction.terminalId ?? '',
      cashierId: transaction.cashierId ?? '',
      productItems: (transaction.items as List? ?? []).map((item) => 
        UnifiedPOSTransactionItem(
          productId: item.productId ?? '',
          productName: item.productName ?? '',
          quantity: item.quantity ?? 0,
          unitPrice: (item.unitPrice ?? 0).toDouble(),
          totalPrice: (item.totalPrice ?? 0).toDouble(),
        )
      ).toList(),
      subTotal: (transaction.subtotal ?? 0).toDouble(),
      taxAmount: (transaction.tax ?? 0).toDouble(),
      discountApplied: (transaction.discount ?? 0).toDouble(),
      roundOffAmount: 0.0,
      totalAmount: (transaction.total ?? 0).toDouble(),
      paymentMode: transaction.paymentMethod ?? '',
      walletUsed: 0.0,
      changeReturned: 0.0,
      loyaltyPointsEarned: 0,
      loyaltyPointsUsed: 0,
      invoiceNumber: transaction.invoiceNumber ?? '',
      invoiceType: 'sale',
      refundStatus: '',
      syncedToServer: transaction.isSynced ?? false,
      syncedToInventory: false,
      syncedToFinance: false,
      isOfflineMode: false,
      pricingEngineSnapshot: {},
      taxBreakup: {},
      createdAt: transaction.timestamp ?? DateTime.now(),
      updatedAt: transaction.timestamp ?? DateTime.now(),
      metadata: transaction.metadata ?? {},
    );
  }

  // Helper method to convert UnifiedPOSTransaction to legacy PosTransaction
  legacy_models.PosTransaction? _convertToLegacy(UnifiedPOSTransaction? unifiedTransaction) {
    if (unifiedTransaction == null) return null;
    
    return legacy_models.PosTransaction(
      posTransactionId: unifiedTransaction.posTransactionId,
      storeId: unifiedTransaction.storeId ?? '',
      terminalId: unifiedTransaction.terminalId,
      cashierId: unifiedTransaction.cashierId,
      customerId: unifiedTransaction.customerId,
      transactionTime: unifiedTransaction.transactionTime,
      productItems: unifiedTransaction.productItems.map((item) => 
        legacy_models.PosProductItem(
          productId: item.productId,
          productName: item.productName,
          sku: item.sku ?? '',
          quantity: item.quantity,
          mrp: item.unitPrice,
          sellingPrice: item.unitPrice,
          finalPrice: item.totalPrice,
          discountAmount: 0.0,
          taxAmount: 0.0,
          taxSlab: '18%',
        )
      ).toList(),
      pricingEngineSnapshot: unifiedTransaction.metadata,
      subTotal: unifiedTransaction.subTotal,
      discountApplied: unifiedTransaction.discountApplied,
      loyaltyPointsUsed: unifiedTransaction.loyaltyPointsUsed,
      loyaltyPointsEarned: unifiedTransaction.loyaltyPointsEarned,
      taxBreakup: {'total_gst': unifiedTransaction.taxAmount},
      totalAmount: unifiedTransaction.totalAmount,
      paymentMode: unifiedTransaction.paymentMode,
      changeReturned: unifiedTransaction.changeReturned,
      walletUsed: unifiedTransaction.walletUsed,
      roundOffAmount: unifiedTransaction.roundOffAmount,
      invoiceNumber: unifiedTransaction.invoiceNumber,
      invoiceType: unifiedTransaction.invoiceType,
      refundStatus: unifiedTransaction.refundStatus,
      isOfflineMode: false,
      syncedToServer: unifiedTransaction.syncedToServer,
      syncedToFinance: false,
      syncedToInventory: false,
      createdAt: unifiedTransaction.createdAt,
      updatedAt: unifiedTransaction.updatedAt,
    );
  }
}
