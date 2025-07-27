import 'package:cloud_firestore/cloud_firestore.dart';

/// 📊 Analytics Service - Business intelligence and reporting
class AnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate comprehensive business report
  static Future<Map<String, dynamic>> generateReport(String reportType, Map<String, dynamic> filters) async {
    try {
      switch (reportType) {
        case 'dashboard':
          return await _generateDashboardReport(filters);
        case 'sales':
          return await _generateSalesReport(filters);
        case 'inventory':
          return await _generateInventoryReport(filters);
        case 'financial':
          return await _generateFinancialReport(filters);
        default:
          return await _generateDashboardReport(filters);
      }
    } catch (e) {
      return {
        'report_type': reportType,
        'status': 'error',
        'error': e.toString(),
        'generated_at': DateTime.now().toIso8601String()
      };
    }
  }

  /// Update metrics and KPIs
  static Future<void> updateMetrics(Map<String, dynamic> data) async {
    try {
      final metricsData = Map<String, dynamic>.from(data);
      metricsData['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('analytics_metrics').add(metricsData);
    } catch (e) {
      throw Exception('Failed to update metrics: $e');
    }
  }

  /// Generate dashboard overview report
  static Future<Map<String, dynamic>> _generateDashboardReport(Map<String, dynamic> filters) async {
    try {
      // Get recent sales data
      final salesSnapshot = await _firestore
          .collection('transactions')
          .orderBy('created_at', descending: true)
          .limit(100)
          .get();

      // Get inventory levels
      final inventorySnapshot = await _firestore
          .collection('inventory')
          .get();

      // Get customer orders
      final ordersSnapshot = await _firestore
          .collection('customer_orders')
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      final totalSales = salesSnapshot.docs.fold<double>(0, (sum, doc) {
        final amount = doc.data()['total_amount'];
        return sum + (amount is num ? amount.toDouble() : 0);
      });

      final lowStockItems = inventorySnapshot.docs.where((doc) {
        final current = doc.data()['current_stock'] ?? 0;
        final minimum = doc.data()['minimum_stock'] ?? 0;
        return current <= minimum;
      }).length;

      final pendingOrders = ordersSnapshot.docs.where((doc) => 
        doc.data()['status'] == 'pending'
      ).length;

      return {
        'report_type': 'dashboard',
        'metrics': {
          'total_sales': totalSales,
          'total_transactions': salesSnapshot.docs.length,
          'low_stock_items': lowStockItems,
          'pending_orders': pendingOrders,
          'total_inventory_items': inventorySnapshot.docs.length,
        },
        'trends': {
          'sales_trend': 'up', // Would calculate actual trend
          'inventory_trend': lowStockItems > 5 ? 'down' : 'stable',
          'orders_trend': pendingOrders > 10 ? 'up' : 'stable',
        },
        'status': 'success',
        'generated_at': DateTime.now().toIso8601String()
      };
    } catch (e) {
      return {
        'report_type': 'dashboard',
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  /// Generate sales performance report
  static Future<Map<String, dynamic>> _generateSalesReport(Map<String, dynamic> filters) async {
    try {
      final startDate = filters['start_date'] ?? DateTime.now().subtract(const Duration(days: 30));
      final endDate = filters['end_date'] ?? DateTime.now();

      final salesSnapshot = await _firestore
          .collection('transactions')
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .where('created_at', isLessThanOrEqualTo: endDate)
          .get();

      final transactions = salesSnapshot.docs.map((doc) => doc.data()).toList();
      
      final totalRevenue = transactions.fold<double>(0, (sum, transaction) {
        final amount = transaction['total_amount'];
        return sum + (amount is num ? amount.toDouble() : 0);
      });

      final averageOrderValue = transactions.isNotEmpty ? totalRevenue / transactions.length : 0;

      return {
        'report_type': 'sales',
        'period': {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String()
        },
        'metrics': {
          'total_revenue': totalRevenue,
          'total_transactions': transactions.length,
          'average_order_value': averageOrderValue,
        },
        'transactions': transactions,
        'status': 'success',
        'generated_at': DateTime.now().toIso8601String()
      };
    } catch (e) {
      return {
        'report_type': 'sales',
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  /// Generate inventory analysis report
  static Future<Map<String, dynamic>> _generateInventoryReport(Map<String, dynamic> filters) async {
    try {
      final inventorySnapshot = await _firestore.collection('inventory').get();
      final items = inventorySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data()
      }).toList();

      final lowStockItems = items.where((item) {
        final current = item['current_stock'] ?? 0;
        final minimum = item['minimum_stock'] ?? 0;
        return current <= minimum;
      }).toList();

      final overStockItems = items.where((item) {
        final current = item['current_stock'] ?? 0;
        final maximum = item['maximum_stock'] ?? 1000;
        return current >= maximum;
      }).toList();

      final totalValue = items.fold<double>(0, (sum, item) {
        final stock = item['current_stock'] ?? 0;
        final price = item['unit_price'] ?? 0;
        return sum + (stock * price);
      });

      return {
        'report_type': 'inventory',
        'metrics': {
          'total_items': items.length,
          'low_stock_count': lowStockItems.length,
          'overstock_count': overStockItems.length,
          'total_inventory_value': totalValue,
        },
        'alerts': {
          'low_stock_items': lowStockItems,
          'overstock_items': overStockItems,
        },
        'status': 'success',
        'generated_at': DateTime.now().toIso8601String()
      };
    } catch (e) {
      return {
        'report_type': 'inventory',
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  /// Generate financial summary report
  static Future<Map<String, dynamic>> _generateFinancialReport(Map<String, dynamic> filters) async {
    try {
      // This would integrate with accounting/financial modules
      return {
        'report_type': 'financial',
        'metrics': {
          'revenue': 0,
          'expenses': 0,
          'profit': 0,
          'profit_margin': 0,
        },
        'status': 'success',
        'note': 'Financial reporting requires accounting module integration',
        'generated_at': DateTime.now().toIso8601String()
      };
    } catch (e) {
      return {
        'report_type': 'financial',
        'status': 'error',
        'error': e.toString()
      };
    }
  }
}
