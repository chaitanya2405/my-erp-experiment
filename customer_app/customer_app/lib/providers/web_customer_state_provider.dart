// 🏪 WEB-ONLY CUSTOMER STATE PROVIDER
// Customer state management for web builds using local models

import 'package:flutter/foundation.dart';
import '../models/web_models.dart';

class WebCustomerStateProvider extends ChangeNotifier {
  WebCustomer? _currentCustomer;
  bool _isLoading = false;
  String? _error;
  List<WebOrder> _recentOrders = [];
  List<WebProduct> _favoriteProducts = [];
  Map<String, dynamic> _preferences = {};

  // Getters
  WebCustomer? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WebOrder> get recentOrders => _recentOrders;
  List<WebProduct> get favoriteProducts => _favoriteProducts;
  Map<String, dynamic> get preferences => _preferences;
  
  bool get hasCustomer => _currentCustomer != null;

  // Set current customer
  void setCustomer(WebCustomer customer) {
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

  // Create demo customer for web
  void createDemoCustomer() {
    final demoCustomer = WebCustomer(
      id: 'demo-customer-1',
      name: 'Demo User',
      email: 'demo@example.com',
      phone: '+91 9876543210',
      address: '123 Demo Street, Demo City, Demo State 123456',
      isActive: true,
      membershipTier: 'Gold',
      totalOrders: 15,
      totalSpent: 125000.0,
      lastOrderDate: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
    setCustomer(demoCustomer);
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
      _currentCustomer = _currentCustomer!.copyWith(
        name: name,
        email: email,
        phone: phone,
        address: address,
        profileImageUrl: profileImageUrl,
      );
      
      // In a real app, you'd save to backend here
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add product to favorites
  Future<void> addToFavorites(WebProduct product) async {
    if (_favoriteProducts.any((p) => p.id == product.id)) return;

    try {
      _favoriteProducts.add(product);
      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add to favorites: $e');
    }
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      _favoriteProducts.removeWhere((p) => p.id == productId);
      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove from favorites: $e');
    }
  }

  // Check if product is favorite
  bool isFavorite(String productId) {
    return _favoriteProducts.any((p) => p.id == productId);
  }

  // Update preference
  void updatePreference(String key, dynamic value) {
    _preferences[key] = value;
    _savePreferences();
    notifyListeners();
  }

  // Get preference
  T? getPreference<T>(String key, [T? defaultValue]) {
    return _preferences[key] as T? ?? defaultValue;
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
      _clearError();
    } catch (e) {
      _setError('Failed to load customer data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load recent orders
  Future<void> _loadRecentOrders() async {
    // For web demo, create sample recent orders
    _recentOrders = [
      WebOrder(
        id: 'order-1',
        customerId: _currentCustomer!.id,
        customerName: _currentCustomer!.name,
        customerEmail: _currentCustomer!.email,
        customerPhone: _currentCustomer!.phone,
        items: [],
        subtotal: 40900.0,
        tax: 4090.0,
        shipping: 0.0,
        totalAmount: 45000.0,
        status: 'delivered',
        paymentStatus: 'paid',
        paymentMethod: 'card',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WebOrder(
        id: 'order-2',
        customerId: _currentCustomer!.id,
        customerName: _currentCustomer!.name,
        customerEmail: _currentCustomer!.email,
        customerPhone: _currentCustomer!.phone,
        items: [],
        subtotal: 29090.0,
        tax: 2909.0,
        shipping: 50.0,
        totalAmount: 32000.0,
        status: 'in_transit',
        paymentStatus: 'paid',
        paymentMethod: 'upi',
        orderDate: DateTime.now().subtract(const Duration(days: 12)),
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
      ),
    ];
  }

  // Load favorite products
  Future<void> _loadFavoriteProducts() async {
    // For web demo, just initialize empty list
    // In real app, load from backend
  }

  // Load preferences
  Future<void> _loadPreferences() async {
    // For web demo, set some default preferences
    _preferences = {
      'notifications_enabled': true,
      'email_marketing': false,
      'preferred_payment': 'card',
      'currency': 'INR',
      'language': 'en',
    };
  }

  // Save favorites
  Future<void> _saveFavorites() async {
    // In real app, save to backend or localStorage
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Save preferences
  Future<void> _savePreferences() async {
    // In real app, save to backend or localStorage
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get customer stats
  Map<String, dynamic> getCustomerStats() {
    if (_currentCustomer == null) return {};
    
    return {
      'total_orders': _currentCustomer!.totalOrders,
      'total_spent': _currentCustomer!.totalSpent,
      'membership_tier': _currentCustomer!.membershipTier,
      'member_since': _currentCustomer!.createdAt,
      'last_order': _currentCustomer!.lastOrderDate,
      'favorite_products_count': _favoriteProducts.length,
    };
  }
}
