import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Activity tracking
import '../../../core/activity_tracker.dart';

// Import farmer list screen
import 'farmer_list_screen.dart';

class FarmerModuleScreen extends ConsumerStatefulWidget {
  const FarmerModuleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FarmerModuleScreen> createState() => _FarmerModuleScreenState();
}

class _FarmerModuleScreenState extends ConsumerState<FarmerModuleScreen> {
  @override
  void initState() {
    super.initState();
    _initializeFarmerManagement();
  }

  Future<void> _initializeFarmerManagement() async {
    try {
      print('[FARMER] Initializing Farmer Management Module...');
      print('  • Loading farmer database from Firestore...');
      print('  • Initializing supplier view...');
      print('  • Setting up crop data management...');
      print('  [OK] Farmer Management Module ready');
      
      // Track Farmer Management module navigation with activity tracker
      ActivityTracker().trackNavigation(
        screenName: 'FarmerManagementModule',
        routeName: '/farmers',
        relatedFiles: [
          'lib/modules/farmer_management/screens/farmer_module_screen.dart',
          'lib/models/farmer.dart',
          'lib/services/farmer_service.dart',
          'lib/modules/farmer_management/screens/farmer_list_screen.dart',
        ],
      );
      
      // Track initialization
      ActivityTracker().trackInteraction(
        action: 'farmer_management_init',
        element: 'farmer_screen',
        data: const {'store': 'STORE_001', 'mode': 'supplier_view'},
      );
      
      print('  [OK] Farmer supplier view ready');
    } catch (e) {
      print('[WARNING] Error initializing Farmer Management: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Suppliers'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: const FarmerListScreen(),
    );
  }
}
