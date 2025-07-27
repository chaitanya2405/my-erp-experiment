import 'package:flutter/material.dart';
import '../widgets/po_list_table.dart';
import '../screens/purchase_order_form_screen.dart';
import '../screens/purchase_order_dashboard_screen.dart';
import '../tool/admin_mock_data_widget.dart';
import '../widgets/po_communication_tab.dart';
import '../widgets/po_advanced_analytics.dart';

class PurchaseOrderModuleScreen extends StatefulWidget {
  const PurchaseOrderModuleScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseOrderModuleScreen> createState() => _PurchaseOrderModuleScreenState();
}

class _PurchaseOrderModuleScreenState extends State<PurchaseOrderModuleScreen> {
  int _selectedTab = 0;
  final List<String> _menuTitles = [
    'Create Purchase Order',
    'View Purchase Orders',
    'Communication',
    'Analytics',
    'Generate Mock Data',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order Management'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedTab,
            onDestinationSelected: (i) => setState(() => _selectedTab = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.add), label: Text('Create PO')),
              NavigationRailDestination(icon: Icon(Icons.list), label: Text('View POs')),
              NavigationRailDestination(icon: Icon(Icons.message), label: Text('Communication')),
              NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Analytics')),
              NavigationRailDestination(icon: Icon(Icons.data_object), label: Text('Generate Mock Data')),
            ],
          ),
          const VerticalDivider(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                const PurchaseOrderFormScreen(), // Create PO
                const PoListTable(), // View PO (table)
                PoCommunicationTab(), // Communication tab
                const PurchaseOrderDashboardScreen(), // Analytics (advanced features included here)
                const AdminMockDataWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}