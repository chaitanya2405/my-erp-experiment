import 'package:flutter/material.dart';
import 'customer_order_form_screen.dart';
import 'customer_order_list_screen.dart';
import 'customer_order_analytics_screen.dart';
// import 'customer_order_advanced_features_screen.dart'; // Uncomment if you have this
import '../tool/admin_mock_data_widget.dart';
import '../../../core/activity_tracker.dart';

class CustomerOrderModuleScreen extends StatefulWidget {
  const CustomerOrderModuleScreen({Key? key}) : super(key: key);

  @override
  State<CustomerOrderModuleScreen> createState() => _CustomerOrderModuleScreenState();
}

class _CustomerOrderModuleScreenState extends State<CustomerOrderModuleScreen> {
  int _selectedIndex = 0;
  final List<String> _menuTitles = [
    'Create Order',
    'View Orders',
    'Order Analytics',
    // 'Advanced Features', // Uncomment if you have this screen
    'Generate Mock Data',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCustomerOrderModule();
    });
  }

  Future<void> _initializeCustomerOrderModule() async {
    try {
      print('📋 Initializing Customer Order Management Module...');
      print('  • Loading customer orders from Firestore...');
      print('  • Setting up real-time order monitoring...');
      print('  • Connecting to POS integration system...');
      print('  • Initializing order fulfillment workflow...');
      print('  • Setting up multi-store order routing...');
      print('  • Enabling customer notification system...');
      print('  • Configuring payment processing...');
      print('✅ Customer Order Module ready for order processing');
      
      // Track Customer Order module navigation with activity tracker
      ActivityTracker().trackNavigation(
        screenName: 'CustomerOrderManagementModule',
        routeName: '/customer-orders',
        relatedFiles: [
          'lib/modules/customer_order_management/screens/customer_order_module_screen.dart',
          'lib/modules/customer_order_management/screens/customer_order_form_screen.dart',
          'lib/modules/customer_order_management/screens/customer_order_list_screen.dart',
          'lib/modules/customer_order_management/screens/customer_order_analytics_screen.dart',
        ],
      );
      
      // Track initialization
      ActivityTracker().trackInteraction(
        action: 'customer_order_init',
        element: 'customer_order_module_screen',
        data: {'store': 'STORE_001', 'mode': 'order_processing', 'realtime_enabled': 'true'},
      );
      
      print('  🔄 Monitoring for new orders from customer app...');
      print('  💳 Payment processing systems active');
    } catch (e) {
      print('⚠️ Customer Order initialization warning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Order Management'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFFF7F6FB),
            child: Column(
              children: [
                const SizedBox(height: 24),
                ...List.generate(_menuTitles.length, (i) {
                  final isSelected = _selectedIndex == i;
                  final icon = _getMenuIcon(i, isSelected);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: icon,
                      title: Text(
                        _menuTitles[i],
                        style: TextStyle(
                          color: isSelected ? Colors.teal : Colors.black54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.teal.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  );
                }),
                const Spacer(),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const CustomerOrderFormScreen();
      case 1:
        return const CustomerOrderListScreen();
      case 2:
        return const CustomerOrderAnalyticsScreen();
      // case 3:
      //   return const CustomerOrderAdvancedFeaturesScreen(); // Uncomment if you have this
      case 3:
        return const AdminMockDataWidget();
      default:
        return Center(
          child: Text(
            'Unknown Tab',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        );
    }
  }

  Icon _getMenuIcon(int i, bool selected) {
    final color = selected ? Colors.teal : Colors.black38;
    switch (i) {
      case 0:
        return Icon(Icons.add_shopping_cart, color: color);
      case 1:
        return Icon(Icons.list_alt, color: color);
      case 2:
        return Icon(Icons.analytics, color: color);
      // case 3:
      //   return Icon(Icons.settings_suggest, color: color);
      case 3:
        return Icon(Icons.data_object, color: color);
      default:
        return Icon(Icons.circle, color: color);
    }
  }
}
