import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/bridge/bridge_helper.dart';

/// 🏭 Supplier Service - Manages supplier data and operations
class SupplierService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'suppliers';

  /// Get all suppliers
  static Future<Map<String, dynamic>> getAllSuppliers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final suppliers = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      return {
        'suppliers': suppliers,
        'total_count': suppliers.length,
        'status': 'success'
      };
    } catch (e) {
      return {
        'suppliers': [],
        'total_count': 0,
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  /// Get supplier by ID
  static Future<Map<String, dynamic>> getSupplierById(String supplierId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(supplierId).get();
      
      if (doc.exists) {
        return {
          'supplier': {'id': doc.id, ...doc.data()!},
          'status': 'success'
        };
      } else {
        return {
          'supplier': null,
          'status': 'not_found',
          'error': 'Supplier not found'
        };
      }
    } catch (e) {
      return {
        'supplier': null,
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  /// Update supplier data
  static Future<void> updateSupplier(Map<String, dynamic> data) async {
    try {
      final supplierId = data['id'] ?? data['supplier_id'];
      if (supplierId != null) {
        final updateData = Map<String, dynamic>.from(data);
        updateData.remove('id');
        updateData['updated_at'] = FieldValue.serverTimestamp();
        
        await _firestore.collection(_collection).doc(supplierId).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  /// Create new supplier
  static Future<String> createSupplier(Map<String, dynamic> data) async {
    try {
      final supplierData = Map<String, dynamic>.from(data);
      supplierData['created_at'] = FieldValue.serverTimestamp();
      supplierData['updated_at'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(_collection).add(supplierData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  /// Get supplier performance metrics
  static Future<Map<String, dynamic>> getSupplierMetrics(String supplierId) async {
    try {
      // Get purchase orders for this supplier
      final ordersSnapshot = await _firestore
          .collection('purchase_orders')
          .where('supplier_id', isEqualTo: supplierId)
          .get();

      final orders = ordersSnapshot.docs;
      final totalOrders = orders.length;
      final completedOrders = orders.where((doc) => doc.data()['status'] == 'completed').length;
      final onTimeDeliveries = orders.where((doc) => doc.data()['delivered_on_time'] == true).length;

      return {
        'supplier_id': supplierId,
        'total_orders': totalOrders,
        'completed_orders': completedOrders,
        'completion_rate': totalOrders > 0 ? (completedOrders / totalOrders * 100).round() : 0,
        'on_time_delivery_rate': totalOrders > 0 ? (onTimeDeliveries / totalOrders * 100).round() : 0,
        'status': 'success'
      };
    } catch (e) {
      return {
        'supplier_id': supplierId,
        'error': e.toString(),
        'status': 'error'
      };
    }
  }

  // 🌉 Bridge Integration - Initialize supplier module
  static Future<void> initializeBridgeConnection() async {
    await BridgeHelper.connectModule(
      moduleName: 'supplier_service',
      capabilities: ['get_suppliers', 'supplier_performance', 'best_supplier_selection', 'supplier_catalog'],
      schema: {
        'suppliers': {
          'fields': ['supplier_id', 'name', 'performance_score', 'products_supplied'],
          'filters': ['performance_score', 'product_category', 'location'],
        },
      },
      dataProvider: (dataType, filters) async {
        switch (dataType) {
          case 'suppliers':
            return await _getFilteredSuppliers(filters);
          case 'supplier_performance':
            if (filters.containsKey('supplier_id')) {
              return await getSupplierMetrics(filters['supplier_id']);
            }
            return {};
          default:
            return [];
        }
      },
      eventHandler: (event) async {
        switch (event.type) {
          case 'purchase_order_completed':
            await _updateSupplierPerformance(event.data);
            break;
          case 'supplier_evaluation_request':
            await _evaluateSupplierForProduct(event.data);
            break;
        }
      },
    );
    
    if (kDebugMode) {
      print('✅ Supplier Service connected to Universal Bridge');
    }
  }

  // Get filtered suppliers based on criteria
  static Future<List<Map<String, dynamic>>> _getFilteredSuppliers(Map<String, dynamic>? filters) async {
    try {
      final suppliersData = await getAllSuppliers();
      var suppliers = suppliersData['suppliers'] as List<Map<String, dynamic>>;

      if (filters != null) {
        // Apply performance score filter
        if (filters.containsKey('min_performance_score')) {
          final minScore = filters['min_performance_score'] as double;
          suppliers = suppliers.where((supplier) {
            final score = supplier['performance_score'] ?? 0.0;
            return score >= minScore;
          }).toList();
        }

        // Apply product category filter
        if (filters.containsKey('product_category')) {
          final category = filters['product_category'] as String;
          suppliers = suppliers.where((supplier) {
            final categories = supplier['product_categories'] as List? ?? [];
            return categories.contains(category);
          }).toList();
        }
      }

      return suppliers;
    } catch (e) {
      if (kDebugMode) {
        print('Error filtering suppliers: $e');
      }
      return [];
    }
  }

  // Update supplier performance after purchase order completion
  static Future<void> _updateSupplierPerformance(Map<String, dynamic> poData) async {
    try {
      final supplierId = poData['supplier_id'];
      final deliveredOnTime = poData['delivered_on_time'] ?? false;
      final qualityRating = poData['quality_rating'] ?? 3.0;

      if (kDebugMode) {
        print('📊 Updating supplier performance: $supplierId');
        print('  • On-time delivery: $deliveredOnTime');
        print('  • Quality rating: $qualityRating');
      }

      // Get current supplier data
      final supplierData = await getSupplierById(supplierId);
      final supplier = supplierData['supplier'];

      if (supplier != null) {
        // Calculate new performance score
        final currentScore = supplier['performance_score'] ?? 3.0;
        final currentOrders = supplier['total_orders'] ?? 0;
        final onTimeDeliveries = supplier['on_time_deliveries'] ?? 0;

        final newOnTimeDeliveries = deliveredOnTime ? onTimeDeliveries + 1 : onTimeDeliveries;
        final newTotalOrders = currentOrders + 1;
        final onTimeRate = newOnTimeDeliveries / newTotalOrders;

        // Simple performance calculation (can be enhanced)
        final newPerformanceScore = (onTimeRate * 2) + (qualityRating / 5 * 3);

        await updateSupplier({
          'id': supplierId,
          'performance_score': newPerformanceScore,
          'total_orders': newTotalOrders,
          'on_time_deliveries': newOnTimeDeliveries,
          'last_quality_rating': qualityRating,
        });

        if (kDebugMode) {
          print('✅ Supplier performance updated');
          print('  • New score: ${newPerformanceScore.toStringAsFixed(2)}');
          print('  • On-time rate: ${(onTimeRate * 100).toStringAsFixed(1)}%');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating supplier performance: $e');
      }
    }
  }

  // Evaluate and recommend best supplier for a product
  static Future<void> _evaluateSupplierForProduct(Map<String, dynamic> requestData) async {
    try {
      final productId = requestData['product_id'];
      final requiredQuantity = requestData['quantity'] ?? 1;

      if (kDebugMode) {
        print('🔍 Evaluating suppliers for product: $productId');
      }

      final suppliers = await _getFilteredSuppliers({'min_performance_score': 2.0});
      
      // Sort by performance score
      suppliers.sort((a, b) {
        final scoreA = a['performance_score'] ?? 0.0;
        final scoreB = b['performance_score'] ?? 0.0;
        return scoreB.compareTo(scoreA);
      });

      // Send recommendation
      await BridgeHelper.sendEvent(
        'supplier_recommendation',
        {
          'product_id': productId,
          'recommended_suppliers': suppliers.take(3).toList(),
          'evaluation_criteria': 'performance_score',
        },
        fromModule: 'supplier_service',
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error evaluating suppliers: $e');
      }
    }
  }

  // Get supplier catalog for inventory planning
  static Future<Map<String, dynamic>> getSupplierCatalog(String supplierId) async {
    try {
      final supplierData = await getSupplierById(supplierId);
      final supplier = supplierData['supplier'];

      if (supplier != null) {
        return {
          'supplier_id': supplierId,
          'supplier_name': supplier['name'],
          'catalog': supplier['product_catalog'] ?? [],
          'pricing': supplier['pricing_info'] ?? {},
          'lead_times': supplier['lead_times'] ?? {},
        };
      }

      return {};
    } catch (e) {
      if (kDebugMode) {
        print('Error getting supplier catalog: $e');
      }
      return {};
    }
  }
}
