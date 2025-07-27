import 'package:cloud_firestore/cloud_firestore.dart';

// Script to add sample inventory data with proper product information
class TestInventoryData {
  static Future<void> addSampleData() async {
    final firestore = FirebaseFirestore.instance;
    
    // Sample products
    final products = [
      {
        'product_id': 'PROD_001',
        'product_name': 'Organic Whole Wheat Flour',
        'sku': 'WHT-FLR-001',
        'category': 'Grains & Cereals',
        'brand': 'Nature Fresh',
        'unit': 'kg',
        'mrp': 85.0,
        'cost_price': 70.0,
        'selling_price': 80.0,
        'product_status': 'active',
      },
      {
        'product_id': 'PROD_002', 
        'product_name': 'Premium Basmati Rice',
        'sku': 'BSM-RIC-002',
        'category': 'Grains & Cereals',
        'brand': 'Royal Feast',
        'unit': 'kg',
        'mrp': 120.0,
        'cost_price': 100.0,
        'selling_price': 115.0,
        'product_status': 'active',
      },
      {
        'product_id': 'PROD_003',
        'product_name': 'Fresh Milk - Full Cream',
        'sku': 'MLK-FUL-003',
        'category': 'Dairy Products',
        'brand': 'Farm Fresh',
        'unit': 'liter',
        'mrp': 55.0,
        'cost_price': 45.0,
        'selling_price': 52.0,
        'product_status': 'active',
      },
    ];
    
    // Sample stores
    final stores = [
      {
        'store_id': 'STR_001',
        'store_code': 'HYD001',
        'store_name': 'Ravali Supermarket - Hitech City',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'store_type': 'Retail',
        'store_status': 'Active',
      },
      {
        'store_id': 'STR_002',
        'store_code': 'HYD002', 
        'store_name': 'Ravali Mart - Jubilee Hills',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'store_type': 'Retail',
        'store_status': 'Active',
      },
      {
        'store_id': 'STR_003',
        'store_code': 'WRH001',
        'store_name': 'Ravali Central Warehouse',
        'city': 'Hyderabad',
        'state': 'Telangana', 
        'store_type': 'Warehouse',
        'store_status': 'Active',
      },
    ];
    
    // Add products
    for (final product in products) {
      await firestore.collection('products').doc(product['product_id'] as String).set({
        ...product,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    }
    
    // Add stores
    for (final store in stores) {
      await firestore.collection('stores').doc(store['store_id'] as String).set({
        ...store,
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
      });
    }
    
    // Sample inventory records
    final inventoryRecords = [
      {
        'inventory_id': 'INV_001',
        'product_id': 'PROD_001',
        'product_name': 'Organic Whole Wheat Flour',
        'product_sku': 'WHT-FLR-001',
        'product_category': 'Grains & Cereals',
        'product_brand': 'Nature Fresh',
        'store_location': 'HYD001',
        'quantity_available': 150,
        'quantity_reserved': 10,
        'quantity_on_order': 50,
        'quantity_damaged': 2,
        'quantity_returned': 0,
        'reorder_point': 20,
        'batch_number': 'WF2024071501',
        'storage_location': 'Aisle A1-Shelf 2',
        'entry_mode': 'Purchase',
        'stock_status': 'In Stock',
        'added_by': 'admin',
        'remarks': 'Fresh stock arrival',
        'fifo_lifo_flag': 'FIFO',
        'audit_flag': true,
        'auto_restock_enabled': true,
        'safety_stock_level': 25,
        'average_daily_usage': 5.5,
        'stock_turnover_ratio': 2.3,
        'last_updated': Timestamp.now(),
      },
      {
        'inventory_id': 'INV_002',
        'product_id': 'PROD_002',
        'product_name': 'Premium Basmati Rice',
        'product_sku': 'BSM-RIC-002',
        'product_category': 'Grains & Cereals',
        'product_brand': 'Royal Feast',
        'store_location': 'HYD001',
        'quantity_available': 80,
        'quantity_reserved': 5,
        'quantity_on_order': 30,
        'quantity_damaged': 1,
        'quantity_returned': 0,
        'reorder_point': 15,
        'batch_number': 'RF2024071502',
        'storage_location': 'Aisle A1-Shelf 3',
        'entry_mode': 'Purchase',
        'stock_status': 'In Stock',
        'added_by': 'admin',
        'remarks': 'Premium quality rice',
        'fifo_lifo_flag': 'FIFO',
        'audit_flag': true,
        'auto_restock_enabled': true,
        'safety_stock_level': 20,
        'average_daily_usage': 3.2,
        'stock_turnover_ratio': 1.8,
        'last_updated': Timestamp.now(),
      },
      {
        'inventory_id': 'INV_003',
        'product_id': 'PROD_003',
        'product_name': 'Fresh Milk - Full Cream',
        'product_sku': 'MLK-FUL-003',
        'product_category': 'Dairy Products',
        'product_brand': 'Farm Fresh',
        'store_location': 'HYD002',
        'quantity_available': 24,
        'quantity_reserved': 6,
        'quantity_on_order': 48,
        'quantity_damaged': 0,
        'quantity_returned': 2,
        'reorder_point': 12,
        'batch_number': 'FF2024071503',
        'storage_location': 'Cold Storage - Section B',
        'entry_mode': 'Purchase',
        'stock_status': 'Low Stock',
        'added_by': 'admin',
        'remarks': 'Requires daily replenishment',
        'fifo_lifo_flag': 'FIFO',
        'audit_flag': true,
        'auto_restock_enabled': true,
        'safety_stock_level': 15,
        'average_daily_usage': 8.5,
        'stock_turnover_ratio': 4.2,
        'last_updated': Timestamp.now(),
      },
    ];
    
    // Add inventory records
    for (final record in inventoryRecords) {
      await firestore.collection('inventory').doc(record['inventory_id'] as String).set(record);
    }
    
    print('✅ Sample inventory data added successfully!');
    print('📦 Added ${products.length} products');
    print('🏪 Added ${stores.length} stores');
    print('📊 Added ${inventoryRecords.length} inventory records');
  }
}
