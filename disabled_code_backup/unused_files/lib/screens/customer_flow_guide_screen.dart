// Customer-Centric Flow Demo Guide
// Explains the new customer-centric order flow and how to test it

import 'package:flutter/material.dart';

class CustomerFlowGuideScreen extends StatelessWidget {
  const CustomerFlowGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer-Centric Flow Guide'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildOldVsNewFlow(),
            const SizedBox(height: 24),
            _buildTestingSteps(),
            const SizedBox(height: 24),
            _buildFeatures(),
            const SizedBox(height: 24),
            _buildTechnicalDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade700, size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '🎯 Customer-Centric ERP Flow',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'A complete transformation of the ERP system to be customer-driven, where customer orders automatically trigger downstream processes including POS invoice generation and inventory updates.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOldVsNewFlow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔄 Flow Transformation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Old Flow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.close, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'OLD FLOW (POS-Centric)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Staff creates POS transaction manually'),
                  const Text('2. Customer order gets created from POS'),
                  const Text('3. CRM gets updated after transaction'),
                  const Text('4. Inventory updated manually'),
                  const SizedBox(height: 8),
                  Text(
                    '❌ Problems: Manual process, disconnected modules, no customer app',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // New Flow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'NEW FLOW (Customer-Centric)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Customer signs up in CRM (gets unique ID)'),
                  const Text('2. Customer places order via app'),
                  const Text('3. System auto-generates POS invoice'),
                  const Text('4. Inventory automatically updated'),
                  const Text('5. Loyalty points awarded automatically'),
                  const SizedBox(height: 8),
                  Text(
                    '✅ Benefits: Automated, event-driven, customer-first, real-time sync',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestingSteps() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 How to Test the New Flow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildTestStep(
              '1',
              'Setup Demo Data',
              'Click "Setup Demo Customer" button on the main screen to create demo customer account and sample products.',
              Colors.blue,
            ),
            
            _buildTestStep(
              '2',
              'Access Customer App',
              'Click "Customer App" from the dashboard or main menu to open the customer interface.',
              Colors.orange,
            ),
            
            _buildTestStep(
              '3',
              'Sign In as Demo Customer',
              'Use credentials: email "john@example.com", password "password123" or click "Demo Sign In".',
              Colors.purple,
            ),
            
            _buildTestStep(
              '4',
              'Browse & Add Products',
              'Go to Products tab, browse available items, and add them to your cart.',
              Colors.teal,
            ),
            
            _buildTestStep(
              '5',
              'Place Order',
              'Go to Cart tab and click "Place Order". Watch the magic happen!',
              Colors.green,
            ),
            
            _buildTestStep(
              '6',
              'Verify Automation',
              'Check POS module for auto-generated invoice, inventory for stock updates, and customer profile for loyalty points.',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestStep(String step, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ Key Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildFeature(
              Icons.account_circle,
              'Customer Authentication',
              'Secure signup/signin with Firebase Auth and automatic CRM entry with unique customer ID.',
            ),
            
            _buildFeature(
              Icons.shopping_cart,
              'Customer Order Placement',
              'Intuitive mobile-first interface for browsing products and placing orders.',
            ),
            
            _buildFeature(
              Icons.receipt_long,
              'Auto POS Invoice Generation',
              'Orders automatically trigger POS invoice creation without manual intervention.',
            ),
            
            _buildFeature(
              Icons.inventory,
              'Real-time Inventory Management',
              'Stock reservation during order, automatic updates after POS transaction.',
            ),
            
            _buildFeature(
              Icons.stars,
              'Automatic Loyalty System',
              'Points awarded automatically based on purchase amount with tier progression.',
            ),
            
            _buildFeature(
              Icons.analytics,
              'Event-Driven Architecture',
              'All modules communicate through events for loose coupling and scalability.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ Technical Implementation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Services Involved:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Text('• CustomerAuthService - Handles customer signup/signin with Firebase Auth'),
            Text('• EnhancedCustomerOrdersService - Manages order placement and auto-POS generation'),
            Text('• EnhancedPosService - Creates POS transactions and updates inventory'),
            Text('• EnhancedInventoryService - Handles stock reservation and updates'),
            Text('• CustomerProfileService - Manages CRM data and loyalty points'),
            
            const SizedBox(height: 16),
            
            const Text(
              'Data Flow:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Text('1. Customer → CRM (signup creates unique ID)'),
            Text('2. Customer Order → Inventory (stock validation & reservation)'),
            Text('3. Customer Order → POS (auto-invoice generation)'),
            Text('4. POS → Inventory (final stock update)'),
            Text('5. POS → CRM (loyalty points update)'),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Future Enhancements',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Real-time order tracking for customers'),
                  const Text('• Push notifications for order status updates'),
                  const Text('• Supplier-centric flow for vendor management'),
                  const Text('• Advanced analytics and AI-powered recommendations'),
                  const Text('• Multi-store and multi-location support'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
