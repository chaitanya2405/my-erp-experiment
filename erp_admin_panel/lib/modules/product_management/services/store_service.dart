import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/store_models.dart';

/// 🏪 Store Management Service
/// Comprehensive service for managing physical store locations and operations
/// Integrates with all ERP modules for location-specific operations
class StoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _storesCollection = 'stores';
  static const String _storePerformanceCollection = 'store_performance';
  static const String _storeTransfersCollection = 'store_transfers';

  /// 📋 CORE CRUD OPERATIONS

  /// Get all stores stream for real-time updates
  static Stream<List<Store>> getStoresStream() {
    if (kDebugMode) {
      print('📊 Setting up real-time stores stream...');
    }
    
    return _firestore
        .collection(_storesCollection)
        .orderBy('store_name')
        .snapshots()
        .map((snapshot) {
      final stores = snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
      
      if (kDebugMode) {
        print('🔄 Stores updated: ${stores.length} stores loaded');
      }
      
      return stores;
    });
  }

  /// Get single store by ID
  static Future<Store?> getStoreById(String storeId) async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching store: $storeId');
      }
      
      final doc = await _firestore.collection(_storesCollection).doc(storeId).get();
      
      if (doc.exists) {
        final store = Store.fromFirestore(doc);
        if (kDebugMode) {
          print('✅ Store found: ${store.storeName}');
        }
        return store;
      }
      
      if (kDebugMode) {
        print('❌ Store not found: $storeId');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching store: $e');
      }
      rethrow;
    }
  }

  /// Add new store
  static Future<String> addStore(Store store) async {
    try {
      if (kDebugMode) {
        print('➕ Adding new store: ${store.storeName}');
        print('  • Store Type: ${store.storeType}');
        print('  • Location: ${store.city}, ${store.state}');
        print('  • Contact: ${store.contactPerson}');
      }
      
      // Check for duplicate store code
      final existingStore = await _getStoreByCode(store.storeCode);
      if (existingStore != null) {
        throw Exception('Store code ${store.storeCode} already exists');
      }
      
      final docRef = await _firestore.collection(_storesCollection).add(store.toFirestore());
      
      if (kDebugMode) {
        print('✅ Store added successfully: ${docRef.id}');
        print('  📍 Address: ${store.fullAddress}');
      }
      
      // Initialize store performance tracking
      await _initializeStorePerformance(docRef.id, store.storeCode, store.storeName);
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding store: $e');
      }
      rethrow;
    }
  }

  /// Update existing store
  static Future<void> updateStore(String storeId, Store store) async {
    try {
      if (kDebugMode) {
        print('✏️ Updating store: ${store.storeName}');
      }
      
      final updatedStore = store.copyWith(updatedAt: Timestamp.now());
      await _firestore.collection(_storesCollection).doc(storeId).update(updatedStore.toFirestore());
      
      if (kDebugMode) {
        print('✅ Store updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating store: $e');
      }
      rethrow;
    }
  }

  /// Delete store (soft delete by setting status to Inactive)
  static Future<void> deleteStore(String storeId) async {
    try {
      if (kDebugMode) {
        print('🗑️ Deactivating store: $storeId');
      }
      
      await _firestore.collection(_storesCollection).doc(storeId).update({
        'store_status': 'Inactive',
        'updated_at': Timestamp.now(),
      });
      
      if (kDebugMode) {
        print('✅ Store deactivated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deactivating store: $e');
      }
      rethrow;
    }
  }

  /// 📊 ANALYTICS & PERFORMANCE

  /// Get store performance data
  static Future<List<StorePerformance>> getStorePerformance(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (kDebugMode) {
        print('📈 Fetching performance data for store: $storeId');
      }
      
      Query query = _firestore
          .collection(_storePerformanceCollection)
          .where('store_id', isEqualTo: storeId);
      
      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.orderBy('date', descending: true).get();
      final performance = snapshot.docs.map((doc) => StorePerformance.fromFirestore(doc)).toList();
      
      if (kDebugMode) {
        print('✅ Performance data loaded: ${performance.length} records');
      }
      
      return performance;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching performance data: $e');
      }
      rethrow;
    }
  }

  /// Get all stores performance comparison
  static Future<List<StorePerformance>> getAllStoresPerformance({
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      
      if (kDebugMode) {
        print('📊 Fetching performance comparison for all stores');
        print('  📅 Date: ${targetDate.toString().split(' ')[0]}');
      }
      
      final snapshot = await _firestore
          .collection(_storePerformanceCollection)
          .where('date', isEqualTo: Timestamp.fromDate(targetDate))
          .get();
      
      final performance = snapshot.docs.map((doc) => StorePerformance.fromFirestore(doc)).toList();
      
      if (kDebugMode) {
        print('✅ Performance comparison loaded: ${performance.length} stores');
      }
      
      return performance;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching performance comparison: $e');
      }
      rethrow;
    }
  }

  /// Update daily store performance
  static Future<void> updateStorePerformance(StorePerformance performance) async {
    try {
      if (kDebugMode) {
        print('📊 Updating performance for store: ${performance.storeName}');
        print('  💰 Sales: ₹${performance.totalSales.toStringAsFixed(2)}');
        print('  🛍️ Transactions: ${performance.totalTransactions}');
      }
      
      final docId = '${performance.storeId}_${performance.date.toString().split(' ')[0]}';
      
      await _firestore
          .collection(_storePerformanceCollection)
          .doc(docId)
          .set(performance.toFirestore(), SetOptions(merge: true));
      
      if (kDebugMode) {
        print('✅ Performance updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating performance: $e');
      }
      rethrow;
    }
  }

  /// 🔄 INTER-STORE TRANSFERS

  /// Get store transfers
  static Stream<List<StoreTransfer>> getStoreTransfersStream({
    String? storeId,
    String? status,
  }) {
    if (kDebugMode) {
      print('🔄 Setting up store transfers stream');
    }
    
    Query query = _firestore.collection(_storeTransfersCollection);
    
    if (storeId != null) {
      // Get transfers where store is either sender or receiver
      query = query.where('from_store_id', isEqualTo: storeId);
      // Note: Firebase doesn't support OR queries easily, so we'll filter in memory
    }
    
    if (status != null) {
      query = query.where('transfer_status', isEqualTo: status);
    }
    
    return query.orderBy('request_date', descending: true).snapshots().map((snapshot) {
      final transfers = snapshot.docs.map((doc) => StoreTransfer.fromFirestore(doc)).toList();
      
      if (kDebugMode) {
        print('🔄 Store transfers updated: ${transfers.length} transfers');
      }
      
      return transfers;
    });
  }

  /// Create store transfer request
  static Future<String> createStoreTransfer(StoreTransfer transfer) async {
    try {
      if (kDebugMode) {
        print('📦 Creating store transfer request');
        print('  📍 From: ${transfer.fromStoreName}');
        print('  📍 To: ${transfer.toStoreName}');
        print('  📋 Items: ${transfer.items.length}');
        print('  💰 Total Value: ₹${transfer.totalValue.toStringAsFixed(2)}');
      }
      
      final docRef = await _firestore.collection(_storeTransfersCollection).add(transfer.toFirestore());
      
      if (kDebugMode) {
        print('✅ Transfer request created: ${docRef.id}');
      }
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating transfer request: $e');
      }
      rethrow;
    }
  }

  /// Update transfer status
  static Future<void> updateTransferStatus(
    String transferId,
    String newStatus, {
    String? approvedBy,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Updating transfer status: $transferId → $newStatus');
      }
      
      final updateData = {
        'transfer_status': newStatus,
        'updated_at': Timestamp.now(),
      };
      
      if (approvedBy != null) {
        updateData['approved_by'] = approvedBy;
        updateData['approval_date'] = Timestamp.now();
      }
      
      if (newStatus == 'Completed') {
        updateData['completion_date'] = Timestamp.now();
      }
      
      await _firestore.collection(_storeTransfersCollection).doc(transferId).update(updateData);
      
      if (kDebugMode) {
        print('✅ Transfer status updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating transfer status: $e');
      }
      rethrow;
    }
  }

  /// 🔍 SEARCH & FILTER OPERATIONS

  /// Search stores by various criteria
  static Future<List<Store>> searchStores({
    String? searchTerm,
    String? storeType,
    String? status,
    String? city,
    String? state,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 Searching stores with criteria:');
        if (searchTerm != null) print('  🔤 Search: $searchTerm');
        if (storeType != null) print('  🏪 Type: $storeType');
        if (status != null) print('  ⭐ Status: $status');
        if (city != null) print('  🏙️ City: $city');
        if (state != null) print('  📍 State: $state');
      }
      
      Query query = _firestore.collection(_storesCollection);
      
      if (storeType != null) {
        query = query.where('store_type', isEqualTo: storeType);
      }
      
      if (status != null) {
        query = query.where('store_status', isEqualTo: status);
      }
      
      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }
      
      if (state != null) {
        query = query.where('state', isEqualTo: state);
      }
      
      final snapshot = await query.get();
      List<Store> stores = snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
      
      // Filter by search term if provided (done in memory for flexibility)
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final searchLower = searchTerm.toLowerCase();
        stores = stores.where((store) {
          return store.storeName.toLowerCase().contains(searchLower) ||
                 store.storeCode.toLowerCase().contains(searchLower) ||
                 store.contactPerson.toLowerCase().contains(searchLower) ||
                 store.city.toLowerCase().contains(searchLower) ||
                 store.state.toLowerCase().contains(searchLower);
        }).toList();
      }
      
      if (kDebugMode) {
        print('✅ Search completed: ${stores.length} stores found');
      }
      
      return stores;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching stores: $e');
      }
      rethrow;
    }
  }

  /// Get stores by type
  static Future<List<Store>> getStoresByType(String storeType) async {
    return await searchStores(storeType: storeType);
  }

  /// Get active stores only
  static Future<List<Store>> getActiveStores() async {
    return await searchStores(status: 'Active');
  }

  /// Get stores in specific city
  static Future<List<Store>> getStoresByCity(String city) async {
    return await searchStores(city: city);
  }

  /// 🎯 CUSTOMER APP INTEGRATION

  /// Get nearest stores based on coordinates
  static Future<List<Store>> getNearestStores({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int limit = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('📍 Finding nearest stores to ($latitude, $longitude)');
        print('  📏 Radius: ${radiusKm}km');
        print('  📊 Limit: $limit stores');
      }
      
      // Get all active stores with coordinates
      final stores = await searchStores(status: 'Active');
      final storesWithCoordinates = stores.where((store) =>
          store.latitude != null && store.longitude != null).toList();
      
      // Calculate distances and sort
      final storesWithDistance = storesWithCoordinates.map((store) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          store.latitude!,
          store.longitude!,
        );
        return {'store': store, 'distance': distance};
      }).where((item) => (item['distance'] as double) <= radiusKm).toList();
      
      storesWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      
      final nearestStores = storesWithDistance
          .take(limit)
          .map((item) => item['store'] as Store)
          .toList();
      
      if (kDebugMode) {
        print('✅ Found ${nearestStores.length} nearby stores');
        for (int i = 0; i < nearestStores.length && i < 3; i++) {
          final storeData = storesWithDistance[i];
          print('  ${i + 1}. ${nearestStores[i].storeName} - ${(storeData['distance'] as double).toStringAsFixed(2)}km');
        }
      }
      
      return nearestStores;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding nearest stores: $e');
      }
      rethrow;
    }
  }

  /// Check product availability in specific store
  static Future<Map<String, dynamic>> checkProductAvailability(
    String storeId,
    String productId,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 Checking product availability in store');
        print('  🏪 Store: $storeId');
        print('  📦 Product: $productId');
      }
      
      // Query inventory for this store and product
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .where('store_id', isEqualTo: storeId)
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();
      
      if (inventorySnapshot.docs.isNotEmpty) {
        final inventoryData = inventorySnapshot.docs.first.data();
        final currentQuantity = inventoryData['current_quantity'] ?? 0;
        final isAvailable = currentQuantity > 0;
        
        if (kDebugMode) {
          print('✅ Product availability checked: ${isAvailable ? "Available" : "Out of Stock"}');
          print('  📊 Quantity: $currentQuantity');
        }
        
        return {
          'available': isAvailable,
          'quantity': currentQuantity,
          'product_id': productId,
          'store_id': storeId,
        };
      }
      
      if (kDebugMode) {
        print('❌ Product not found in store inventory');
      }
      
      return {
        'available': false,
        'quantity': 0,
        'product_id': productId,
        'store_id': storeId,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking product availability: $e');
      }
      rethrow;
    }
  }

  /// 🔧 ADVANCED ERP FEATURES

  /// Get store analytics summary
  static Future<Map<String, dynamic>> getStoreAnalytics() async {
    try {
      if (kDebugMode) {
        print('📊 Calculating store analytics...');
      }
      
      final allStores = await searchStores();
      final activeStores = allStores.where((store) => store.storeStatus == 'Active').toList();
      final inactiveStores = allStores.where((store) => store.storeStatus == 'Inactive').toList();
      final underRenovation = allStores.where((store) => store.storeStatus == 'Under Renovation').toList();
      
      final totalSales = activeStores.fold<double>(0, (sum, store) => sum + (store.todaysSales ?? 0));
      final totalTransactions = activeStores.fold<int>(0, (sum, store) => sum + (store.todaysTransactions ?? 0));
      final totalStaff = activeStores.fold<int>(0, (sum, store) => sum + (store.currentStaffCount ?? 0));
      final totalInventoryItems = activeStores.fold<int>(0, (sum, store) => sum + (store.inventoryItemCount ?? 0));
      
      final storesByType = <String, int>{};
      for (final store in allStores) {
        storesByType[store.storeType] = (storesByType[store.storeType] ?? 0) + 1;
      }
      
      final storesByCity = <String, int>{};
      for (final store in allStores) {
        storesByCity[store.city] = (storesByCity[store.city] ?? 0) + 1;
      }
      
      final averageTransactionValue = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;
      final averageStoreSize = activeStores.where((s) => s.storeAreaSqft != null).fold<double>(0, (sum, store) => sum + store.storeAreaSqft!) / activeStores.where((s) => s.storeAreaSqft != null).length;
      
      if (kDebugMode) {
        print('✅ Store analytics calculated');
        print('  🏪 Total Stores: ${allStores.length}');
        print('  ✅ Active: ${activeStores.length}');
        print('  💰 Total Sales: ₹${totalSales.toStringAsFixed(2)}');
        print('  🛍️ Total Transactions: $totalTransactions');
      }
      
      return {
        'total_stores': allStores.length,
        'active_stores': activeStores.length,
        'inactive_stores': inactiveStores.length,
        'under_renovation': underRenovation.length,
        'total_sales': totalSales,
        'total_transactions': totalTransactions,
        'total_staff': totalStaff,
        'total_inventory_items': totalInventoryItems,
        'average_transaction_value': averageTransactionValue,
        'average_store_size': averageStoreSize,
        'stores_by_type': storesByType,
        'stores_by_city': storesByCity,
        'stores_needing_attention': activeStores.where((s) => s.needsAttention).length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating store analytics: $e');
      }
      rethrow;
    }
  }

  /// Get low performing stores
  static Future<List<Store>> getLowPerformingStores({
    double performanceThreshold = 50.0,
  }) async {
    try {
      if (kDebugMode) {
        print('📉 Finding low performing stores (threshold: $performanceThreshold%)');
      }
      
      final activeStores = await searchStores(status: 'Active');
      final lowPerformingStores = activeStores.where((store) {
        return store.monthlyAchievementPercentage < performanceThreshold;
      }).toList();
      
      // Sort by performance (worst first)
      lowPerformingStores.sort((a, b) => a.monthlyAchievementPercentage.compareTo(b.monthlyAchievementPercentage));
      
      if (kDebugMode) {
        print('✅ Found ${lowPerformingStores.length} low performing stores');
      }
      
      return lowPerformingStores;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding low performing stores: $e');
      }
      rethrow;
    }
  }

  /// Get top performing stores
  static Future<List<Store>> getTopPerformingStores({
    int limit = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('🏆 Finding top performing stores (limit: $limit)');
      }
      
      final activeStores = await searchStores(status: 'Active');
      final storesWithTargets = activeStores.where((store) => 
          store.monthlyTarget != null && store.monthlyAchieved != null).toList();
      
      // Sort by performance (best first)
      storesWithTargets.sort((a, b) => b.monthlyAchievementPercentage.compareTo(a.monthlyAchievementPercentage));
      
      final topStores = storesWithTargets.take(limit).toList();
      
      if (kDebugMode) {
        print('✅ Found ${topStores.length} top performing stores');
      }
      
      return topStores;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding top performing stores: $e');
      }
      rethrow;
    }
  }

  /// Update store real-time metrics
  static Future<void> updateStoreMetrics(String storeId, {
    double? todaysSales,
    int? todaysTransactions,
    int? customerFootfall,
    double? conversionRate,
    int? currentStaffCount,
  }) async {
    try {
      if (kDebugMode) {
        print('📊 Updating real-time metrics for store: $storeId');
      }
      
      final updateData = <String, dynamic>{
        'updated_at': Timestamp.now(),
      };
      
      if (todaysSales != null) {
        updateData['todays_sales'] = todaysSales;
      }
      if (todaysTransactions != null) {
        updateData['todays_transactions'] = todaysTransactions;
        if (todaysSales != null) {
          updateData['average_transaction_value'] = todaysSales / todaysTransactions;
        }
      }
      if (customerFootfall != null) {
        updateData['customer_footfall'] = customerFootfall;
        if (todaysTransactions != null) {
          updateData['conversion_rate'] = (todaysTransactions / customerFootfall) * 100;
        }
      }
      if (conversionRate != null) {
        updateData['conversion_rate'] = conversionRate;
      }
      if (currentStaffCount != null) {
        updateData['current_staff_count'] = currentStaffCount;
      }
      
      await _firestore.collection(_storesCollection).doc(storeId).update(updateData);
      
      if (kDebugMode) {
        print('✅ Store metrics updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating store metrics: $e');
      }
      rethrow;
    }
  }

  /// Bulk update stores
  static Future<void> bulkUpdateStores(List<Map<String, dynamic>> updates) async {
    try {
      if (kDebugMode) {
        print('🔄 Bulk updating ${updates.length} stores');
      }
      
      final batch = _firestore.batch();
      
      for (final update in updates) {
        final storeId = update['store_id'];
        final data = Map<String, dynamic>.from(update);
        data.remove('store_id');
        data['updated_at'] = Timestamp.now();
        
        final docRef = _firestore.collection(_storesCollection).doc(storeId);
        batch.update(docRef, data);
      }
      
      await batch.commit();
      
      if (kDebugMode) {
        print('✅ Bulk update completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in bulk update: $e');
      }
      rethrow;
    }
  }

  /// Export stores data
  static Future<List<Map<String, dynamic>>> exportStoresData({
    String? storeType,
    String? status,
    List<String>? fields,
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Exporting stores data');
      }
      
      final stores = await searchStores(storeType: storeType, status: status);
      final exportData = <Map<String, dynamic>>[];
      
      for (final store in stores) {
        final storeData = store.toFirestore();
        
        if (fields != null && fields.isNotEmpty) {
          final filteredData = <String, dynamic>{};
          for (final field in fields) {
            if (storeData.containsKey(field)) {
              filteredData[field] = storeData[field];
            }
          }
          exportData.add(filteredData);
        } else {
          exportData.add(storeData);
        }
      }
      
      if (kDebugMode) {
        print('✅ Export completed: ${exportData.length} stores exported');
      }
      
      return exportData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error exporting stores data: $e');
      }
      rethrow;
    }
  }

  /// Get stores requiring attention
  static Future<List<Store>> getStoresRequiringAttention() async {
    try {
      if (kDebugMode) {
        print('⚠️ Finding stores requiring attention...');
      }
      
      final activeStores = await searchStores(status: 'Active');
      final attentionStores = activeStores.where((store) => store.needsAttention).toList();
      
      // Sort by urgency (most urgent first)
      attentionStores.sort((a, b) {
        final aReasons = a.attentionReasons.length;
        final bReasons = b.attentionReasons.length;
        return bReasons.compareTo(aReasons);
      });
      
      if (kDebugMode) {
        print('✅ Found ${attentionStores.length} stores requiring attention');
      }
      
      return attentionStores;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding stores requiring attention: $e');
      }
      rethrow;
    }
  }

  /// Validate store data
  static Future<Map<String, dynamic>> validateStoreData(Store store) async {
    try {
      if (kDebugMode) {
        print('✅ Validating store data for: ${store.storeName}');
      }
      
      final errors = <String>[];
      final warnings = <String>[];
      
      // Required field validation
      if (store.storeCode.isEmpty) errors.add('Store code is required');
      if (store.storeName.isEmpty) errors.add('Store name is required');
      if (store.contactPerson.isEmpty) errors.add('Contact person is required');
      if (store.contactNumber.isEmpty) errors.add('Contact number is required');
      if (store.email.isEmpty) errors.add('Email is required');
      if (store.addressLine1.isEmpty) errors.add('Address line 1 is required');
      if (store.city.isEmpty) errors.add('City is required');
      if (store.state.isEmpty) errors.add('State is required');
      if (store.postalCode.isEmpty) errors.add('Postal code is required');
      if (store.country.isEmpty) errors.add('Country is required');
      
      // Format validation
      if (store.email.isNotEmpty && !store.email.contains('@')) {
        errors.add('Invalid email format');
      }
      
      if (store.contactNumber.isNotEmpty && store.contactNumber.length < 10) {
        errors.add('Contact number must be at least 10 digits');
      }
      
      // Business logic validation
      if (store.gstRegistrationNumber == null || store.gstRegistrationNumber!.isEmpty) {
        warnings.add('GST registration number is recommended');
      }
      
      if (store.latitude == null || store.longitude == null) {
        warnings.add('GPS coordinates are recommended for location services');
      }
      
      if (store.storeAreaSqft == null || store.storeAreaSqft! <= 0) {
        warnings.add('Store area information is recommended');
      }
      
      // Check for duplicate store code
      final existingStore = await _getStoreByCode(store.storeCode);
      if (existingStore != null && existingStore.storeId != store.storeId) {
        errors.add('Store code already exists');
      }
      
      if (kDebugMode) {
        print('✅ Validation completed');
        print('  ❌ Errors: ${errors.length}');
        print('  ⚠️ Warnings: ${warnings.length}');
      }
      
      return {
        'is_valid': errors.isEmpty,
        'errors': errors,
        'warnings': warnings,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error validating store data: $e');
      }
      rethrow;
    }
  }

  /// Sync with POS system
  static Future<void> syncWithPOSSystem(String storeId) async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing store with POS system: $storeId');
      }
      
      final store = await getStoreById(storeId);
      if (store == null) {
        throw Exception('Store not found');
      }
      
      // Calculate today's metrics from POS transactions
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final posTransactions = await _firestore
          .collection('pos_transactions')
          .where('store_id', isEqualTo: storeId)
          .where('transaction_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('transaction_date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      
      final totalSales = posTransactions.docs.fold<double>(0, (sum, doc) {
        final data = doc.data();
        return sum + (data['total_amount']?.toDouble() ?? 0);
      });
      
      final totalTransactions = posTransactions.docs.length;
      
      // Update store metrics
      await updateStoreMetrics(
        storeId,
        todaysSales: totalSales,
        todaysTransactions: totalTransactions,
      );
      
      if (kDebugMode) {
        print('✅ POS sync completed');
        print('  💰 Sales: ₹${totalSales.toStringAsFixed(2)}');
        print('  🛍️ Transactions: $totalTransactions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing with POS system: $e');
      }
      rethrow;
    }
  }

  /// Get store dashboard data
  static Future<Map<String, dynamic>> getStoreDashboardData(String storeId) async {
    try {
      if (kDebugMode) {
        print('📊 Loading dashboard data for store: $storeId');
      }
      
      final store = await getStoreById(storeId);
      if (store == null) {
        throw Exception('Store not found');
      }
      
      // Get recent performance data
      final recentPerformance = await getStorePerformance(
        storeId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      // Get recent transfers
      final recentTransfers = await getStoreTransfersStream(storeId: storeId)
          .take(1)
          .single;
      
      // Get inventory summary
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .where('store_id', isEqualTo: storeId)
          .get();
      
      final inventoryItems = inventorySnapshot.docs.length;
      final lowStockItems = inventorySnapshot.docs.where((doc) {
        final data = doc.data();
        final currentQty = data['current_quantity'] ?? 0;
        final minQty = data['minimum_quantity'] ?? 0;
        return currentQty <= minQty;
      }).length;
      
      if (kDebugMode) {
        print('✅ Dashboard data loaded');
      }
      
      return {
        'store': store.toFirestore(),
        'recent_performance': recentPerformance.map((p) => p.toFirestore()).toList(),
        'recent_transfers': recentTransfers.map((t) => t.toFirestore()).toList(),
        'inventory_items': inventoryItems,
        'low_stock_items': lowStockItems,
        'performance_trends': _calculatePerformanceTrends(recentPerformance),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading dashboard data: $e');
      }
      rethrow;
    }
  }

  /// Calculate performance trends
  static Map<String, dynamic> _calculatePerformanceTrends(List<StorePerformance> performances) {
    if (performances.isEmpty) return {};
    
    performances.sort((a, b) => a.date.compareTo(b.date));
    
    final totalSalesTrend = performances.map((p) => p.totalSales).toList();
    final transactionsTrend = performances.map((p) => p.totalTransactions).toList();
    
    return {
      'sales_trend': totalSalesTrend,
      'transactions_trend': transactionsTrend,
      'avg_daily_sales': totalSalesTrend.reduce((a, b) => a + b) / totalSalesTrend.length,
      'avg_daily_transactions': transactionsTrend.reduce((a, b) => a + b) / transactionsTrend.length,
    };
  }

  /// 🛠️ HELPER METHODS

  /// Get store by code
  static Future<Store?> _getStoreByCode(String storeCode) async {
    final snapshot = await _firestore
        .collection(_storesCollection)
        .where('store_code', isEqualTo: storeCode)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return Store.fromFirestore(snapshot.docs.first);
    }
    
    return null;
  }

  /// Initialize store performance tracking
  static Future<void> _initializeStorePerformance(
    String storeId,
    String storeCode,
    String storeName,
  ) async {
    try {
      final today = DateTime.now();
      final performance = StorePerformance(
        storeId: storeId,
        storeCode: storeCode,
        storeName: storeName,
        date: today,
        totalSales: 0.0,
        totalTransactions: 0,
        customerCount: 0,
        averageTransactionValue: 0.0,
        grossProfit: 0.0,
        netProfit: 0.0,
        inventoryTurnover: 0,
        footfallCount: 0.0,
        conversionRate: 0.0,
      );
      
      await updateStorePerformance(performance);
      
      if (kDebugMode) {
        print('✅ Store performance tracking initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Warning: Could not initialize performance tracking: $e');
      }
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth radius in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
