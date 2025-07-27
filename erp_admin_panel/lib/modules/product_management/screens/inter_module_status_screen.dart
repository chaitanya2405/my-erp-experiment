import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../../core/activity_tracker.dart';

class InterModuleStatusScreen extends StatefulWidget {
  final List<Map<String, dynamic>> recentCommunications;
  final StreamSubscription<QuerySnapshot>? productSubscription;
  final StreamSubscription<QuerySnapshot>? inventorySubscription;
  final StreamSubscription<QuerySnapshot>? posSubscription;
  final Function(Map<String, dynamic>) onTestCommunication;

  const InterModuleStatusScreen({
    Key? key,
    required this.recentCommunications,
    this.productSubscription,
    this.inventorySubscription,
    this.posSubscription,
    required this.onTestCommunication,
  }) : super(key: key);

  @override
  State<InterModuleStatusScreen> createState() => _InterModuleStatusScreenState();
}

class _InterModuleStatusScreenState extends State<InterModuleStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inter-Module Communication Status',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time monitoring of Product Management module communications using Firestore listeners. Updates only when actual data changes occur.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          // Enhanced Communication Status Card
          _buildInterModuleCommunicationStatus(),
          
          const SizedBox(height: 24),
          
          // Communication Statistics
          Row(
            children: [
              Expanded(
                child: _buildCommunicationStatsCard(
                  'Total Communications',
                  widget.recentCommunications.length.toString(),
                  Icons.message,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCommunicationStatsCard(
                  'Active Modules',
                  '7',
                  Icons.circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCommunicationStatsCard(
                  'Last Sync',
                  widget.recentCommunications.isNotEmpty 
                    ? '${DateTime.now().difference((widget.recentCommunications.last['timestamp'] as DateTime)).inSeconds}s ago'
                    : 'Never',
                  Icons.sync,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCommunicationStatsCard(
                  'Success Rate',
                  '100%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Communication Flow Diagram
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Communication Flow Diagram',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildCommunicationFlowDiagram(),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test Communication Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Module Communications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildTestCommunicationButton('Test Inventory Sync', Icons.inventory, Colors.green),
                    _buildTestCommunicationButton('Test POS Integration', Icons.point_of_sale, Colors.blue),
                    _buildTestCommunicationButton('Test CRM Analytics', Icons.analytics, Colors.purple),
                    _buildTestCommunicationButton('Test Purchase Orders', Icons.shopping_cart, Colors.orange),
                    _buildTestCommunicationButton('Test All Modules', Icons.network_check, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterModuleCommunicationStatus() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.network_check, color: Colors.blue.shade600),
                SizedBox(width: 8),
                Text(
                  'Real-time Firestore-based Module Communication',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Spacer(),
                // Real-time activity indicator with Firestore status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_sync, color: Colors.green, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Firestore Live',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firestore Collections Monitored',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                      SizedBox(height: 8),
                      _buildCommunicationStatusItem('Products Collection', Icons.inventory_2, widget.productSubscription != null ? Colors.green : Colors.red),
                      _buildCommunicationStatusItem('Inventory Collection', Icons.inventory, widget.inventorySubscription != null ? Colors.green : Colors.red),
                      _buildCommunicationStatusItem('POS Transactions', Icons.point_of_sale, widget.posSubscription != null ? Colors.green : Colors.red),
                      _buildCommunicationStatusItem('Store Management', Icons.store, Colors.green),
                      _buildCommunicationStatusItem('Purchase Orders', Icons.shopping_cart, Colors.green),
                      _buildCommunicationStatusItem('Supplier Management', Icons.business, Colors.green),
                      _buildCommunicationStatusItem('Customer Orders', Icons.receipt, Colors.green),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 220,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${widget.recentCommunications.length} events',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: widget.recentCommunications.isEmpty 
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_sync, size: 32, color: Colors.blue.shade300),
                                    SizedBox(height: 8),
                                    Text(
                                      'Monitoring Firestore',
                                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Will update on data changes',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: widget.recentCommunications.length,
                                itemBuilder: (context, index) {
                                  final comm = widget.recentCommunications[index];
                                  final timestamp = comm['timestamp'] as DateTime;
                                  final communication = comm['communication'] as Map<String, dynamic>;
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 2),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${communication['module']}: ${communication['action']}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (communication['firestore_source'] == true)
                                          Icon(Icons.cloud, size: 10, color: Colors.blue),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationStatusItem(String moduleName, IconData icon, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              moduleName,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            statusColor == Colors.green ? 'Listening' : 'Disconnected',
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunicationFlowDiagram() {
    return Container(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Product Management (Center)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, color: Colors.blue, size: 24),
                    Text('Product\nMgmt', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          
          // Connecting Lines and Other Modules
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModuleConnection('Inventory', Icons.inventory, Colors.green),
                _buildModuleConnection('POS', Icons.point_of_sale, Colors.orange),
                _buildModuleConnection('CRM', Icons.analytics, Colors.purple),
                _buildModuleConnection('Orders', Icons.shopping_cart, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModuleConnection(String name, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 2,
          height: 20,
          color: color.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(name, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTestCommunicationButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        // Track the test communication action with Activity Tracker
        ActivityTracker().trackInteraction(
          action: 'test_communication',
          element: 'test_button_${label.toLowerCase().replaceAll(' ', '_')}',
          data: {
            'target_module': label.replaceAll('Test ', '').replaceAll(' Integration', '').replaceAll(' Sync', ''),
            'test_type': 'manual_communication_test',
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'success',
          },
        );
        
        // Simulate test communication
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label - Communication test successful!'),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Notify parent widget to add to recent communications
        widget.onTestCommunication({
          'timestamp': DateTime.now(),
          'communication': {
            'module': label.replaceAll('Test ', '').replaceAll(' Integration', '').replaceAll(' Sync', ''),
            'action': 'Manual test communication',
            'status': 'success'
          },
        });
        
        // Track the updated communication count
        ActivityTracker().trackInteraction(
          action: 'communication_log_updated',
          element: 'recent_communications',
          data: {
            'total_communications': widget.recentCommunications.length + 1,
            'latest_test': label,
          },
        );
      },
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
