// 🏪 CUSTOMER STATE PROVIDER
// Main state management for customer app

import 'package:flutter/foundation.dart';
import 'package:shared_erp_package/shared_erp_package.dart';

class CustomerStateProvider extends ChangeNotifier {
  Customer? _currentCustomer;
  bool _isLoading = false;
  String? _error;
  List<Order> _recentOrders = [];
  List<Product> _favoriteProducts = [];
  Map<String, dynamic> _preferences = {};

  // Getters
  Customer? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Order> get recentOrders => _recentOrders;
  List<Product> get favoriteProducts => _favoriteProducts;
  Map<String, dynamic> get preferences => _preferences;
  
  bool get hasCustomer => _currentCustomer != null;

  // Set current customer
  void setCustomer(Customer customer) {
    _currentCustomer = customer;
    _error = null;
    notifyListeners();
    _loadCustomerData();
  }

  // Clear customer data
  void clearCustomer() {
    _currentCustomer = null;
    _recentOrders.clear();
    _favoriteProducts.clear();
    _preferences.clear();
    _error = null;
    notifyListeners();
  }

  // Update customer profile
  Future<void> updateCustomerProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? profileImageUrl,
  }) async {
    if (_currentCustomer == null) return;

    _setLoading(true);
    try {
      // Handle address update - add to addresses list if provided
      List<String> addresses = List.from(_currentCustomer!.addresses);
      if (address != null && address.isNotEmpty) {
        if (!addresses.contains(address)) {
          addresses.insert(0, address); // Add as primary address
        }
      }

      final updatedCustomer = _currentCustomer!.copyWith(
        name: name,
        email: email,
        phone: phone,
        addresses: addresses,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      final firestoreService = FirestoreService();
      await firestoreService.updateDocument(
        'customers',
        _currentCustomer!.id,
        updatedCustomer.toMap(),
      );

      _currentCustomer = updatedCustomer;
      _error = null;
    } catch (e) {
      _error = 'Failed to update profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load customer data by ID (public method for auth screen)
  Future<void> loadCustomerData(String customerId) async {
    try {
      final firestoreService = FirestoreService();
      final customerData = await firestoreService.getDocument('customers', customerId);
      
      if (customerData != null) {
        _currentCustomer = Customer.fromMap(customerData);
        await _loadCustomerData(); // Load related data
      }
    } catch (e) {
      _error = 'Failed to load customer data: $e';
      notifyListeners();
    }
  }

  // Create customer profile (for registration)
  Future<void> createCustomerProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    String? address,
  }) async {
    try {
      _setLoading(true);
      
      List<String> addresses = [];
      if (address != null && address.isNotEmpty) {
        addresses.add(address);
      }

      final customer = Customer(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        addresses: addresses,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final firestoreService = FirestoreService();
      await firestoreService.createDoc('customers', userId, customer.toMap());
      
      _currentCustomer = customer;
      _error = null;
    } catch (e) {
      _error = 'Failed to create customer profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Add address
  Future<void> addAddress(String address) async {
    if (_currentCustomer == null || address.isEmpty) return;

    try {
      List<String> addresses = List.from(_currentCustomer!.addresses);
      if (!addresses.contains(address)) {
        addresses.add(address);
        
        final updatedCustomer = _currentCustomer!.copyWith(
          addresses: addresses,
          updatedAt: DateTime.now(),
        );

        final firestoreService = FirestoreService();
        await firestoreService.updateDocument(
          'customers',
          _currentCustomer!.id,
          updatedCustomer.toMap(),
        );

        _currentCustomer = updatedCustomer;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add address: $e';
      notifyListeners();
    }
  }

  // Update address
  Future<void> updateAddress(int index, String newAddress) async {
    if (_currentCustomer == null || index < 0 || index >= _currentCustomer!.addresses.length) return;

    try {
      List<String> addresses = List.from(_currentCustomer!.addresses);
      addresses[index] = newAddress;
      
      final updatedCustomer = _currentCustomer!.copyWith(
        addresses: addresses,
        updatedAt: DateTime.now(),
      );

      final firestoreService = FirestoreService();
      await firestoreService.updateDocument(
        'customers',
        _currentCustomer!.id,
        updatedCustomer.toMap(),
      );

      _currentCustomer = updatedCustomer;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update address: $e';
      notifyListeners();
    }
  }

  // Remove address
  Future<void> removeAddress(int index) async {
    if (_currentCustomer == null || index < 0 || index >= _currentCustomer!.addresses.length) return;

    try {
      List<String> addresses = List.from(_currentCustomer!.addresses);
      addresses.removeAt(index);
      
      final updatedCustomer = _currentCustomer!.copyWith(
        addresses: addresses,
        updatedAt: DateTime.now(),
      );

      final firestoreService = FirestoreService();
      await firestoreService.updateDocument(
        'customers',
        _currentCustomer!.id,
        updatedCustomer.toMap(),
      );

      _currentCustomer = updatedCustomer;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove address: $e';
      notifyListeners();
    }
  }

  // Load customer data
  Future<void> _loadCustomerData() async {
    if (_currentCustomer == null) return;

    _setLoading(true);
    try {
      await Future.wait([
        _loadRecentOrders(),
        _loadFavoriteProducts(),
        _loadPreferences(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load customer data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load recent orders
  Future<void> _loadRecentOrders() async {
    if (_currentCustomer == null) return;

    try {
      final firestoreService = FirestoreService();
      final ordersData = await firestoreService.getDocuments(
        'orders',
        where: {'customerId': _currentCustomer!.id},
        orderBy: 'createdAt',
        descending: true,
        limit: 10,
      );

      _recentOrders = ordersData
          .map((data) => Order.fromMap(data))
          .toList();
    } catch (e) {
      print('Error loading recent orders: $e');
    }
  }

  // Load favorite products
  Future<void> _loadFavoriteProducts() async {
    if (_currentCustomer == null) return;

    try {
      final favoriteIds = _currentCustomer!.favoriteProductIds;
      if (favoriteIds.isEmpty) {
        _favoriteProducts = [];
        return;
      }

      final firestoreService = FirestoreService();
      final productsData = await firestoreService.getDocuments(
        'products',
        where: {'id': favoriteIds},
      );

      _favoriteProducts = productsData
          .map((data) => Product.fromMap(data))
          .toList();
    } catch (e) {
      print('Error loading favorite products: $e');
      _favoriteProducts = [];
    }
  }

  // Load user preferences
  Future<void> _loadPreferences() async {
    if (_currentCustomer == null) return;

    try {
      // Get preferences from customer model
      _preferences = Map.from(_currentCustomer!.preferences ?? {});
    } catch (e) {
      print('Error loading preferences: $e');
      _preferences = {};
    }
  }

  // Add product to favorites
  Future<void> addToFavorites(Product product) async {
    if (_currentCustomer == null) return;

    try {
      if (!_favoriteProducts.any((p) => p.id == product.id)) {
        _favoriteProducts.add(product);
        
        final updatedIds = _favoriteProducts.map((p) => p.id).toList();
        
        // Update preferences with favorite product IDs
        Map<String, dynamic> updatedPreferences = Map.from(_currentCustomer!.preferences ?? {});
        updatedPreferences['favoriteProductIds'] = updatedIds;
        
        final updatedCustomer = _currentCustomer!.copyWith(
          preferences: updatedPreferences,
          updatedAt: DateTime.now(),
        );

        // Update in Firestore
        final firestoreService = FirestoreService();
        await firestoreService.updateDocument(
          'customers',
          _currentCustomer!.id,
          updatedCustomer.toMap(),
        );

        _currentCustomer = updatedCustomer;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add to favorites: $e';
      notifyListeners();
    }
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    if (_currentCustomer == null) return;

    try {
      _favoriteProducts.removeWhere((p) => p.id == productId);
      
      final updatedIds = _favoriteProducts.map((p) => p.id).toList();
      
      // Update preferences with favorite product IDs
      Map<String, dynamic> updatedPreferences = Map.from(_currentCustomer!.preferences ?? {});
      updatedPreferences['favoriteProductIds'] = updatedIds;
      
      final updatedCustomer = _currentCustomer!.copyWith(
        preferences: updatedPreferences,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      final firestoreService = FirestoreService();
      await firestoreService.updateDocument(
        'customers',
        _currentCustomer!.id,
        updatedCustomer.toMap(),
      );

      _currentCustomer = updatedCustomer;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove from favorites: $e';
      notifyListeners();
    }
  }

  // Update preference
  Future<void> updatePreference(String key, dynamic value) async {
    if (_currentCustomer == null) return;

    try {
      _preferences[key] = value;
      
      // Update customer preferences
      Map<String, dynamic> updatedPreferences = Map.from(_currentCustomer!.preferences ?? {});
      updatedPreferences[key] = value;
      
      final updatedCustomer = _currentCustomer!.copyWith(
        preferences: updatedPreferences,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      final firestoreService = FirestoreService();
      await firestoreService.updateDocument(
        'customers',
        _currentCustomer!.id,
        updatedCustomer.toMap(),
      );

      _currentCustomer = updatedCustomer;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update preference: $e';
      notifyListeners();
    }
  }

  // Get preference
  T? getPreference<T>(String key, [T? defaultValue]) {
    return _preferences[key] as T? ?? defaultValue;
  }

  // Refresh all data
  Future<void> refresh() async {
    if (_currentCustomer != null) {
      await _loadCustomerData();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}