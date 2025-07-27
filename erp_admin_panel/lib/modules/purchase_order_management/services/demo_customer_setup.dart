// Demo Customer Setup - Auto-creates demo customer account for testing
// This service creates a demo customer with some sample data for testing the customer-centric flow

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../services/customer_auth_service.dart';
import '../../../services/enhanced_services.dart';

class DemoCustomerSetup {
  static const String demoCustomerId = 'demo_customer_001';
  static const String demoEmail = 'john@example.com';
  static const String demoPassword = 'password123';

  // Setup demo customer account with sample data
  static Future<Map<String, dynamic>> setupDemoCustomer() async {
    try {
      debugPrint('🎭 Setting up demo customer account...');

      // First, check if demo customer already exists
      final existingCustomer = await CustomerAuthService.getCustomerByEmail(demoEmail);
      
      if (existingCustomer != null) {
        debugPrint('✅ Demo customer already exists: ${existingCustomer.customerName}');
        return {
          'success': true,
          'message': 'Demo customer already exists',
          'customer': existingCustomer,
          'credentials': {
            'email': demoEmail,
            'password': demoPassword,
          },
        };
      }

      debugPrint('🔨 Creating new demo customer...');

      // Create demo customer account
      final result = await CustomerAuthService.createCustomer(
        customerName: 'John Doe',
        email: demoEmail,
        password: demoPassword,
        mobileNumber: '+91 9876543210',
        address: '123 Demo Street, Demo Colony',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        dateOfBirth: DateTime(1990, 5, 15),
      );

      if (result != null && result['success'] == true) {
        final customer = result['customerProfile'];
        debugPrint('✅ Demo customer created with ID: ${customer.customerId}');
        
        // Add some demo loyalty points
        await CustomerAuthService.addLoyaltyPoints(
          customer.customerId, 
          500, 
          'Welcome bonus for demo account'
        );

        // Verify the customer was saved correctly
        final verifyCustomer = await CustomerAuthService.getCustomerByEmail(demoEmail);
        if (verifyCustomer != null) {
          debugPrint('✅ Demo customer verified in Firestore');
        } else {
          debugPrint('❌ Demo customer not found after creation!');
        }

        debugPrint('✅ Demo customer created successfully!');
        debugPrint('📧 Email: $demoEmail');
        debugPrint('🔑 Password: $demoPassword');
        debugPrint('🎯 Customer ID: ${customer.customerId}');

        return {
          'success': true,
          'message': 'Demo customer created successfully',
          'customer': customer,
          'credentials': {
            'email': demoEmail,
            'password': demoPassword,
          },
        };
      } else {
        debugPrint('❌ Failed to create demo customer: ${result?['error']}');
        return {
          'success': false,
          'error': result?['error'] ?? 'Failed to create demo customer',
        };
      }
    } catch (e) {
      debugPrint('❌ Error setting up demo customer: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Setup demo products for the customer to order
  static Future<void> setupDemoProducts() async {
    try {
      debugPrint('📦 Setting up demo products...');

      final demoProducts = [
        {
          'product_name': 'Wireless Headphones',
          'category': 'Electronics',
          'selling_price': 2999.0,
          'cost_price': 2000.0,
          'current_stock': 50,
          'min_stock_level': 10,
          'max_stock_level': 100,
          'unit': 'pieces',
          'tax_percent': 18.0,
          'description': 'High-quality wireless Bluetooth headphones with noise cancellation',
        },
        {
          'product_name': 'Smartphone Case',
          'category': 'Accessories',
          'selling_price': 799.0,
          'cost_price': 400.0,
          'current_stock': 200,
          'min_stock_level': 20,
          'max_stock_level': 300,
          'unit': 'pieces',
          'tax_percent': 18.0,
          'description': 'Durable protective case for smartphones',
        },
        {
          'product_name': 'Coffee Mug',
          'category': 'Home & Kitchen',
          'selling_price': 299.0,
          'cost_price': 150.0,
          'current_stock': 100,
          'min_stock_level': 15,
          'max_stock_level': 200,
          'unit': 'pieces',
          'tax_percent': 12.0,
          'description': 'Ceramic coffee mug with beautiful design',
        },
        {
          'product_name': 'Bluetooth Speaker',
          'category': 'Electronics',
          'selling_price': 1999.0,
          'cost_price': 1200.0,
          'current_stock': 30,
          'min_stock_level': 5,
          'max_stock_level': 50,
          'unit': 'pieces',
          'tax_percent': 18.0,
          'description': 'Portable Bluetooth speaker with excellent sound quality',
        },
        {
          'product_name': 'Notebook Set',
          'category': 'Stationery',
          'selling_price': 499.0,
          'cost_price': 250.0,
          'current_stock': 75,
          'min_stock_level': 10,
          'max_stock_level': 150,
          'unit': 'set',
          'tax_percent': 12.0,
          'description': 'Set of 3 high-quality notebooks for writing',
        },
      ];

      // Check if products already exist
      final existingProducts = await EnhancedProductService.getAllProducts();
      if (existingProducts.isNotEmpty) {
        debugPrint('✅ Demo products already exist (${existingProducts.length} products)');
        return;
      }

      // Create demo products
      for (final productData in demoProducts) {
        await FirebaseFirestore.instance.collection('products').add({
          ...productData,
          'product_id': '',
          'sku': 'SKU${DateTime.now().millisecondsSinceEpoch}',
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
        });
      }

      debugPrint('✅ Demo products created successfully!');
    } catch (e) {
      debugPrint('❌ Error setting up demo products: $e');
    }
  }

  // Complete demo setup
  static Future<Map<String, dynamic>> setupCompleteDemo() async {
    try {
      debugPrint('🚀 Setting up complete demo environment...');

      // Setup demo products first
      await setupDemoProducts();

      // Setup demo customer
      final customerResult = await setupDemoCustomer();

      if (customerResult['success'] == true) {
        debugPrint('🎉 Demo setup complete!');
        debugPrint('');
        debugPrint('=== DEMO CREDENTIALS ===');
        debugPrint('Email: $demoEmail');
        debugPrint('Password: $demoPassword');
        debugPrint('========================');
        debugPrint('');
        debugPrint('You can now test the customer-centric flow:');
        debugPrint('1. Go to Customer App');
        debugPrint('2. Sign in with the demo credentials');
        debugPrint('3. Browse products and place orders');
        debugPrint('4. Orders will auto-generate POS invoices');
        debugPrint('5. Inventory will be automatically updated');
        debugPrint('6. Customer loyalty points will be awarded');

        return customerResult;
      } else {
        return customerResult;
      }
    } catch (e) {
      debugPrint('❌ Error in complete demo setup: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Reset demo data
  static Future<void> resetDemoData() async {
    try {
      debugPrint('🔄 Resetting demo data...');

      // Delete demo customer orders
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('customer_orders')
          .where('customer_id', isEqualTo: demoCustomerId)
          .get();

      for (final doc in ordersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Reset demo customer loyalty points
      final customer = await CustomerAuthService.getCustomerByEmail(demoEmail);
      if (customer != null) {
        await CustomerAuthService.updateCustomerProfile(customer.customerId, {
          'loyalty_points': 500, // Reset to welcome bonus
        });
      }

      debugPrint('✅ Demo data reset complete!');
    } catch (e) {
      debugPrint('❌ Error resetting demo data: $e');
    }
  }
}
