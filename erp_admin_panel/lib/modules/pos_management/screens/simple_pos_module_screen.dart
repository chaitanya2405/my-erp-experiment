import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Activity tracking
import '../../../core/activity_tracker.dart';

// Riverpod state providers
import '../providers/pos_providers.dart';

class SimplePosModuleScreen extends ConsumerStatefulWidget {
  const SimplePosModuleScreen({super.key});

  @override
  ConsumerState<SimplePosModuleScreen> createState() => _SimplePosModuleScreenState();
}

class _SimplePosModuleScreenState extends ConsumerState<SimplePosModuleScreen> {
  @override
  void initState() {
    super.initState();
    
    // Track POS module navigation with activity tracker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ActivityTracker().trackNavigation(
        screenName: 'POSModule',
        routeName: '/pos',
        relatedFiles: [
          'lib/modules/pos_management/screens/simple_pos_module_screen.dart',
          'lib/modules/pos_management/providers/pos_providers.dart',
          'lib/services/pos_service.dart',
        ],
      );
      
      ActivityTracker().trackInteraction(
        action: 'pos_module_init',
        element: 'pos_screen',
        data: {'store': 'STORE_001', 'mode': 'riverpod'},
        filesInvolved: [
          'lib/modules/pos_management/screens/simple_pos_module_screen.dart',
          'lib/modules/pos_management/providers/pos_providers.dart',
        ],
      );
      
      print('💳 Simple POS Module initialized with Riverpod');
      print('  • Activity tracking: ENABLED');
      print('  • File mapping: COMPLETE');
      print('  • Provider pattern: RIVERPOD ONLY');
    });
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posStateProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('POS Module (Riverpod + Activity Tracking)'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              ActivityTracker().trackInteraction(
                action: 'view_analytics',
                element: 'analytics_button',
                filesInvolved: [
                  'lib/modules/pos_management/screens/simple_pos_module_screen.dart',
                ],
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📊 Analytics action tracked!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Tracking Demo Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.track_changes, color: Colors.green, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Activity Tracking Demo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'This POS module demonstrates the activity tracking system:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    _buildTrackingFeature('🧭 Navigation Tracking', 'Screen transitions logged to terminal'),
                    _buildTrackingFeature('👆 Interaction Tracking', 'Button clicks captured with file mapping'),
                    _buildTrackingFeature('📁 File Mapping', 'Precise file identification for debugging'),
                    _buildTrackingFeature('📊 Real-time Logging', 'Terminal output with timestamps'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Interactive Buttons for Testing Activity Tracking
            Text(
              'Test Activity Tracking:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTestButton(
                  'Process Transaction',
                  Icons.point_of_sale,
                  Colors.blue,
                  () => _trackTestAction('process_transaction', 'POS transaction processing'),
                ),
                _buildTestButton(
                  'View Reports',
                  Icons.analytics,
                  Colors.green,
                  () => _trackTestAction('view_reports', 'Sales reports and analytics'),
                ),
                _buildTestButton(
                  'Manage Inventory',
                  Icons.inventory,
                  Colors.orange,
                  () => _trackTestAction('manage_inventory', 'Inventory management'),
                ),
                _buildTestButton(
                  'Customer Lookup',
                  Icons.people,
                  Colors.purple,
                  () => _trackTestAction('customer_lookup', 'Customer database search'),
                ),
                _buildTestButton(
                  'Settings',
                  Icons.settings,
                  Colors.grey,
                  () => _trackTestAction('open_settings', 'POS system configuration'),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Status Display
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ POS Module with Activity Tracking',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Check the terminal for real-time activity logs with file mappings!',
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrackingFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 8),
          Expanded(child: Text(description, style: TextStyle(color: Colors.grey.shade600))),
        ],
      ),
    );
  }
  
  Widget _buildTestButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  void _trackTestAction(String action, String description) {
    ActivityTracker().trackInteraction(
      action: action,
      element: '${action}_button',
      data: {
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
        'store': 'STORE_001',
      },
      filesInvolved: [
        'lib/modules/pos_management/screens/simple_pos_module_screen.dart',
        'lib/services/pos_service.dart',
        'lib/modules/pos_management/providers/pos_providers.dart',
      ],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎯 Action "$action" tracked! Check terminal output.'),
        backgroundColor: Colors.blue.shade600,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
