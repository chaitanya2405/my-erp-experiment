// 🛍️ WEB-ONLY PRODUCT PROVIDER
// Product catalog management for web builds using local models

import 'package:flutter/foundation.dart';
import '../models/web_models.dart';

class WebProductProvider extends ChangeNotifier {
  List<WebProduct> _products = [];
  List<WebProduct> _filteredProducts = [];
  List<WebCategory> _categories = [];
  WebProduct? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Getters
  List<WebProduct> get products => _filteredProducts.isNotEmpty ? _filteredProducts : _products;
  List<WebProduct> get allProducts => _products;
  List<WebCategory> get categories => _categories;
  WebProduct? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  
  List<WebProduct> get featuredProducts => _products.where((p) => p.isFeatured).toList();
  List<WebProduct> get newProducts => _products.where((p) => p.isNew).toList();
  List<WebProduct> get saleProducts => _products.where((p) => p.isOnSale).toList();

  // Initialize products
  Future<void> initialize() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
    ]);
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    await loadProducts(); // Load all products, featured ones are filtered in getter
  }

  // Load all products
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      // For web demo, we'll use sample data
      _products = _getSampleProducts();
      _applyFiltersAndSort();
      _clearError();
    } catch (e) {
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = _getSampleCategories();
      notifyListeners();
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndSort();
  }

  // Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategory = categoryId;
    _applyFiltersAndSort();
  }

  // Sort products
  void sortProducts(String sortBy, {bool ascending = true}) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applyFiltersAndSort();
  }

  // Get product by ID
  WebProduct? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Select product
  void selectProduct(WebProduct? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFiltersAndSort();
  }

  // Get products by category
  List<WebProduct> getProductsByCategory(String categoryId) {
    return _products.where((product) => product.categoryId == categoryId).toList();
  }

  // Get related products
  List<WebProduct> getRelatedProducts(String productId, {int limit = 4}) {
    final product = getProductById(productId);
    if (product == null) return [];
    
    return _products
        .where((p) => p.id != productId && p.categoryId == product.categoryId)
        .take(limit)
        .toList();
  }

  // Apply filters and sorting
  void _applyFiltersAndSort() {
    List<WebProduct> filtered = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
               (product.description?.toLowerCase().contains(_searchQuery) ?? false) ||
               product.sku.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => product.categoryId == _selectedCategory).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'popularity':
          comparison = (b.rating ?? 0).compareTo(a.rating ?? 0);
          break;
        case 'newest':
          comparison = (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredProducts = filtered;
    notifyListeners();
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

  // Sample data for web demo
  List<WebProduct> _getSampleProducts() {
    return [
      WebProduct(
        id: '1',
        name: 'Premium Laptop',
        sku: 'LAP-001',
        description: 'High-performance laptop for professionals',
        price: 75000.0,
        categoryId: 'electronics',
        imageUrl: 'https://via.placeholder.com/300x300/3498db/ffffff?text=Laptop',
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: false,
        stockQuantity: 25,
        rating: 4.5,
        reviewCount: 123,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WebProduct(
        id: '2',
        name: 'Wireless Headphones',
        sku: 'HDN-001',
        description: 'Premium wireless headphones with noise cancellation',
        price: 15000.0,
        categoryId: 'electronics',
        imageUrl: 'https://via.placeholder.com/300x300/e74c3c/ffffff?text=Headphones',
        isActive: true,
        isFeatured: false,
        isNew: true,
        isOnSale: true,
        stockQuantity: 50,
        rating: 4.2,
        reviewCount: 87,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      WebProduct(
        id: '3',
        name: 'Smart Watch',
        sku: 'SWT-001',
        description: 'Advanced smartwatch with health monitoring',
        price: 25000.0,
        categoryId: 'electronics',
        imageUrl: 'https://via.placeholder.com/300x300/2ecc71/ffffff?text=Watch',
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: false,
        stockQuantity: 35,
        rating: 4.7,
        reviewCount: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      WebProduct(
        id: '4',
        name: 'Office Desk',
        sku: 'DSK-001',
        description: 'Ergonomic office desk for productivity',
        price: 12000.0,
        categoryId: 'furniture',
        imageUrl: 'https://via.placeholder.com/300x300/f39c12/ffffff?text=Desk',
        isActive: true,
        isFeatured: false,
        isNew: false,
        isOnSale: true,
        stockQuantity: 15,
        rating: 4.0,
        reviewCount: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      WebProduct(
        id: '5',
        name: 'Gaming Chair',
        sku: 'CHR-001',
        description: 'Comfortable gaming chair with lumbar support',
        price: 18000.0,
        categoryId: 'furniture',
        imageUrl: 'https://via.placeholder.com/300x300/9b59b6/ffffff?text=Chair',
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: false,
        stockQuantity: 20,
        rating: 4.4,
        reviewCount: 78,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }

  List<WebCategory> _getSampleCategories() {
    return [
      WebCategory(
        id: 'electronics',
        name: 'Electronics',
        description: 'Electronic devices and gadgets',
        imageUrl: 'https://via.placeholder.com/150x150/3498db/ffffff?text=Electronics',
        isActive: true,
      ),
      WebCategory(
        id: 'furniture',
        name: 'Furniture',
        description: 'Office and home furniture',
        imageUrl: 'https://via.placeholder.com/150x150/e67e22/ffffff?text=Furniture',
        isActive: true,
      ),
    ];
  }
}
