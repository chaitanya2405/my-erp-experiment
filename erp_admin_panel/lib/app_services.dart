import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================================================
// MINIMAL MODEL DEFINITIONS
// ==========================================================================
// These classes provide the necessary structure for the services to function.
// Ensure your actual model files in `lib/models/` match these fields and methods.

class Product {
  final String productId;
  final String productName;
  final String sku;
  final String category;
  final int minStockLevel;
  final int maxStockLevel;

  Product({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.category,
    this.minStockLevel = 10,
    this.maxStockLevel = 100,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      productId: doc.id,
      productName: data['product_name'] ?? '',
      sku: data['sku'] ?? '',
      category: data['category'] ?? 'Uncategorized',
      minStockLevel: data['min_stock_level'] ?? 10,
      maxStockLevel: data['max_stock_level'] ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'sku': sku,
      'category': category,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
    };
  }
}

class InventoryItem {
  final String inventoryId;
  final String productId;
  final int currentStock;
  final int minStockLevel;

  InventoryItem({
    required this.inventoryId,
    required this.productId,
    required this.currentStock,
    required this.minStockLevel,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InventoryItem(
      inventoryId: doc.id,
      productId: data['product_id'] ?? '',
      currentStock: data['current_stock'] ?? 0,
      minStockLevel: data['min_stock_level'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
    };
  }
}

class Supplier {
  final String supplierId;
  final String supplierName;

  Supplier({required this.supplierId, required this.supplierName});

  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Supplier(
      supplierId: doc.id,
      supplierName: data['supplier_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'supplier_name': supplierName};
  }
}

class PurchaseOrder {
  final String poId;
  final String status;

  PurchaseOrder({required this.poId, required this.status});

  factory PurchaseOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PurchaseOrder(
      poId: doc.id,
      status: data['status'] ?? 'draft',
    );
  }

  Map<String, dynamic> toMap() {
    return {'status': status};
  }
}

// Aliased to avoid conflict with Flutter's Order class
class AppOrder {
  final String orderId;
  final String status;
  final double totalValue;

  AppOrder({required this.orderId, required this.status, required this.totalValue});

  factory AppOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppOrder(
      orderId: doc.id,
      status: data['status'] ?? 'pending',
      totalValue: (data['total_value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'total_value': totalValue,
    };
  }
}

class CustomerProfile {
  final String customerId;
  final String customerName;
  final String? segment;

  CustomerProfile({required this.customerId, required this.customerName, this.segment});

  factory CustomerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerProfile(
      customerId: doc.id,
      customerName: data['customer_name'] ?? '',
      segment: data['segment'] ?? 'Regular',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'segment': segment,
    };
  }
}

class UserProfile {
  final String userId;
  final String displayName;

  UserProfile({required this.userId, required this.displayName});

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      userId: doc.id,
      displayName: data['display_name'] ?? 'No Name',
    );
  }

  Map<String, dynamic> toMap() {
    return {'display_name': displayName};
  }
}

class Store {
  final String storeId;
  final String storeCode;
  final String storeName;
  final String storeType;
  final String contactPerson;
  final String contactNumber;
  final String email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String operatingHours;
  final double? storeAreaSqft;
  final String? gstRegistrationNumber;
  final String? fssaiLicense;
  final String storeStatus;
  final String? parentCompany;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int? currentStaffCount;
  final double? todaysSales;
  final int? todaysTransactions;
  final int? inventoryItemCount;
  final double? averageTransactionValue;
  final String? managerName;
  final bool? isOperational;
  final double? monthlyTarget;
  final double? monthlyAchieved;
  final double? yearlyTarget;
  final double? yearlyAchieved;
  final int? customerFootfall;
  final double? conversionRate;
  final List<String>? tags;
  final Map<String, dynamic>? customFields;

  Store({
    required this.storeId,
    required this.storeCode,
    required this.storeName,
    required this.storeType,
    required this.contactPerson,
    required this.contactNumber,
    required this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.operatingHours,
    this.storeAreaSqft,
    this.gstRegistrationNumber,
    this.fssaiLicense,
    required this.storeStatus,
    this.parentCompany,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.currentStaffCount,
    this.todaysSales,
    this.todaysTransactions,
    this.inventoryItemCount,
    this.averageTransactionValue,
    this.managerName,
    this.isOperational,
    this.monthlyTarget,
    this.monthlyAchieved,
    this.yearlyTarget,
    this.yearlyAchieved,
    this.customerFootfall,
    this.conversionRate,
    this.tags,
    this.customFields,
  });

  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Store(
      storeId: doc.id,
      storeCode: data['store_code'] ?? '',
      storeName: data['store_name'] ?? '',
      storeType: data['store_type'] ?? 'Retail',
      contactPerson: data['contact_person'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      email: data['email'] ?? '',
      addressLine1: data['address_line1'] ?? '',
      addressLine2: data['address_line2'],
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postal_code'] ?? '',
      country: data['country'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      operatingHours: data['operating_hours'] ?? '9:00 AM - 9:00 PM',
      storeAreaSqft: data['store_area_sqft']?.toDouble(),
      gstRegistrationNumber: data['gst_registration_number'],
      fssaiLicense: data['fssai_license'],
      storeStatus: data['store_status'] ?? 'Active',
      parentCompany: data['parent_company'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
      currentStaffCount: data['current_staff_count'],
      todaysSales: data['todays_sales']?.toDouble(),
      todaysTransactions: data['todays_transactions'],
      inventoryItemCount: data['inventory_item_count'],
      averageTransactionValue: data['average_transaction_value']?.toDouble(),
      managerName: data['manager_name'],
      isOperational: data['is_operational'],
      monthlyTarget: data['monthly_target']?.toDouble(),
      monthlyAchieved: data['monthly_achieved']?.toDouble(),
      yearlyTarget: data['yearly_target']?.toDouble(),
      yearlyAchieved: data['yearly_achieved']?.toDouble(),
      customerFootfall: data['customer_footfall'],
      conversionRate: data['conversion_rate']?.toDouble(),
      tags: data['tags'] == null ? null : List<String>.from(data['tags']),
      customFields: data['custom_fields'] == null ? null : Map<String, dynamic>.from(data['custom_fields']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_code': storeCode,
      'store_name': storeName,
      'store_type': storeType,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'email': email,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'operating_hours': operatingHours,
      'store_area_sqft': storeAreaSqft,
      'gst_registration_number': gstRegistrationNumber,
      'fssai_license': fssaiLicense,
      'store_status': storeStatus,
      'parent_company': parentCompany,
      'current_staff_count': currentStaffCount,
      'todays_sales': todaysSales,
      'todays_transactions': todaysTransactions,
      'inventory_item_count': inventoryItemCount,
      'average_transaction_value': averageTransactionValue,
      'manager_name': managerName,
      'is_operational': isOperational,
      'monthly_target': monthlyTarget,
      'monthly_achieved': monthlyAchieved,
      'yearly_target': yearlyTarget,
      'yearly_achieved': yearlyAchieved,
      'customer_footfall': customerFootfall,
      'conversion_rate': conversionRate,
      'tags': tags,
      'custom_fields': customFields,
    };
  }

  Map<String, dynamic> toFirestore() => toMap();

  // Utility getters for business logic
  bool get needsAttention {
    if (storeStatus != 'Active') return true;
    if (monthlyTarget != null && monthlyAchieved != null) {
      final percentage = (monthlyAchieved! / monthlyTarget!) * 100;
      if (percentage < 50) return true;
    }
    if (todaysSales != null && todaysSales! < 1000) return true;
    return false;
  }

  double get monthlyAchievementPercentage {
    if (monthlyTarget == null || monthlyAchieved == null || monthlyTarget == 0) return 0.0;
    return (monthlyAchieved! / monthlyTarget!) * 100;
  }
}

// ==========================================================================
// CORE SERVICES
// ==========================================================================

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

  Future<void> add(T entity) async {
    try {
      await _firestore.collection(collectionPath).add(toFirestore(entity));
      // Clear cache to refresh data
      _cache.clear();
    } catch (e) {
      debugPrint('Error adding to $collectionPath: $e');
      rethrow;
    }
  }

  Future<void> update(String id, T entity) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update(toFirestore(entity));
      // Clear cache to refresh data
      _cache.remove('$collectionPath:$id');
    } catch (e) {
      debugPrint('Error updating $collectionPath: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).update({
        'deleted_at': Timestamp.now(),
      });
      // Clear cache to refresh data
      _cache.remove('$collectionPath:$id');
    } catch (e) {
      debugPrint('Error deleting from $collectionPath: $e');
      rethrow;
    }
  }
}

// ==========================================================================
// MODULE-SPECIFIC SERVICES
// ==========================================================================

class ProductService extends BaseService<Product> {
  ProductService(CacheService cache) : super('products', cache);
  @override
  Product fromFirestore(DocumentSnapshot doc) => Product.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(Product entity) => entity.toMap();
}

class InventoryService extends BaseService<InventoryItem> {
  InventoryService(CacheService cache) : super('inventory', cache);
  @override
  InventoryItem fromFirestore(DocumentSnapshot doc) => InventoryItem.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(InventoryItem entity) => entity.toMap();
}

class SupplierService extends BaseService<Supplier> {
  SupplierService(CacheService cache) : super('suppliers', cache);
  @override
  Supplier fromFirestore(DocumentSnapshot doc) => Supplier.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(Supplier entity) => entity.toMap();
}

class PurchaseOrderService extends BaseService<PurchaseOrder> {
  PurchaseOrderService(CacheService cache) : super('purchase_orders', cache);
  @override
  PurchaseOrder fromFirestore(DocumentSnapshot doc) => PurchaseOrder.fromFirestore(doc);
  @override
  Map<String, dynamic> toFirestore(PurchaseOrder entity) => entity.toMap();
}

class CustomerOrderService extends BaseService<AppOrder> {
  CustomerOrderService(CacheService cache) : super('orders', cache);
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
  
  // Additional methods required by providers
  Stream<List<Store>> getStoresStream() {
    return getAll();
  }
  
  Future<void> addStore(Store store) async {
    await add(store);
  }
  
  Future<void> updateStore(String storeId, Store store) async {
    await update(storeId, store);
  }
  
  Future<void> deleteStore(String storeId) async {
    await delete(storeId);
  }
}

// ==========================================================================
// RIVERPOD PROVIDERS
// ==========================================================================

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(cacheServiceProvider));
});

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(ref.watch(cacheServiceProvider));
});

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(ref.watch(cacheServiceProvider));
});

final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  return PurchaseOrderService(ref.watch(cacheServiceProvider));
});

final customerOrderServiceProvider = Provider<CustomerOrderService>((ref) {
  return CustomerOrderService(ref.watch(cacheServiceProvider));
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
