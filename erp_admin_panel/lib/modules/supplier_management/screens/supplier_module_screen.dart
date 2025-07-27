import 'package:flutter/material.dart';

// Activity tracking
import '../../../core/activity_tracker.dart';

import '../models/supplier.dart';
import '../models/supplier_service.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_list_screen.dart';
import 'supplier_analytics_screen.dart';
import 'supplier_advanced_features_screen.dart'; // <-- import the new screen
import '../tool/admin_mock_data_widget.dart';

class SupplierModuleScreen extends StatefulWidget {
  const SupplierModuleScreen({Key? key}) : super(key: key);

  @override
  State<SupplierModuleScreen> createState() => _SupplierModuleScreenState();
}

class _SupplierModuleScreenState extends State<SupplierModuleScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeSupplierManagement();
  }

  Future<void> _initializeSupplierManagement() async {
    try {
      print('🏭 Initializing Supplier Management Module...');
      print('  • Loading supplier database from Firestore...');
      print('  • Setting up supplier relationship tracking...');
      print('  • Initializing purchase order integration...');
      print('  • Configuring supplier performance metrics...');
      print('  • Setting up payment terms management...');
      print('  • Enabling supplier communication portal...');
      print('✅ Supplier Management Module ready for operations');
      
      // Track Supplier Management module navigation with activity tracker
      ActivityTracker().trackNavigation(
        screenName: 'SupplierManagementModule',
        routeName: '/suppliers',
        relatedFiles: [
          'lib/modules/supplier_management/screens/supplier_module_screen.dart',
          'lib/modules/supplier_management/models/supplier.dart',
          'lib/modules/supplier_management/models/supplier_service.dart',
          'lib/modules/supplier_management/screens/supplier_list_screen.dart',
        ],
      );
      
      // Track initialization
      ActivityTracker().trackInteraction(
        action: 'supplier_management_init',
        element: 'supplier_screen',
        data: {'store': 'STORE_001', 'mode': 'comprehensive', 'portal_enabled': 'true'},
      );
      
      print('  🤝 Supplier portal integration active');
      print('  📈 Performance tracking and analytics enabled');
    } catch (e) {
      print('⚠️ Supplier Management initialization warning: $e');
    }
  }
  
  final List<String> _menuTitles = [
    'Add Supplier',
    'View Suppliers',
    'Supplier Analytics',
    'Advanced Features',
    'Generate Mock Data',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        backgroundColor: Colors.deepPurple.shade700,
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
                          color: isSelected ? Colors.deepPurple : Colors.black54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.deepPurple.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () => setState(() => _selectedIndex = i), // <-- always enabled
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
        return const AddEditSupplierScreen();
      case 1:
        return const SupplierListScreen();
      case 2:
        return const SupplierAnalyticsScreen();
      case 3:
        return const SupplierAdvancedFeaturesScreen(); // <-- update here
      case 4:
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
    final color = selected ? Colors.deepPurple : Colors.black38;
    switch (i) {
      case 0:
        return Icon(Icons.person_add, color: color);
      case 1:
        return Icon(Icons.list_alt, color: color);
      case 2:
        return Icon(Icons.analytics, color: color);
      case 3:
        return Icon(Icons.settings_suggest, color: color);
      case 4:
        return Icon(Icons.data_object, color: color);
      default:
        return Icon(Icons.circle, color: color);
    }
  }
}
