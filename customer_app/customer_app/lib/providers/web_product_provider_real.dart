// 🛍️ WEB-ONLY PRODUCT PROVIDER 
// Product state management for web builds using REAL Firestore data

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/web_models.dart';

class WebProductProviderReal extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<WebProduct> _products = [];
  List<WebProduct> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _selectedCategory;

  // Getters
  List<WebProduct> get products => _filteredProducts.isNotEmpty ? _filteredProducts : _products;
  List<WebProduct> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _products.isNotEmpty;
  List<WebProduct> get featuredProducts => _products.where((p) => p.isFeatured).toList();

  // Load real products from Firestore
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📦 Loading real products from Firestore...');
      final snapshot = await _firestore.collection('products').get();
      
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return WebProduct(
          id: doc.id,
          name: data['product_name'] ?? data['name'] ?? 'Unknown Product',
          sku: data['sku'] ?? data['product_id'] ?? doc.id,
          price: (data['price'] ?? data['selling_price'] ?? 0).toDouble(),
          categoryId: data['category'] ?? 'general',
          description: data['description'] ?? '',
          imageUrl: data['image_url'] ?? data['imageUrl'],
          isActive: data['is_active'] ?? data['isActive'] ?? true,
          isFeatured: data['is_featured'] ?? data['isFeatured'] ?? false,
          isNew: data['is_new'] ?? data['isNew'] ?? false,
          isOnSale: data['is_on_sale'] ?? data['isOnSale'] ?? false,
          stockQuantity: data['stock'] ?? data['current_stock'] ?? 0,
          rating: data['rating']?.toDouble(),
          reviewCount: data['review_count'] ?? data['reviewCount'],
        );
      }).toList();

      print('✅ Loaded ${_products.length} real products from Firestore');
      
      // If no products found, use demo data for testing
      if (_products.isEmpty) {
        print('📦 No products found in Firestore, loading demo products...');
        _products = _getDemoProducts();
        print('✅ Loaded ${_products.length} demo products');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoading = false;
      print('❌ Error loading products: $e');
      print('📦 Loading demo products as fallback...');
      _products = _getDemoProducts();
      print('✅ Loaded ${_products.length} demo products as fallback');
      notifyListeners();
    }
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadProducts();
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Apply filters and search
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery == null || 
          _searchQuery!.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery!.toLowerCase()) ?? false);
      
      final matchesCategory = _selectedCategory == null || 
          product.categoryId == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
    
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategory = null;
    _filteredProducts = [];
    notifyListeners();
  }

  // Demo products for testing and fallback
  List<WebProduct> _getDemoProducts() {
    return [
      WebProduct(
        id: 'demo_prod_001',
        name: 'Premium Coffee Beans',
        sku: 'COFFEE-001',
        price: 299.99,
        categoryId: 'beverages',
        description: 'Premium arabica coffee beans from the highlands. Perfect for espresso and drip coffee.',
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: false,
        stockQuantity: 50,
        rating: 4.8,
        reviewCount: 127,
      ),
      WebProduct(
        id: 'demo_prod_002',
        name: 'Organic Green Tea',
        sku: 'TEA-002',
        price: 199.99,
        categoryId: 'beverages',
        description: 'Organic green tea leaves with antioxidants. Refreshing and healthy.',
        imageUrl: 'https://images.unsplash.com/photo-1556881286-fc3bd5c2fc72?w=400',
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: false,
        stockQuantity: 75,
        rating: 4.6,
        reviewCount: 89,
      ),
      WebProduct(
        id: 'demo_prod_003',
        name: 'Artisan Chocolate Bar',
        sku: 'CHOC-003',
        price: 149.99,
        categoryId: 'confectionery',
        description: 'Handcrafted dark chocolate bar with 70% cocoa. Rich and indulgent.',
        imageUrl: 'https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=400',
        isActive: true,
        isFeatured: false,
        isNew: false,
        isOnSale: true,
        stockQuantity: 30,
        rating: 4.9,
        reviewCount: 156,
      ),
      WebProduct(
        id: 'demo_prod_004',
        name: 'Fresh Bakery Bread',
        sku: 'BREAD-004',
        price: 89.99,
        categoryId: 'bakery',
        description: 'Freshly baked whole wheat bread. Perfect for sandwiches and toast.',
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
        isActive: true,
        isFeatured: false,
        isNew: true,
        isOnSale: false,
        stockQuantity: 20,
        rating: 4.4,
        reviewCount: 67,
      ),
      WebProduct(
        id: 'demo_prod_005',
        name: 'Premium Olive Oil',
        sku: 'OIL-005',
        price: 399.99,
        categoryId: 'pantry',
        description: 'Extra virgin olive oil from Mediterranean olives. Perfect for cooking and salads.',
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400',
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: true,
        stockQuantity: 40,
        rating: 4.7,
        reviewCount: 203,
      ),
      WebProduct(
        id: 'demo_prod_006',
        name: 'Gourmet Pasta',
        sku: 'PASTA-006',
        price: 179.99,
        categoryId: 'pantry',
        description: 'Handmade pasta from durum wheat. Authentic Italian taste.',
        imageUrl: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400',
        isActive: true,
        isFeatured: false,
        isNew: false,
        isOnSale: false,
        stockQuantity: 60,
        rating: 4.5,
        reviewCount: 94,
      ),
    ];
  }
}
