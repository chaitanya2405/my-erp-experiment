import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_services.dart'; // Correctly import all models and services from the single source.

// ==================== GLOBAL APP STATE ====================

class AppState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfile? userProfile;

  AppState({this.isLoading = false, this.errorMessage, this.userProfile});

  AppState copyWith({bool? isLoading, String? errorMessage, UserProfile? userProfile}) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});

class AppStateNotifier extends StateNotifier<AppState> {
  final Ref _ref;

  AppStateNotifier(this._ref) : super(AppState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    // Listen to auth changes to automatically update user state
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final userProfile = await _ref.read(userProfileServiceProvider).getById(user.uid);
        state = state.copyWith(userProfile: userProfile, isLoading: false);
      } else {
        state = state.copyWith(userProfile: null, isLoading: false);
      }
    });
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ==================== INVENTORY STATE ====================

class InventoryState {
  final bool isLoading;
  final List<InventoryItem> inventoryItems;
  final String? errorMessage;

  InventoryState({
    this.isLoading = false,
    this.inventoryItems = const [],
    this.errorMessage,
  });

  InventoryState copyWith({
    bool? isLoading,
    List<InventoryItem>? inventoryItems,
    String? errorMessage,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final inventoryStateProvider = StateNotifierProvider<InventoryStateNotifier, InventoryState>((ref) {
  return InventoryStateNotifier(ref);
});

class InventoryStateNotifier extends StateNotifier<InventoryState> {
  final Ref _ref;

  InventoryStateNotifier(this._ref) : super(InventoryState()) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true);
    try {
      final inventoryService = _ref.read(inventoryServiceProvider);
      final inventoryItems = await inventoryService.getAll().first;
      state = state.copyWith(inventoryItems: inventoryItems, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void refresh() {
    loadInventory();
  }
}

// ==================== PRODUCT STATE ====================

class ProductState {
  final bool isLoading;
  final List<Product> products;
  final String? errorMessage;

  ProductState({
    this.isLoading = false,
    this.products = const [],
    this.errorMessage,
  });

  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? errorMessage,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final productStateProvider = StateNotifierProvider<ProductStateNotifier, ProductState>((ref) {
  return ProductStateNotifier(ref);
});

class ProductStateNotifier extends StateNotifier<ProductState> {
  final Ref _ref;

  ProductStateNotifier(this._ref) : super(ProductState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final productService = _ref.read(productServiceProvider);
      final products = await productService.getAll().first;
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void refresh() {
    loadProducts();
  }
}

// ==================== POS STATE ====================

class PosState {
  final bool isLoading;
  final List<dynamic> transactions; // Using dynamic for now to match existing code
  final String? errorMessage;

  PosState({this.isLoading = false, this.transactions = const [], this.errorMessage});

  PosState copyWith({bool? isLoading, List<dynamic>? transactions, String? errorMessage}) {
    return PosState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final posStateProvider = StateNotifierProvider<PosStateNotifier, PosState>((ref) {
  return PosStateNotifier(ref);
});

class PosStateNotifier extends StateNotifier<PosState> {
  final Ref _ref;

  PosStateNotifier(this._ref) : super(PosState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    try {
      // For now, use empty list until POS service is properly integrated
      final transactions = <dynamic>[];
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void refresh() {
    loadTransactions();
  }
}

// ==================== STORE STATE ====================

class StoreState {
  final bool isLoading;
  final List<Store> stores;
  final String? errorMessage;

  StoreState({
    this.isLoading = false,
    this.stores = const [],
    this.errorMessage,
  });

  StoreState copyWith({
    bool? isLoading,
    List<Store>? stores,
    String? errorMessage,
  }) {
    return StoreState(
      isLoading: isLoading ?? this.isLoading,
      stores: stores ?? this.stores,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final storeStateProvider = StateNotifierProvider<StoreStateNotifier, StoreState>((ref) {
  return StoreStateNotifier(ref);
});

class StoreStateNotifier extends StateNotifier<StoreState> {
  final Ref _ref;

  StoreStateNotifier(this._ref) : super(StoreState()) {
    loadStores();
  }

  Future<void> loadStores() async {
    state = state.copyWith(isLoading: true);
    try {
      final storeService = _ref.read(storeServiceProvider);
      final stores = await storeService.getStoresStream().first;
      state = state.copyWith(stores: stores, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void refresh() {
    loadStores();
  }

  Future<void> addStore(Store store) async {
    try {
      final storeService = _ref.read(storeServiceProvider);
      await storeService.addStore(store);
      loadStores(); // Refresh the list
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateStore(String storeId, Store store) async {
    try {
      final storeService = _ref.read(storeServiceProvider);
      await storeService.updateStore(storeId, store);
      loadStores(); // Refresh the list
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      final storeService = _ref.read(storeServiceProvider);
      await storeService.deleteStore(storeId);
      loadStores(); // Refresh the list
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// ==================== ERROR HANDLER ====================

class ErrorHandler {
  void handleError(String error) {
    debugPrint('Error: $error');
  }
  
  void clearError() {
    // Clear error implementation
    debugPrint('Error cleared');
  }
}

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});

// ==================== MODULE DATA PROVIDERS ====================
// Using simple StreamProviders to fetch real-time data from Firestore via the service layer.

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productServiceProvider).getAll();
});

final inventoryStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryServiceProvider).getAll();
});

final supplierStreamProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(supplierServiceProvider).getAll();
});

final purchaseOrderStreamProvider = StreamProvider<List<PurchaseOrder>>((ref) {
  return ref.watch(purchaseOrderServiceProvider).getAll();
});

final customerOrderStreamProvider = StreamProvider<List<AppOrder>>((ref) {
  return ref.watch(customerOrderServiceProvider).getAll();
});

final customerProfileStreamProvider = StreamProvider<List<CustomerProfile>>((ref) {
  return ref.watch(customerProfileServiceProvider).getAll();
});

final storeStreamProvider = StreamProvider<List<Store>>((ref) {
  return ref.watch(storeServiceProvider).getStoresStream();
});

// ==================== UNIFIED DASHBOARD DATA AGGREGATOR ====================

class DashboardData {
  final int totalProducts;
  final int lowStockItems;
  final int pendingOrders;
  final int pendingPurchaseOrders;
  final double totalRevenue;
  final Map<String, int> poStatusCounts;
  final Map<String, int> customerSegments;
  final int totalStores;
  final int activeStores;
  final int storesNeedingAttention;
  final double totalStoresSales;

  DashboardData({
    this.totalProducts = 0,
    this.lowStockItems = 0,
    this.pendingOrders = 0,
    this.pendingPurchaseOrders = 0,
    this.totalRevenue = 0.0,
    this.poStatusCounts = const {},
    this.customerSegments = const {},
    this.totalStores = 0,
    this.activeStores = 0,
    this.storesNeedingAttention = 0,
    this.totalStoresSales = 0.0,
  });
}

/// A provider that watches all the necessary data streams and aggregates them
/// into a single, easy-to-use object for the dashboard UI.
final dashboardDataProvider = Provider<DashboardData>((ref) {
  // Watch all the streams. When any of them update, this provider will re-run.
  final productsAsync = ref.watch(productsStreamProvider);
  final inventoryAsync = ref.watch(inventoryStreamProvider);
  final ordersAsync = ref.watch(customerOrderStreamProvider);
  final posAsync = ref.watch(purchaseOrderStreamProvider);
  final customersAsync = ref.watch(customerProfileStreamProvider);
  final storesAsync = ref.watch(storeStreamProvider);

  // Safely extract data from each stream, providing default values if data is not yet available.
  final products = productsAsync.asData?.value ?? [];
  final inventory = inventoryAsync.asData?.value ?? [];
  final orders = ordersAsync.asData?.value ?? [];
  final pos = posAsync.asData?.value ?? [];
  final customers = customersAsync.asData?.value ?? [];
  final stores = storesAsync.asData?.value ?? [];

  // --- Perform aggregations ---

  final totalProducts = products.length;

  final lowStockItems = inventory
      .where((item) => item.currentStock <= item.minStockLevel)
      .length;

  final pendingOrders = orders
      .where((order) => order.status == 'pending' || order.status == 'processing')
      .length;
      
  final totalRevenue = orders
      .where((order) => order.status != 'cancelled')
      .fold(0.0, (sum, order) => sum + order.totalValue);

  final pendingPOs = pos
      .where((po) => po.status == 'pending' || po.status == 'approved')
      .length;
      
  final poStatusCounts = <String, int>{};
  for (final po in pos) {
    poStatusCounts[po.status] = (poStatusCounts[po.status] ?? 0) + 1;
  }

  final customerSegments = <String, int>{};
  for (final customer in customers) {
    final segment = customer.segment ?? 'Unknown';
    customerSegments[segment] = (customerSegments[segment] ?? 0) + 1;
  }

  // Store-specific aggregations
  final totalStores = stores.length;
  final activeStores = stores.where((store) => store.storeStatus == 'Active').length;
  final storesNeedingAttention = stores.where((store) => store.needsAttention).length;
  final totalStoresSales = stores.fold(0.0, (sum, store) => sum + (store.todaysSales ?? 0));

  // Return the aggregated data object.
  return DashboardData(
    totalProducts: totalProducts,
    lowStockItems: lowStockItems,
    pendingOrders: pendingOrders,
    pendingPurchaseOrders: pendingPOs,
    totalRevenue: totalRevenue,
    poStatusCounts: poStatusCounts,
    customerSegments: customerSegments,
    totalStores: totalStores,
    activeStores: activeStores,
    storesNeedingAttention: storesNeedingAttention,
    totalStoresSales: totalStoresSales,
  );
});
