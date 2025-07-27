import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting all products: $e');
      return [];
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product by ID: $e');
      return null;
    }
  }

  // Search products by name, barcode, or SKU
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final allProducts = await getAllProducts();
      return allProducts.where((product) {
        final name = product.productName.toLowerCase();
        final barcode = product.barcode?.toLowerCase() ?? '';
        final sku = product.sku?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || 
               barcode.contains(searchQuery) || 
               sku.contains(searchQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Get product by barcode
  static Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product by barcode: $e');
      return null;
    }
  }

  // Update product sales statistics
  static Future<void> updateSalesStats(String productId, int quantitySold, double revenue) async {
    try {
      final productRef = _firestore.collection(_collection).doc(productId);
      
      await productRef.update({
        'total_sales_quantity': FieldValue.increment(quantitySold),
        'total_sales_revenue': FieldValue.increment(revenue),
        'last_sold_date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating product sales stats: $e');
    }
  }

  // Get top selling products
  static Future<List<Map<String, dynamic>>> getTopSellingProducts(
    int limit, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      // This would require aggregating sales data from POS transactions
      // For now, return a simple list based on total sales
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('total_sales_quantity', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'product_id': doc.id,
          'product_name': data['product_name'] ?? 'Unknown',
          'total_quantity': data['total_sales_quantity'] ?? 0,
          'total_revenue': data['total_sales_revenue'] ?? 0.0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top selling products: $e');
      return [];
    }
  }

  // Create product
  static Future<String> createProduct(Product product) async {
    try {
      final docRef = await _firestore.collection(_collection).add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating product: $e');
      rethrow;
    }
  }

  // Update product
  static Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore.collection(_collection).doc(productId).update(product.toFirestore());
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // Sync product data
  static Future<void> syncProductData() async {
    try {
      // Implementation for syncing product data across modules
      debugPrint('Syncing product data...');
      // This could include syncing with external systems, updating caches, etc.
    } catch (e) {
      debugPrint('Error syncing product data: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // Stream products for real-time updates
  static Stream<List<Product>> streamProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('product_name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }
}
