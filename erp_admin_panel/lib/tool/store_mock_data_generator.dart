import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/store_models.dart';

/// 🏪 Store Management Mock Data Generator
/// Creates realistic test data for Store Management module testing
class StoreMockDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate and insert mock store data
  static Future<void> generateMockStores() async {
    if (kDebugMode) {
      print('🏪 Generating Store Management mock data...');
    }

    try {
      // Clear existing mock data
      await _clearExistingStores();

      // Generate mock stores
      final mockStores = _generateStoreData();

      // Insert stores into Firestore
      for (final store in mockStores) {
        await _firestore.collection('stores').add(store.toFirestore());
        if (kDebugMode) {
          print('✅ Added store: ${store.storeName} (${store.storeCode})');
        }
      }

      // Generate store performance data
      await _generatePerformanceData();

      // Generate inter-store transfers
      await _generateTransferData();

      if (kDebugMode) {
        print('🎉 Store Management mock data generation completed!');
        print('📊 Generated: ${mockStores.length} stores with performance data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating store mock data: $e');
      }
    }
  }

  /// Clear existing mock stores
  static Future<void> _clearExistingStores() async {
    try {
      final storesSnapshot = await _firestore.collection('stores').get();
      for (final doc in storesSnapshot.docs) {
        await doc.reference.delete();
      }

      final performanceSnapshot = await _firestore.collection('store_performance').get();
      for (final doc in performanceSnapshot.docs) {
        await doc.reference.delete();
      }

      final transfersSnapshot = await _firestore.collection('store_transfers').get();
      for (final doc in transfersSnapshot.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('🗑️ Cleared existing store data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Warning: Could not clear existing data: $e');
      }
    }
  }

  /// Generate realistic store data
  static List<Store> _generateStoreData() {
    final now = Timestamp.now();
    
    return [
      // Main Retail Stores
      Store(
        storeId: 'store_001',
        storeCode: 'HYD001',
        storeName: 'Ravali SuperMart - Hyderabad Central',
        storeType: 'Retail',
        contactPerson: 'Rajesh Kumar',
        contactNumber: '+91 9876543210',
        email: 'hyderabad.central@ravali.com',
        addressLine1: 'Plot No. 123, Road No. 36',
        addressLine2: 'Jubilee Hills',
        city: 'Hyderabad',
        state: 'Telangana',
        postalCode: '500033',
        country: 'India',
        latitude: 17.4065,
        longitude: 78.4772,
        operatingHours: '8:00 AM - 10:00 PM',
        storeAreaSqft: 15000,
        gstRegistrationNumber: '36AABCS1234A1Z5',
        fssaiLicense: '12345678901234',
        storeStatus: 'Active',
        parentCompany: 'Ravali Retail Ltd',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin_001',
        updatedBy: 'admin_001',
        currentStaffCount: 45,
        todaysSales: 125000.50,
        todaysTransactions: 320,
        inventoryItemCount: 2500,
        averageTransactionValue: 390.63,
        managerName: 'Priya Sharma',
        isOperational: true,
        monthlyTarget: 3500000,
        monthlyAchieved: 2100000,
        yearlyTarget: 42000000,
        yearlyAchieved: 25200000,
        customerFootfall: 450,
        conversionRate: 71.11,
        tags: ['Premium', 'High Traffic', 'Metro'],
        customFields: {
          'parking_spaces': 200,
          'escalators': 4,
          'food_court': true,
          'security_level': 'High'
        },
      ),

      Store(
        storeId: 'store_002',
        storeCode: 'BLR001',
        storeName: 'Ravali Express - Bangalore MG Road',
        storeType: 'Retail',
        contactPerson: 'Suresh Babu',
        contactNumber: '+91 9876543211',
        email: 'bangalore.mgroad@ravali.com',
        addressLine1: '45, MG Road',
        addressLine2: 'Brigade Road Junction',
        city: 'Bangalore',
        state: 'Karnataka',
        postalCode: '560001',
        country: 'India',
        latitude: 12.9716,
        longitude: 77.5946,
        operatingHours: '9:00 AM - 9:00 PM',
        storeAreaSqft: 8000,
        gstRegistrationNumber: '29AABCS1234B2Z6',
        fssaiLicense: '12345678901235',
        storeStatus: 'Active',
        parentCompany: 'Ravali Retail Ltd',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin_001',
        updatedBy: 'admin_001',
        currentStaffCount: 25,
        todaysSales: 89500.75,
        todaysTransactions: 195,
        inventoryItemCount: 1800,
        averageTransactionValue: 459.00,
        managerName: 'Anjali Reddy',
        isOperational: true,
        monthlyTarget: 2500000,
        monthlyAchieved: 1950000,
        yearlyTarget: 30000000,
        yearlyAchieved: 23400000,
        customerFootfall: 285,
        conversionRate: 68.42,
        tags: ['Urban', 'Express Format', 'Tech Hub'],
        customFields: {
          'parking_spaces': 50,
          'digital_displays': 12,
          'self_checkout': true,
          'wifi_enabled': true
        },
      ),

      // Warehouse
      Store(
        storeId: 'store_003',
        storeCode: 'WH001',
        storeName: 'Ravali Distribution Center - Gurgaon',
        storeType: 'Warehouse',
        contactPerson: 'Vikram Singh',
        contactNumber: '+91 9876543212',
        email: 'warehouse.gurgaon@ravali.com',
        addressLine1: 'Plot 567, Sector 18',
        addressLine2: 'Industrial Area',
        city: 'Gurgaon',
        state: 'Haryana',
        postalCode: '122015',
        country: 'India',
        latitude: 28.4595,
        longitude: 77.0266,
        operatingHours: '6:00 AM - 8:00 PM',
        storeAreaSqft: 50000,
        gstRegistrationNumber: '06AABCS1234C3Z7',
        fssaiLicense: '12345678901236',
        storeStatus: 'Active',
        parentCompany: 'Ravali Logistics Ltd',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin_001',
        updatedBy: 'admin_001',
        currentStaffCount: 80,
        todaysSales: 0, // Warehouse doesn't have direct sales
        todaysTransactions: 0,
        inventoryItemCount: 15000,
        averageTransactionValue: 0,
        managerName: 'Ravi Kumar',
        isOperational: true,
        monthlyTarget: 0,
        monthlyAchieved: 0,
        yearlyTarget: 0,
        yearlyAchieved: 0,
        customerFootfall: 0,
        conversionRate: 0,
        tags: ['Warehouse', 'Distribution', 'Logistics Hub'],
        customFields: {
          'loading_docks': 20,
          'cold_storage': true,
          'automated_sorting': true,
          'truck_capacity': 100
        },
      ),

      // Small Town Store
      Store(
        storeId: 'store_004',
        storeCode: 'VJA001',
        storeName: 'Ravali Local - Vijayawada',
        storeType: 'Retail',
        contactPerson: 'Lakshmi Devi',
        contactNumber: '+91 9876543213',
        email: 'vijayawada@ravali.com',
        addressLine1: 'Door No. 12-34-56',
        addressLine2: 'Governorpet',
        city: 'Vijayawada',
        state: 'Andhra Pradesh',
        postalCode: '520002',
        country: 'India',
        latitude: 16.5062,
        longitude: 80.6480,
        operatingHours: '7:00 AM - 9:00 PM',
        storeAreaSqft: 3500,
        gstRegistrationNumber: '37AABCS1234D4Z8',
        fssaiLicense: '12345678901237',
        storeStatus: 'Active',
        parentCompany: 'Ravali Retail Ltd',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin_001',
        updatedBy: 'admin_001',
        currentStaffCount: 12,
        todaysSales: 45200.25,
        todaysTransactions: 145,
        inventoryItemCount: 1200,
        averageTransactionValue: 311.73,
        managerName: 'Satish Reddy',
        isOperational: true,
        monthlyTarget: 1200000,
        monthlyAchieved: 890000,
        yearlyTarget: 14400000,
        yearlyAchieved: 10680000,
        customerFootfall: 185,
        conversionRate: 78.38,
        tags: ['Local', 'Community Store', 'Budget Friendly'],
        customFields: {
          'parking_spaces': 15,
          'local_language_support': true,
          'cash_only': false,
          'home_delivery': true
        },
      ),

      // Store Under Renovation
      Store(
        storeId: 'store_005',
        storeCode: 'CHN001',
        storeName: 'Ravali Mega - Chennai T. Nagar',
        storeType: 'Retail',
        contactPerson: 'Murugan Pillai',
        contactNumber: '+91 9876543214',
        email: 'chennai.tnagar@ravali.com',
        addressLine1: '789, Usman Road',
        addressLine2: 'T. Nagar',
        city: 'Chennai',
        state: 'Tamil Nadu',
        postalCode: '600017',
        country: 'India',
        latitude: 13.0827,
        longitude: 80.2707,
        operatingHours: 'Temporarily Closed',
        storeAreaSqft: 12000,
        gstRegistrationNumber: '33AABCS1234E5Z9',
        fssaiLicense: '12345678901238',
        storeStatus: 'Under Renovation',
        parentCompany: 'Ravali Retail Ltd',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin_001',
        updatedBy: 'admin_001',
        currentStaffCount: 5, // Minimal staff during renovation
        todaysSales: 0,
        todaysTransactions: 0,
        inventoryItemCount: 500, // Reduced inventory
        averageTransactionValue: 0,
        managerName: 'Karthik Raman',
        isOperational: false,
        monthlyTarget: 0,
        monthlyAchieved: 0,
        yearlyTarget: 0,
        yearlyAchieved: 0,
        customerFootfall: 0,
        conversionRate: 0,
        tags: ['Under Renovation', 'Expansion', 'Premium Location'],
        customFields: {
          'renovation_end_date': '2025-08-15',
          'expansion_area': 5000,
          'new_features': ['escalator', 'food_court', 'branded_sections'],
          'investment_amount': 2500000
        },
      ),

      // New Small Store (Low Performance)
      Store(
        storeId: 'store_006',
        storeCode: 'PUN001',
        storeName: 'Ravali Quick - Pune Kothrud',
        storeType: 'Retail',
        contactPerson: 'Amit Patil',
        contactNumber: '+91 9876543215',
        email: 'pune.kothrud@ravali.com',
        addressLine1: 'Shop No. 15, Kothrud Depot',
        addressLine2: 'Near Bus Stand',
        city: 'Pune',
        state: 'Maharashtra',
        postalCode: '411038',
        country: 'India',
        latitude: 18.5204,
        longitude: 73.8567,
        operatingHours: '8:00 AM - 8:00 PM',
        storeAreaSqft: 2000,
        gstRegistrationNumber: '27AABCS1234F6ZA',
        fssaiLicense: '12345678901239',
        storeStatus: 'Active',
        parentCompany: 'Ravali Retail Ltd',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin_001',
        updatedBy: 'admin_001',
        currentStaffCount: 6, // Understaffed
        todaysSales: 15800.00, // Low sales
        todaysTransactions: 85,
        inventoryItemCount: 800,
        averageTransactionValue: 185.88,
        managerName: 'Neha Joshi',
        isOperational: true,
        monthlyTarget: 800000,
        monthlyAchieved: 320000, // Only 40% of target
        yearlyTarget: 9600000,
        yearlyAchieved: 3840000,
        customerFootfall: 125,
        conversionRate: 68.00,
        tags: ['New Store', 'Needs Attention', 'Growing Market'],
        customFields: {
          'parking_spaces': 8,
          'opened_date': '2025-04-01',
          'local_competition': 'high',
          'promotional_budget': 50000
        },
      ),
    ];
  }

  /// Generate store performance data for the last 30 days
  static Future<void> _generatePerformanceData() async {
    if (kDebugMode) {
      print('📊 Generating store performance data...');
    }

    final stores = ['store_001', 'store_002', 'store_004', 'store_006']; // Active retail stores
    final storeCodes = ['HYD001', 'BLR001', 'VJA001', 'PUN001'];
    final storeNames = [
      'Ravali SuperMart - Hyderabad Central',
      'Ravali Express - Bangalore MG Road',
      'Ravali Local - Vijayawada',
      'Ravali Quick - Pune Kothrud'
    ];

    for (int i = 0; i < stores.length; i++) {
      for (int day = 30; day >= 0; day--) {
        final date = DateTime.now().subtract(Duration(days: day));
        final performance = _generateDailyPerformance(stores[i], storeCodes[i], storeNames[i], date, i);
        
        final docId = '${stores[i]}_${date.toString().split(' ')[0]}';
        await _firestore.collection('store_performance').doc(docId).set(performance.toFirestore());
      }
    }

    if (kDebugMode) {
      print('✅ Generated 30 days of performance data for ${stores.length} stores');
    }
  }

  /// Generate daily performance data for a store
  static StorePerformance _generateDailyPerformance(String storeId, String storeCode, String storeName, DateTime date, int storeIndex) {
    // Base values per store
    final baseValues = [
      {'sales': 120000, 'transactions': 300, 'customers': 420, 'footfall': 450},  // HYD001
      {'sales': 85000, 'transactions': 180, 'customers': 250, 'footfall': 285},   // BLR001
      {'sales': 42000, 'transactions': 135, 'customers': 170, 'footfall': 185},   // VJA001
      {'sales': 16000, 'transactions': 80, 'customers': 110, 'footfall': 125},    // PUN001
    ];

    final base = baseValues[storeIndex];
    
    // Add some randomness (±20%)
    final randomFactor = 0.8 + (DateTime.now().millisecondsSinceEpoch % 100) / 250;
    
    final totalSales = (base['sales']! * randomFactor).round().toDouble();
    final totalTransactions = (base['transactions']! * randomFactor).round();
    final customerCount = (base['customers']! * randomFactor).round();
    final footfallCount = (base['footfall']! * randomFactor).round().toDouble();
    
    final averageTransactionValue = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;
    final conversionRate = footfallCount > 0 ? (customerCount / footfallCount) * 100 : 0.0;
    final grossProfit = totalSales * 0.25; // 25% gross margin
    final netProfit = totalSales * 0.12; // 12% net margin

    return StorePerformance(
      storeId: storeId,
      storeCode: storeCode,
      storeName: storeName,
      date: date,
      totalSales: totalSales,
      totalTransactions: totalTransactions,
      customerCount: customerCount,
      averageTransactionValue: averageTransactionValue,
      grossProfit: grossProfit,
      netProfit: netProfit,
      inventoryTurnover: 3 + (DateTime.now().millisecondsSinceEpoch % 5),
      footfallCount: footfallCount,
      conversionRate: conversionRate,
      additionalMetrics: {
        'peak_hour': '6:00 PM - 8:00 PM',
        'payment_methods': {
          'cash': (totalSales * 0.3).round(),
          'card': (totalSales * 0.5).round(),
          'upi': (totalSales * 0.2).round(),
        },
        'top_category': storeIndex == 0 ? 'Electronics' : storeIndex == 1 ? 'Fashion' : 'Groceries',
      },
    );
  }

  /// Generate inter-store transfer data
  static Future<void> _generateTransferData() async {
    if (kDebugMode) {
      print('🔄 Generating inter-store transfer data...');
    }

    final transfers = [
      // Transfer from warehouse to retail stores
      StoreTransfer(
        transferId: 'transfer_001',
        fromStoreId: 'store_003',
        toStoreId: 'store_001',
        fromStoreName: 'Ravali Distribution Center - Gurgaon',
        toStoreName: 'Ravali SuperMart - Hyderabad Central',
        items: [
          {'product_id': 'prod_001', 'product_name': 'Samsung Galaxy S24', 'quantity': 50, 'unit_price': 75000},
          {'product_id': 'prod_002', 'product_name': 'Apple iPhone 15', 'quantity': 30, 'unit_price': 89000},
          {'product_id': 'prod_003', 'product_name': 'Laptop Dell Inspiron', 'quantity': 20, 'unit_price': 55000},
        ],
        transferStatus: 'Completed',
        requestedBy: 'priya.sharma@ravali.com',
        approvedBy: 'ravi.kumar@ravali.com',
        requestDate: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        approvalDate: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
        completionDate: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        notes: 'Urgent restock for weekend sale',
        totalValue: 6520000,
      ),

      // Pending transfer between retail stores
      StoreTransfer(
        transferId: 'transfer_002',
        fromStoreId: 'store_001',
        toStoreId: 'store_002',
        fromStoreName: 'Ravali SuperMart - Hyderabad Central',
        toStoreName: 'Ravali Express - Bangalore MG Road',
        items: [
          {'product_id': 'prod_004', 'product_name': 'Adidas Running Shoes', 'quantity': 25, 'unit_price': 8500},
          {'product_id': 'prod_005', 'product_name': 'Nike T-Shirts', 'quantity': 40, 'unit_price': 2500},
          {'product_id': 'prod_006', 'product_name': 'Levi\'s Jeans', 'quantity': 30, 'unit_price': 4500},
        ],
        transferStatus: 'Pending',
        requestedBy: 'anjali.reddy@ravali.com',
        requestDate: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        notes: 'Fashion items for upcoming festival season',
        totalValue: 447500,
      ),

      // In transit transfer
      StoreTransfer(
        transferId: 'transfer_003',
        fromStoreId: 'store_003',
        toStoreId: 'store_004',
        fromStoreName: 'Ravali Distribution Center - Gurgaon',
        toStoreName: 'Ravali Local - Vijayawada',
        items: [
          {'product_id': 'prod_007', 'product_name': 'Rice (25kg)', 'quantity': 100, 'unit_price': 1800},
          {'product_id': 'prod_008', 'product_name': 'Cooking Oil (5L)', 'quantity': 50, 'unit_price': 650},
          {'product_id': 'prod_009', 'product_name': 'Sugar (1kg)', 'quantity': 200, 'unit_price': 45},
        ],
        transferStatus: 'In Transit',
        requestedBy: 'satish.reddy@ravali.com',
        approvedBy: 'ravi.kumar@ravali.com',
        requestDate: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        approvalDate: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        notes: 'Regular grocery restock',
        totalValue: 221500,
      ),
    ];

    for (final transfer in transfers) {
      await _firestore.collection('store_transfers').add(transfer.toFirestore());
    }

    if (kDebugMode) {
      print('✅ Generated ${transfers.length} inter-store transfers');
    }
  }

  /// Generate integration test data for other modules
  static Future<void> generateIntegrationTestData() async {
    if (kDebugMode) {
      print('🔗 Generating integration test data for other modules...');
    }

    try {
      // Generate POS transactions for stores
      await _generatePOSTransactions();
      
      // Generate inventory data linked to stores
      await _generateStoreInventory();
      
      // Generate customer orders with store assignments
      await _generateCustomerOrders();

      if (kDebugMode) {
        print('🎉 Integration test data generation completed!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating integration test data: $e');
      }
    }
  }

  /// Generate POS transactions for each store
  static Future<void> _generatePOSTransactions() async {
    final storeIds = ['store_001', 'store_002', 'store_004', 'store_006'];
    
    for (final storeId in storeIds) {
      for (int i = 0; i < 10; i++) {
        final transaction = {
          'transaction_id': 'pos_${storeId}_${DateTime.now().millisecondsSinceEpoch + i}',
          'store_id': storeId,
          'cashier_id': 'cashier_${(i % 3) + 1}',
          'customer_id': 'customer_${(i % 50) + 1}',
          'transaction_date': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: i))),
          'items': [
            {'product_id': 'prod_00${(i % 9) + 1}', 'quantity': (i % 3) + 1, 'unit_price': 500 + (i * 100)},
          ],
          'total_amount': (500 + (i * 100)) * ((i % 3) + 1),
          'payment_method': ['cash', 'card', 'upi'][i % 3],
          'status': 'completed',
        };
        
        await _firestore.collection('pos_transactions').add(transaction);
      }
    }

    if (kDebugMode) {
      print('✅ Generated POS transactions for stores');
    }
  }

  /// Generate inventory data linked to stores
  static Future<void> _generateStoreInventory() async {
    final storeIds = ['store_001', 'store_002', 'store_003', 'store_004', 'store_006'];
    final products = [
      {'id': 'prod_001', 'name': 'Samsung Galaxy S24'},
      {'id': 'prod_002', 'name': 'Apple iPhone 15'},
      {'id': 'prod_003', 'name': 'Laptop Dell Inspiron'},
      {'id': 'prod_004', 'name': 'Adidas Running Shoes'},
      {'id': 'prod_005', 'name': 'Nike T-Shirts'},
    ];

    for (final storeId in storeIds) {
      for (final product in products) {
        final inventory = {
          'inventory_id': 'inv_${storeId}_${product['id']}',
          'product_id': product['id'],
          'store_id': storeId,
          'current_quantity': 50 + (DateTime.now().millisecondsSinceEpoch % 100),
          'minimum_quantity': 10,
          'maximum_quantity': 200,
          'unit_cost': 1000 + (DateTime.now().millisecondsSinceEpoch % 5000),
          'last_updated': Timestamp.now(),
        };
        
        await _firestore.collection('inventory').add(inventory);
      }
    }

    if (kDebugMode) {
      print('✅ Generated store-linked inventory data');
    }
  }

  /// Generate customer orders with store assignments
  static Future<void> _generateCustomerOrders() async {
    final storeIds = ['store_001', 'store_002', 'store_004', 'store_006'];
    
    for (int i = 0; i < 20; i++) {
      final order = {
        'order_id': 'order_${DateTime.now().millisecondsSinceEpoch + i}',
        'customer_id': 'customer_${(i % 10) + 1}',
        'store_id': storeIds[i % storeIds.length],
        'order_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: i % 7))),
        'items': [
          {'product_id': 'prod_00${(i % 5) + 1}', 'quantity': (i % 3) + 1, 'unit_price': 800 + (i * 200)},
        ],
        'total_value': (800 + (i * 200)) * ((i % 3) + 1),
        'status': ['pending', 'processing', 'completed', 'delivered'][i % 4],
        'fulfillment_type': ['pickup', 'delivery', 'click_collect'][i % 3],
      };
      
      await _firestore.collection('orders').add(order);
    }

    if (kDebugMode) {
      print('✅ Generated customer orders with store assignments');
    }
  }
}
