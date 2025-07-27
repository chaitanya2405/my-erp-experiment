// Enhanced ERP System - Analytics and Business Intelligence Service
// Provides real-time analytics, reporting, and business intelligence

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../events/erp_events.dart';
import '../events/erp_event_bus.dart';
import '../orchestration/transaction_orchestrator.dart';
import '../models/index.dart';
import 'enhanced_service_base.dart';

class EnhancedAnalyticsService extends EnhancedERPService 
    with TransactionCapable, RealTimeSyncCapable {
  
  static EnhancedAnalyticsService? _instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Analytics collections
  static const String _metricsCollection = 'analytics_metrics';
  static const String _dashboardCollection = 'analytics_dashboards';
  static const String _reportsCollection = 'analytics_reports';
  
  EnhancedAnalyticsService._(ERPEventBus eventBus, TransactionOrchestrator orchestrator)
      : super(eventBus, orchestrator);

  static EnhancedAnalyticsService getInstance(ERPEventBus eventBus, TransactionOrchestrator orchestrator) {
    _instance ??= EnhancedAnalyticsService._(eventBus, orchestrator);
    return _instance!;
  }

  @override
  Future<void> setupEventListeners() async {
    // Listen to all analytics events
    listenToEvent<AnalyticsEvent>(_handleAnalyticsEvent);
    
    // Listen to business events for real-time aggregation
    listenToEvent<POSTransactionCreatedEvent>(_aggregatePOSMetrics);
    listenToEvent<InventoryUpdatedEvent>(_aggregateInventoryMetrics);
    listenToEvent<PurchaseOrderCreatedEvent>(_aggregatePurchaseMetrics);
    listenToEvent<CustomerProfileCreatedEvent>(_aggregateCustomerMetrics);
    
    // Setup real-time sync
    setupRealTimeSync();
  }

  @override
  void listenToDataChanges() {
    // Listen for metric threshold alerts
    listenToEvent<MetricThresholdExceededEvent>(_handleThresholdAlert);
  }

  /// Handle raw analytics events and store metrics
  Future<void> _handleAnalyticsEvent(AnalyticsEvent event) async {
    try {
      // Store the metric data
      await _storeMetric(
        metricName: event.metricName,
        data: event.data,
        timestamp: event.timestamp,
        source: event.source,
        metadata: event.metadata,
      );
      
      // Check for threshold violations
      await _checkThresholds(event.metricName, event.data);
      
    } catch (e) {
      debugPrint('❌ Error handling analytics event: $e');
    }
  }

  /// Store metric data in analytics collection
  Future<void> _storeMetric({
    required String metricName,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required String source,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final metricDoc = {
        'metric_name': metricName,
        'data': data,
        'timestamp': Timestamp.fromDate(timestamp),
        'source': source,
        'metadata': metadata,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_metricsCollection).add(metricDoc);
      
    } catch (e) {
      debugPrint('❌ Error storing metric: $e');
    }
  }

  /// Check metric thresholds and emit alerts
  Future<void> _checkThresholds(String metricName, Map<String, dynamic> data) async {
    // TODO: Implement configurable thresholds
    // For now, hardcode some basic thresholds
    
    if (metricName == 'pos.transaction_amount' && data['value'] != null) {
      final amount = data['value'] as double;
      if (amount > 1000) { // Large transaction threshold
        emitEvent(MetricThresholdExceededEvent(
          eventId: 'threshold_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedAnalyticsService',
          metricName: metricName,
          value: amount,
          threshold: 1000,
          severity: 'info',
          metadata: {'type': 'large_transaction'},
        ));
      }
    }
    
    if (metricName == 'inventory.low_stock_alert' && data['value'] != null) {
      emitEvent(MetricThresholdExceededEvent(
        eventId: 'threshold_${DateTime.now().millisecondsSinceEpoch}',
        source: 'EnhancedAnalyticsService',
        metricName: metricName,
        value: data['value'] as double,
        threshold: 1,
        severity: 'warning',
        metadata: data,
      ));
    }
  }

  /// Aggregate POS metrics in real-time
  Future<void> _aggregatePOSMetrics(POSTransactionCreatedEvent event) async {
    try {
      final hour = event.timestamp.hour;
      final date = DateTime(event.timestamp.year, event.timestamp.month, event.timestamp.day);
      
      // Aggregate hourly sales
      await _updateAggregatedMetric(
        'pos_sales_hourly',
        '${date.toIso8601String().split('T')[0]}_$hour',
        {
          'total_amount': event.totalAmount,
          'transaction_count': 1,
          'store_id': event.storeId,
          'date': date.toIso8601String(),
          'hour': hour,
        },
      );
      
      // Aggregate daily sales
      await _updateAggregatedMetric(
        'pos_sales_daily',
        date.toIso8601String().split('T')[0],
        {
          'total_amount': event.totalAmount,
          'transaction_count': 1,
          'store_id': event.storeId,
          'date': date.toIso8601String(),
        },
      );
      
      // Product sales aggregation
      for (final item in event.items) {
        await _updateAggregatedMetric(
          'product_sales_daily',
          '${item['product_id']}_${date.toIso8601String().split('T')[0]}',
          {
            'quantity_sold': item['quantity'],
            'revenue': item['total_price'],
            'product_id': item['product_id'],
            'date': date.toIso8601String(),
          },
        );
      }
      
    } catch (e) {
      debugPrint('❌ Error aggregating POS metrics: $e');
    }
  }

  /// Aggregate inventory metrics
  Future<void> _aggregateInventoryMetrics(InventoryUpdatedEvent event) async {
    try {
      final date = DateTime(event.timestamp.year, event.timestamp.month, event.timestamp.day);
      
      await _updateAggregatedMetric(
        'inventory_movements_daily',
        '${event.productId}_${date.toIso8601String().split('T')[0]}',
        {
          'movement_count': 1,
          'quantity_change': event.newQuantity - event.previousQuantity,
          'product_id': event.productId,
          'location': event.location,
          'date': date.toIso8601String(),
        },
      );
      
    } catch (e) {
      debugPrint('❌ Error aggregating inventory metrics: $e');
    }
  }

  /// Aggregate purchase order metrics
  Future<void> _aggregatePurchaseMetrics(PurchaseOrderCreatedEvent event) async {
    try {
      final date = DateTime(event.timestamp.year, event.timestamp.month, event.timestamp.day);
      
      await _updateAggregatedMetric(
        'purchase_orders_daily',
        date.toIso8601String().split('T')[0],
        {
          'po_count': 1,
          'total_amount': event.totalAmount,
          'supplier_id': event.supplierId,
          'auto_generated': event.metadata['auto_generated'] == true ? 1 : 0,
          'date': date.toIso8601String(),
        },
      );
      
    } catch (e) {
      debugPrint('❌ Error aggregating purchase metrics: $e');
    }
  }

  /// Aggregate customer metrics
  Future<void> _aggregateCustomerMetrics(CustomerProfileCreatedEvent event) async {
    try {
      final date = DateTime(event.timestamp.year, event.timestamp.month, event.timestamp.day);
      
      await _updateAggregatedMetric(
        'customers_daily',
        date.toIso8601String().split('T')[0],
        {
          'new_customers': 1,
          'date': date.toIso8601String(),
        },
      );
      
    } catch (e) {
      debugPrint('❌ Error aggregating customer metrics: $e');
    }
  }

  /// Update aggregated metric with atomic operations
  Future<void> _updateAggregatedMetric(
    String metricType,
    String aggregationKey,
    Map<String, dynamic> incrementData,
  ) async {
    try {
      final docRef = _firestore
          .collection('analytics_aggregated')
          .doc('${metricType}_$aggregationKey');

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        if (doc.exists) {
          // Update existing aggregation
          final data = doc.data()!;
          for (final key in incrementData.keys) {
            if (key == 'date' || key == 'hour' || key == 'product_id' || 
                key == 'store_id' || key == 'supplier_id' || key == 'location') {
              // Don't aggregate these fields, just set them
              data[key] = incrementData[key];
            } else {
              // Aggregate numeric fields
              data[key] = (data[key] ?? 0) + (incrementData[key] ?? 0);
            }
          }
          data['last_updated'] = FieldValue.serverTimestamp();
          transaction.update(docRef, data);
        } else {
          // Create new aggregation
          final newData = Map<String, dynamic>.from(incrementData);
          newData['created_at'] = FieldValue.serverTimestamp();
          newData['last_updated'] = FieldValue.serverTimestamp();
          transaction.set(docRef, newData);
        }
      });
      
    } catch (e) {
      debugPrint('❌ Error updating aggregated metric: $e');
    }
  }

  /// Handle threshold alerts
  Future<void> _handleThresholdAlert(MetricThresholdExceededEvent event) async {
    debugPrint('⚠️ Metric threshold exceeded: ${event.metricName} = ${event.value} (threshold: ${event.threshold})');
    
    // TODO: Send notifications, trigger workflows, etc.
  }

  /// Generate real-time dashboard data
  Future<Map<String, dynamic>> generateDashboard({
    required String dashboardType,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? storeIds,
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 7));
      endDate ??= DateTime.now();
      
      switch (dashboardType) {
        case 'sales_overview':
          return await _generateSalesDashboard(startDate, endDate, storeIds, filters);
        case 'inventory_status':
          return await _generateInventoryDashboard(startDate, endDate, filters);
        case 'customer_analytics':
          return await _generateCustomerDashboard(startDate, endDate, filters);
        case 'executive_summary':
          return await _generateExecutiveDashboard(startDate, endDate, filters);
        default:
          throw ArgumentError('Unknown dashboard type: $dashboardType');
      }
    } catch (e) {
      debugPrint('❌ Error generating dashboard: $e');
      return {'error': e.toString()};
    }
  }

  /// Generate sales dashboard
  Future<Map<String, dynamic>> _generateSalesDashboard(
    DateTime startDate,
    DateTime endDate,
    List<String>? storeIds,
    Map<String, dynamic> filters,
  ) async {
    // Query aggregated sales data
    final salesQuery = _firestore
        .collection('analytics_aggregated')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0])
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0]);

    final salesSnapshot = await salesQuery.get();
    
    double totalRevenue = 0;
    int totalTransactions = 0;
    final Map<String, double> dailySales = {};
    final Map<String, double> hourlySales = {};
    
    for (final doc in salesSnapshot.docs) {
      final data = doc.data();
      if (doc.id.startsWith('pos_sales_daily_')) {
        totalRevenue += (data['total_amount'] ?? 0.0);
        totalTransactions += (data['transaction_count'] ?? 0) as int;
        final date = data['date'];
        dailySales[date] = (dailySales[date] ?? 0) + (data['total_amount'] ?? 0.0);
      }
      if (doc.id.startsWith('pos_sales_hourly_')) {
        final hour = data['hour']?.toString() ?? '0';
        hourlySales[hour] = (hourlySales[hour] ?? 0) + (data['total_amount'] ?? 0.0);
      }
    }
    
    return {
      'dashboard_type': 'sales_overview',
      'date_range': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'summary': {
        'total_revenue': totalRevenue,
        'total_transactions': totalTransactions,
        'average_transaction_value': totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
      },
      'trends': {
        'daily_sales': dailySales,
        'hourly_sales': hourlySales,
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Generate inventory dashboard
  Future<Map<String, dynamic>> _generateInventoryDashboard(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    // TODO: Implement inventory analytics
    return {
      'dashboard_type': 'inventory_status',
      'summary': {
        'total_products': 0,
        'low_stock_items': 0,
        'out_of_stock_items': 0,
        'total_inventory_value': 0.0,
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Generate customer dashboard
  Future<Map<String, dynamic>> _generateCustomerDashboard(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    // TODO: Implement customer analytics
    return {
      'dashboard_type': 'customer_analytics',
      'summary': {
        'total_customers': 0,
        'new_customers': 0,
        'returning_customers': 0,
        'average_clv': 0.0,
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Generate executive dashboard
  Future<Map<String, dynamic>> _generateExecutiveDashboard(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> filters,
  ) async {
    // Combine multiple dashboard types
    final salesDashboard = await _generateSalesDashboard(startDate, endDate, null, filters);
    final inventoryDashboard = await _generateInventoryDashboard(startDate, endDate, filters);
    final customerDashboard = await _generateCustomerDashboard(startDate, endDate, filters);
    
    return {
      'dashboard_type': 'executive_summary',
      'date_range': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'sales_summary': salesDashboard['summary'],
      'inventory_summary': inventoryDashboard['summary'],
      'customer_summary': customerDashboard['summary'],
      'kpis': {
        'revenue_growth': 0.0, // TODO: Calculate growth
        'profit_margin': 0.0, // TODO: Calculate margin
        'customer_acquisition_cost': 0.0, // TODO: Calculate CAC
        'inventory_turnover': 0.0, // TODO: Calculate turnover
      },
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get real-time metrics stream
  Stream<List<UnifiedMetric>> getMetricsStream({
    required String metricName,
    DateTime? since,
    int limit = 100,
  }) {
    since ??= DateTime.now().subtract(const Duration(hours: 1));
    
    return _firestore
        .collection(_metricsCollection)
        .where('metric_name', isEqualTo: metricName)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(since))
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return UnifiedMetric(
              id: doc.id,
              name: data['metric_name'] ?? '',
              category: data['category'] ?? 'analytics',
              type: data['type'] ?? 'counter',
              value: data['data']['value'] ?? 0.0,
              unit: data['data']['unit'] ?? '',
              timestamp: (data['timestamp'] as Timestamp).toDate(),
              source: data['source'] ?? 'analytics_service',
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            );
          }).toList();
        });
  }

  /// Export analytics data
  Future<Map<String, dynamic>> exportAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? metricNames,
    String format = 'json',
  }) async {
    try {
      Query query = _firestore.collection(_metricsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      
      if (metricNames != null && metricNames.isNotEmpty) {
        query = query.where('metric_name', whereIn: metricNames);
      }
      
      final snapshot = await query.get();
      final metrics = snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          'id': doc.id,
          if (data != null) ...Map<String, dynamic>.from(data as Map),
        };
      }).toList();
      
      return {
        'export_info': {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'metric_names': metricNames,
          'format': format,
          'record_count': metrics.length,
          'exported_at': DateTime.now().toIso8601String(),
        },
        'data': metrics,
      };
      
    } catch (e) {
      debugPrint('❌ Error exporting analytics: $e');
      return {'error': e.toString()};
    }
  }
}

/// Metric threshold event
class MetricThresholdExceededEvent extends ERPEvent {
  final String metricName;
  final double value;
  final double threshold;
  final String severity;

  MetricThresholdExceededEvent({
    required String eventId,
    required String source,
    required this.metricName,
    required this.value,
    required this.threshold,
    required this.severity,
    Map<String, dynamic> metadata = const {},
  }) : super(eventId: eventId, source: source, metadata: metadata);
}
