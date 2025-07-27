// Unified ERP mock data generator
import 'package:flutter/foundation.dart';

class UnifiedERPMockDataGenerator {
  static Future<void> generateAllMockData() async {
    if (kDebugMode) {
      print('Generating unified ERP mock data...');
    }
    
    await Future.wait([
      generateMockSuppliers(),
      generateMockCustomers(),
      generateMockProducts(),
      generateMockOrders(),
    ]);
    
    if (kDebugMode) {
      print('Mock data generation completed!');
    }
  }

  static Future<void> generateUnifiedMockData() async {
    // Alias for generateAllMockData for compatibility
    await generateAllMockData();
  }

  static Future<void> generateMockSuppliers() async {
    if (kDebugMode) {
      print('Generating mock suppliers...');
    }
    // TODO: Implement mock supplier generation
  }

  static Future<void> generateMockCustomers() async {
    if (kDebugMode) {
      print('Generating mock customers...');
    }
    // TODO: Implement mock customer generation
  }

  static Future<void> generateMockProducts() async {
    if (kDebugMode) {
      print('Generating mock products...');
    }
    // TODO: Implement mock product generation
  }

  static Future<void> generateMockOrders() async {
    if (kDebugMode) {
      print('Generating mock orders...');
    }
    // TODO: Implement mock order generation
  }

  static List<Map<String, dynamic>> getSupplierMockData() {
    return [
      {
        'id': 'supplier_1',
        'name': 'ABC Electronics',
        'contactPerson': 'John Manager',
        'email': 'contact@abcelectronics.com',
        'phone': '+1234567890',
        'category': 'Electronics',
      },
      {
        'id': 'supplier_2',
        'name': 'XYZ Textiles',
        'contactPerson': 'Jane Supplier',
        'email': 'info@xyztextiles.com',
        'phone': '+1234567891',
        'category': 'Textiles',
      },
    ];
  }
}
