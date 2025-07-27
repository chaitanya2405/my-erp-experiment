import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import all models and services from the unified app_services.dart file
import '../app_services.dart';

// ==================== CORE SERVICES ====================

class CacheService {
  final Map<String, dynamic> _cache = {};
  T? get<T>(String key) => _cache[key] as T?;
  void set<T>(String key, T value) => _cache[key] = value;
  void remove(String key) => _cache.remove(key);
  void clear() => _cache.clear();
}

abstract class BaseService<T> {
  final String collectionPath;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cache;

  BaseService(this.collectionPath, this._cache);

  T fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore(T entity);

  Future<T?> create(T entity) async {
    try {
      final data = toFirestore(entity);
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        data['created_by'] = user.uid;
        data['updated_by'] = user.uid;
      }
      final docRef = await _firestore.collection(collectionPath).add(data);
      final doc = await docRef.get();
      final result = fromFirestore(doc);
      _cache.set('$collectionPath:${doc.id}', result);
      return result;
    } catch (e) {
      debugPrint('Error creating in $collectionPath: $e');
      return null;
    }
  }

  Future<T?> getById(String id) async {
    try {
      final cached = _cache.get<T>('$collectionPath:$id');
      if (cached != null) return cached;
      final doc = await _firestore.collection(collectionPath).doc(id).get();
      if (!doc.exists) return null;
      final result = fromFirestore(doc);
      _cache.set('$collectionPath:$id', result);
      return result;
    } catch (e) {
      debugPrint('Error getting from $collectionPath by ID: $e');
      return null;
    }
  }

  Stream<List<T>> getAll() {
    try {
      return _firestore
          .collection(collectionPath)
          .where('deleted_at', isNull: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList());
    } catch (e) {
      debugPrint('Error getting all from $collectionPath: $e');
      return Stream.value([]);
    }
  }

  Future<T?> update(String id, T entity) async {
    try {
      final data = toFirestore(entity);
      data['updated_at'] = FieldValue.serverTimestamp();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) data['updated_by'] = user.uid;
      await _firestore.collection(collectionPath).doc(id).update(data);
      _cache.remove('$collectionPath:$id');
      return await getById(id);
    } catch (e) {
      debugPrint('Error updating in $collectionPath: $e');
      return null;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update({
        'deleted_at': FieldValue.serverTimestamp(),
        'deleted_by': FirebaseAuth.instance.currentUser?.uid,
      });
      _cache.remove('$collectionPath:$id');
      return true;
    } catch (e) {
      debugPrint('Error deleting from $collectionPath: $e');
      return false;
    }
  }
}

// ==================== MODULE SERVICES ====================

class ProductService extends BaseService<Product> {
  ProductService(CacheService cache) : super('products', cache);
  @override
  Product fromFirestore(DocumentSnapshot doc) => Product.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(Product entity) => entity.toMap();
}

// Custom inventory service implementation that extends the base service
class InventoryService extends BaseService<InventoryItem> {
  InventoryService(CacheService cache) : super('inventory', cache);
  
  @override
  InventoryItem fromFirestore(DocumentSnapshot doc) => InventoryItem.fromFirestore(doc);
  
  @override
  Map<String, dynamic> toFirestore(InventoryItem entity) => entity.toMap();

  Future<InventoryItem?> getByProductId(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(collectionPath)
          .where('product_id', isEqualTo: productId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting inventory by product ID: $e');
      return null;
    }
  }
  
  Future<bool> adjustQuantity(String inventoryId, int adjustment) async {
    try {
      await _firestore.collection(collectionPath).doc(inventoryId).update({
        'current_stock': FieldValue.increment(adjustment),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adjusting inventory quantity: $e');
      return false;
    }
  }
}

class SupplierService extends BaseService<Supplier> {
  SupplierService(CacheService cache) : super('suppliers', cache);
  @override
  Supplier fromFirestore(DocumentSnapshot doc) => Supplier.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(Supplier entity) => entity.toMap();
}

class PurchaseOrderService extends BaseService<PurchaseOrder> {
  final InventoryService _inventoryService;
  PurchaseOrderService(CacheService cache, this._inventoryService) : super('purchase_orders', cache);
  @override
  PurchaseOrder fromFirestore(DocumentSnapshot doc) => PurchaseOrder.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(PurchaseOrder entity) => entity.toMap();
  
  Future<bool> updateStatus(String poId, String status) async {
    try {
      await _firestore.collection(collectionPath).doc(poId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating PO status: $e');
      return false;
    }
  }
}

class CustomerOrderService extends BaseService<AppOrder> {
  final InventoryService _inventoryService;
  CustomerOrderService(CacheService cache, this._inventoryService) : super('orders', cache);
  @override
  AppOrder fromFirestore(DocumentSnapshot doc) => AppOrder.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(AppOrder entity) => entity.toMap();
}

class CustomerProfileService extends BaseService<CustomerProfile> {
  CustomerProfileService(CacheService cache) : super('customer_profiles', cache);
  @override
  CustomerProfile fromFirestore(DocumentSnapshot doc) => CustomerProfile.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(CustomerProfile entity) => entity.toMap();
}

class UserProfileService extends BaseService<UserProfile> {
  UserProfileService(CacheService cache) : super('users', cache);
  @override
  UserProfile fromFirestore(DocumentSnapshot doc) => UserProfile.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(UserProfile entity) => entity.toMap();

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await getById(user.uid);
  }
}

class StoreService extends BaseService<Store> {
  StoreService(CacheService cache) : super('stores', cache);
  
  @override
  Store fromFirestore(DocumentSnapshot doc) => Store.fromFirestore(doc);
  
  @override
  Map<String, dynamic> toFirestore(Store entity) => entity.toFirestore();

  // Additional store-specific methods
  Future<List<Store>> searchStores({
    String? searchTerm,
    String? storeType,
    String? status,
    String? city,
    String? state,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath).where('deleted_at', isNull: true);
      
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
      List<Store> stores = snapshot.docs.map((doc) => fromFirestore(doc)).toList();
      
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
      
      return stores;
    } catch (e) {
      debugPrint('Error searching stores: $e');
      return [];
    }
  }

  Future<Store?> addStore(Store store) async {
    // Check for duplicate store code
    final existingStore = await _getStoreByCode(store.storeCode);
    if (existingStore != null) {
      throw Exception('Store code ${store.storeCode} already exists');
    }
    
    return await create(store);
  }

  Future<Store?> updateStore(String storeId, Store store) async {
    return await update(storeId, store);
  }

  Future<bool> deleteStore(String storeId) async {
    // Soft delete by setting status to Inactive
    try {
      await _firestore.collection(collectionPath).doc(storeId).update({
        'store_status': 'Inactive',
        'updated_at': FieldValue.serverTimestamp(),
      });
      _cache.remove('$collectionPath:$storeId');
      return true;
    } catch (e) {
      debugPrint('Error deactivating store: $e');
      return false;
    }
  }

  Stream<List<Store>> getStoresStream() {
    try {
      return _firestore
          .collection(collectionPath)
          .where('deleted_at', isNull: true)
          .orderBy('store_name')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList());
    } catch (e) {
      debugPrint('Error getting stores stream: $e');
      return Stream.value([]);
    }
  }

  Future<Store?> _getStoreByCode(String storeCode) async {
    try {
      final snapshot = await _firestore
          .collection(collectionPath)
          .where('store_code', isEqualTo: storeCode)
          .where('deleted_at', isNull: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return fromFirestore(snapshot.docs.first);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting store by code: $e');
      return null;
    }
  }
}

// ==================== VALIDATION SERVICE ====================

class ValidationService {
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool validateRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool validateMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }
}

// ==================== AUDIT SERVICE ====================

class AuditService {
  Future<void> logAction(String action, Map<String, dynamic> details) async {
    try {
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      debugPrint('Error logging audit action: $e');
    }
  }
}

// ==================== RIVERPOD PROVIDERS ====================

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final validationServiceProvider = Provider<ValidationService>((ref) => ValidationService());

final auditServiceProvider = Provider<AuditService>((ref) => AuditService());

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(ref.watch(cacheServiceProvider));
});

// Re-export providers from app_services.dart
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(cacheServiceProvider));
});

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(ref.watch(cacheServiceProvider));
});

final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  return PurchaseOrderService(
    ref.watch(cacheServiceProvider),
    ref.watch(inventoryServiceProvider),
  );
});

final customerOrderServiceProvider = Provider<CustomerOrderService>((ref) {
  return CustomerOrderService(
    ref.watch(cacheServiceProvider),
    ref.watch(inventoryServiceProvider),
  );
});

final customerProfileServiceProvider = Provider<CustomerProfileService>((ref) {
  return CustomerProfileService(ref.watch(cacheServiceProvider));
});

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(ref.watch(cacheServiceProvider));
});

final storeServiceProvider = Provider<StoreService>((ref) {
  return StoreService(ref.watch(cacheServiceProvider));
});
