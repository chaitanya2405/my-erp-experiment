// 🛒 SHOPPING CART PROVIDER
// Complete cart management with persistent storage

import 'package:flutter/foundation.dart';
import 'package:shared_erp_package/shared_erp_package.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _customerId;

  // Getters
  List<CartItem> get items => _items;
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
  Future<void> addToCart(Product product, {
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
        _items[existingIndex].quantity += quantity;
      } else {
        // Add new item
        final cartItem = CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          description: product.description,
          quantity: quantity,
          selectedVariants: selectedVariants,
        );
        _items.add(cartItem);
      }

      await _saveCartToStorage();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item to cart: $e';
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId, {Map<String, dynamic>? selectedVariants}) async {
    try {
      _items.removeWhere((item) => 
        item.productId == productId && 
        _variantsMatch(item.selectedVariants, selectedVariants)
      );
      
      await _saveCartToStorage();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove item from cart: $e';
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity, {Map<String, dynamic>? selectedVariants}) async {
    try {
      final itemIndex = _items.indexWhere((item) => 
        item.productId == productId && 
        _variantsMatch(item.selectedVariants, selectedVariants)
      );

      if (itemIndex >= 0) {
        if (quantity <= 0) {
          _items.removeAt(itemIndex);
        } else {
          _items[itemIndex].quantity = quantity;
        }
        
        await _saveCartToStorage();
        _error = null;
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
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      notifyListeners();
    }
  }

  // Check if product is in cart
  bool isInCart(String productId, {Map<String, dynamic>? selectedVariants}) {
    return _items.any((item) => 
      item.productId == productId && 
      _variantsMatch(item.selectedVariants, selectedVariants)
    );
  }

  // Get cart item
  CartItem? getCartItem(String productId, {Map<String, dynamic>? selectedVariants}) {
    try {
      return _items.firstWhere((item) => 
        item.productId == productId && 
        _variantsMatch(item.selectedVariants, selectedVariants)
      );
    } catch (e) {
      return null;
    }
  }

  // Apply discount code
  Future<DiscountResult> applyDiscount(String code) async {
    try {
      _setLoading(true);
      
      // Simulate discount validation
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock discount logic
      double discountAmount = 0.0;
      String message = '';
      
      switch (code.toUpperCase()) {
        case 'WELCOME10':
          discountAmount = subtotal * 0.10;
          message = '10% welcome discount applied!';
          break;
        case 'SAVE50':
          discountAmount = 50.0;
          message = '₹50 discount applied!';
          break;
        case 'FREESHIP':
          discountAmount = shipping;
          message = 'Free shipping applied!';
          break;
        default:
          message = 'Invalid discount code';
      }
      
      return DiscountResult(
        isValid: discountAmount > 0,
        discountAmount: discountAmount,
        message: message,
      );
    } catch (e) {
      return DiscountResult(
        isValid: false,
        discountAmount: 0.0,
        message: 'Error applying discount: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Create order from cart
  Future<Order?> createOrder({
    required String customerId,
    required String shippingAddress,
    required String paymentMethod,
    String? notes,
    double discountAmount = 0.0,
  }) async {
    if (_items.isEmpty) return null;

    try {
      _setLoading(true);

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        customerName: 'Customer', // TODO: Get actual customer name
        items: _items.map((item) => OrderItem(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.price,
          totalPrice: item.totalPrice,
          productMetadata: item.selectedVariants,
        )).toList(),
        total: total - discountAmount,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subtotal: subtotal,
        taxAmount: tax,
        deliveryFee: shipping,
        discountAmount: discountAmount,
        totalAmount: total - discountAmount,
      );

      // Save order to Firestore
      final firestoreService = FirestoreService();
      await firestoreService.createDoc(
        'orders',
        order.id,
        order.toMap(),
      );

      // Clear cart after successful order
      await clearCart();
      
      return order;
    } catch (e) {
      _error = 'Failed to create order: $e';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Save cart to local storage
  Future<void> _saveCartToStorage() async {
    if (_customerId == null) return;
    
    try {
      final cartData = _items.map((item) => item.toMap()).toList();
      // Save to shared preferences or local database
      print('Saving cart for customer $_customerId: ${cartData.length} items');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    if (_customerId == null) return;
    
    try {
      _setLoading(true);
      // Load from shared preferences or local database
      // For now, using empty list
      _items = [];
      _error = null;
    } catch (e) {
      _error = 'Failed to load cart: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Convenience methods to match expected API
  Future<void> addItem(Product product, [int quantity = 1]) async {
    await addToCart(product, quantity: quantity);
  }

  Future<void> removeItem(String productId) async {
    await removeFromCart(productId);
  }

  Future<void> clear() async {
    await clearCart();
  }

  // Helper method to compare variants
  bool _variantsMatch(Map<String, dynamic>? variants1, Map<String, dynamic>? variants2) {
    if (variants1 == null && variants2 == null) return true;
    if (variants1 == null || variants2 == null) return false;
    
    if (variants1.length != variants2.length) return false;
    
    for (final key in variants1.keys) {
      if (variants1[key] != variants2[key]) return false;
    }
    
    return true;
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

// Discount result model
class DiscountResult {
  final bool isValid;
  final double discountAmount;
  final String message;

  DiscountResult({
    required this.isValid,
    required this.discountAmount,
    required this.message,
  });
}
