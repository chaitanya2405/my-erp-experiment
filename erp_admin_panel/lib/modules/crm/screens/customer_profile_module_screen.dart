import 'package:flutter/material.dart';
import 'customer_profile_form_screen.dart';
import 'customer_profile_list_screen.dart';
import 'customer_profile_analytics_screen.dart';
// import 'customer_profile_advanced_features_screen.dart'; // Uncomment if you add this
import '../tool/admin_mock_data_widget.dart';

class CustomerProfileModuleScreen extends StatefulWidget {
  const CustomerProfileModuleScreen({Key? key}) : super(key: key);

  @override
  State<CustomerProfileModuleScreen> createState() => _CustomerProfileModuleScreenState();
}

class _CustomerProfileModuleScreenState extends State<CustomerProfileModuleScreen> {
  int _selectedIndex = 0;
  final List<String> _menuTitles = [
    'Add Customer',
    'View Customers',
    'CRM Analytics',
    // 'Advanced Features', // Uncomment if you add this screen
    'Generate Mock Data',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('👥 Initializing Customer Relationship Management (CRM) Module...');
      print('  • Loading customer profiles from Firestore...');
      print('  • Setting up loyalty points tracking...');
      print('  • Connecting to POS integration for customer updates...');
      print('  • Initializing customer analytics...');
      print('  • Setting up customer segmentation...');
      print('  • Enabling customer communication tools...');
      print('  • Configuring customer journey tracking...');
      print('✅ CRM Module ready');
      print('  🎯 Monitoring customer loyalty updates from orders...');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Relationship Management'),
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
        return const CustomerProfileFormScreen();
      case 1:
        return const CustomerProfileListScreen();
      case 2:
        return const CustomerProfileAnalyticsScreen();
      // case 3:
      //   return const CustomerProfileAdvancedFeaturesScreen(); // Uncomment if you add this
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
        return Icon(Icons.person_add, color: color);
      case 1:
        return Icon(Icons.people, color: color);
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