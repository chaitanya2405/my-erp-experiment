import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

class ExportWidget {
  /// Export data to CSV format
  static Future<void> exportToCSV({
    required BuildContext context,
    required String data,
    required String filename,
    bool share = true,
  }) async {
    try {
      final bytes = utf8.encode(data);
      await _saveAndShareFile(
        context: context,
        bytes: bytes,
        filename: filename.endsWith('.csv') ? filename : '$filename.csv',
        mimeType: 'text/csv',
        share: share,
      );
    } catch (e) {
      _showErrorDialog(context, 'Failed to export CSV: $e');
    }
  }

  /// Export list data to CSV
  static Future<void> exportListToCSV({
    required BuildContext context,
    required List<List<dynamic>> data,
    required String filename,
    bool share = true,
  }) async {
    try {
      final csv = const ListToCsvConverter().convert(data);
      await exportToCSV(
        context: context,
        data: csv,
        filename: filename,
        share: share,
      );
    } catch (e) {
      _showErrorDialog(context, 'Failed to export CSV: $e');
    }
  }

  /// Export to JSON format
  static Future<void> exportToJSON({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String filename,
    bool share = true,
  }) async {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);
      final bytes = utf8.encode(jsonString);
      
      await _saveAndShareFile(
        context: context,
        bytes: bytes,
        filename: filename.endsWith('.json') ? filename : '$filename.json',
        mimeType: 'application/json',
        share: share,
      );
    } catch (e) {
      _showErrorDialog(context, 'Failed to export JSON: $e');
    }
  }

  /// Export to text format
  static Future<void> exportToText({
    required BuildContext context,
    required String data,
    required String filename,
    bool share = true,
  }) async {
    try {
      final bytes = utf8.encode(data);
      await _saveAndShareFile(
        context: context,
        bytes: bytes,
        filename: filename.endsWith('.txt') ? filename : '$filename.txt',
        mimeType: 'text/plain',
        share: share,
      );
    } catch (e) {
      _showErrorDialog(context, 'Failed to export text: $e');
    }
  }

  /// Generate CSV from transaction data
  static String generateTransactionCSV(List<Map<String, dynamic>> transactions) {
    final List<List<dynamic>> csvData = [];
    
    // Header row
    csvData.add([
      'Transaction ID',
      'Date',
      'Time',
      'Customer Name',
      'Customer Phone',
      'Customer Email',
      'Payment Mode',
      'Channel',
      'Subtotal',
      'Discount',
      'GST',
      'Final Amount',
      'Staff ID',
      'Status',
      'Items Count',
    ]);

    // Data rows
    for (final transaction in transactions) {
      csvData.add([
        transaction['id'] ?? '',
        transaction['transactionDate']?.split(' ')[0] ?? '',
        transaction['transactionDate']?.split(' ')[1] ?? '',
        transaction['customerName'] ?? '',
        transaction['customerPhone'] ?? '',
        transaction['customerEmail'] ?? '',
        transaction['paymentMode'] ?? '',
        transaction['channel'] ?? '',
        transaction['subtotal']?.toString() ?? '0',
        transaction['totalDiscount']?.toString() ?? '0',
        transaction['totalGst']?.toString() ?? '0',
        transaction['finalAmount']?.toString() ?? '0',
        transaction['staffId'] ?? '',
        transaction['status'] ?? '',
        transaction['items']?.length?.toString() ?? '0',
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  /// Generate analytics report CSV
  static String generateAnalyticsCSV(Map<String, dynamic> analytics) {
    final List<List<dynamic>> csvData = [];
    
    // Summary section
    csvData.add(['ANALYTICS SUMMARY']);
    csvData.add(['']);
    csvData.add(['Metric', 'Value']);
    csvData.add(['Total Sales', analytics['totalSales']?.toString() ?? '0']);
    csvData.add(['Total Transactions', analytics['totalTransactions']?.toString() ?? '0']);
    csvData.add(['Average Transaction', analytics['averageTransaction']?.toString() ?? '0']);
    csvData.add(['Total Discount', analytics['totalDiscount']?.toString() ?? '0']);
    csvData.add(['Total GST', analytics['totalGst']?.toString() ?? '0']);
    csvData.add(['']);

    // Top products section
    if (analytics['topProducts'] != null) {
      csvData.add(['TOP PRODUCTS']);
      csvData.add(['']);
      csvData.add(['Product Name', 'SKU', 'Quantity Sold', 'Revenue']);
      
      for (final product in analytics['topProducts']) {
        csvData.add([
          product['name'] ?? '',
          product['sku'] ?? '',
          product['quantitySold']?.toString() ?? '0',
          product['revenue']?.toString() ?? '0',
        ]);
      }
      csvData.add(['']);
    }

    // Payment methods section
    if (analytics['paymentMethods'] != null) {
      csvData.add(['PAYMENT METHODS']);
      csvData.add(['']);
      csvData.add(['Payment Method', 'Count', 'Amount']);
      
      for (final method in analytics['paymentMethods']) {
        csvData.add([
          method['method'] ?? '',
          method['count']?.toString() ?? '0',
          method['amount']?.toString() ?? '0',
        ]);
      }
    }

    return const ListToCsvConverter().convert(csvData);
  }

  /// Generate audit log CSV
  static String generateAuditLogCSV(List<Map<String, dynamic>> logs) {
    final List<List<dynamic>> csvData = [];
    
    // Header row
    csvData.add([
      'Timestamp',
      'Event Type',
      'User ID',
      'Entity ID',
      'Description',
      'IP Address',
      'Additional Data',
    ]);

    // Data rows
    for (final log in logs) {
      csvData.add([
        log['timestamp'] ?? '',
        log['eventType'] ?? '',
        log['userId'] ?? '',
        log['entityId'] ?? '',
        log['description'] ?? '',
        log['ipAddress'] ?? '',
        log['additionalData']?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  /// Show export options dialog
  static Future<void> showExportDialog({
    required BuildContext context,
    required String title,
    required List<ExportOption> options,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              leading: Icon(option.icon),
              title: Text(option.title),
              subtitle: Text(option.description),
              onTap: () {
                Navigator.of(context).pop();
                option.onTap();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Internal method to save and share file
  static Future<void> _saveAndShareFile({
    required BuildContext context,
    required List<int> bytes,
    required String filename,
    required String mimeType,
    bool share = true,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platforms
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes);
        
        if (share) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Exported data: $filename',
          );
        }
      } else {
        // Desktop platforms - save to Downloads folder
        final downloadsDirectory = await getDownloadsDirectory();
        if (downloadsDirectory != null) {
          final file = File('${downloadsDirectory.path}/$filename');
          await file.writeAsBytes(bytes);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved to: ${file.path}'),
              action: SnackBarAction(
                label: 'Open Folder',
                onPressed: () => _openFileLocation(file.path),
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to save file: $e');
    }
  }

  /// Open file location (desktop only)
  static Future<void> _openFileLocation(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [File(filePath).parent.path]);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Create backup data
  static Future<void> createBackup({
    required BuildContext context,
    required Map<String, dynamic> data,
    String? customFilename,
  }) async {
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final filename = customFilename ?? 'pos_backup_$timestamp';
    
    await exportToJSON(
      context: context,
      data: {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
        'data': data,
      },
      filename: filename,
    );
  }

  /// Print invoice (web/desktop)
  static Future<void> printInvoice({
    required BuildContext context,
    required String invoiceHtml,
  }) async {
    try {
      // For web platform, this would use web APIs
      // For desktop, this would use platform-specific printing
      
      // Placeholder implementation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Print functionality not implemented for this platform'),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, 'Failed to print: $e');
    }
  }
}

class ExportOption {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  ExportOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

/// Extension for commonly used export operations
extension ExportExtensions on BuildContext {
  /// Quick export for transaction data
  Future<void> exportTransactions(List<Map<String, dynamic>> transactions) async {
    final csvData = ExportWidget.generateTransactionCSV(transactions);
    await ExportWidget.exportToCSV(
      context: this,
      data: csvData,
      filename: 'transactions_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Quick export for analytics data
  Future<void> exportAnalytics(Map<String, dynamic> analytics) async {
    final csvData = ExportWidget.generateAnalyticsCSV(analytics);
    await ExportWidget.exportToCSV(
      context: this,
      data: csvData,
      filename: 'analytics_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Quick export for audit logs
  Future<void> exportAuditLogs(List<Map<String, dynamic>> logs) async {
    final csvData = ExportWidget.generateAuditLogCSV(logs);
    await ExportWidget.exportToCSV(
      context: this,
      data: csvData,
      filename: 'audit_logs_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
