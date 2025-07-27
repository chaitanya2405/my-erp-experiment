// Minimal test classes
import 'package:cloud_firestore/cloud_firestore.dart';

class UnifiedPOSTransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  UnifiedPOSTransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class UnifiedCustomer {
  final String id;
  final String fullName;
  final String mobileNumber;

  UnifiedCustomer({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
  });
}

class UnifiedPOLineItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  UnifiedPOLineItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
}
