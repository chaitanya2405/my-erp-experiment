import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../firebase_options.dart';

/// 🎯 UNIFIED ERP MOCK DATA GENERATOR
/// Creates interconnected data for all modules with store-specific availability
/// Unified pricing across all stores with store-specific inventory
class UnifiedERPMockDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Uuid _uuid = Uuid();
  static final Random _random = Random();

  /// 🚀 Generate complete unified ERP data
  static Future<void> generateUnifiedMockData() async {
    print('🎯 Starting Unified ERP Mock Data Generation...');
    print('═══════════════════════════════════════════════════');
    
    try {
      // Step 1: Clear existing data
      await _clearAllData();
      
      // Step 2: Generate stores (6 stores)
      final stores = await _generateStores();
      
      // Step 3: Generate suppliers (20 suppliers with store assignments)
      final suppliers = await _generateSuppliers(stores);
      
      // Step 4: Generate products (100 products with unified pricing)
      final products = await _generateProducts(suppliers);
      
      // Step 5: Generate store-specific inventory
      await _generateStoreInventory(stores, products, suppliers);
      
      // Step 6: Generate purchase orders (store-specific)
      await _generatePurchaseOrders(stores, suppliers, products);
      
      // Step 7: Generate customers with store preferences
      final customers = await _generateCustomers(stores);
      
      // Step 8: Generate customer orders (store-assigned)
      await _generateCustomerOrders(stores, customers, products);
      
      // Step 9: Generate POS transactions (store-specific)
      await _generatePOSTransactions(stores, products, customers);
      
      // Step 10: Generate store performance data
      await _generateStorePerformance(stores);
      
      print('🎉 Unified ERP Mock Data Generation Completed!');
      print('═══════════════════════════════════════════════════');
      _printSummary();
      
    } catch (e) {
      print('❌ Error generating unified mock data: $e');
    }
  }

  /// 🗑️ Clear all existing data
  static Future<void> _clearAllData() async {
    print('🧹 Clearing existing data...');
    
    final collections = [
      'stores', 'products', 'inventory', 'suppliers', 'purchase_orders',
      'customer_orders', 'customers', 'pos_transactions', 'store_performance',
      'store_transfers', 'orders', 'customer_profiles'
    ];
    
    for (final collection in collections) {
      try {
        final snapshot = await _firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        print('  ✅ Cleared $collection (${snapshot.docs.length} docs)');
      } catch (e) {
        print('  ⚠️ Error clearing $collection: $e');
      }
    }
  }

  /// 🏪 Generate 6 stores
  static Future<List<Map<String, dynamic>>> _generateStores() async {
    print('🏪 Generating 6 stores...');
    
    final stores = [
      {
        'store_id': 'store_001',
        'store_code': 'HYD001',
        'store_name': 'Ravali SuperMart - Hyderabad Central',
        'store_type': 'Retail',
        'contact_person': 'Rajesh Kumar',
        'contact_number': '+91-9876543210',
        'email': 'hyderabad@ravali.com',
        'address_line1': 'Plot No. 123, Banjara Hills Road',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'postal_code': '500034',
        'country': 'India',
        'store_status': 'Active',
        'is_operational': true,
        'store_area_sqft': 2500.0,
        'monthly_target': 500000.0,
        'created_at': Timestamp.now(),
      },
      {
        'store_id': 'store_002',
        'store_code': 'BLR001',
        'store_name': 'Ravali Express - Bangalore MG Road',
        'store_type': 'Retail',
        'contact_person': 'Priya Sharma',
        'contact_number': '+91-9876543211',
        'email': 'bangalore@ravali.com',
        'address_line1': '45, MG Road',
        'city': 'Bangalore',
        'state': 'Karnataka',
        'postal_code': '560001',
        'country': 'India',
        'store_status': 'Active',
        'is_operational': true,
        'store_area_sqft': 1800.0,
        'monthly_target': 400000.0,
        'created_at': Timestamp.now(),
      },
      {
        'store_id': 'store_003',
        'store_code': 'WH001',
        'store_name': 'Ravali Distribution Center - Gurgaon',
        'store_type': 'Warehouse',
        'contact_person': 'Amit Singh',
        'contact_number': '+91-9876543212',
        'email': 'warehouse@ravali.com',
        'address_line1': 'Sector 18, Industrial Area',
        'city': 'Gurgaon',
        'state': 'Haryana',
        'postal_code': '122001',
        'country': 'India',
        'store_status': 'Active',
        'is_operational': true,
        'store_area_sqft': 15000.0,
        'monthly_target': 0.0, // Warehouse, no direct sales
        'created_at': Timestamp.now(),
      },
      {
        'store_id': 'store_004',
        'store_code': 'VJA001',
        'store_name': 'Ravali Local - Vijayawada',
        'store_type': 'Retail',
        'contact_person': 'Lakshmi Devi',
        'contact_number': '+91-9876543213',
        'email': 'vijayawada@ravali.com',
        'address_line1': 'MG Road, Labbipet',
        'city': 'Vijayawada',
        'state': 'Andhra Pradesh',
        'postal_code': '520010',
        'country': 'India',
        'store_status': 'Active',
        'is_operational': true,
        'store_area_sqft': 1200.0,
        'monthly_target': 250000.0,
        'created_at': Timestamp.now(),
      },
      {
        'store_id': 'store_005',
        'store_code': 'CHN001',
        'store_name': 'Ravali Mega - Chennai T. Nagar',
        'store_type': 'Retail',
        'contact_person': 'Suresh Babu',
        'contact_number': '+91-9876543214',
        'email': 'chennai@ravali.com',
        'address_line1': 'T. Nagar Main Road',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'postal_code': '600017',
        'country': 'India',
        'store_status': 'Under Renovation',
        'is_operational': false,
        'store_area_sqft': 3000.0,
        'monthly_target': 600000.0,
        'created_at': Timestamp.now(),
      },
      {
        'store_id': 'store_006',
        'store_code': 'PUN001',
        'store_name': 'Ravali Quick - Pune Kothrud',
        'store_type': 'Retail',
        'contact_person': 'Anil Patil',
        'contact_number': '+91-9876543215',
        'email': 'pune@ravali.com',
        'address_line1': 'Kothrud Main Road',
        'city': 'Pune',
        'state': 'Maharashtra',
        'postal_code': '411038',
        'country': 'India',
        'store_status': 'Active',
        'is_operational': true,
        'store_area_sqft': 1600.0,
        'monthly_target': 350000.0,
        'created_at': Timestamp.now(),
      },
    ];

    for (final store in stores) {
      await _firestore.collection('stores').doc(store['store_id'] as String).set(store);
    }

    print('  ✅ Generated ${stores.length} stores');
    return stores;
  }

  /// 🏭 Generate 20 suppliers with store assignments
  static Future<List<Map<String, dynamic>>> _generateSuppliers(List<Map<String, dynamic>> stores) async {
    print('🏭 Generating 20 suppliers with store assignments...');
    
    final suppliers = <Map<String, dynamic>>[];
    final supplierTypes = ['Manufacturer', 'Wholesaler', 'Distributor', 'Local Vendor'];
    final categories = ['Dairy', 'Snacks', 'Beverages', 'Fruits', 'Vegetables'];
    
    for (int i = 1; i <= 20; i++) {
      final supplierId = 'SUPP-${i.toString().padLeft(3, '0')}';
      final category = categories[(i - 1) % categories.length];
      
      // Assign suppliers to 2-4 stores (not all suppliers serve all stores)
      final assignedStores = <String>[];
      final storeCount = 2 + _random.nextInt(3); // 2-4 stores
      final shuffledStores = List.from(stores)..shuffle(_random);
      
      for (int j = 0; j < storeCount; j++) {
        assignedStores.add(shuffledStores[j]['store_id']);
      }
      
      final supplier = {
        'supplier_id': supplierId,
        'supplier_code': supplierId,
        'supplier_name': '$category Supplier $i Pvt Ltd',
        'contact_person_name': 'Contact Person $i',
        'contact_person_mobile': '+91-${9000000000 + i}',
        'email': 'supplier$i@example.com',
        'address_line1': 'Address Line 1, Supplier $i',
        'city': 'City $i',
        'state': 'State $i',
        'postal_code': '${500000 + i}',
        'country': 'India',
        'supplier_type': supplierTypes[_random.nextInt(supplierTypes.length)],
        'primary_category': category,
        'assigned_stores': assignedStores, // Store-specific assignments
        'payment_terms': 'Net ${[15, 30, 45][_random.nextInt(3)]}',
        'rating': 3.0 + _random.nextDouble() * 2, // 3.0 to 5.0
        'status': 'Active',
        'created_at': Timestamp.now(),
      };
      
      suppliers.add(supplier);
      await _firestore.collection('suppliers').doc(supplierId).set(supplier);
    }

    print('  ✅ Generated ${suppliers.length} suppliers with store assignments');
    return suppliers;
  }

  /// 📦 Generate 100 products with unified pricing
  static Future<List<Map<String, dynamic>>> _generateProducts(List<Map<String, dynamic>> suppliers) async {
    print('📦 Generating 100 products with unified pricing...');
    
    final products = <Map<String, dynamic>>[];
    final categories = ['Dairy', 'Snacks', 'Beverages', 'Fruits', 'Vegetables'];
    final brands = ['Fresh Choice', 'Premium', 'Daily Essentials', 'Organic Plus', 'Value Pack'];
    final units = ['1L', '500ml', '1kg', '500g', '250g', 'piece', 'dozen'];
    
    for (int i = 1; i <= 100; i++) {
      final productId = 'PROD-${i.toString().padLeft(3, '0')}';
      final category = categories[(i - 1) % categories.length];
      final brand = brands[(i - 1) % brands.length];
      final unit = units[(i - 1) % units.length];
      
      // Find supplier for this category
      final categorySuppliers = suppliers.where((s) => s['primary_category'] == category).toList();
      final defaultSupplier = categorySuppliers.isNotEmpty 
          ? categorySuppliers[_random.nextInt(categorySuppliers.length)]
          : suppliers[_random.nextInt(suppliers.length)];
      
      // Unified pricing (same price across all stores)
      final basePrice = 50 + (i * 5) + _random.nextInt(50);
      final costPrice = basePrice * 0.7;
      final sellingPrice = basePrice * 0.9;
      final mrp = basePrice.toDouble();
      
      final product = {
        'product_id': productId,
        'product_name': '$category $brand Item $i',
        'product_slug': '${category.toLowerCase()}-${brand.toLowerCase()}-item-$i',
        'category': category,
        'subcategory': '${category} Subcategory',
        'brand': brand,
        'variant': unit,
        'unit': unit,
        'description': 'High quality $category product from $brand',
        'sku': 'SKU-${category.substring(0, 3).toUpperCase()}-$i',
        'barcode': '${8901030800000 + i}',
        'hsn_code': '${1000 + (i % 100)}',
        'mrp': mrp, // Unified pricing
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'margin_percent': ((sellingPrice - costPrice) / costPrice * 100).roundToDouble(),
        'tax_percent': 18.0,
        'tax_category': 'GST',
        'default_supplier_id': defaultSupplier['supplier_id'],
        'min_stock_level': 10,
        'max_stock_level': 500,
        'lead_time_days': 3 + _random.nextInt(7),
        'shelf_life_days': 30 + _random.nextInt(335),
        'product_status': 'Active',
        'product_type': 'Regular',
        'product_image_urls': ['https://via.placeholder.com/300x300?text=$category+$i'],
        'tags': [category.toLowerCase(), brand.toLowerCase()],
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      };
      
      products.add(product);
      await _firestore.collection('products').doc(productId).set(product);
    }

    print('  ✅ Generated ${products.length} products with unified pricing');
    return products;
  }

  /// 📦 Generate store-specific inventory (not all products available in all stores)
  static Future<void> _generateStoreInventory(List<Map<String, dynamic>> stores, List<Map<String, dynamic>> products, List<Map<String, dynamic>> suppliers) async {
    print('📦 Generating store-specific inventory...');
    
    int totalInventoryRecords = 0;
    
    for (final store in stores) {
      final storeId = store['store_id'];
      final storeCode = store['store_code'];
      final storeName = store['store_name'];
      final storeType = store['store_type'];
      
      // Determine how many products this store carries
      int productCount;
      if (storeType == 'Warehouse') {
        productCount = products.length; // Warehouse has all products
      } else if (store['store_area_sqft'] > 2000) {
        productCount = (products.length * 0.8).round(); // Large stores: 80% of products
      } else if (store['store_area_sqft'] > 1500) {
        productCount = (products.length * 0.6).round(); // Medium stores: 60% of products
      } else {
        productCount = (products.length * 0.4).round(); // Small stores: 40% of products
      }
      
      // Randomly select products for this store
      final storeProducts = List.from(products)..shuffle(_random);
      final selectedProducts = storeProducts.take(productCount).toList();
      
      for (final product in selectedProducts) {
        final inventoryId = _uuid.v4();
        
        // Determine stock level based on store type
        int stockLevel;
        if (storeType == 'Warehouse') {
          stockLevel = 500 + _random.nextInt(1000); // High stock for warehouse
        } else {
          stockLevel = 20 + _random.nextInt(100); // Lower stock for retail
        }
        
        final inventory = {
          'inventory_id': inventoryId,
          'product_id': product['product_id'],
          'product_name': product['product_name'],
          'product_sku': product['sku'],
          'product_barcode': product['barcode'],
          'store_id': storeId,
          'store_code': storeCode,
          'store_name': storeName,
          'store_type': storeType,
          'category': product['category'],
          'subcategory': product['subcategory'],
          'brand': product['brand'],
          'variant': product['variant'],
          'unit': product['unit'],
          'store_location': '${storeName} - ${product['category']} Section',
          'warehouse_section': 'Section-${product['category'].substring(0, 1)}${_random.nextInt(10)}',
          'aisle_number': 'A${_random.nextInt(20) + 1}',
          'shelf_number': 'S${_random.nextInt(50) + 1}',
          'bin_location': 'B${_random.nextInt(100) + 1}',
          
          // Stock quantities
          'quantity_available': stockLevel,
          'quantity_reserved': _random.nextInt(5),
          'quantity_on_order': _random.nextInt(20),
          'quantity_damaged': _random.nextInt(3),
          'quantity_returned': _random.nextInt(2),
          'quantity_in_transit': _random.nextInt(10),
          'quantity_allocated': _random.nextInt(5),
          'total_quantity': stockLevel + _random.nextInt(5),
          
          // Stock management
          'reorder_point': product['min_stock_level'],
          'max_stock_level': product['max_stock_level'],
          'economic_order_qty': ((product['max_stock_level'] - product['min_stock_level']) / 2).round(),
          'safety_stock': (product['min_stock_level'] * 0.2).round(),
          'lead_time_days': product['lead_time_days'],
          
          // Batch and expiry info
          'batch_number': 'BATCH-${product['product_id']}-${DateTime.now().millisecondsSinceEpoch}',
          'lot_number': 'LOT-${product['product_id']}-${_random.nextInt(1000)}',
          'serial_numbers': storeType == 'Warehouse' ? 
              List.generate(3, (i) => 'SN${product['product_id']}${i + 1}') : [],
          'expiry_date': Timestamp.fromDate(DateTime.now().add(Duration(days: product['shelf_life_days']))),
          'manufacture_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 30))),
          'received_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 15))),
          'shelf_life_days': product['shelf_life_days'],
          'days_to_expiry': product['shelf_life_days'] - 30,
          
          // Pricing and cost
          'cost_price': product['cost_price'],
          'selling_price': product['selling_price'],
          'mrp': product['mrp'],
          'total_cost_value': stockLevel * product['cost_price'],
          'total_selling_value': stockLevel * product['selling_price'],
          'margin_amount': stockLevel * (product['selling_price'] - product['cost_price']),
          'margin_percent': product['margin_percent'],
          
          // Quality and condition
          'quality_grade': ['A', 'B', 'C'][_random.nextInt(3)],
          'condition_status': ['New', 'Good', 'Fair'][_random.nextInt(3)],
          'temperature_zone': product['category'] == 'Dairy' ? 'Cold' : 
                             product['category'] == 'Fruits' ? 'Cool' : 'Ambient',
          'storage_requirements': product['category'] == 'Dairy' ? 'Refrigerated (2-8°C)' : 
                                product['category'] == 'Fruits' ? 'Cool & Dry' : 'Room Temperature',
          
          // Movement tracking
          'last_movement_date': Timestamp.now(),
          'last_movement_type': ['In', 'Out', 'Transfer', 'Adjustment'][_random.nextInt(4)],
          'movement_frequency': _random.nextInt(10) + 1, // movements per week
          'turnover_rate': _random.nextDouble() * 5, // times per month
          
          // Supply chain info
          'supplier_id': product['default_supplier_id'],
          'supplier_name': suppliers.firstWhere((s) => s['supplier_id'] == product['default_supplier_id'])['supplier_name'],
          'last_purchase_order': 'PO-${_random.nextInt(1000)}',
          'last_received_qty': _random.nextInt(50) + 10,
          'next_delivery_date': Timestamp.fromDate(DateTime.now().add(Duration(days: _random.nextInt(14) + 1))),
          
          // Status and flags
          'stock_status': stockLevel > product['min_stock_level'] ? 'In Stock' : 'Low Stock',
          'is_active': true,
          'is_blocked': false,
          'is_quarantined': _random.nextInt(20) == 0, // 5% chance
          'requires_inspection': product['category'] == 'Dairy',
          'is_hazardous': false,
          'is_perishable': ['Dairy', 'Fruits', 'Vegetables'].contains(product['category']),
          'is_fragile': product['category'] == 'Beverages',
          'track_by_serial': storeType == 'Warehouse',
          'track_by_batch': true,
          
          // Audit trail
          'created_at': Timestamp.now(),
          'created_by': 'System Auto-Generator',
          'last_updated': Timestamp.now(),
          'updated_by': 'System',
          'last_counted_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _random.nextInt(30)))),
          'last_counted_by': 'Store Manager',
          'cycle_count_frequency': 'Monthly',
          'next_count_due': Timestamp.fromDate(DateTime.now().add(Duration(days: 30 - _random.nextInt(30)))),
          
          // Additional metadata
          'entry_mode': 'Auto-Generated',
          'data_source': 'Mock Data Generator',
          'verification_status': 'Verified',
          'approval_status': 'Approved',
          'notes': 'Auto-generated inventory record for testing',
          'tags': [product['category'].toLowerCase(), 'auto-generated', storeType.toLowerCase()],
          'custom_fields': {
            'zone': '${product['category']}-Zone',
            'priority': stockLevel < product['min_stock_level'] ? 'High' : 'Normal',
            'season': 'All Season'
          },
        };
        
        await _firestore.collection('inventory').add(inventory);
        totalInventoryRecords++;
      }
      
      print('  ✅ Store ${storeCode}: ${selectedProducts.length} products (${productCount}/${products.length})');
    }
    
    print('  ✅ Generated ${totalInventoryRecords} inventory records across all stores');
  }

  /// 📋 Generate store-specific purchase orders
  static Future<void> _generatePurchaseOrders(List<Map<String, dynamic>> stores, List<Map<String, dynamic>> suppliers, List<Map<String, dynamic>> products) async {
    print('📋 Generating store-specific purchase orders...');
    
    int totalPOs = 0;
    
    for (final store in stores) {
      final storeId = store['store_id'];
      final storeCode = store['store_code'];
      
      // Find suppliers that serve this store
      final storeSuppliers = suppliers.where((s) => 
        (s['assigned_stores'] as List).contains(storeId)).toList();
      
      if (storeSuppliers.isEmpty) continue;
      
      // Generate 2-5 POs per store
      final poCount = 2 + _random.nextInt(4);
      
      for (int i = 0; i < poCount; i++) {
        final poId = _uuid.v4();
        final poNumber = 'PO-${storeCode}-${(totalPOs + 1).toString().padLeft(3, '0')}';
        final supplier = storeSuppliers[_random.nextInt(storeSuppliers.length)];
        
        // Generate line items
        final lineItems = <Map<String, dynamic>>[];
        final itemCount = 2 + _random.nextInt(4);
        final categoryProducts = products.where((p) => p['category'] == supplier['primary_category']).toList();
        
        double totalAmount = 0;
        for (int j = 0; j < itemCount; j++) {
          if (categoryProducts.isEmpty) break;
          final product = categoryProducts[_random.nextInt(categoryProducts.length)];
          final quantity = 10 + _random.nextInt(40);
          final unitPrice = product['cost_price'];
          final totalPrice = quantity * unitPrice;
          
          lineItems.add({
            'line_item_id': _uuid.v4(),
            'product_id': product['product_id'],
            'product_name': product['product_name'],
            'quantity': quantity,
            'unit_price': unitPrice,
            'total_price': totalPrice,
            'received_quantity': 0,
            'pending_quantity': quantity,
          });
          
          totalAmount += totalPrice;
        }
        
        final purchaseOrder = {
          'purchase_order_id': poId,
          'po_number': poNumber,
          'supplier_id': supplier['supplier_id'],
          'supplier_name': supplier['supplier_name'],
          'destination_store_id': storeId, // Store-specific destination
          'destination_store_code': storeCode,
          'destination_store_name': store['store_name'],
          'order_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _random.nextInt(30)))),
          'expected_delivery_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 7 + _random.nextInt(14)))),
          'status': ['Pending', 'Approved', 'In Transit', 'Delivered'][_random.nextInt(4)],
          'line_items': lineItems,
          'subtotal': totalAmount,
          'tax_amount': totalAmount * 0.18,
          'total_amount': totalAmount * 1.18,
          'notes': 'Store-specific purchase order for ${store['store_name']}',
          'created_by': store['contact_person'],
          'created_at': Timestamp.now(),
        };
        
        await _firestore.collection('purchase_orders').doc(poId).set(purchaseOrder);
        totalPOs++;
      }
    }
    
    print('  ✅ Generated ${totalPOs} store-specific purchase orders');
  }

  /// 👥 Generate customers with store preferences
  static Future<List<Map<String, dynamic>>> _generateCustomers(List<Map<String, dynamic>> stores) async {
    print('👥 Generating customers with store preferences...');
    
    final customers = <Map<String, dynamic>>[];
    final firstNames = ['John', 'Jane', 'Mike', 'Sarah', 'David', 'Emily', 'Chris', 'Lisa', 'Tom', 'Anna'];
    final lastNames = ['Smith', 'Johnson', 'Brown', 'Davis', 'Wilson', 'Miller', 'Taylor', 'Anderson', 'Thomas', 'Jackson'];
    
    // Operational stores only for customer preferences
    final operationalStores = stores.where((s) => s['is_operational'] == true).toList();
    
    for (int i = 1; i <= 50; i++) {
      final customerId = 'CUST-${i.toString().padLeft(3, '0')}';
      final firstName = firstNames[_random.nextInt(firstNames.length)];
      final lastName = lastNames[_random.nextInt(lastNames.length)];
      
      // Assign customer to a preferred store (nearest/chosen store)
      final preferredStore = operationalStores[_random.nextInt(operationalStores.length)];
      
      final customer = {
        'customer_id': customerId,
        'customer_name': '$firstName $lastName',
        'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}$i@example.com',
        'phone': '+91-${9000000000 + i}',
        'address': '${i}, Demo Street, ${preferredStore['city']}',
        'city': preferredStore['city'],
        'state': preferredStore['state'],
        'pincode': preferredStore['postal_code'],
        'preferred_store_id': preferredStore['store_id'], // Store preference
        'preferred_store_name': preferredStore['store_name'],
        'customer_type': ['regular', 'premium', 'vip'][_random.nextInt(3)],
        'customer_status': 'active',
        'loyalty_points': _random.nextInt(1000),
        'total_orders': _random.nextInt(20),
        'total_spent': _random.nextDouble() * 10000,
        'created_at': Timestamp.now(),
      };
      
      customers.add(customer);
      await _firestore.collection('customers').doc(customerId).set(customer);
    }
    
    print('  ✅ Generated ${customers.length} customers with store preferences');
    return customers;
  }

  /// 🛍️ Generate customer orders with store assignments
  static Future<void> _generateCustomerOrders(List<Map<String, dynamic>> stores, List<Map<String, dynamic>> customers, List<Map<String, dynamic>> products) async {
    print('🛍️ Generating customer orders with store assignments...');
    
    int totalOrders = 0;
    
    for (final customer in customers) {
      final orderCount = 1 + _random.nextInt(3); // 1-3 orders per customer
      
      for (int i = 0; i < orderCount; i++) {
        final orderId = _uuid.v4();
        final orderNumber = 'ORD-${(totalOrders + 1).toString().padLeft(5, '0')}';
        
        // Assign order to customer's preferred store
        final assignedStore = stores.firstWhere((s) => s['store_id'] == customer['preferred_store_id']);
        
        // Select products available in the assigned store
        final storeInventory = await _firestore
            .collection('inventory')
            .where('store_id', isEqualTo: assignedStore['store_id'])
            .get();
        
        if (storeInventory.docs.isEmpty) continue;
        
        // Generate order items
        final orderItems = <Map<String, dynamic>>[];
        final itemCount = 1 + _random.nextInt(4);
        
        double totalAmount = 0;
        for (int j = 0; j < itemCount && j < storeInventory.docs.length; j++) {
          final inventoryDoc = storeInventory.docs[j];
          final inventory = inventoryDoc.data();
          
          final product = products.firstWhere((p) => p['product_id'] == inventory['product_id']);
          final quantity = 1 + _random.nextInt(3);
          final unitPrice = product['selling_price'];
          final totalPrice = quantity * unitPrice;
          
          orderItems.add({
            'product_id': product['product_id'],
            'product_name': product['product_name'],
            'quantity': quantity,
            'unit_price': unitPrice,
            'total_price': totalPrice,
          });
          
          totalAmount += totalPrice;
        }
        
        if (orderItems.isEmpty) continue;
        
        final customerOrder = {
          'order_id': orderId,
          'order_number': orderNumber,
          'customer_id': customer['customer_id'],
          'customer_name': customer['customer_name'],
          'assigned_store_id': assignedStore['store_id'], // Store assignment
          'assigned_store_code': assignedStore['store_code'],
          'assigned_store_name': assignedStore['store_name'],
          'fulfillment_type': ['Pickup', 'Delivery'][_random.nextInt(2)],
          'order_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _random.nextInt(30)))),
          'order_status': ['New', 'Confirmed', 'Preparing', 'Ready', 'Completed'][_random.nextInt(5)],
          'payment_status': ['Pending', 'Paid', 'Failed'][_random.nextInt(3)],
          'payment_mode': ['UPI', 'Card', 'Cash', 'Wallet'][_random.nextInt(4)],
          'products_ordered': orderItems,
          'total_amount': totalAmount,
          'tax_amount': totalAmount * 0.05,
          'grand_total': totalAmount * 1.05,
          'delivery_address': customer['address'],
          'notes': 'Order assigned to ${assignedStore['store_name']}',
          'created_at': Timestamp.now(),
        };
        
        await _firestore.collection('customer_orders').doc(orderId).set(customerOrder);
        totalOrders++;
      }
    }
    
    print('  ✅ Generated ${totalOrders} customer orders with store assignments');
  }

  /// 💳 Generate store-specific POS transactions
  static Future<void> _generatePOSTransactions(List<Map<String, dynamic>> stores, List<Map<String, dynamic>> products, List<Map<String, dynamic>> customers) async {
    print('💳 Generating store-specific POS transactions...');
    
    int totalTransactions = 0;
    
    // Only generate POS transactions for retail stores
    final retailStores = stores.where((s) => s['store_type'] == 'Retail' && s['is_operational']).toList();
    
    for (final store in retailStores) {
      final storeId = store['store_id'];
      final storeCode = store['store_code'];
      
      // Generate 10-20 transactions per retail store
      final transactionCount = 10 + _random.nextInt(11);
      
      for (int i = 0; i < transactionCount; i++) {
        final transactionId = _uuid.v4();
        final invoiceNumber = 'INV-${storeCode}-${(i + 1).toString().padLeft(3, '0')}';
        
        // Random customer (or walk-in)
        final customer = _random.nextBool() ? customers[_random.nextInt(customers.length)] : null;
        
        // Get products available in this store
        final storeInventory = await _firestore
            .collection('inventory')
            .where('store_id', isEqualTo: storeId)
            .limit(10)
            .get();
        
        if (storeInventory.docs.isEmpty) continue;
        
        // Generate transaction items
        final transactionItems = <Map<String, dynamic>>[];
        final itemCount = 1 + _random.nextInt(4);
        
        double subtotal = 0;
        for (int j = 0; j < itemCount && j < storeInventory.docs.length; j++) {
          final inventory = storeInventory.docs[j].data();
          final product = products.firstWhere((p) => p['product_id'] == inventory['product_id']);
          
          final quantity = 1 + _random.nextInt(3);
          final unitPrice = product['selling_price'];
          final totalPrice = quantity * unitPrice;
          
          transactionItems.add({
            'product_id': product['product_id'],
            'product_name': product['product_name'],
            'quantity': quantity,
            'unit_price': unitPrice,
            'total_price': totalPrice,
            'tax_amount': totalPrice * 0.18,
          });
          
          subtotal += totalPrice;
        }
        
        if (transactionItems.isEmpty) continue;
        
        final taxAmount = subtotal * 0.18;
        final totalAmount = subtotal + taxAmount;
        
        final posTransaction = {
          'transaction_id': transactionId,
          'invoice_number': invoiceNumber,
          'store_id': storeId, // Store-specific transaction
          'store_code': storeCode,
          'store_name': store['store_name'],
          'customer_id': customer?['customer_id'],
          'customer_name': customer?['customer_name'],
          'transaction_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: _random.nextInt(7)))),
          'items': transactionItems,
          'subtotal': subtotal,
          'tax_amount': taxAmount,
          'total_amount': totalAmount,
          'payment_method': ['Cash', 'Card', 'UPI', 'Wallet'][_random.nextInt(4)],
          'cashier_id': 'CASHIER-${_random.nextInt(5) + 1}',
          'status': 'Completed',
          'created_at': Timestamp.now(),
        };
        
        await _firestore.collection('pos_transactions').doc(transactionId).set(posTransaction);
        totalTransactions++;
      }
    }
    
    print('  ✅ Generated ${totalTransactions} store-specific POS transactions');
  }

  /// 📊 Generate store performance data
  static Future<void> _generateStorePerformance(List<Map<String, dynamic>> stores) async {
    print('📊 Generating store performance data...');
    
    final retailStores = stores.where((s) => s['store_type'] == 'Retail').toList();
    int totalRecords = 0;
    
    for (final store in retailStores) {
      // Generate 30 days of performance data
      for (int day = 30; day >= 0; day--) {
        final date = DateTime.now().subtract(Duration(days: day));
        final baseTarget = (store['monthly_target'] ?? 100000) / 30;
        final variance = 0.7 + (_random.nextDouble() * 0.6); // 0.7 to 1.3 multiplier
        
        final performance = {
          'store_id': store['store_id'],
          'store_code': store['store_code'],
          'store_name': store['store_name'],
          'date': Timestamp.fromDate(date),
          'total_sales': baseTarget * variance,
          'total_transactions': 50 + _random.nextInt(100),
          'customer_count': 40 + _random.nextInt(80),
          'average_transaction_value': (baseTarget * variance) / (50 + _random.nextInt(100)),
          'gross_profit': (baseTarget * variance) * 0.25,
          'net_profit': (baseTarget * variance) * 0.15,
          'footfall_count': 60 + _random.nextInt(100),
          'conversion_rate': 70.0 + _random.nextDouble() * 25,
          'created_at': Timestamp.now(),
        };
        
        await _firestore.collection('store_performance').add(performance);
        totalRecords++;
      }
    }
    
    print('  ✅ Generated ${totalRecords} store performance records (31 days x ${retailStores.length} stores)');
  }

  /// 📊 Print generation summary
  static void _printSummary() {
    print('📊 UNIFIED ERP MOCK DATA SUMMARY:');
    print('');
    print('🏪 STORES: 6 stores');
    print('   • 4 Retail stores (operational)');
    print('   • 1 Warehouse (operational)');
    print('   • 1 Store under renovation');
    print('');
    print('🏭 SUPPLIERS: 20 suppliers');
    print('   • Store-specific assignments (2-4 stores each)');
    print('   • Category-based specialization');
    print('');
    print('📦 PRODUCTS: 100 products');
    print('   • Unified pricing across all stores');
    print('   • 5 categories, 5 brands');
    print('');
    print('📦 INVENTORY: Store-specific availability');
    print('   • Warehouse: 100% of products (high stock)');
    print('   • Large stores: 80% of products');
    print('   • Medium stores: 60% of products');
    print('   • Small stores: 40% of products');
    print('');
    print('📋 PURCHASE ORDERS: Store-specific destinations');
    print('   • 2-5 POs per store');
    print('   • Only from assigned suppliers');
    print('');
    print('👥 CUSTOMERS: 50 customers');
    print('   • Store preferences assigned');
    print('   • City-based distribution');
    print('');
    print('🛍️ CUSTOMER ORDERS: Store-assigned fulfillment');
    print('   • 1-3 orders per customer');
    print('   • Only products available in assigned store');
    print('');
    print('💳 POS TRANSACTIONS: Store-specific sales');
    print('   • 10-20 transactions per retail store');
    print('   • Only available products');
    print('');
    print('📊 STORE PERFORMANCE: 31 days of data');
    print('   • Daily metrics for all retail stores');
    print('');
    print('🎯 INTEGRATION FEATURES:');
    print('   ✅ Store-specific product availability');
    print('   ✅ Unified pricing across stores');
    print('   ✅ Store-assigned suppliers');
    print('   ✅ Store-specific inventory levels');
    print('   ✅ Store-assigned customer orders');
    print('   ✅ Store-specific POS transactions');
    print('   ✅ Store-destination purchase orders');
    print('   ✅ Customer store preferences');
    print('');
    print('🎉 Ready for comprehensive ERP testing!');
  }
}

/// 🚀 Main function to run the generator
Future<void> main() async {
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized successfully!');
  
  await UnifiedERPMockDataGenerator.generateUnifiedMockData();
}
