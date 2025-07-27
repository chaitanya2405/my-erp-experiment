// 🛍️ PRODUCT PROVIDER
// Product catalog and search management

import 'package:flutter/foundation.dart';
import 'package:shared_erp_package/shared_erp_package.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Getters
  List<Product> get products => _filteredProducts.isNotEmpty ? _filteredProducts : _products;
  List<Product> get allProducts => _products;
  List<Category> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  
  List<Product> get featuredProducts => _products.where((p) => p.isFeatured == true).toList();
  List<Product> get newProducts => _products.where((p) => p.isNew == true).toList();
  List<Product> get saleProducts => _products.where((p) => p.isOnSale == true).toList();

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
      final firestoreService = FirestoreService();
      final productsData = await firestoreService.getDocuments(
        'products',
        where: {'isActive': true},
        orderBy: 'name',
      );

      _products = productsData.map((data) => Product.fromMap(data)).toList();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final firestoreService = FirestoreService();
      final categoriesData = await firestoreService.getDocuments(
        'categories',
        where: {'isActive': true},
        orderBy: 'name',
      );

      _categories = categoriesData.map((data) => Category.fromMap(data)).toList();
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  // Load product by ID
  Future<void> loadProductById(String productId) async {
    _setLoading(true);
    try {
      final firestoreService = FirestoreService();
      final productData = await firestoreService.getDocument('products', productId);
      
      if (productData != null) {
        _selectedProduct = Product.fromMap(productData);
        _error = null;
      } else {
        _error = 'Product not found';
      }
    } catch (e) {
      _error = 'Failed to load product: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategory = categoryId;
    _applyFilters();
    notifyListeners();
  }

  // Sort products
  void sortProducts(String sortBy, {bool ascending = true}) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _sortBy = 'name';
    _sortAscending = true;
    _applyFilters();
    notifyListeners();
  }

  // Get products by category
  List<Product> getProductsByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  // Get related products
  List<Product> getRelatedProducts(Product product, {int limit = 4}) {
    return _products
        .where((p) => 
          p.id != product.id && 
          p.categoryId == product.categoryId
        )
        .take(limit)
        .toList();
  }

  // Get product suggestions
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final suggestions = <String>{};
    final lowerQuery = query.toLowerCase();
    
    for (final product in _products) {
      if (product.name.toLowerCase().contains(lowerQuery)) {
        suggestions.add(product.name);
      }
      if (product.description.toLowerCase().contains(lowerQuery)) {
        suggestions.add(product.name);
      }
    }
    
    return suggestions.take(10).toList();
  }

  // Apply filters and sorting
  void _applyFilters() {
    List<Product> filtered = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => 
        product.categoryId == _selectedCategory
      ).toList();
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
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'rating':
          comparison = a.rating.compareTo(b.rating);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    _filteredProducts = filtered;
  }

  // Refresh products
  Future<void> refresh() async {
    await loadProducts();
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

// Category model
class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
