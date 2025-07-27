import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../models/audit_log.dart';

class PosAuditService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'pos_audit_logs';

  // Log a POS audit event
  static Future<void> logAuditEvent({
    required String action,
    required String userId,
    required String storeId,
    String? transactionId,
    String? invoiceNumber,
    Map<String, dynamic>? details,
    double? amount,
    String? entityType,
    String? entityId,
    String? description,
  }) async {
    try {
      final auditLog = {
        'timestamp': FieldValue.serverTimestamp(),
        'action': action,
        'user_id': userId,
        'store_id': storeId,
        'transaction_id': transactionId,
        'invoice_number': invoiceNumber,
        'entity_type': entityType,
        'entity_id': entityId,
        'amount': amount,
        'description': description,
        'details': details ?? {},
        'ip_address': await _getDeviceInfo(),
        'session_id': _generateSessionId(),
      };

      await _firestore.collection(_collection).add(auditLog);
      debugPrint('Audit log created: $action');
    } catch (e) {
      debugPrint('Error creating audit log: $e');
      // Don't rethrow to avoid affecting main functionality
    }
  }

  // Log transaction creation
  static Future<void> logTransactionCreated({
    required String userId,
    required String storeId,
    required String transactionId,
    required String invoiceNumber,
    required double amount,
    required String paymentMode,
    Map<String, dynamic>? additionalDetails,
  }) async {
    await logAuditEvent(
      action: 'transaction_created',
      userId: userId,
      storeId: storeId,
      transactionId: transactionId,
      invoiceNumber: invoiceNumber,
      amount: amount,
      entityType: 'pos_transaction',
      entityId: transactionId,
      description: 'POS transaction created with invoice $invoiceNumber',
      details: {
        'payment_mode': paymentMode,
        'amount': amount,
        ...?additionalDetails,
      },
    );
  }

  // Log transaction update
  static Future<void> logTransactionUpdated({
    required String userId,
    required String storeId,
    required String transactionId,
    required String invoiceNumber,
    required Map<String, dynamic> changes,
    String? reason,
  }) async {
    await logAuditEvent(
      action: 'transaction_updated',
      userId: userId,
      storeId: storeId,
      transactionId: transactionId,
      invoiceNumber: invoiceNumber,
      entityType: 'pos_transaction',
      entityId: transactionId,
      description: 'POS transaction updated: ${reason ?? 'No reason provided'}',
      details: {
        'changes': changes,
        'reason': reason,
      },
    );
  }

  // Log refund processed
  static Future<void> logRefundProcessed({
    required String userId,
    required String storeId,
    required String transactionId,
    required String invoiceNumber,
    required double refundAmount,
    required String reason,
  }) async {
    await logAuditEvent(
      action: 'refund_processed',
      userId: userId,
      storeId: storeId,
      transactionId: transactionId,
      invoiceNumber: invoiceNumber,
      amount: refundAmount,
      entityType: 'pos_refund',
      entityId: transactionId,
      description: 'Refund processed for invoice $invoiceNumber',
      details: {
        'refund_amount': refundAmount,
        'reason': reason,
        'original_transaction_id': transactionId,
      },
    );
  }

  // Log discount applied
  static Future<void> logDiscountApplied({
    required String userId,
    required String storeId,
    required String transactionId,
    required String invoiceNumber,
    required double discountAmount,
    required String discountType,
    String? couponCode,
  }) async {
    await logAuditEvent(
      action: 'discount_applied',
      userId: userId,
      storeId: storeId,
      transactionId: transactionId,
      invoiceNumber: invoiceNumber,
      amount: discountAmount,
      entityType: 'pos_discount',
      entityId: transactionId,
      description: 'Discount applied to invoice $invoiceNumber',
      details: {
        'discount_amount': discountAmount,
        'discount_type': discountType,
        'coupon_code': couponCode,
      },
    );
  }

  // Log cash drawer operation
  static Future<void> logCashDrawerOperation({
    required String userId,
    required String storeId,
    required String operation, // 'open', 'close', 'count'
    double? amount,
    String? reason,
    Map<String, dynamic>? cashBreakdown,
  }) async {
    await logAuditEvent(
      action: 'cash_drawer_$operation',
      userId: userId,
      storeId: storeId,
      amount: amount,
      entityType: 'cash_drawer',
      entityId: storeId,
      description: 'Cash drawer $operation operation',
      details: {
        'operation': operation,
        'amount': amount,
        'reason': reason,
        'cash_breakdown': cashBreakdown,
      },
    );
  }

  // Log user login/logout
  static Future<void> logUserSession({
    required String userId,
    required String storeId,
    required String action, // 'login', 'logout'
    Map<String, dynamic>? sessionDetails,
  }) async {
    await logAuditEvent(
      action: 'user_$action',
      userId: userId,
      storeId: storeId,
      entityType: 'user_session',
      entityId: userId,
      description: 'User $action to POS system',
      details: {
        'session_action': action,
        ...?sessionDetails,
      },
    );
  }

  // Log system configuration changes
  static Future<void> logConfigurationChange({
    required String userId,
    required String storeId,
    required String configType,
    required Map<String, dynamic> oldValues,
    required Map<String, dynamic> newValues,
    String? reason,
  }) async {
    await logAuditEvent(
      action: 'configuration_changed',
      userId: userId,
      storeId: storeId,
      entityType: 'pos_configuration',
      entityId: configType,
      description: 'POS configuration changed: $configType',
      details: {
        'config_type': configType,
        'old_values': oldValues,
        'new_values': newValues,
        'reason': reason,
      },
    );
  }

  // Log data export
  static Future<void> logDataExport({
    required String userId,
    required String storeId,
    required String exportType,
    required DateTime startDate,
    required DateTime endDate,
    int? recordCount,
  }) async {
    await logAuditEvent(
      action: 'data_exported',
      userId: userId,
      storeId: storeId,
      entityType: 'data_export',
      description: 'Data exported: $exportType',
      details: {
        'export_type': exportType,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'record_count': recordCount,
      },
    );
  }

  // Log security events
  static Future<void> logSecurityEvent({
    required String userId,
    required String storeId,
    required String eventType,
    required String severity, // 'low', 'medium', 'high', 'critical'
    String? description,
    Map<String, dynamic>? details,
  }) async {
    await logAuditEvent(
      action: 'security_event',
      userId: userId,
      storeId: storeId,
      entityType: 'security',
      description: description ?? 'Security event: $eventType',
      details: {
        'event_type': eventType,
        'severity': severity,
        ...?details,
      },
    );
  }

  // Get audit logs for a specific transaction
  static Future<List<Map<String, dynamic>>> getTransactionAuditLogs(
    String transactionId,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('transaction_id', isEqualTo: transactionId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting transaction audit logs: $e');
      return [];
    }
  }

  // Get audit logs for a specific user
  static Future<List<Map<String, dynamic>>> getUserAuditLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final result = await query
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting user audit logs: $e');
      return [];
    }
  }

  // Get audit logs for a specific store
  static Future<List<Map<String, dynamic>>> getStoreAuditLogs(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('store_id', isEqualTo: storeId);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (action != null) {
        query = query.where('action', isEqualTo: action);
      }

      final result = await query
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting store audit logs: $e');
      return [];
    }
  }

  // Get audit summary for dashboard
  static Future<Map<String, dynamic>> getAuditSummary(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('store_id', isEqualTo: storeId);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final result = await query.get();
      
      Map<String, int> actionCounts = {};
      Map<String, int> userCounts = {};
      int securityEvents = 0;
      
      for (final doc in result.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final action = data['action'] as String? ?? 'unknown';
        final userId = data['user_id'] as String? ?? 'unknown';
        
        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        userCounts[userId] = (userCounts[userId] ?? 0) + 1;
        
        if (action.contains('security')) {
          securityEvents++;
        }
      }

      return {
        'total_events': result.docs.length,
        'action_counts': actionCounts,
        'user_counts': userCounts,
        'security_events': securityEvents,
        'most_active_user': userCounts.entries
            .fold<MapEntry<String, int>?>(null, (prev, curr) =>
                prev == null || curr.value > prev.value ? curr : prev)
            ?.key,
        'most_common_action': actionCounts.entries
            .fold<MapEntry<String, int>?>(null, (prev, curr) =>
                prev == null || curr.value > prev.value ? curr : prev)
            ?.key,
      };
    } catch (e) {
      debugPrint('Error getting audit summary: $e');
      return {};
    }
  }

  // Generate device/session info
  static Future<String> _getDeviceInfo() async {
    // This is a simplified implementation
    // In a real app, you'd use device_info_plus package
    return 'Unknown Device';
  }

  static String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Clean up old audit logs (older than retention period)
  static Future<void> cleanupOldAuditLogs({
    required String storeId,
    int retentionDays = 365,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      
      final query = await _firestore
          .collection(_collection)
          .where('store_id', isEqualTo: storeId)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Cleaned up ${query.docs.length} old audit logs');
    } catch (e) {
      debugPrint('Error cleaning up old audit logs: $e');
    }
  }

  // Export audit logs to CSV
  static Future<String> exportAuditLogsToCsv(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await getStoreAuditLogs(
        storeId,
        startDate: startDate,
        endDate: endDate,
        limit: 10000,
      );

      final csvHeader = 'Timestamp,Action,User ID,Transaction ID,Invoice Number,Amount,Description\n';
      final csvData = logs.map((log) {
        final timestamp = (log['timestamp'] as Timestamp?)?.toDate().toIso8601String() ?? '';
        final action = log['action'] ?? '';
        final userId = log['user_id'] ?? '';
        final transactionId = log['transaction_id'] ?? '';
        final invoiceNumber = log['invoice_number'] ?? '';
        final amount = log['amount']?.toString() ?? '';
        final description = (log['description'] ?? '').replaceAll(',', ';');
        
        return '$timestamp,$action,$userId,$transactionId,$invoiceNumber,$amount,"$description"';
      }).join('\n');

      return csvHeader + csvData;
    } catch (e) {
      debugPrint('Error exporting audit logs to CSV: $e');
      return '';
    }
  }

  // Simple log event method that matches the calling signature
  static Future<void> logEvent(
    String eventType,
    String description, {
    required String userId,
    required String entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final auditLog = AuditLog(
        logId: '',
        eventType: eventType,
        description: description,
        userId: userId,
        entityType: 'pos_event',
        entityId: entityId,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        ipAddress: '',
        userAgent: '',
        deviceInfo: '',
      );

      await _firestore.collection(_collection).add(auditLog.toFirestore());
      debugPrint('Audit log created: $eventType');
    } catch (e) {
      debugPrint('Error creating audit log: $e');
    }
  }

  // Get all logs method
  static Future<List<AuditLog>> getAllLogs() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AuditLog.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
      return [];
    }
  }
}
