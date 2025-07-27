// 🛒 WEB-ONLY SHOPPING CART PROVIDER
// Cart management for web builds using local models

import 'package:flutter/foundation.dart';
import '../models/web_models.dart';

class WebCartProvider extends ChangeNotifier {
  List<WebCartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _customerId;

  // Getters
  List<WebCartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  
  double get subtotal => _items.fold(0.0, (total, item) => total + item.totalPrice);
  
  double get tax => subtotal * 0.1; // 10% tax
  
  double get shipping => subtotal > 500 ? 0.0 : 50.0; // Free shipping over ₹500
  
  double get total => subtotal + tax + shipping;
  
  bool get isEmpty => _items.isEmpty;
  
  bool get isNotEmpty => _items.isNotEmpty;

  // Initialize cart for customer
  void initializeCart(String customerId) {
    _customerId = customerId;
    _loadCartFromStorage();
  }

  // Add product to cart
  Future<void> addToCart(WebProduct product, {
    int quantity = 1,
    Map<String, dynamic>? selectedVariants,
  }) async {
    try {
      final existingIndex = _items.indexWhere((item) => 
        item.productId == product.id && 
        _variantsMatch(item.selectedVariants, selectedVariants)
      );

      if (existingIndex >= 0) {
        // Update existing item quantity
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item
        final cartItem = WebCartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          productName: product.name,
          productImage: product.imageUrl,
          price: _calculatePrice(product, selectedVariants),
          quantity: quantity,
          selectedVariants: selectedVariants ?? {},
          addedAt: DateTime.now(),
        );
        _items.add(cartItem);
      }

      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item to cart: $e';
      notifyListeners();
    }
  }

  // Remove product from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      _items.removeWhere((item) => item.id == cartItemId);
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove item: $e';
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        await _saveCartToStorage();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      _items.clear();
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      notifyListeners();
    }
  }

  // Get cart item by product
  WebCartItem? getCartItemByProduct(String productId, Map<String, dynamic>? variants) {
    try {
      return _items.firstWhere((item) => 
        item.productId == productId && 
        _variantsMatch(item.selectedVariants, variants)
      );
    } catch (e) {
      return null;
    }
  }

  // Check if product is in cart
  bool isInCart(String productId, {Map<String, dynamic>? variants}) {
    return getCartItemByProduct(productId, variants) != null;
  }

  // Get quantity for specific product variant
  int getQuantityInCart(String productId, {Map<String, dynamic>? variants}) {
    final item = getCartItemByProduct(productId, variants);
    return item?.quantity ?? 0;
  }

  // Calculate price with variants
  double _calculatePrice(WebProduct product, Map<String, dynamic>? variants) {
    double basePrice = product.price;
    
    if (variants != null && variants.isNotEmpty) {
      // Add variant pricing logic here if needed
      // For now, return base price
    }
    
    return basePrice;
  }

  // Check if variants match
  bool _variantsMatch(Map<String, dynamic>? variants1, Map<String, dynamic>? variants2) {
    if (variants1 == null && variants2 == null) return true;
    if (variants1 == null || variants2 == null) return false;
    
    if (variants1.length != variants2.length) return false;
    
    for (String key in variants1.keys) {
      if (variants1[key] != variants2[key]) return false;
    }
    
    return true;
  }

  // Load cart from storage (web localStorage simulation)
  Future<void> _loadCartFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // For web demo, we'll just use in-memory storage
      // In a real app, you'd use localStorage or IndexedDB
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load cart: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save cart to storage (web localStorage simulation)
  Future<void> _saveCartToStorage() async {
    try {
      // For web demo, we'll just use in-memory storage
      // In a real app, you'd save to localStorage or IndexedDB
    } catch (e) {
      print('Failed to save cart: $e');
    }
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
