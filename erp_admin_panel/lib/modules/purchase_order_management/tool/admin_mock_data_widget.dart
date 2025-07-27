import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../services/demo_customer_setup.dart'; // Add demo setup import
import '../../../tool/supplier_auth_setup.dart'; // Add supplier setup import
import '../../../models/store_models.dart'; // Add store models import
import '../../../tool/unified_erp_mock_data_generator.dart'; // Add unified generator

class AdminMockDataWidget extends StatefulWidget {
  const AdminMockDataWidget({Key? key}) : super(key: key);

  @override
  State<AdminMockDataWidget> createState() => _AdminMockDataWidgetState();
}

class _AdminMockDataWidgetState extends State<AdminMockDataWidget> {
  bool _loading = false;
  bool _demoLoading = false;
  bool _storeLoading = false;
  bool _storeDataLoading = false;
  bool _unifiedLoading = false; // New unified generator
  String? _result;
  String? _demoResult;
  String? _storeResult;
  String? _storeDataResult;
  String? _unifiedResult; // New unified result

  Future<void> _generateMockData() async {
    setState(() { _loading = true; _result = null; });
    try {
      await Firebase.initializeApp();
      await _addBulkMockProductsAndInventory();
      setState(() { _result = 'Mock data generated successfully!'; });
    } catch (e) {
      setState(() { _result = 'Error: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _setupDemoCustomer() async {
    setState(() { _demoLoading = true; _demoResult = null; });
    try {
      final result = await DemoCustomerSetup.setupCompleteDemo();
      if (result['success'] == true) {
        setState(() { 
          _demoResult = 'Demo customer setup complete!\n'
                       'Email: john@example.com\n'
                       'Password: password123'; 
        });
      } else {
        setState(() { _demoResult = 'Error: ${result['error']}'; });
      }
    } catch (e) {
      setState(() { _demoResult = 'Error: $e'; });
    } finally {
      setState(() { _demoLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _generateMockData,
                    child: _loading ? const CircularProgressIndicator() : const Text('Generate Mock Data'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _demoLoading ? null : _setupDemoCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _demoLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('🎭 Setup Demo Customer'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _storeLoading ? null : _generateStoreData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _storeLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('🏪 Generate Store Data'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // NEW: Unified ERP Data Generator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade700, Colors.indigo.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎯 UNIFIED ERP DATA GENERATOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generate complete interconnected data for all modules',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _unifiedLoading ? null : _generateUnifiedERPData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _unifiedLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
                            )
                          : const Icon(Icons.auto_awesome, color: Colors.purple),
                      label: Text(
                        _unifiedLoading ? 'Generating...' : '🚀 Generate Unified ERP Data',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _storeDataLoading ? null : _generateComprehensiveStoreData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _storeDataLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('🏬 Complete Store ERP Data'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _clearStoreData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('🗑️ Clear Store Data'),
                  ),
                ],
              ),
              if (_result != null) ...[
                const SizedBox(height: 16),
                Text(_result!, style: TextStyle(color: _result!.startsWith('Error') ? Colors.red : Colors.green)),
              ],
              if (_demoResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _demoResult!.startsWith('Error') ? Colors.red.shade50 : Colors.blue.shade50,
                    border: Border.all(
                      color: _demoResult!.startsWith('Error') ? Colors.red : Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _demoResult!, 
                    style: TextStyle(
                      color: _demoResult!.startsWith('Error') ? Colors.red : Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_storeResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _storeResult!.startsWith('Error') ? Colors.red.shade50 : Colors.purple.shade50,
                    border: Border.all(
                      color: _storeResult!.startsWith('Error') ? Colors.red : Colors.purple,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _storeResult!, 
                    style: TextStyle(
                      color: _storeResult!.startsWith('Error') ? Colors.red : Colors.purple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_storeDataResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _storeDataResult!.startsWith('Error') ? Colors.red.shade50 : Colors.teal.shade50,
                    border: Border.all(
                      color: _storeDataResult!.startsWith('Error') ? Colors.red : Colors.teal,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _storeDataResult!, 
                    style: TextStyle(
                      color: _storeDataResult!.startsWith('Error') ? Colors.red : Colors.teal.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_unifiedResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _unifiedResult!.startsWith('Error') 
                        ? LinearGradient(colors: [Colors.red.shade50, Colors.red.shade100])
                        : LinearGradient(colors: [Colors.purple.shade50, Colors.indigo.shade50]),
                    border: Border.all(
                      color: _unifiedResult!.startsWith('Error') ? Colors.red : Colors.purple,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _unifiedResult!.startsWith('Error') ? Icons.error : Icons.check_circle,
                            color: _unifiedResult!.startsWith('Error') ? Colors.red : Colors.purple,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _unifiedResult!.startsWith('Error') ? 'Generation Failed' : 'Unified ERP Data Generated!',
                            style: TextStyle(
                              color: _unifiedResult!.startsWith('Error') ? Colors.red : Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _unifiedResult!,
                        style: TextStyle(
                          color: _unifiedResult!.startsWith('Error') ? Colors.red.shade700 : Colors.purple.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Add supplier setup widget
        const SupplierAuthSetupWidget(),
      ],
    );
  }

  /// 🎯 Generate unified ERP data
  Future<void> _generateUnifiedERPData() async {
    setState(() { _unifiedLoading = true; _unifiedResult = null; });
    try {
      await Firebase.initializeApp();
      await UnifiedERPMockDataGenerator.generateUnifiedMockData();
      setState(() { 
        _unifiedResult = '🎉 SUCCESS! Unified ERP data generated!\n\n'
                        '✅ 6 stores with different operational status\n'
                        '✅ 100 products with unified pricing\n'
                        '✅ Store-specific inventory (not all products in all stores)\n'
                        '✅ 20 suppliers with store assignments\n'
                        '✅ Store-specific purchase orders\n'
                        '✅ 50 customers with store preferences\n'
                        '✅ Customer orders assigned to preferred stores\n'
                        '✅ Store-specific POS transactions\n'
                        '✅ 31 days of store performance data\n\n'
                        '🔗 All modules are now perfectly interconnected!\n'
                        '🏪 Products show store availability\n'
                        '📦 Inventory is store-specific\n'
                        '🏭 Suppliers serve specific stores\n'
                        '📋 Purchase orders go to specific stores\n'
                        '💳 POS transactions are store-specific\n'
                        '🛍️ Customer orders assigned to stores\n\n'
                        '🎯 Ready for comprehensive ERP testing!'; 
      });
    } catch (e) {
      setState(() { _unifiedResult = 'Error: $e'; });
    } finally {
      setState(() { _unifiedLoading = false; });
    }
  }

  /// 🏪 Generate basic store data
  Future<void> _generateStoreData() async {
    setState(() { _storeLoading = true; _storeResult = null; });
    try {
      await Firebase.initializeApp();
      await _addStoreLocations();
      setState(() { _storeResult = '🏪 Store locations generated successfully!\n6 stores with basic info added to Firestore'; });
    } catch (e) {
      setState(() { _storeResult = 'Error: $e'; });
    } finally {
      setState(() { _storeLoading = false; });
    }
  }

  /// 🏬 Generate comprehensive store ERP data
  Future<void> _generateComprehensiveStoreData() async {
    setState(() { _storeDataLoading = true; _storeDataResult = null; });
    try {
      await Firebase.initializeApp();
      await _addComprehensiveStoreData();
      setState(() { 
        _storeDataResult = '🎉 Complete Store ERP data generated!\n'
                          '• 6 stores with performance analytics\n'
                          '• 30 days of sales history per store\n'
                          '• Inter-store transfer records\n'
                          '• Store-specific inventory links\n'
                          '• POS transactions by store\n'
                          '• Customer order assignments\n'
                          '• Real-time integration ready!'; 
      });
    } catch (e) {
      setState(() { _storeDataResult = 'Error: $e'; });
    } finally {
      setState(() { _storeDataLoading = false; });
    }
  }

  /// 🗑️ Clear all store data
  Future<void> _clearStoreData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Clear stores collection
      final storesSnapshot = await firestore.collection('stores').get();
      for (var doc in storesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear store performance data
      final performanceSnapshot = await firestore.collection('store_performance').get();
      for (var doc in performanceSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear store transfers
      final transfersSnapshot = await firestore.collection('store_transfers').get();
      for (var doc in transfersSnapshot.docs) {
        await doc.reference.delete();
      }
      
      setState(() { 
        _storeResult = '🗑️ All store data cleared from Firestore';
        _storeDataResult = null;
      });
    } catch (e) {
      setState(() { _storeResult = 'Error clearing data: $e'; });
    }
  }

  /// Add basic store locations to Firestore
  Future<void> _addStoreLocations() async {
    final firestore = FirebaseFirestore.instance;
    final now = Timestamp.now();
    
    final List<Map<String, dynamic>> storeData = [
      {
        'store_code': 'HYD001',
        'store_name': 'Ravali SuperMart - Hyderabad Central',
        'store_type': 'Retail',
        'contact_person': 'Rajesh Kumar',
        'contact_number': '+91-9876543210',
        'email': 'hyderabad@ravali.com',
        'address_line1': 'Plot No. 123, Banjara Hills Road',
        'address_line2': 'Near Jubilee Hills Check Post',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'postal_code': '500034',
        'country': 'India',
        'latitude': 17.4126,
        'longitude': 78.4307,
        'operating_hours': '8:00 AM - 10:00 PM',
        'store_area_sqft': 2500.0,
        'gst_registration_number': '36AABCR1234M1Z5',
        'fssai_license': 'FSSAI123456789012',
        'store_status': 'Active',
        'created_at': now,
        'updated_at': now,
        'created_by': 'admin@ravali.com',
        'manager_name': 'Rajesh Kumar',
        'is_operational': true,
        'monthly_target': 500000.0,
        'monthly_achieved': 450000.0,
        'yearly_target': 6000000.0,
        'yearly_achieved': 5200000.0,
        'tags': ['Premium', 'High-Traffic', 'Metro'],
      },
      {
        'store_code': 'BLR001', 
        'store_name': 'Ravali Express - Bangalore MG Road',
        'store_type': 'Retail',
        'contact_person': 'Priya Sharma',
        'contact_number': '+91-9876543211',
        'email': 'bangalore@ravali.com',
        'address_line1': '45, MG Road',
        'address_line2': 'Opposite Brigade Road',
        'city': 'Bangalore',
        'state': 'Karnataka',
        'postal_code': '560001',
        'country': 'India',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'operating_hours': '9:00 AM - 9:00 PM',
        'store_area_sqft': 1800.0,
        'gst_registration_number': '29AABCR1234M1Z6',
        'fssai_license': 'FSSAI123456789013',
        'store_status': 'Active',
        'created_at': now,
        'updated_at': now,
        'created_by': 'admin@ravali.com',
        'manager_name': 'Priya Sharma',
        'is_operational': true,
        'monthly_target': 400000.0,
        'monthly_achieved': 420000.0,
        'yearly_target': 4800000.0,
        'yearly_achieved': 4900000.0,
        'tags': ['Express', 'City-Center', 'Quick-Shop'],
      },
      {
        'store_code': 'WH001',
        'store_name': 'Ravali Distribution Center - Gurgaon',
        'store_type': 'Warehouse',
        'contact_person': 'Amit Singh',
        'contact_number': '+91-9876543212',
        'email': 'warehouse@ravali.com',
        'address_line1': 'Sector 18, Industrial Area',
        'address_line2': 'Near IMT Manesar',
        'city': 'Gurgaon',
        'state': 'Haryana',
        'postal_code': '122001',
        'country': 'India',
        'latitude': 28.4595,
        'longitude': 77.0266,
        'operating_hours': '6:00 AM - 10:00 PM',
        'store_area_sqft': 15000.0,
        'gst_registration_number': '06AABCR1234M1Z7',
        'store_status': 'Active',
        'created_at': now,
        'updated_at': now,
        'created_by': 'admin@ravali.com',
        'manager_name': 'Amit Singh',
        'is_operational': true,
        'tags': ['Warehouse', 'Distribution', 'B2B'],
      },
      {
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
        'latitude': 16.5062,
        'longitude': 80.6480,
        'operating_hours': '7:00 AM - 9:00 PM',
        'store_area_sqft': 1200.0,
        'gst_registration_number': '37AABCR1234M1Z8',
        'fssai_license': 'FSSAI123456789014',
        'store_status': 'Active',
        'created_at': now,
        'updated_at': now,
        'created_by': 'admin@ravali.com',
        'manager_name': 'Lakshmi Devi',
        'is_operational': true,
        'monthly_target': 250000.0,
        'monthly_achieved': 230000.0,
        'yearly_target': 3000000.0,
        'yearly_achieved': 2800000.0,
        'tags': ['Local', 'Community', 'Traditional'],
      },
      {
        'store_code': 'CHN001',
        'store_name': 'Ravali Mega - Chennai T. Nagar',
        'store_type': 'Retail',
        'contact_person': 'Suresh Babu',
        'contact_number': '+91-9876543214',
        'email': 'chennai@ravali.com',
        'address_line1': 'T. Nagar Main Road',
        'address_line2': 'Near Pondy Bazaar',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'postal_code': '600017',
        'country': 'India',
        'latitude': 13.0827,
        'longitude': 80.2707,
        'operating_hours': '8:00 AM - 10:00 PM',
        'store_area_sqft': 3000.0,
        'gst_registration_number': '33AABCR1234M1Z9',
        'fssai_license': 'FSSAI123456789015',
        'store_status': 'Active',
        'created_at': now,
        'updated_at': now,
        'created_by': 'admin@ravali.com',
        'manager_name': 'Suresh Babu',
        'is_operational': true,
        'monthly_target': 600000.0,
        'monthly_achieved': 580000.0,
        'yearly_target': 7200000.0,
        'yearly_achieved': 6900000.0,
        'tags': ['Mega', 'Shopping-District', 'High-Volume'],
      },
      {
        'store_code': 'PUN001',
        'store_name': 'Ravali Quick - Pune Kothrud',
        'store_type': 'Retail',
        'contact_person': 'Anil Patil',
        'contact_number': '+91-9876543215',
        'email': 'pune@ravali.com',
        'address_line1': 'Kothrud Main Road',
        'address_line2': 'Near SNDT College',
        'city': 'Pune',
        'state': 'Maharashtra',
        'postal_code': '411038',
        'country': 'India',
        'latitude': 18.5074,
        'longitude': 73.8077,
        'operating_hours': '7:00 AM - 11:00 PM',
        'store_area_sqft': 1600.0,
        'gst_registration_number': '27AABCR1234M1ZA',
        'fssai_license': 'FSSAI123456789016',
        'store_status': 'Active',
        'created_at': now,
        'updated_at': now,
        'created_by': 'admin@ravali.com',
        'manager_name': 'Anil Patil',
        'is_operational': true,
        'monthly_target': 350000.0,
        'monthly_achieved': 370000.0,
        'yearly_target': 4200000.0,
        'yearly_achieved': 4400000.0,
        'tags': ['Quick', 'College-Area', 'Young-Demographic'],
      },
    ];
    
    // Add each store to Firestore
    for (var store in storeData) {
      await firestore.collection('stores').add(store);
    }
    
    print('✅ Added ${storeData.length} stores to Firestore');
  }

  /// Add comprehensive store ERP data including performance, transfers, and integrations
  Future<void> _addComprehensiveStoreData() async {
    final firestore = FirebaseFirestore.instance;
    final uuid = Uuid();
    final random = Random();
    
    // First ensure stores exist
    await _addStoreLocations();
    
    // Get all stores
    final storesSnapshot = await firestore.collection('stores').get();
    final stores = storesSnapshot.docs;
    
    if (stores.isEmpty) {
      throw Exception('No stores found. Generate store data first.');
    }
    
    print('🏪 Generating comprehensive data for ${stores.length} stores...');
    
    // 1. Generate Store Performance Data (30 days)
    await _generateStorePerformanceData(firestore, stores);
    
    // 2. Generate Inter-Store Transfers
    await _generateStoreTransfers(firestore, stores, uuid);
    
    // 3. Link existing inventory to stores
    await _linkInventoryToStores(firestore, stores);
    
    // 4. Generate store-specific POS transactions
    await _generateStorePOSTransactions(firestore, stores, uuid);
    
    // 5. Assign customer orders to stores
    await _assignCustomerOrdersToStores(firestore, stores);
    
    print('✅ Comprehensive store ERP data generation completed!');
  }

  /// Generate 30 days of performance data for each store
  Future<void> _generateStorePerformanceData(FirebaseFirestore firestore, List<QueryDocumentSnapshot> stores) async {
    final random = Random();
    
    for (var storeDoc in stores) {
      final storeData = storeDoc.data() as Map<String, dynamic>;
      final storeCode = storeData['store_code'];
      final storeName = storeData['store_name'];
      final baseTarget = (storeData['monthly_target'] ?? 300000.0) / 30; // Daily target
      
      // Generate 30 days of performance data
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final variance = 0.7 + (random.nextDouble() * 0.6); // 0.7 to 1.3 multiplier
        final dailySales = baseTarget * variance;
        final transactions = 50 + random.nextInt(100);
        final customers = transactions * (0.8 + random.nextDouble() * 0.4); // 0.8 to 1.2 ratio
        
        await firestore.collection('store_performance').add({
          'store_id': storeDoc.id,
          'store_code': storeCode,
          'store_name': storeName,
          'date': Timestamp.fromDate(date),
          'total_sales': dailySales,
          'total_transactions': transactions,
          'customer_count': customers.round(),
          'average_transaction_value': dailySales / transactions,
          'gross_profit': dailySales * 0.25, // 25% gross margin
          'net_profit': dailySales * 0.15, // 15% net margin
          'inventory_turnover': 5 + random.nextInt(10),
          'footfall_count': customers * 1.2, // Some browsers don't buy
          'conversion_rate': 75.0 + random.nextDouble() * 20, // 75-95%
          'additional_metrics': {
            'peak_hour_sales': dailySales * 0.3,
            'staff_on_duty': 3 + random.nextInt(5),
            'payment_methods': {
              'cash': dailySales * 0.3,
              'card': dailySales * 0.5,
              'digital': dailySales * 0.2,
            }
          }
        });
      }
      
      print('📊 Generated 30 days performance data for $storeName');
    }
  }

  /// Generate inter-store transfer records
  Future<void> _generateStoreTransfers(FirebaseFirestore firestore, List<QueryDocumentSnapshot> stores, Uuid uuid) async {
    final random = Random();
    final transferStatuses = ['Pending', 'In Transit', 'Completed', 'Cancelled'];
    
    // Generate 5-8 transfer records
    for (int i = 0; i < 5 + random.nextInt(4); i++) {
      final fromStore = stores[random.nextInt(stores.length)];
      final toStore = stores[random.nextInt(stores.length)];
      
      if (fromStore.id == toStore.id) continue; // Skip same store transfers
      
      final fromStoreData = fromStore.data() as Map<String, dynamic>;
      final toStoreData = toStore.data() as Map<String, dynamic>;
      final status = transferStatuses[random.nextInt(transferStatuses.length)];
      final requestDate = DateTime.now().subtract(Duration(days: random.nextInt(15)));
      
      final items = List.generate(2 + random.nextInt(4), (index) => {
        'product_id': 'PROD-${uuid.v4().substring(0, 8)}',
        'product_name': 'Product ${index + 1}',
        'quantity': 10 + random.nextInt(50),
        'unit_price': 100.0 + random.nextDouble() * 500,
      });
      
      final totalValue = items.fold<double>(0, (sum, item) => 
        sum + (item['quantity'] as int) * (item['unit_price'] as double));
      
      await firestore.collection('store_transfers').add({
        'from_store_id': fromStore.id,
        'to_store_id': toStore.id,
        'from_store_name': fromStoreData['store_name'],
        'to_store_name': toStoreData['store_name'],
        'items': items,
        'transfer_status': status,
        'requested_by': fromStoreData['manager_name'] ?? 'Manager',
        'approved_by': status != 'Pending' ? 'Supervisor' : null,
        'request_date': Timestamp.fromDate(requestDate),
        'approval_date': status != 'Pending' ? 
          Timestamp.fromDate(requestDate.add(Duration(hours: 2 + random.nextInt(24)))) : null,
        'completion_date': status == 'Completed' ?
          Timestamp.fromDate(requestDate.add(Duration(days: 1 + random.nextInt(3)))) : null,
        'notes': status == 'Cancelled' ? 'Cancelled due to stock unavailability' : 
                status == 'Completed' ? 'Transfer completed successfully' : null,
        'total_value': totalValue,
      });
    }
    
    print('🔄 Generated inter-store transfer records');
  }

  /// Link existing inventory records to specific stores
  Future<void> _linkInventoryToStores(FirebaseFirestore firestore, List<QueryDocumentSnapshot> stores) async {
    final inventorySnapshot = await firestore.collection('inventory').get();
    final random = Random();
    
    for (var inventoryDoc in inventorySnapshot.docs) {
      final randomStore = stores[random.nextInt(stores.length)];
      final storeData = randomStore.data() as Map<String, dynamic>;
      
      await inventoryDoc.reference.update({
        'store_id': randomStore.id,
        'store_code': storeData['store_code'],
        'store_name': storeData['store_name'],
        'store_location': storeData['store_name'],
      });
    }
    
    print('📦 Linked ${inventorySnapshot.docs.length} inventory items to stores');
  }

  /// Generate store-specific POS transactions
  Future<void> _generateStorePOSTransactions(FirebaseFirestore firestore, List<QueryDocumentSnapshot> stores, Uuid uuid) async {
    final random = Random();
    
    for (var storeDoc in stores) {
      final storeData = storeDoc.data() as Map<String, dynamic>;
      final storeCode = storeData['store_code'];
      
      // Generate 10-20 POS transactions per store for last 7 days
      for (int day = 0; day < 7; day++) {
        final transactionsPerDay = 10 + random.nextInt(11);
        
        for (int t = 0; t < transactionsPerDay; t++) {
          final transactionDate = DateTime.now().subtract(Duration(days: day, hours: random.nextInt(12)));
          final items = List.generate(1 + random.nextInt(5), (index) => {
            'product_id': 'PROD-${uuid.v4().substring(0, 8)}',
            'product_name': 'Product ${index + 1}',
            'quantity': 1 + random.nextInt(3),
            'unit_price': 50.0 + random.nextDouble() * 200,
          });
          
          final subtotal = items.fold<double>(0, (sum, item) => 
            sum + (item['quantity'] as int) * (item['unit_price'] as double));
          final tax = subtotal * 0.18; // 18% GST
          final total = subtotal + tax;
          
          await firestore.collection('pos_transactions').add({
            'transaction_id': 'TXN-${uuid.v4()}',
            'store_id': storeDoc.id,
            'store_code': storeCode,
            'transaction_date': Timestamp.fromDate(transactionDate),
            'items': items,
            'subtotal': subtotal,
            'tax_amount': tax,
            'total_amount': total,
            'payment_method': ['Cash', 'Card', 'UPI'][random.nextInt(3)],
            'cashier_id': 'CASHIER-${random.nextInt(5) + 1}',
            'customer_id': random.nextBool() ? 'CUST-${uuid.v4().substring(0, 8)}' : null,
            'status': 'Completed',
          });
        }
      }
      
      print('💳 Generated POS transactions for ${storeData['store_name']}');
    }
  }

  /// Assign existing customer orders to stores
  Future<void> _assignCustomerOrdersToStores(FirebaseFirestore firestore, List<QueryDocumentSnapshot> stores) async {
    final ordersSnapshot = await firestore.collection('customer_orders').get();
    final random = Random();
    
    for (var orderDoc in ordersSnapshot.docs) {
      final randomStore = stores[random.nextInt(stores.length)];
      final storeData = randomStore.data() as Map<String, dynamic>;
      final fulfillmentType = ['Pickup', 'Delivery', 'Express'][random.nextInt(3)];
      
      await orderDoc.reference.update({
        'assigned_store_id': randomStore.id,
        'assigned_store_code': storeData['store_code'],
        'assigned_store_name': storeData['store_name'],
        'fulfillment_type': fulfillmentType,
        'pickup_store': fulfillmentType == 'Pickup' ? storeData['store_name'] : null,
        'delivery_store': fulfillmentType != 'Pickup' ? storeData['store_name'] : null,
      });
    }
    
    print('🛍️ Assigned ${ordersSnapshot.docs.length} customer orders to stores');
  }
}

Future<void> _addBulkMockProductsAndInventory() async {
  final firestore = FirebaseFirestore.instance;
  final uuid = Uuid();
  final List<Map<String, String>> mockProducts = [
    {'name': 'Milk 1L', 'sku': 'MILK-AMUL-1L', 'category': 'Dairy', 'brand': 'Amul', 'unit': '1L'},
    {'name': 'Milk 1L', 'sku': 'MILK-NANDINI-1L', 'category': 'Dairy', 'brand': 'Nandini', 'unit': '1L'},
    // ... (add more or copy from your script) ...
  ];
  for (int i = mockProducts.length; i < 100; i++) {
    mockProducts.add({
      'name': 'Mock Product $i',
      'sku': 'SKU-$i',
      'category': i % 2 == 0 ? 'Misc' : 'Other',
      'brand': 'Brand $i',
      'unit': 'Unit',
    });
  }
  // Clear collections
  for (final col in ['products', 'inventory', 'suppliers']) {
    final snap = await firestore.collection(col).get();
    for (final doc in snap.docs) { await doc.reference.delete(); }
  }
  // Suppliers
  final supplierTypes = ['Manufacturer', 'Wholesaler', 'Distributor', 'Local Vendor'];
  final paymentModes = ['UPI', 'Bank Transfer', 'Cheque', 'Cash'];
  final currencies = ['INR', 'USD', 'EUR'];
  final random = Random();
  final List<String> supplierIds = [];
  final List<Map<String, dynamic>> suppliers = [];
  for (int i = 1; i <= 20; i++) {
    final id = uuid.v4();
    supplierIds.add(id);
    final code = 'SUP${i.toString().padLeft(3, '0')}';
    final type = supplierTypes[random.nextInt(supplierTypes.length)];
    final now = DateTime.now();
    final contractStart = now.subtract(Duration(days: random.nextInt(365)));
    final contractEnd = contractStart.add(Duration(days: 365 + random.nextInt(365)));
    final rating = (random.nextDouble() * 4 + 1).toStringAsFixed(1);
    final onTime = (random.nextDouble() * 100).toStringAsFixed(1);
    final leadTime = random.nextInt(15) + 1;
    final totalOrders = random.nextInt(100) + 1;
    final totalValue = (random.nextDouble() * 100000).toStringAsFixed(2);
    final isPreferred = random.nextBool();
    final status = ['Active', 'Inactive', 'Blacklisted'][random.nextInt(3)];
    final complianceDocs = [
      'https://example.com/gstin_${code}.pdf',
      'https://example.com/fssai_${code}.pdf',
    ];
    suppliers.add({
      'supplier_id': id,
      'supplier_code': code,
      'supplier_name': 'Supplier $i Pvt Ltd',
      'contact_person_name': 'Contact $i',
      'contact_person_mobile': '90000000${i.toString().padLeft(2, '0')}',
      'alternate_contact_number': '80000000${i.toString().padLeft(2, '0')}',
      'email': 'supplier$i@email.com',
      'address_line1': 'Address Line 1, $i',
      'address_line2': 'Address Line 2, $i',
      'city': 'City $i',
      'state': 'State $i',
      'postal_code': '5000${i.toString().padLeft(2, '0')}',
      'country': 'India',
      'gstin': 'GSTIN${i.toString().padLeft(4, '0')}',
      'pan_number': 'PAN${i.toString().padLeft(4, '0')}',
      'supplier_type': type,
      'business_registration_no': 'BRN${i.toString().padLeft(4, '0')}',
      'website': 'https://supplier$i.com',
      'bank_account_number': '1234567890${i.toString().padLeft(2, '0')}',
      'bank_ifsc_code': 'IFSC000${i.toString().padLeft(3, '0')}',
      'bank_name': 'Bank $i',
      'upi_id': 'supplier$i@upi',
      'payment_terms': 'Net ${[15, 30, 45][random.nextInt(3)]}',
      'preferred_payment_mode': paymentModes[random.nextInt(paymentModes.length)],
      'credit_limit': random.nextInt(100000) + 10000,
      'default_currency': currencies[random.nextInt(currencies.length)],
      'products_supplied': <String>[],
      'contract_start_date': contractStart,
      'contract_end_date': contractEnd,
      'rating': double.parse(rating),
      'on_time_delivery_rate': double.parse(onTime),
      'average_lead_time_days': leadTime,
      'last_supplied_date': now.subtract(Duration(days: random.nextInt(60))),
      'total_orders_supplied': totalOrders,
      'total_order_value': double.parse(totalValue),
      'compliance_documents': complianceDocs,
      'is_preferred_supplier': isPreferred,
      'notes': 'Notes for supplier $i',
      'status': status,
      'created_at': now.subtract(Duration(days: random.nextInt(365))),
      'updated_at': now,
    });
  }
  for (int i = 0; i < mockProducts.length; i++) {
    final supplierIdx = i % suppliers.length;
    final supplierId = supplierIds[supplierIdx];
    mockProducts[i]['default_supplier_id'] = supplierId;
    suppliers[supplierIdx]['products_supplied'].add(mockProducts[i]['sku']);
  }
  final supplierCol = firestore.collection('suppliers');
  for (final s in suppliers) {
    await supplierCol.doc(s['supplier_id']).set(s);
  }
  for (final prod in mockProducts) {
    final productId = prod['sku']!;
    await firestore.collection('products').doc(productId).set({
      'product_id': productId,
      'product_name': prod['name'],
      'product_slug': productId.toLowerCase().replaceAll(' ', '-'),
      'category': prod['category'],
      'subcategory': prod['subcategory'] ?? '',
      'brand': prod['brand'],
      'variant': prod['variant'] ?? '',
      'unit': prod['unit'],
      'description': prod['description'] ?? 'Mock description',
      'sku': prod['sku'],
      'barcode': prod['barcode'] ?? '',
      'hsn_code': prod['hsn_code'] ?? '',
      'mrp': prod['mrp'] ?? 120.0,
      'cost_price': prod['cost_price'] ?? 100.0,
      'selling_price': prod['selling_price'] ?? 110.0,
      'margin_percent': prod['margin_percent'] ?? 10.0,
      'tax_percent': prod['tax_percent'] ?? 18.0,
      'tax_category': prod['tax_category'] ?? 'GST',
      'default_supplier_id': prod['default_supplier_id'] ?? 'SUP-001',
      'min_stock_level': prod['min_stock_level'] ?? 10,
      'max_stock_level': prod['max_stock_level'] ?? 200,
      'lead_time_days': prod['lead_time_days'] ?? 7,
      'shelf_life_days': prod['shelf_life_days'] ?? 365,
      'product_status': prod['product_status'] ?? 'Active',
      'product_type': prod['product_type'] ?? 'Regular',
      'product_image_urls': prod['product_image_urls'] ?? ['https://via.placeholder.com/100'],
      'tags': prod['tags'] ?? ['mock'],
      'created_at': DateTime.now(),
    });
    await firestore.collection('inventory').add({
      'inventory_id': uuid.v4(),
      'product_id': productId,
      'category': prod['category'],
      'brand': prod['brand'],
      'store_location': 'Warehouse ${['A', 'B', 'C'][productId.hashCode % 3]}',
      'quantity_available': 50 + (productId.hashCode % 100),
      'quantity_reserved': 5,
      'quantity_on_order': 10,
      'quantity_damaged': 1,
      'quantity_returned': 2,
      'reorder_point': 20,
      'batch_number': 'BATCH-$productId',
      'expiry_date': DateTime.now().add(Duration(days: 90 + (productId.hashCode % 180))),
      'manufacture_date': DateTime.now().subtract(Duration(days: 30 + (productId.hashCode % 60))),
      'storage_location': 'Aisle ${1 + (productId.hashCode % 5)}, Bin ${1 + (productId.hashCode % 10)}',
      'entry_mode': 'Manual',
      'last_updated': DateTime.now(),
      'stock_status': 'In Stock',
      'added_by': 'Mock User',
      'remarks': 'Bulk mock data',
      'fifo_lifo_flag': 'FIFO',
      'audit_flag': false,
      'auto_restock_enabled': false,
      'last_sold_date': DateTime.now().subtract(Duration(days: 1 + (productId.hashCode % 10))),
      'safety_stock_level': 10,
      'average_daily_usage': 2.5,
      'stock_turnover_ratio': 10.0 + (productId.hashCode % 10),
      'cost_price': prod['cost_price'] ?? 100.0,
    });
  }
}
