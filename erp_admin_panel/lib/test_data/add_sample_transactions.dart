import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pos_transaction.dart';

/// Script to add sample transactions for testing
/// Run this once to populate the database with test data
Future<void> addSampleTransactions() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('pos_transactions');

  final sampleTransactions = [
    {
      'pos_transaction_id': 'POS-STORE001-${DateTime.now().millisecondsSinceEpoch}',
      'store_id': 'STORE_001',
      'terminal_id': 'TERMINAL_001',
      'cashier_id': 'CASHIER_001',
      'customer_id': 'CUSTOMER_001',
      'transaction_time': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
      'invoice_number': 'INV-001',
      'customer_name': 'John Doe',
      'customer_phone': '+1234567890',
      'customer_email': 'john@example.com',
      'payment_mode': 'Cash',
      'sub_total': 100.0,
      'discount_amount': 10.0,
      'discount_applied': 10.0,
      'tax_amount': 9.0,
      'total_amount': 99.0,
      'amount_paid': 100.0,
      'amount_due': 0.0,
      'change_amount': 1.0,
      'loyalty_points_earned': 5,
      'loyalty_points_redeemed': 0,
      'coupon_code': '',
      'items': [
        {
          'product_id': 'PROD_001',
          'product_name': 'Sample Product 1',
          'sku': 'SKU001',
          'quantity': 2,
          'unit_price': 50.0,
          'discount': 5.0,
          'tax_rate': 10.0,
          'tax_amount': 4.5,
          'total_price': 95.0,
          'category': 'Electronics',
          'hsn_code': '85171200',
        }
      ],
      'status': 'completed',
      'notes': 'Sample transaction for testing',
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
    },
    {
      'pos_transaction_id': 'POS-STORE001-${DateTime.now().millisecondsSinceEpoch + 1}',
      'store_id': 'STORE_001',
      'terminal_id': 'TERMINAL_001',
      'cashier_id': 'CASHIER_001',
      'customer_id': 'CUSTOMER_002',
      'transaction_time': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      'invoice_number': 'INV-002',
      'customer_name': 'Jane Smith',
      'customer_phone': '+1234567891',
      'customer_email': 'jane@example.com',
      'payment_mode': 'Card',
      'sub_total': 150.0,
      'discount_amount': 0.0,
      'discount_applied': 0.0,
      'tax_amount': 15.0,
      'total_amount': 165.0,
      'amount_paid': 165.0,
      'amount_due': 0.0,
      'change_amount': 0.0,
      'loyalty_points_earned': 8,
      'loyalty_points_redeemed': 0,
      'coupon_code': '',
      'items': [
        {
          'product_id': 'PROD_002',
          'product_name': 'Sample Product 2',
          'sku': 'SKU002',
          'quantity': 1,
          'unit_price': 150.0,
          'discount': 0.0,
          'tax_rate': 10.0,
          'tax_amount': 15.0,
          'total_price': 165.0,
          'category': 'Clothing',
          'hsn_code': '62051000',
        }
      ],
      'status': 'completed',
      'notes': 'Another sample transaction',
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
    },
    {
      'pos_transaction_id': 'POS-STORE001-${DateTime.now().millisecondsSinceEpoch + 2}',
      'store_id': 'STORE_001',
      'terminal_id': 'TERMINAL_001',
      'cashier_id': 'CASHIER_002',
      'customer_id': 'CUSTOMER_003',
      'transaction_time': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
      'invoice_number': 'INV-003',
      'customer_name': 'Bob Wilson',
      'customer_phone': '+1234567892',
      'customer_email': 'bob@example.com',
      'payment_mode': 'UPI',
      'sub_total': 75.0,
      'discount_amount': 5.0,
      'discount_applied': 5.0,
      'tax_amount': 7.0,
      'total_amount': 77.0,
      'amount_paid': 77.0,
      'amount_due': 0.0,
      'change_amount': 0.0,
      'loyalty_points_earned': 4,
      'loyalty_points_redeemed': 0,
      'coupon_code': 'SAVE5',
      'items': [
        {
          'product_id': 'PROD_003',
          'product_name': 'Sample Product 3',
          'sku': 'SKU003',
          'quantity': 3,
          'unit_price': 25.0,
          'discount': 5.0,
          'tax_rate': 10.0,
          'tax_amount': 7.0,
          'total_price': 77.0,
          'category': 'Books',
          'hsn_code': '49011000',
        }
      ],
      'status': 'completed',
      'notes': 'Transaction with discount coupon',
      'created_at': DateTime.now(),
      'updated_at': DateTime.now(),
    },
  ];

  try {
    for (final transaction in sampleTransactions) {
      await collection.add(transaction);
      print('Added transaction: ${transaction['invoice_number']}');
    }
    print('Successfully added ${sampleTransactions.length} sample transactions');
  } catch (e) {
    print('Error adding sample transactions: $e');
  }
}
