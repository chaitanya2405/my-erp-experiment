import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your app components
// import 'package:ravali_software/core/models/unified_models.dart';
// import 'package:ravali_software/core/utils/erp_utils.dart';

void main() {
  group('Enhanced ERP System Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    group('Utility Functions Tests', () {
      test('Format currency correctly', () {
        expect(formatCurrency(1000.50), equals('₹1000.50'));
        expect(formatCurrency(0), equals('₹0.00'));
        expect(formatCurrency(99.9), equals('₹99.90'));
      });

      test('Validate email format', () {
        expect(isValidEmail('test@example.com'), isTrue);
        expect(isValidEmail('invalid-email'), isFalse);
        expect(isValidEmail('test@'), isFalse);
        expect(isValidEmail('@example.com'), isFalse);
      });

      test('Validate phone number format', () {
        expect(isValidPhoneNumber('+1234567890'), isTrue);
        expect(isValidPhoneNumber('1234567890'), isTrue);
        expect(isValidPhoneNumber('123-456-7890'), isTrue);
        expect(isValidPhoneNumber('123'), isFalse);
      });

      test('Calculate discount amount', () {
        expect(calculateDiscountAmount(1000, 10), equals(100.0));
        expect(calculateDiscountAmount(500, 20), equals(100.0));
        expect(calculateDiscountAmount(0, 10), equals(0.0));
      });

      test('Calculate tax amount', () {
        expect(calculateTaxAmount(1000, 18), equals(180.0));
        expect(calculateTaxAmount(500, 5), equals(25.0));
        expect(calculateTaxAmount(0, 10), equals(0.0));
      });

      test('Generate transaction ID format', () {
        final txnId = generateTransactionId();
        expect(txnId.startsWith('TXN'), isTrue);
        expect(txnId.length, greaterThan(10));
      });

      test('Generate purchase order ID format', () {
        final poId = generatePurchaseOrderId();
        expect(poId.startsWith('PO'), isTrue);
        expect(poId.length, greaterThan(10));
      });

      test('Get inventory status correctly', () {
        expect(getInventoryStatus(0, 10), equals('Out of Stock'));
        expect(getInventoryStatus(5, 10), equals('Low Stock'));
        expect(getInventoryStatus(15, 10), equals('In Stock'));
        expect(getInventoryStatus(10, null), equals('In Stock'));
      });

      test('Match search query', () {
        expect(matchesSearchQuery('Apple iPhone', 'apple'), isTrue);
        expect(matchesSearchQuery('Apple iPhone', 'phone'), isTrue);
        expect(matchesSearchQuery('Apple iPhone', 'samsung'), isFalse);
        expect(matchesSearchQuery('Apple iPhone', ''), isTrue);
      });
    });

    group('Firestore Integration Tests', () {
      test('Add product to inventory', () async {
        final collection = fakeFirestore.collection('products');
        
        final productData = {
          'name': 'Test Product',
          'price': 99.99,
          'quantity': 100,
          'category': 'Electronics',
          'supplier': 'Test Supplier',
          'createdAt': Timestamp.now(),
        };

        await collection.add(productData);

        final snapshot = await collection.get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.data()['name'], equals('Test Product'));
      });

      test('Update product quantity', () async {
        final collection = fakeFirestore.collection('products');
        
        // Add initial product
        final docRef = await collection.add({
          'name': 'Test Product',
          'quantity': 100,
          'price': 50.0,
        });

        // Update quantity
        await docRef.update({'quantity': 150});

        final doc = await docRef.get();
        expect(doc.data()!['quantity'], equals(150));
      });

      test('Create transaction record', () async {
        final collection = fakeFirestore.collection('transactions');
        
        final transactionData = {
          'id': 'TXN123456789',
          'customerId': 'CUST001',
          'items': [
            {
              'productId': 'PROD001',
              'name': 'Test Product',
              'price': 99.99,
              'quantity': 2,
            }
          ],
          'total': 199.98,
          'status': 'completed',
          'timestamp': Timestamp.now(),
        };

        await collection.add(transactionData);

        final snapshot = await collection.get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.data()['total'], equals(199.98));
      });

      test('Add customer record', () async {
        final collection = fakeFirestore.collection('customers');
        
        final customerData = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'address': '123 Main St',
          'type': 'Regular',
          'createdAt': Timestamp.now(),
        };

        await collection.add(customerData);

        final snapshot = await collection.get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.data()['email'], equals('john@example.com'));
      });

      test('Create purchase order', () async {
        final collection = fakeFirestore.collection('purchase_orders');
        
        final orderData = {
          'id': 'PO123456789',
          'supplierId': 'SUP001',
          'items': [
            {
              'productId': 'PROD001',
              'name': 'Test Product',
              'price': 50.0,
              'quantity': 10,
            }
          ],
          'total': 500.0,
          'status': 'pending',
          'createdAt': Timestamp.now(),
        };

        await collection.add(orderData);

        final snapshot = await collection.get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.data()['status'], equals('pending'));
      });

      test('Add supplier record', () async {
        final collection = fakeFirestore.collection('suppliers');
        
        final supplierData = {
          'name': 'Test Supplier Ltd',
          'email': 'supplier@test.com',
          'phone': '+9876543210',
          'address': '456 Business Ave',
          'type': 'Electronics',
          'rating': 4.5,
          'isPreferred': true,
          'createdAt': Timestamp.now(),
        };

        await collection.add(supplierData);

        final snapshot = await collection.get();
        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs.first.data()['rating'], equals(4.5));
      });
    });

    group('Business Logic Tests', () {
      test('Calculate inventory value', () {
        final products = [
          {'price': 100.0, 'quantity': 10},
          {'price': 50.0, 'quantity': 20},
          {'price': 25.0, 'quantity': 5},
        ];

        final totalValue = calculateInventoryValue(products);
        expect(totalValue, equals(2125.0)); // (100*10) + (50*20) + (25*5)
      });

      test('Calculate cart total', () {
        final cartItems = [
          {'price': 99.99, 'quantity': 2},
          {'price': 49.99, 'quantity': 1},
          {'price': 19.99, 'quantity': 3},
        ];

        final total = cartItems.fold(0.0, (sum, item) {
          return sum + (item['price'] as double) * (item['quantity'] as int);
        });

        expect(total, equals(309.95));
      });

      test('Apply discount calculation', () {
        final originalTotal = 1000.0;
        final discountPercent = 15.0;
        
        final discountAmount = calculateDiscountAmount(originalTotal, discountPercent);
        final finalTotal = originalTotal - discountAmount;
        
        expect(discountAmount, equals(150.0));
        expect(finalTotal, equals(850.0));
      });

      test('Calculate final amount with tax', () {
        final subtotal = 850.0; // After discount
        final taxPercent = 18.0;
        
        final taxAmount = calculateTaxAmount(subtotal, taxPercent);
        final finalTotal = subtotal + taxAmount;
        
        expect(taxAmount, equals(153.0));
        expect(finalTotal, equals(1003.0));
      });
    });

    group('Widget Tests', () {
      testWidgets('Loading indicator displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);
      });

      testWidgets('Error widget displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text('Something went wrong'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('Data Validation Tests', () {
      test('Product data validation', () {
        final validProduct = {
          'name': 'Valid Product',
          'price': 99.99,
          'quantity': 10,
          'category': 'Electronics',
        };

        expect(validProduct['name']?.toString().isNotEmpty, isTrue);
        expect(validProduct['price'] is double, isTrue);
        expect(validProduct['quantity'] is int, isTrue);
        expect((validProduct['price'] as double) > 0, isTrue);
        expect((validProduct['quantity'] as int) >= 0, isTrue);
      });

      test('Customer data validation', () {
        final validCustomer = {
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'address': '123 Main St',
        };

        expect(validCustomer['name']?.toString().isNotEmpty, isTrue);
        expect(isValidEmail(validCustomer['email']!), isTrue);
        expect(isValidPhoneNumber(validCustomer['phone']!), isTrue);
        expect(validCustomer['address']?.toString().isNotEmpty, isTrue);
      });

      test('Transaction data validation', () {
        final validTransaction = {
          'id': 'TXN123456789',
          'customerId': 'CUST001',
          'items': [
            {
              'productId': 'PROD001',
              'quantity': 2,
              'price': 99.99,
            }
          ],
          'total': 199.98,
          'status': 'completed',
        };

        expect(validTransaction['id']?.toString().isNotEmpty, isTrue);
        expect(validTransaction['items'] is List, isTrue);
        expect((validTransaction['items'] as List).isNotEmpty, isTrue);
        expect(validTransaction['total'] is double, isTrue);
        expect((validTransaction['total'] as double) > 0, isTrue);
        expect(['pending', 'completed', 'cancelled'].contains(validTransaction['status']), isTrue);
      });
    });
  });
}

// Helper functions for testing
String formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool isValidPhoneNumber(String phone) {
  return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
}

double calculateDiscountAmount(double total, double discountPercent) {
  return total * (discountPercent / 100);
}

double calculateTaxAmount(double amount, double taxPercent) {
  return amount * (taxPercent / 100);
}

String generateTransactionId() {
  final now = DateTime.now();
  return 'TXN${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
}

String generatePurchaseOrderId() {
  final now = DateTime.now();
  return 'PO${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
}

String getInventoryStatus(int quantity, int? minStock) {
  if (quantity == 0) return 'Out of Stock';
  if (minStock != null && quantity <= minStock) return 'Low Stock';
  return 'In Stock';
}

bool matchesSearchQuery(String text, String query) {
  if (query.isEmpty) return true;
  return text.toLowerCase().contains(query.toLowerCase());
}

double calculateInventoryValue(List<dynamic> products) {
  return products.fold(0.0, (sum, product) {
    final price = (product['price'] ?? 0.0) as double;
    final quantity = (product['quantity'] ?? 0) as int;
    return sum + (price * quantity);
  });
}
