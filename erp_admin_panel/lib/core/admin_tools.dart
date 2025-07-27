import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../tool/unified_erp_mock_data_generator.dart';
import 'activity_viewer.dart';
import 'activity_tracker.dart';

class AdminMockDataWidget extends StatefulWidget {
  const AdminMockDataWidget({super.key});

  @override
  State<AdminMockDataWidget> createState() => _AdminMockDataWidgetState();
}

class _AdminMockDataWidgetState extends State<AdminMockDataWidget> {
  bool _isGenerating = false;
  bool _isClearing = false;
  String _lastOperationMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize activity tracker
    ActivityTracker().setEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Activity Tracker Widget
        const ActivityViewerWidget(),
        const SizedBox(height: 16),
        
        // Mock Data Generator
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.science, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Mock Data Generator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Generate or clear mock data for testing purposes.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                
                // Operation Status
                if (_lastOperationMessage.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _lastOperationMessage,
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            
            // Main Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating || _isClearing ? null : _forceRegenerateAllData,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isGenerating ? 'Generating...' : 'Force Regenerate All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating || _isClearing ? null : _clearAllData,
                    icon: _isClearing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text(_isClearing ? 'Clearing...' : 'Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Original Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating || _isClearing ? null : _generateUnifiedERPData,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch),
                label: Text(_isGenerating ? 'Generating...' : '🚀 Generate Unified ERP Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _forceRegenerateAllData() async {
    // Track this interaction
    ActivityTracker().trackInteraction(
      action: 'force_regenerate_data',
      element: 'force_regenerate_button',
      filesInvolved: [
        'lib/core/admin_tools.dart',
        'lib/tool/unified_erp_mock_data_generator.dart',
      ],
    );

    setState(() {
      _isGenerating = true;
      _lastOperationMessage = '';
    });

    try {
      // First clear all existing data
      await _clearAllDataInternal();
      
      // Wait a moment for clearing to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Then generate new data
      await UnifiedERPMockDataGenerator.generateUnifiedMockData();
      
      setState(() {
        _lastOperationMessage = '✅ All data cleared and regenerated successfully!';
      });
    } catch (e) {
      ActivityTracker().trackError(
        error: 'Failed to regenerate data: $e',
        affectedFiles: [
          'lib/core/admin_tools.dart',
          'lib/tool/unified_erp_mock_data_generator.dart',
        ],
      );
      setState(() {
        _lastOperationMessage = '❌ Error during regeneration: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to clear all mock data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isClearing = true;
      _lastOperationMessage = '';
    });

    try {
      await _clearAllDataInternal();
      
      setState(() {
        _lastOperationMessage = '✅ All mock data cleared successfully!';
      });
    } catch (e) {
      setState(() {
        _lastOperationMessage = '❌ Error clearing data: $e';
      });
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  Future<void> _clearAllDataInternal() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    
    // List all collections to clear
    final collections = [
      'stores',
      'products', 
      'inventory',
      'suppliers',
      'purchase_orders',
      'customers',
      'customer_orders',
      'pos_transactions',
      'store_performance',
      'transfers',
    ];
    
    for (final collectionName in collections) {
      final querySnapshot = await firestore.collection(collectionName).get();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
    }
    
    await batch.commit();
  }

  Future<void> _generateUnifiedERPData() async {
    // Track this interaction
    ActivityTracker().trackInteraction(
      action: 'generate_mock_data',
      element: 'generate_data_button',
      filesInvolved: [
        'lib/core/admin_tools.dart',
        'lib/tool/unified_erp_mock_data_generator.dart',
      ],
    );

    setState(() {
      _isGenerating = true;
      _lastOperationMessage = '';
    });

    try {
      await UnifiedERPMockDataGenerator.generateUnifiedMockData();
      
      setState(() {
        _lastOperationMessage = '✅ Unified ERP data generated successfully!';
      });
    } catch (e) {
      ActivityTracker().trackError(
        error: 'Failed to generate data: $e',
        affectedFiles: [
          'lib/core/admin_tools.dart',
          'lib/tool/unified_erp_mock_data_generator.dart',
        ],
      );
      setState(() {
        _lastOperationMessage = '❌ Error generating data: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
}
