// Comprehensive mock data script with proper stock levels
// This will clear all existing data and create complete test data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('🚀 Starting comprehensive mock data creation...');
  final firestore = FirebaseFirestore.instance;
  final uuid = Uuid();
  final random = Random();

  // --- STEP 1: Clear ALL existing data ---
  print('🧹 Clearing existing data...');
  final collections = [
    'products', 
    'inventory', 
    'suppliers', 
    'purchase_orders', 
    'orders', 
    'customers',
    'customer_profiles',
    'customer_orders',
    'pos_invoices',
    'transactions'
  ];

  for (final collectionName in collections) {
    try {
      final snapshot = await firestore.collection(collectionName).get();
      print('📦 Clearing ${snapshot.docs.length} documents from $collectionName');
      
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('⚠️ Error clearing $collectionName: $e');
    }
  }
  print('✅ All collections cleared!');

  // --- STEP 2: Create Categories and Basic Data ---
  final categories = ['Dairy', 'Snacks', 'Beverages', 'Fruits', 'Vegetables'];
  final brands = ['Fresh Choice', 'Premium', 'Daily Essentials', 'Organic Plus', 'Value Pack'];
  final units = ['1L', '500ml', '1kg', '500g', '250g', 'piece', 'dozen'];

  // --- STEP 3: Create Products with Guaranteed Stock ---
  print('🏭 Creating products...');
  final List<Map<String, dynamic>> products = [];
  
  // Create 50 products across categories
  for (int i = 1; i <= 50; i++) {
    final category = categories[(i - 1) % categories.length];
    final brand = brands[(i - 1) % brands.length];
    final unit = units[(i - 1) % units.length];
    final productId = 'PROD-${i.toString().padLeft(3, '0')}';
    
    final product = {
      'product_id': productId,
      'product_name': '$category Item $i',
      'category': category,
      'brand': brand,
      'unit': unit,
      'description': 'High quality $category product from $brand',
      'sku': 'SKU-${category.substring(0, 3).toUpperCase()}-$i',
      'barcode': '${8901030800000 + i}',
      'hsn_code': '${1000 + i}',
      'mrp': (50 + i * 2).toDouble(),
      'cost_price': (30 + i * 1.5).toDouble(),
      'selling_price': (40 + i * 1.8).toDouble(),
      'current_stock': 500, // High stock for testing
      'min_stock_level': 10,
      'max_stock_level': 1000,
      'tax_percent': 5.0,
      'product_status': 'Active',
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    };
    
    products.add(product);
    await firestore.collection('products').doc(productId).set(product);
  }
  print('✅ Created ${products.length} products with high stock!');

  // --- STEP 4: Create Inventory Records ---
  print('📦 Creating inventory records...');
  final locations = ['Main Store', 'Warehouse A', 'Warehouse B'];
  
  for (final product in products) {
    for (final location in locations) {
      final inventoryId = uuid.v4();
      final currentStock = 200 + random.nextInt(300); // 200-500 stock
      final inventory = {
        'inventory_id': inventoryId,
        'product_id': product['product_id'],
        'store_id': 'STORE-${locations.indexOf(location) + 1}',
        'location': location,
        'current_stock': currentStock,
        'reserved_stock': 0,
        'available_stock': currentStock, // Same as current stock initially
        'min_stock_level': 20,
        'max_stock_level': 1000,
        'cost_price': product['cost_price'],
        'status': 'active',
        'last_updated': Timestamp.now(),
        'batch_number': 'BATCH${random.nextInt(1000)}',
        'expiry_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 180))),
        'last_updated_by': 'admin',
      };
      
      await firestore.collection('inventory').add(inventory);
    }
  }
  print('✅ Created inventory records for all products!');

  // --- STEP 5: Create Test Customers ---
  print('👥 Creating test customers...');
  
  // Create the main test customer
  final mainCustomer = {
    'customer_id': 'CUST914961496',
    'customer_name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+91 9876543210',
    'address': '123 Demo Street, Demo Colony',
    'city': 'Mumbai',
    'state': 'Maharashtra',
    'pincode': '400001',
    'customer_type': 'regular',
    'customer_status': 'active',
    'loyalty_points': 100,
    'wallet_balance': 0.0,
    'credit_limit': 0.0,
    'date_of_birth': Timestamp.fromDate(DateTime(1990, 5, 15)),
    'gender': 'other',
    'preferences': {
      'notifications': true,
      'email_marketing': true,
      'sms_marketing': true,
      'created_via': 'customer_app'
    },
    'preferred_categories': [],
    'alt_phone': null,
    'gst_number': null,
    'company_name': null,
    'created_at': Timestamp.now(),
    'updated_at': Timestamp.now(),
  };
  
  await firestore.collection('customers').doc('CUST914961496').set(mainCustomer);
  
  // Create additional test customers
  final testCustomers = [
    {
      'email': 'john.doe@email.com',
      'customer_name': 'John Doe',
      'customer_id': 'CUST-001',
    },
    {
      'email': 'jane.smith@email.com', 
      'customer_name': 'Jane Smith',
      'customer_id': 'CUST-002',
    },
    {
      'email': 'test@example.com',
      'customer_name': 'Test User',
      'customer_id': 'CUST-003',
    }
  ];
  
  for (final customer in testCustomers) {
    final customerData = {
      'customer_id': customer['customer_id'],
      'customer_name': customer['customer_name'],
      'email': customer['email'],
      'phone': '+91 9876543210',
      'address': '123 Test Street',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pincode': '400001',
      'customer_type': 'regular',
      'customer_status': 'active',
      'loyalty_points': 50,
      'wallet_balance': 0.0,
      'credit_limit': 0.0,
      'date_of_birth': Timestamp.fromDate(DateTime(1990, 1, 1)),
      'gender': 'other',
      'preferences': {
        'notifications': true,
        'email_marketing': true,
        'sms_marketing': true,
        'created_via': 'customer_app'
      },
      'preferred_categories': [],
      'alt_phone': null,
      'gst_number': null,
      'company_name': null,
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    };
    
    await firestore.collection('customers').doc(customer['customer_id']).set(customerData);
  }
  print('✅ Created test customers!');

  // --- STEP 6: Create Suppliers ---
  print('🏪 Creating suppliers...');
  for (int i = 1; i <= 10; i++) {
    final category = categories[(i - 1) % categories.length];
    final supplierId = 'SUPP-${i.toString().padLeft(3, '0')}';
    
    final supplier = {
      'supplier_id': supplierId,
      'supplier_code': 'SUP${i.toString().padLeft(3, '0')}',
      'supplier_name': '$category Supplier $i Pvt Ltd',
      'contact_person_name': 'Manager $i',
      'contact_person_mobile': '9000000${i.toString().padLeft(3, '0')}',
      'email': 'supplier$i@email.com',
      'address_line1': 'Supplier Address $i',
      'city': 'Supplier City $i',
      'state': 'Supplier State $i',
      'postal_code': '500${i.toString().padLeft(3, '0')}',
      'country': 'India',
      'gstin': 'GSTIN${i.toString().padLeft(10, '0')}',
      'supplier_type': category,
      'payment_terms': 'Net 30',
      'credit_limit': 500000,
      'status': 'Active',
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    };
    
    await firestore.collection('suppliers').doc(supplierId).set(supplier);
  }
  print('✅ Created suppliers!');

  // --- STEP 7: Create Sample Orders ---
  print('📋 Creating sample orders...');
  for (int i = 1; i <= 5; i++) {
    final orderId = 'ORD-${i.toString().padLeft(6, '0')}';
    final customerId = i == 1 ? 'CUST914961496' : 'CUST-00$i';
    
    // Select random products for the order
    final orderItems = [];
    final selectedProducts = products.take(3).toList();
    
    double totalAmount = 0;
    for (final product in selectedProducts) {
      final quantity = 1 + random.nextInt(3);
      final itemTotal = product['selling_price'] * quantity;
      totalAmount += itemTotal;
      
      orderItems.add({
        'product_id': product['product_id'],
        'product_name': product['product_name'],
        'quantity': quantity,
        'unit_price': product['selling_price'],
        'total_price': itemTotal,
      });
    }
    
    final order = {
      'order_id': orderId,
      'customer_id': customerId,
      'order_date': Timestamp.now(),
      'order_status': 'completed',
      'total_amount': totalAmount,
      'tax_amount': totalAmount * 0.05,
      'discount_amount': 0.0,
      'final_amount': totalAmount * 1.05,
      'payment_method': 'cash',
      'payment_status': 'paid',
      'items': orderItems,
      'delivery_address': '123 Test Street, Mumbai',
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    };
    
    await firestore.collection('orders').doc(orderId).set(order);
    await firestore.collection('customer_orders').doc(orderId).set(order);
  }
  print('✅ Created sample orders!');

  print('🎉 Mock data creation completed successfully!');
  print('📊 Summary:');
  print('   - ${products.length} products with high stock (500+ each)');
  print('   - ${products.length * locations.length} inventory records');
  print('   - 4 test customers including main test customer');
  print('   - 10 suppliers');
  print('   - 5 sample orders');
  print('');
  print('🧪 Test Credentials:');
  print('   Email: john@example.com');
  print('   Also: john.doe@email.com');
  print('   Also: jane.smith@email.com');
  print('   Password: password123');
  print('');
  print('✅ Ready for end-to-end testing!');
}
