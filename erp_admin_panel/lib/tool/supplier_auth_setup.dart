// Script to set up Firebase Auth accounts for existing suppliers
// This creates Firebase Auth users for suppliers who only exist in Firestore

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierAuthSetupWidget extends StatefulWidget {
  const SupplierAuthSetupWidget({Key? key}) : super(key: key);

  @override
  State<SupplierAuthSetupWidget> createState() => _SupplierAuthSetupWidgetState();
}

class _SupplierAuthSetupWidgetState extends State<SupplierAuthSetupWidget> {
  bool _isLoading = false;
  bool _isExpanded = false;
  String _status = '';
  final List<String> _logs = [];

  void _log(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      _status = message;
    });
    print(message);
  }

  Future<void> _setupSupplierAuthAccounts() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _log('🔥 Starting supplier Firebase Auth setup...');

      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;

      // Get all suppliers from Firestore
      final suppliersSnapshot = await firestore.collection('suppliers').get();
      _log('📋 Found ${suppliersSnapshot.docs.length} suppliers in Firestore');

      int created = 0;
      int existing = 0;
      int errors = 0;

      for (final doc in suppliersSnapshot.docs) {
        final supplierData = doc.data();
        final email = supplierData['email'] as String?;
        final supplierName = supplierData['supplier_name'] as String?;

        if (email == null || supplierName == null) {
          _log('⚠️ Skipping supplier ${doc.id} - missing email or name');
          errors++;
          continue;
        }

        try {
          // Check if user already exists
          final methods = await auth.fetchSignInMethodsForEmail(email);
          if (methods.isNotEmpty) {
            _log('✅ Auth user already exists for $email');
            existing++;
            continue;
          }

          // Create Firebase Auth user
          final userCredential = await auth.createUserWithEmailAndPassword(
            email: email,
            password: 'password', // Default password for demo
          );

          if (userCredential.user != null) {
            // Update the user's display name
            await userCredential.user!.updateDisplayName(supplierName);
            _log('✅ Created auth user for $email ($supplierName)');
            created++;
          }

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));

        } catch (e) {
          _log('❌ Error creating auth user for $email: $e');
          errors++;
        }
      }

      _log('🎉 Supplier auth setup completed!');
      _log('📊 Summary: $created created, $existing existing, $errors errors');

    } catch (e) {
      _log('❌ Setup failed: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _createSamplePurchaseOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _log('📋 Creating sample purchase orders...');

      final firestore = FirebaseFirestore.instance;

      // Get suppliers for PO assignment
      final suppliersSnapshot = await firestore.collection('suppliers').limit(5).get();
      final suppliers = suppliersSnapshot.docs;

      if (suppliers.isEmpty) {
        _log('❌ No suppliers found to create purchase orders');
        return;
      }

      // Get products for PO items
      final productsSnapshot = await firestore.collection('products').limit(10).get();
      final products = productsSnapshot.docs;

      if (products.isEmpty) {
        _log('❌ No products found to create purchase orders');
        return;
      }

      int ordersCreated = 0;

      for (int i = 1; i <= 10; i++) {
        final supplier = suppliers[(i - 1) % suppliers.length].data();
        final orderId = 'PO-${DateTime.now().millisecondsSinceEpoch}-$i';

        // Select 2-4 random products for this order
        final orderProducts = (products..shuffle()).take(2 + (i % 3)).toList();
        
        final List<Map<String, dynamic>> items = [];
        double totalAmount = 0;

        for (final productDoc in orderProducts) {
          final product = productDoc.data();
          final quantity = 10 + (i * 5); // Varying quantities
          final unitPrice = (product['price'] as num?)?.toDouble() ?? 100.0;
          final lineTotal = quantity * unitPrice;
          
          items.add({
            'product_id': product['product_id'],
            'product_name': product['product_name'],
            'quantity': quantity,
            'unit_price': unitPrice,
            'total_price': lineTotal,
            'unit': 'pcs',
          });
          
          totalAmount += lineTotal;
        }

        final purchaseOrder = {
          'order_id': orderId,
          'order_number': 'PO${i.toString().padLeft(4, '0')}',
          'supplier_id': supplier['supplier_id'],
          'supplier_name': supplier['supplier_name'],
          'order_date': Timestamp.now(),
          'expected_delivery_date': Timestamp.fromDate(
            DateTime.now().add(Duration(days: 7 + (i * 2))),
          ),
          'status': ['pending', 'confirmed', 'processing'][i % 3],
          'items': items,
          'total_amount': totalAmount,
          'currency': 'INR',
          'payment_terms': 'Net 30',
          'shipping_address': {
            'line1': 'Company Warehouse',
            'city': 'Mumbai',
            'state': 'Maharashtra',
            'postal_code': '400001',
            'country': 'India',
          },
          'notes': 'Sample purchase order $i for testing',
          'created_by': 'admin@company.com',
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
          'status_history': [
            {
              'status': ['pending', 'confirmed', 'processing'][i % 3],
              'timestamp': Timestamp.now(),
              'remarks': 'Order created',
              'updated_by': 'system',
            }
          ],
        };

        await firestore.collection('purchase_orders').doc(orderId).set(purchaseOrder);
        ordersCreated++;
        _log('✅ Created PO: ${purchaseOrder['order_number']} for ${supplier['supplier_name']}');
      }

      _log('🎉 Created $ordersCreated sample purchase orders!');

    } catch (e) {
      _log('❌ Error creating purchase orders: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.factory, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Supplier Portal Setup',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  tooltip: _isExpanded ? 'Collapse' : 'Expand',
                  iconSize: 20,
                ),
              ],
            ),
            
            if (!_isExpanded && !_isLoading) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _setupSupplierAuthAccounts,
                      icon: const Icon(Icons.account_circle, size: 16),
                      label: const Text('Auth', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _createSamplePurchaseOrders,
                      icon: const Icon(Icons.assignment, size: 16),
                      label: const Text('POs', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              const Text(
                'Set up Firebase Auth accounts for existing suppliers and create sample purchase orders.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _setupSupplierAuthAccounts,
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Setup Supplier Auth'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createSamplePurchaseOrders,
                      icon: const Icon(Icons.assignment),
                      label: const Text('Create Sample POs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(_status, style: const TextStyle(fontSize: 12)),
            ],
            
            if (_isExpanded && _logs.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Setup Log:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Text(
                      log,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: log.contains('❌') ? Colors.red :
                               log.contains('✅') ? Colors.green :
                               log.contains('⚠️') ? Colors.orange :
                               Colors.black87,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
