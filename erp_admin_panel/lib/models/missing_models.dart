import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a line item in a purchase order
class PoLineItem {
  final String lineItemId;
  final String poId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double? totalPrice;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  PoLineItem({
    required this.lineItemId,
    required this.poId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory PoLineItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PoLineItem(
      lineItemId: doc.id,
      poId: data['po_id'] ?? '',
      productId: data['product_id'] ?? '',
      quantity: (data['quantity'] ?? 0) is int ? data['quantity'] : (data['quantity'] ?? 0).toInt(),
      unitPrice: (data['unit_price'] ?? 0.0) is double ? data['unit_price'] : (data['unit_price'] ?? 0.0).toDouble(),
      totalPrice: (data['total_price'] ?? 0.0) is double ? data['total_price'] : (data['total_price'] ?? 0.0).toDouble(),
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'po_id': poId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice ?? (quantity * unitPrice),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  PoLineItem copyWith({
    String? lineItemId,
    String? poId,
    String? productId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return PoLineItem(
      lineItemId: lineItemId ?? this.lineItemId,
      poId: poId ?? this.poId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Represents a line item in a customer order
class OrderItem {
  final String orderItemId;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double? totalPrice;
  final double? discount;
  final String? notes;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.totalPrice,
    this.discount,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory OrderItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderItem(
      orderItemId: doc.id,
      orderId: data['order_id'] ?? '',
      productId: data['product_id'] ?? '',
      quantity: (data['quantity'] ?? 0) is int ? data['quantity'] : (data['quantity'] ?? 0).toInt(),
      unitPrice: (data['unit_price'] ?? 0.0) is double ? data['unit_price'] : (data['unit_price'] ?? 0.0).toDouble(),
      totalPrice: (data['total_price'] ?? 0.0) is double ? data['total_price'] : (data['total_price'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0) is double ? data['discount'] : (data['discount'] ?? 0.0).toDouble(),
      notes: data['notes'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice ?? (quantity * unitPrice),
      'discount': discount,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  OrderItem copyWith({
    String? orderItemId,
    String? orderId,
    String? productId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? discount,
    String? notes,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return OrderItem(
      orderItemId: orderItemId ?? this.orderItemId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Represents an inventory item in the system
class InventoryItem {
  final String inventoryId;
  final String productId;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final int? reservedStock;
  final int? incomingStock;
  final String? location;
  final String? batchNumber;
  final DateTime? expiryDate;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? deletedBy;

  InventoryItem({
    required this.inventoryId,
    required this.productId,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    this.reservedStock,
    this.incomingStock,
    this.location,
    this.batchNumber,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      inventoryId: doc.id,
      productId: data['product_id'] ?? '',
      currentStock: (data['current_stock'] ?? 0) is int ? data['current_stock'] : (data['current_stock'] ?? 0).toInt(),
      minStockLevel: (data['min_stock_level'] ?? 0) is int ? data['min_stock_level'] : (data['min_stock_level'] ?? 0).toInt(),
      maxStockLevel: (data['max_stock_level'] ?? 100) is int ? data['max_stock_level'] : (data['max_stock_level'] ?? 100).toInt(),
      reservedStock: data['reserved_stock'] != null ? ((data['reserved_stock'] is int) ? data['reserved_stock'] : data['reserved_stock'].toInt()) : null,
      incomingStock: data['incoming_stock'] != null ? ((data['incoming_stock'] is int) ? data['incoming_stock'] : data['incoming_stock'].toInt()) : null,
      location: data['location'],
      batchNumber: data['batch_number'],
      expiryDate: data['expiry_date'] != null ? (data['expiry_date'] as Timestamp).toDate() : null,
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
      deletedBy: data['deleted_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'reserved_stock': reservedStock,
      'incoming_stock': incomingStock,
      'location': location,
      'batch_number': batchNumber,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
    };
  }
}
