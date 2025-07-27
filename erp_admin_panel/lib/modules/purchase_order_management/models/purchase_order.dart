import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseOrder {
  final String poId;
  final String poNumber;
  final String supplierId;
  final String storeId;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final String status;
  final int totalItems;
  final double totalValue;
  final String createdBy;
  final String? approvedBy;
  final String? remarks;
  final List<POItem> lineItems;
  final String? paymentTerms;
  final String? deliveryTerms;
  final String? invoiceNumber;
  final DateTime? receivedDate;
  final String deliveryStatus;
  final List<String> documentsAttached;
  final List<Map<String, dynamic>> approvalHistory;
  // New fields
  final String billingAddress;
  final String shippingAddress;

  PurchaseOrder({
    required this.poId,
    required this.poNumber,
    required this.supplierId,
    required this.storeId,
    required this.orderDate,
    required this.expectedDelivery,
    required this.status,
    required this.totalItems,
    required this.totalValue,
    required this.createdBy,
    this.approvedBy,
    this.remarks,
    required this.lineItems,
    this.paymentTerms,
    this.deliveryTerms,
    this.invoiceNumber,
    this.receivedDate,
    required this.deliveryStatus,
    required this.documentsAttached,
    this.approvalHistory = const [],
    required this.billingAddress,
    required this.shippingAddress,
  });

  // Getters for UI compatibility
  String get id => poId;
  DateTime get date => orderDate;
  double get totalAmount => totalValue;

  // Firestore integration
  factory PurchaseOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PurchaseOrder(
      poId: doc.id,
      poNumber: data['poNumber'] ?? '',
      supplierId: data['supplierId'] ?? '',
      storeId: data['storeId'] ?? '',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      expectedDelivery: (data['expectedDelivery'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      totalItems: data['totalItems'] ?? 0,
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      approvedBy: data['approvedBy'],
      remarks: data['remarks'],
      lineItems: (data['lineItems'] as List<dynamic>? ?? [])
          .map((item) => POItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      paymentTerms: data['paymentTerms'],
      deliveryTerms: data['deliveryTerms'],
      invoiceNumber: data['invoiceNumber'],
      receivedDate: data['receivedDate'] != null
          ? (data['receivedDate'] as Timestamp).toDate()
          : null,
      deliveryStatus: data['deliveryStatus'] ?? '',
      documentsAttached: List<String>.from(data['documentsAttached'] ?? []),
      approvalHistory: List<Map<String, dynamic>>.from(data['approvalHistory'] ?? []),
      billingAddress: data['billingAddress'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'poNumber': poNumber,
      'supplierId': supplierId,
      'storeId': storeId,
      'orderDate': orderDate,
      'expectedDelivery': expectedDelivery,
      'status': status,
      'totalItems': totalItems,
      'totalValue': totalValue,
      'createdBy': createdBy,
      'approvedBy': approvedBy,
      'remarks': remarks,
      'lineItems': lineItems.map((item) => item.toMap()).toList(),
      'paymentTerms': paymentTerms,
      'deliveryTerms': deliveryTerms,
      'invoiceNumber': invoiceNumber,
      'receivedDate': receivedDate,
      'deliveryStatus': deliveryStatus,
      'documentsAttached': documentsAttached,
      'approvalHistory': approvalHistory,
      'billingAddress': billingAddress,
      'shippingAddress': shippingAddress,
    };
  }
}

class POItem {
  final String sku;
  final int quantity;
  final double price;
  final double discount;
  final double tax;

  POItem({
    required this.sku,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.tax,
  });

  factory POItem.fromMap(Map<String, dynamic> map) {
    return POItem(
      sku: map['sku'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'tax': tax,
    };
  }
}
