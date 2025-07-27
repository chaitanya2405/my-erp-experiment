import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerService {
  static const MethodChannel _channel = MethodChannel('barcode_scanner');
  
  /// Scan barcode/QR code and return the scanned value
  static Future<String?> scanBarcode() async {
    try {
      // Check camera permission
      if (!await _requestCameraPermission()) {
        throw Exception('Camera permission denied');
      }
      
      final String? result = await _channel.invokeMethod('scanBarcode');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to scan barcode: ${e.message}');
    }
  }
  
  /// Scan QR code specifically
  static Future<String?> scanQRCode() async {
    try {
      if (!await _requestCameraPermission()) {
        throw Exception('Camera permission denied');
      }
      
      final String? result = await _channel.invokeMethod('scanQRCode');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to scan QR code: ${e.message}');
    }
  }
  
  /// Generate barcode for product
  static String generateProductBarcode(String productId, String sku) {
    // Simple barcode generation logic - in production use proper barcode library
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${sku.toUpperCase()}${timestamp.substring(timestamp.length - 6)}';
  }
  
  /// Generate QR code data for transaction
  static String generateTransactionQR(String transactionId, double amount, String customerPhone) {
    return 'TXN:$transactionId|AMT:$amount|PHONE:$customerPhone|TIME:${DateTime.now().toIso8601String()}';
  }
  
  /// Validate barcode format
  static bool isValidBarcode(String barcode) {
    if (barcode.isEmpty || barcode.length < 8) return false;
    
    // Check for common barcode formats
    final patterns = [
      RegExp(r'^\d{8}$'), // EAN-8
      RegExp(r'^\d{12}$'), // UPC-A
      RegExp(r'^\d{13}$'), // EAN-13
      RegExp(r'^[A-Z0-9]{6,20}$'), // Custom format
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(barcode));
  }
  
  /// Parse scanned barcode to extract product information
  static Map<String, dynamic> parseProductBarcode(String barcode) {
    try {
      if (!isValidBarcode(barcode)) {
        throw Exception('Invalid barcode format');
      }
      
      // For custom format: Extract SKU and timestamp
      if (RegExp(r'^[A-Z0-9]{6,20}$').hasMatch(barcode)) {
        final sku = barcode.substring(0, barcode.length - 6);
        final timestamp = barcode.substring(barcode.length - 6);
        
        return {
          'sku': sku,
          'timestamp': timestamp,
          'format': 'custom',
          'raw': barcode,
        };
      }
      
      // For standard formats
      return {
        'code': barcode,
        'format': _detectBarcodeFormat(barcode),
        'raw': barcode,
      };
    } catch (e) {
      throw Exception('Failed to parse barcode: $e');
    }
  }
  
  /// Parse QR code for transaction data
  static Map<String, dynamic> parseTransactionQR(String qrData) {
    try {
      final parts = qrData.split('|');
      final Map<String, dynamic> data = {};
      
      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0]] = keyValue[1];
        }
      }
      
      return data;
    } catch (e) {
      throw Exception('Failed to parse QR code: $e');
    }
  }
  
  /// Request camera permission
  static Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Web handles permissions differently
    
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }
  
  /// Detect barcode format
  static String _detectBarcodeFormat(String barcode) {
    if (RegExp(r'^\d{8}$').hasMatch(barcode)) return 'EAN-8';
    if (RegExp(r'^\d{12}$').hasMatch(barcode)) return 'UPC-A';
    if (RegExp(r'^\d{13}$').hasMatch(barcode)) return 'EAN-13';
    return 'Unknown';
  }
  
  /// Mock scanner for testing/demo purposes
  static Future<String?> mockScan({String? predefinedResult}) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate scanning delay
    
    if (predefinedResult != null) return predefinedResult;
    
    // Return mock barcode
    final mockBarcodes = [
      'PROD123456',
      'SKU789012',
      'ITEM345678',
      '1234567890123',
    ];
    
    mockBarcodes.shuffle();
    return mockBarcodes.first;
  }
  
  /// Batch scan multiple items
  static Future<List<String>> batchScan({int maxItems = 10}) async {
    final List<String> scannedItems = [];
    
    for (int i = 0; i < maxItems; i++) {
      try {
        final String? result = await scanBarcode();
        if (result != null && result.isNotEmpty) {
          scannedItems.add(result);
        } else {
          break; // User cancelled or no more items
        }
      } catch (e) {
        break; // Error occurred, stop scanning
      }
    }
    
    return scannedItems;
  }
}
