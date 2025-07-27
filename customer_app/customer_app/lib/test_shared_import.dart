// Test file to verify shared package imports work correctly
import 'package:shared_erp_package/test_exports.dart';

void testSharedPackage() {
  // Test model creation
  final product = Product(
    id: 'test',
    name: 'Test Product',
    description: 'Test Description',
    category: 'Test Category',
    price: 10.0,
    stockQuantity: 5,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final _ = CartItem(
    productId: product.id,
    productName: product.name,
    price: product.price,
  );

  final customer = Customer(
    id: 'test-customer',
    name: 'Test Customer',
    email: 'test@example.com',
    phone: '1234567890',
    createdAt: DateTime.now(),
  );

  final testOrder = Order(
    id: 'test-order',
    customerId: customer.id,
    customerName: customer.name,
    items: [],
    total: 100.0,
    status: OrderStatus.pending,
    createdAt: DateTime.now(),
    shippingAddress: 'Test Address',
  );

  // Test service creation
  final firestoreService = FirestoreService();
  
  // Test what methods are available
  firestoreService.getDocument('test', 'doc');
  firestoreService.updateDocument('test', 'doc', {});
  firestoreService.deleteDocument('test', 'doc');
  firestoreService.createDoc('test', 'doc', {});

  print('All FirestoreService methods including createDoc are accessible');
  print('✅ Order: ${testOrder.id} - ${testOrder.status.name}');
}
