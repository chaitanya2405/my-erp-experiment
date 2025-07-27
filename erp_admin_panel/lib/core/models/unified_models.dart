// Enhanced Unified Data Models for Ravali Software ERP
// This file contains the unified, consolidated data models that replace
// the fragmented models throughout the original codebase.

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// UNIFIED PRODUCT MODEL 
// ============================================================================

class UnifiedProduct {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? category;
  final String? brand;
  final double costPrice;
  final double salePrice;
  final double? mrp;
  final String? unit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  // Pricing and tax
  final String? taxCategory;
  final double taxRate;
  final List<String> priceComponents;

  // Inventory related
  final bool trackInventory;
  final int? currentStock;
  final int? minStockLevel;
  final int? maxStockLevel;

  UnifiedProduct({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.category,
    this.brand,
    required this.costPrice,
    required this.salePrice,
    this.mrp,
    this.unit,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    this.taxCategory,
    this.taxRate = 0.0,
    this.priceComponents = const [],
    this.trackInventory = true,
    this.currentStock,
    this.minStockLevel,
    this.maxStockLevel,
  });

  factory UnifiedProduct.fromMap(Map<String, dynamic> data) {
    return UnifiedProduct(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      description: data['description'],
      category: data['category'],
      brand: data['brand'],
      costPrice: (data['cost_price'] ?? 0).toDouble(),
      salePrice: (data['sale_price'] ?? 0).toDouble(),
      mrp: data['mrp']?.toDouble(),
      unit: data['unit'],
      isActive: data['is_active'] ?? true,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      taxCategory: data['tax_category'],
      taxRate: (data['tax_rate'] ?? 0).toDouble(),
      priceComponents: List<String>.from(data['price_components'] ?? []),
      trackInventory: data['track_inventory'] ?? true,
      currentStock: data['current_stock'],
      minStockLevel: data['min_stock_level'],
      maxStockLevel: data['max_stock_level'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'category': category,
      'brand': brand,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'mrp': mrp,
      'unit': unit,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
      'tax_category': taxCategory,
      'tax_rate': taxRate,
      'price_components': priceComponents,
      'track_inventory': trackInventory,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
    };
  }

  // Compatibility getters for legacy code
  String get productName => name;
  String get sku => code;
  String get barcode => metadata['barcode'] ?? code;
  double get sellingPrice => salePrice;
  int get stockQuantity => currentStock ?? 0;
  String get productId => id;
  double get taxPercent => taxRate;
  
  factory UnifiedProduct.fromFirestore(Map<String, dynamic> data, String docId) {
    return UnifiedProduct.fromMap({
      ...data,
      'id': docId,
    });
  }
}

// ============================================================================
// UNIFIED CUSTOMER MODEL
// ============================================================================

class UnifiedCustomer {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String? email;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final DateTime? dateOfBirth;
  final String? gender;
  final String loyaltyTier;
  final double totalSpent;
  final int totalOrders;
  final double averageOrderValue;
  final DateTime? lastVisit;
  final bool isActive;
  final String customerSegment;
  final String preferredContactMode;
  final String? preferredStoreId;
  final bool marketingOptIn;
  final String? referralCode;
  final String? referredBy;
  final List<String> supportTickets;
  final List<String> feedbackNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  UnifiedCustomer({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.email,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.dateOfBirth,
    this.gender,
    this.loyaltyTier = 'Bronze',
    this.totalSpent = 0.0,
    this.totalOrders = 0,
    this.averageOrderValue = 0.0,
    this.lastVisit,
    this.isActive = true,
    this.customerSegment = 'Regular',
    this.preferredContactMode = 'SMS',
    this.preferredStoreId,
    this.marketingOptIn = false,
    this.referralCode,
    this.referredBy,
    this.supportTickets = const [],
    this.feedbackNotes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory UnifiedCustomer.fromMap(Map<String, dynamic> data) {
    return UnifiedCustomer(
      id: data['id'] ?? '',
      fullName: data['full_name'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      email: data['email'],
      addressLine1: data['address_line1'],
      addressLine2: data['address_line2'],
      city: data['city'],
      state: data['state'],
      postalCode: data['postal_code'],
      dateOfBirth: data['date_of_birth'] != null 
          ? (data['date_of_birth'] as Timestamp).toDate() 
          : null,
      gender: data['gender'],
      loyaltyTier: data['loyalty_tier'] ?? 'Bronze',
      totalSpent: (data['total_spent'] ?? 0).toDouble(),
      totalOrders: data['total_orders'] ?? 0,
      averageOrderValue: (data['average_order_value'] ?? 0).toDouble(),
      lastVisit: data['last_visit'] != null 
          ? (data['last_visit'] as Timestamp).toDate() 
          : null,
      isActive: data['is_active'] ?? true,
      customerSegment: data['customer_segment'] ?? 'Regular',
      preferredContactMode: data['preferred_contact_mode'] ?? 'SMS',
      preferredStoreId: data['preferred_store_id'],
      marketingOptIn: data['marketing_opt_in'] ?? false,
      referralCode: data['referral_code'],
      referredBy: data['referred_by'],
      supportTickets: List<String>.from(data['support_tickets'] ?? []),
      feedbackNotes: List<String>.from(data['feedback_notes'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'email': email,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'date_of_birth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'loyalty_tier': loyaltyTier,
      'total_spent': totalSpent,
      'total_orders': totalOrders,
      'average_order_value': averageOrderValue,
      'last_visit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'is_active': isActive,
      'customer_segment': customerSegment,
      'preferred_contact_mode': preferredContactMode,
      'preferred_store_id': preferredStoreId,
      'marketing_opt_in': marketingOptIn,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'support_tickets': supportTickets,
      'feedback_notes': feedbackNotes,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }
}

// ============================================================================
// UNIFIED SUPPLIER MODEL
// ============================================================================

class UnifiedSupplier {
  final String id;
  final String name;
  final String contactPerson;
  final String phoneNumber;
  final String? email;
  final String address;
  final String? gstNumber;
  final String? panNumber;
  final bool isActive;
  final double creditLimit;
  final int paymentTerms;
  final String preferredPaymentMode;
  final double totalPurchased;
  final double outstandingAmount;
  final DateTime lastOrderDate;
  final int totalOrders;
  final double averageOrderValue;
  final String supplierRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  UnifiedSupplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phoneNumber,
    this.email,
    required this.address,
    this.gstNumber,
    this.panNumber,
    this.isActive = true,
    this.creditLimit = 0.0,
    this.paymentTerms = 30,
    this.preferredPaymentMode = 'Cash',
    this.totalPurchased = 0.0,
    this.outstandingAmount = 0.0,
    required this.lastOrderDate,
    this.totalOrders = 0,
    this.averageOrderValue = 0.0,
    this.supplierRating = 'A',
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory UnifiedSupplier.fromMap(Map<String, dynamic> data) {
    return UnifiedSupplier(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      contactPerson: data['contact_person'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      email: data['email'],
      address: data['address'] ?? '',
      gstNumber: data['gst_number'],
      panNumber: data['pan_number'],
      isActive: data['is_active'] ?? true,
      creditLimit: (data['credit_limit'] ?? 0).toDouble(),
      paymentTerms: data['payment_terms'] ?? 30,
      preferredPaymentMode: data['preferred_payment_mode'] ?? 'Cash',
      totalPurchased: (data['total_purchased'] ?? 0).toDouble(),
      outstandingAmount: (data['outstanding_amount'] ?? 0).toDouble(),
      lastOrderDate: (data['last_order_date'] as Timestamp).toDate(),
      totalOrders: data['total_orders'] ?? 0,
      averageOrderValue: (data['average_order_value'] ?? 0).toDouble(),
      supplierRating: data['supplier_rating'] ?? 'A',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'is_active': isActive,
      'credit_limit': creditLimit,
      'payment_terms': paymentTerms,
      'preferred_payment_mode': preferredPaymentMode,
      'total_purchased': totalPurchased,
      'outstanding_amount': outstandingAmount,
      'last_order_date': Timestamp.fromDate(lastOrderDate),
      'total_orders': totalOrders,
      'average_order_value': averageOrderValue,
      'supplier_rating': supplierRating,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  factory UnifiedSupplier.fromFirestore(Map<String, dynamic> data, String docId) {
    return UnifiedSupplier.fromMap({
      ...data,
      'id': docId,
    });
  }
}

// ============================================================================
// UNIFIED INVENTORY ITEM MODEL
// ============================================================================

class UnifiedInventoryItem {
  final String id;
  final String productId;
  final String productName;
  final int quantityAvailable;
  final int quantityOnOrder;
  final int quantityReserved;
  final int quantityDamaged;
  final int quantityReturned;
  final int reorderPoint;
  final int safetyStockLevel;
  final double averageDailyUsage;
  final double stockTurnoverRatio;
  final String storageLocation;
  final String storeLocation;
  final String batchNumber;
  final String entryMode;
  final String addedBy;
  final bool autoRestockEnabled;
  final String fifoLifoFlag;
  final String stockStatus;
  final bool auditFlag;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  UnifiedInventoryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityAvailable,
    required this.quantityOnOrder,
    required this.quantityReserved,
    required this.quantityDamaged,
    required this.quantityReturned,
    required this.reorderPoint,
    required this.safetyStockLevel,
    required this.averageDailyUsage,
    required this.stockTurnoverRatio,
    required this.storageLocation,
    required this.storeLocation,
    required this.batchNumber,
    required this.entryMode,
    required this.addedBy,
    required this.autoRestockEnabled,
    required this.fifoLifoFlag,
    required this.stockStatus,
    required this.auditFlag,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory UnifiedInventoryItem.fromMap(Map<String, dynamic> data) {
    return UnifiedInventoryItem(
      id: data['id'] ?? '',
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantityAvailable: data['quantity_available'] ?? 0,
      quantityOnOrder: data['quantity_on_order'] ?? 0,
      quantityReserved: data['quantity_reserved'] ?? 0,
      quantityDamaged: data['quantity_damaged'] ?? 0,
      quantityReturned: data['quantity_returned'] ?? 0,
      reorderPoint: data['reorder_point'] ?? 0,
      safetyStockLevel: data['safety_stock_level'] ?? 0,
      averageDailyUsage: (data['average_daily_usage'] ?? 0).toDouble(),
      stockTurnoverRatio: (data['stock_turnover_ratio'] ?? 0).toDouble(),
      storageLocation: data['storage_location'] ?? '',
      storeLocation: data['store_location'] ?? '',
      batchNumber: data['batch_number'] ?? '',
      entryMode: data['entry_mode'] ?? '',
      addedBy: data['added_by'] ?? '',
      autoRestockEnabled: data['auto_restock_enabled'] ?? false,
      fifoLifoFlag: data['fifo_lifo_flag'] ?? '',
      stockStatus: data['stock_status'] ?? '',
      auditFlag: data['audit_flag'] ?? false,
      remarks: data['remarks'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity_available': quantityAvailable,
      'quantity_on_order': quantityOnOrder,
      'quantity_reserved': quantityReserved,
      'quantity_damaged': quantityDamaged,
      'quantity_returned': quantityReturned,
      'reorder_point': reorderPoint,
      'safety_stock_level': safetyStockLevel,
      'average_daily_usage': averageDailyUsage,
      'stock_turnover_ratio': stockTurnoverRatio,
      'storage_location': storageLocation,
      'store_location': storeLocation,
      'batch_number': batchNumber,
      'entry_mode': entryMode,
      'added_by': addedBy,
      'auto_restock_enabled': autoRestockEnabled,
      'fifo_lifo_flag': fifoLifoFlag,
      'stock_status': stockStatus,
      'audit_flag': auditFlag,
      'remarks': remarks,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  factory UnifiedInventoryItem.fromFirestore(Map<String, dynamic> data, String docId) {
    return UnifiedInventoryItem.fromMap({...data, 'id': docId});
  }

  // Compatibility getters for legacy code
  int get currentStock => quantityAvailable;
  int get minStockLevel => reorderPoint;
  int get maxStockLevel => safetyStockLevel;
  String get location => storageLocation;
  int get availableStock => quantityAvailable - quantityReserved;
  int get reservedStock => quantityReserved;

  UnifiedInventoryItem copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantityAvailable,
    int? quantityOnOrder,
    int? quantityReserved,
    int? quantityDamaged,
    int? quantityReturned,
    int? reorderPoint,
    int? safetyStockLevel,
    double? averageDailyUsage,
    double? stockTurnoverRatio,
    String? storageLocation,
    String? storeLocation,
    String? batchNumber,
    String? entryMode,
    String? addedBy,
    bool? autoRestockEnabled,
    String? fifoLifoFlag,
    String? stockStatus,
    bool? auditFlag,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UnifiedInventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityOnOrder: quantityOnOrder ?? this.quantityOnOrder,
      quantityReserved: quantityReserved ?? this.quantityReserved,
      quantityDamaged: quantityDamaged ?? this.quantityDamaged,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      safetyStockLevel: safetyStockLevel ?? this.safetyStockLevel,
      averageDailyUsage: averageDailyUsage ?? this.averageDailyUsage,
      stockTurnoverRatio: stockTurnoverRatio ?? this.stockTurnoverRatio,
      storageLocation: storageLocation ?? this.storageLocation,
      storeLocation: storeLocation ?? this.storeLocation,
      batchNumber: batchNumber ?? this.batchNumber,
      entryMode: entryMode ?? this.entryMode,
      addedBy: addedBy ?? this.addedBy,
      autoRestockEnabled: autoRestockEnabled ?? this.autoRestockEnabled,
      fifoLifoFlag: fifoLifoFlag ?? this.fifoLifoFlag,
      stockStatus: stockStatus ?? this.stockStatus,
      auditFlag: auditFlag ?? this.auditFlag,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ============================================================================
// UNIFIED PURCHASE ORDER MODELS
// ============================================================================

class UnifiedPOLineItem {
  final String productId;
  final String productName;
  final int orderedQuantity;
  final int receivedQuantity;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final DateTime? expectedDelivery;
  final DateTime? actualDelivery;
  final Map<String, dynamic> metadata;

  UnifiedPOLineItem({
    required this.productId,
    required this.productName,
    required this.orderedQuantity,
    this.receivedQuantity = 0,
    required this.unitPrice,
    required this.totalPrice,
    this.status = 'Pending',
    this.expectedDelivery,
    this.actualDelivery,
    this.metadata = const {},
  });

  factory UnifiedPOLineItem.fromMap(Map<String, dynamic> data) {
    return UnifiedPOLineItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      orderedQuantity: data['ordered_quantity'] ?? 0,
      receivedQuantity: data['received_quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      expectedDelivery: data['expected_delivery'] != null 
          ? (data['expected_delivery'] as Timestamp).toDate() 
          : null,
      actualDelivery: data['actual_delivery'] != null 
          ? (data['actual_delivery'] as Timestamp).toDate() 
          : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'ordered_quantity': orderedQuantity,
      'received_quantity': receivedQuantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'status': status,
      'expected_delivery': expectedDelivery != null ? Timestamp.fromDate(expectedDelivery!) : null,
      'actual_delivery': actualDelivery != null ? Timestamp.fromDate(actualDelivery!) : null,
      'metadata': metadata,
    };
  }

  // Compatibility getters for legacy code
  int get quantity => orderedQuantity;
}

// ============================================================================
// UNIFIED PURCHASE ORDER MODEL
// ============================================================================

class UnifiedPurchaseOrder {
  final String id;
  final String poId;
  final String supplierId;
  final String supplierName;
  final String storeId;
  final String createdBy;
  final String status;
  final List<UnifiedPOLineItem> lineItems;
  final int totalItems;
  final double totalValue;
  final DateTime? expectedDelivery;
  final DateTime? actualDelivery;
  final String deliveryStatus;
  final String billingAddress;
  final String shippingAddress;
  final List<String> documentsAttached;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  UnifiedPurchaseOrder({
    required this.id,
    required this.poId,
    required this.supplierId,
    required this.supplierName,
    required this.storeId,
    required this.createdBy,
    this.status = 'Draft',
    required this.lineItems,
    required this.totalItems,
    required this.totalValue,
    this.expectedDelivery,
    this.actualDelivery,
    required this.deliveryStatus,
    required this.billingAddress,
    required this.shippingAddress,
    this.documentsAttached = const [],
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory UnifiedPurchaseOrder.fromMap(Map<String, dynamic> data) {
    return UnifiedPurchaseOrder(
      id: data['id'] ?? '',
      poId: data['po_id'] ?? '',
      supplierId: data['supplier_id'] ?? '',
      supplierName: data['supplier_name'] ?? '',
      storeId: data['store_id'] ?? '',
      createdBy: data['created_by'] ?? '',
      status: data['status'] ?? 'Draft',
      lineItems: (data['line_items'] as List? ?? [])
          .map((item) => UnifiedPOLineItem.fromMap(item))
          .toList(),
      totalItems: data['total_items'] ?? 0,
      totalValue: (data['total_value'] ?? 0).toDouble(),
      expectedDelivery: data['expected_delivery'] != null 
          ? (data['expected_delivery'] as Timestamp).toDate() 
          : null,
      actualDelivery: data['actual_delivery'] != null 
          ? (data['actual_delivery'] as Timestamp).toDate() 
          : null,
      deliveryStatus: data['delivery_status'] ?? 'Pending',
      billingAddress: data['billing_address'] ?? '',
      shippingAddress: data['shipping_address'] ?? '',
      documentsAttached: List<String>.from(data['documents_attached'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'po_id': poId,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'store_id': storeId,
      'created_by': createdBy,
      'status': status,
      'line_items': lineItems.map((item) => item.toMap()).toList(),
      'total_items': totalItems,
      'total_value': totalValue,
      'expected_delivery': expectedDelivery != null ? Timestamp.fromDate(expectedDelivery!) : null,
      'actual_delivery': actualDelivery != null ? Timestamp.fromDate(actualDelivery!) : null,
      'delivery_status': deliveryStatus,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress,
      'documents_attached': documentsAttached,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  factory UnifiedPurchaseOrder.fromFirestore(Map<String, dynamic> data, String docId) {
    return UnifiedPurchaseOrder.fromMap({...data, 'id': docId});
  }

  UnifiedPurchaseOrder copyWith({
    String? id,
    String? poId,
    String? supplierId,
    String? supplierName,
    String? storeId,
    String? createdBy,
    String? status,
    List<UnifiedPOLineItem>? lineItems,
    int? totalItems,
    double? totalValue,
    DateTime? expectedDelivery,
    DateTime? actualDelivery,
    String? deliveryStatus,
    String? billingAddress,
    String? shippingAddress,
    List<String>? documentsAttached,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UnifiedPurchaseOrder(
      id: id ?? this.id,
      poId: poId ?? this.poId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      storeId: storeId ?? this.storeId,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      totalItems: totalItems ?? this.totalItems,
      totalValue: totalValue ?? this.totalValue,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      documentsAttached: documentsAttached ?? this.documentsAttached,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Compatibility getters for legacy code
  String get poNumber => poId;
  DateTime get orderDate => createdAt;
  String? get approvedBy => metadata['approved_by'];
  String? get remarks => metadata['remarks'];
}

// ============================================================================
// UNIFIED POS TRANSACTION ITEM MODEL
// ============================================================================

class UnifiedPOSTransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discount;
  final Map<String, dynamic> metadata;

  UnifiedPOSTransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discount,
    this.metadata = const {},
  });

  factory UnifiedPOSTransactionItem.fromMap(Map<String, dynamic> data) {
    return UnifiedPOSTransactionItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      discount: data['discount']?.toDouble(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
      'metadata': metadata,
    };
  }

  // Compatibility getters for legacy code
  String get sku => metadata['sku'] ?? productId;
  double get sellingPrice => unitPrice;
  double get totalAmount => totalPrice;
  double get mrp => metadata['mrp']?.toDouble() ?? unitPrice;
  double get discountAmount => discount ?? 0.0;
  double get finalPrice => totalPrice;
  double get taxAmount => metadata['tax_amount']?.toDouble() ?? 0.0;
  String get category => metadata['category'] ?? 'general';
  String? get batchNumber => metadata['batch_number'];
  String get taxSlab => metadata['tax_slab'] ?? '18%';
}

// ============================================================================
// UNIFIED POS TRANSACTION MODEL
// ============================================================================

class UnifiedPOSTransaction {
  final String id;
  final String posTransactionId;
  final String transactionId;
  final String? customerId;
  final String? storeId;
  final String terminalId;
  final String cashierId;
  final List<UnifiedPOSTransactionItem> productItems;
  final double subTotal;
  final double taxAmount;
  final double discountApplied;
  final double roundOffAmount;
  final double totalAmount;
  final String paymentMode;
  final double walletUsed;
  final double changeReturned;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;
  final String invoiceNumber;
  final String invoiceType;
  final String refundStatus;
  final bool syncedToServer;
  final bool syncedToInventory;
  final bool syncedToFinance;
  final bool isOfflineMode;
  final Map<String, dynamic> pricingEngineSnapshot;
  final Map<String, dynamic> taxBreakup;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  UnifiedPOSTransaction({
    required this.id,
    required this.posTransactionId,
    required this.transactionId,
    this.customerId,
    this.storeId,
    required this.terminalId,
    required this.cashierId,
    required this.productItems,
    required this.subTotal,
    required this.taxAmount,
    required this.discountApplied,
    required this.roundOffAmount,
    required this.totalAmount,
    required this.paymentMode,
    required this.walletUsed,
    required this.changeReturned,
    required this.loyaltyPointsEarned,
    required this.loyaltyPointsUsed,
    required this.invoiceNumber,
    required this.invoiceType,
    required this.refundStatus,
    required this.syncedToServer,
    required this.syncedToInventory,
    required this.syncedToFinance,
    required this.isOfflineMode,
    required this.pricingEngineSnapshot,
    required this.taxBreakup,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory UnifiedPOSTransaction.fromMap(Map<String, dynamic> data) {
    return UnifiedPOSTransaction(
      id: data['id'] ?? '',
      posTransactionId: data['pos_transaction_id'] ?? '',
      transactionId: data['transaction_id'] ?? '',
      customerId: data['customer_id'],
      storeId: data['store_id'],
      terminalId: data['terminal_id'] ?? '',
      cashierId: data['cashier_id'] ?? '',
      productItems: (data['product_items'] as List? ?? [])
          .map((item) => UnifiedPOSTransactionItem.fromMap(item))
          .toList(),
      subTotal: (data['sub_total'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      discountApplied: (data['discount_applied'] ?? 0).toDouble(),
      roundOffAmount: (data['round_off_amount'] ?? 0).toDouble(),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      paymentMode: data['payment_mode'] ?? '',
      walletUsed: (data['wallet_used'] ?? 0).toDouble(),
      changeReturned: (data['change_returned'] ?? 0).toDouble(),
      loyaltyPointsEarned: data['loyalty_points_earned'] ?? 0,
      loyaltyPointsUsed: data['loyalty_points_used'] ?? 0,
      invoiceNumber: data['invoice_number'] ?? '',
      invoiceType: data['invoice_type'] ?? '',
      refundStatus: data['refund_status'] ?? '',
      syncedToServer: data['synced_to_server'] ?? false,
      syncedToInventory: data['synced_to_inventory'] ?? false,
      syncedToFinance: data['synced_to_finance'] ?? false,
      isOfflineMode: data['is_offline_mode'] ?? false,
      pricingEngineSnapshot: Map<String, dynamic>.from(data['pricing_engine_snapshot'] ?? {}),
      taxBreakup: Map<String, dynamic>.from(data['tax_breakup'] ?? {}),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pos_transaction_id': posTransactionId,
      'transaction_id': transactionId,
      'customer_id': customerId,
      'store_id': storeId,
      'terminal_id': terminalId,
      'cashier_id': cashierId,
      'product_items': productItems.map((item) => item.toMap()).toList(),
      'sub_total': subTotal,
      'tax_amount': taxAmount,
      'discount_applied': discountApplied,
      'round_off_amount': roundOffAmount,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      'wallet_used': walletUsed,
      'change_returned': changeReturned,
      'loyalty_points_earned': loyaltyPointsEarned,
      'loyalty_points_used': loyaltyPointsUsed,
      'invoice_number': invoiceNumber,
      'invoice_type': invoiceType,
      'refund_status': refundStatus,
      'synced_to_server': syncedToServer,
      'synced_to_inventory': syncedToInventory,
      'synced_to_finance': syncedToFinance,
      'is_offline_mode': isOfflineMode,
      'pricing_engine_snapshot': pricingEngineSnapshot,
      'tax_breakup': taxBreakup,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  // Compatibility getters for legacy code
  DateTime get transactionTime => createdAt;
  String get paymentMethod => paymentMode;
  List<UnifiedPOSTransactionItem> get items => productItems;
  String get remarks => metadata['remarks'] ?? '';
  String get transactionStatus => refundStatus.isEmpty ? 'completed' : refundStatus;
  String get status => transactionStatus; // Alias for transactionStatus
  String get customerName => metadata['customer_name'] ?? '';
  String get customerPhone => metadata['customer_phone'] ?? '';
  String get customerEmail => metadata['customer_email'] ?? '';
  String get customerTier => metadata['customer_tier'] ?? 'Regular';

  // Additional compatibility getters for POS system
  double get subtotal => subTotal;
  double get subtotalAmount => subTotal;
  double get discountAmount => discountApplied;
  String get channel => metadata['channel'] ?? 'POS';
  String get notes => metadata['notes'] ?? '';

  // Required methods for Firestore operations
  factory UnifiedPOSTransaction.fromFirestore(Map<String, dynamic> data, String id) {
    return UnifiedPOSTransaction.fromMap({...data, 'id': id});
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  // Copy with method for updates
  UnifiedPOSTransaction copyWith({
    String? id,
    String? posTransactionId,
    String? transactionId,
    String? customerId,
    String? storeId,
    String? terminalId,
    String? cashierId,
    List<UnifiedPOSTransactionItem>? productItems,
    double? subTotal,
    double? taxAmount,
    double? discountApplied,
    double? roundOffAmount,
    double? totalAmount,
    String? paymentMode,
    double? walletUsed,
    double? changeReturned,
    int? loyaltyPointsEarned,
    int? loyaltyPointsUsed,
    String? invoiceNumber,
    String? invoiceType,
    String? refundStatus,
    bool? syncedToServer,
    bool? syncedToInventory,
    bool? syncedToFinance,
    bool? isOfflineMode,
    Map<String, dynamic>? pricingEngineSnapshot,
    Map<String, dynamic>? taxBreakup,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UnifiedPOSTransaction(
      id: id ?? this.id,
      posTransactionId: posTransactionId ?? this.posTransactionId,
      transactionId: transactionId ?? this.transactionId,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      terminalId: terminalId ?? this.terminalId,
      cashierId: cashierId ?? this.cashierId,
      productItems: productItems ?? this.productItems,
      subTotal: subTotal ?? this.subTotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountApplied: discountApplied ?? this.discountApplied,
      roundOffAmount: roundOffAmount ?? this.roundOffAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      walletUsed: walletUsed ?? this.walletUsed,
      changeReturned: changeReturned ?? this.changeReturned,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceType: invoiceType ?? this.invoiceType,
      refundStatus: refundStatus ?? this.refundStatus,
      syncedToServer: syncedToServer ?? this.syncedToServer,
      syncedToInventory: syncedToInventory ?? this.syncedToInventory,
      syncedToFinance: syncedToFinance ?? this.syncedToFinance,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      pricingEngineSnapshot: pricingEngineSnapshot ?? this.pricingEngineSnapshot,
      taxBreakup: taxBreakup ?? this.taxBreakup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ============================================================================
// UNIFIED CUSTOMER ORDER MODEL
// ============================================================================

class UnifiedCustomerOrder {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String storeId;
  final String status;
  final List<UnifiedPOSTransactionItem> items;
  final double subtotal;
  final double taxAmount;
  final double discount;
  final double totalAmount;
  final String paymentStatus;
  final String deliveryStatus;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  
  // Additional properties for compatibility
  final String? orderNumber;
  final double? deliveryCharges;
  final double? grandTotal;
  final String? remarks;
  final String? orderStatus;
  final String? paymentMode;
  final String? deliveryMode;
  final bool? subscriptionFlag;
  final Map<String, dynamic>? deliveryAddress;
  final String? deliverySlot;
  final String? deliveryPersonId;
  final String? invoiceId;
  final double? walletUsed;
  final String? subscriptionPlan;
  final List<Map<String, dynamic>>? productsOrdered;

  // Compatibility getters
  double get totalValue => totalAmount;

  UnifiedCustomerOrder({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.storeId,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discount,
    required this.totalAmount,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.orderDate,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    this.orderNumber,
    this.deliveryCharges,
    this.grandTotal,
    this.remarks,
    this.orderStatus,
    this.paymentMode,
    this.deliveryMode,
    this.subscriptionFlag,
    this.deliveryAddress,
    this.deliverySlot,
    this.deliveryPersonId,
    this.invoiceId,
    this.walletUsed,
    this.subscriptionPlan,
    this.productsOrdered,
  });

  static String generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }

  factory UnifiedCustomerOrder.fromMap(Map<String, dynamic> data) {
    return UnifiedCustomerOrder(
      id: data['id'] ?? '',
      orderId: data['order_id'] ?? '',
      customerId: data['customer_id'] ?? '',
      customerName: data['customer_name'] ?? '',
      storeId: data['store_id'] ?? '',
      status: data['status'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => UnifiedPOSTransactionItem.fromMap(item))
          .toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      paymentStatus: data['payment_status'] ?? '',
      deliveryStatus: data['delivery_status'] ?? '',
      orderDate: (data['order_date'] as Timestamp).toDate(),
      deliveryDate: data['delivery_date'] != null
          ? (data['delivery_date'] as Timestamp).toDate()
          : null,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      orderNumber: data['order_number'],
      deliveryCharges: data['delivery_charges']?.toDouble(),
      grandTotal: data['grand_total']?.toDouble(),
      remarks: data['remarks'],
      orderStatus: data['order_status'],
      paymentMode: data['payment_mode'],
      deliveryMode: data['delivery_mode'],
      subscriptionFlag: data['subscription_flag'],
      deliveryAddress: data['delivery_address'],
      deliverySlot: data['delivery_slot'],
      deliveryPersonId: data['delivery_person_id'],
      invoiceId: data['invoice_id'],
      walletUsed: data['wallet_used']?.toDouble(),
      subscriptionPlan: data['subscription_plan'],
      productsOrdered: data['products_ordered'] != null 
          ? List<Map<String, dynamic>>.from(data['products_ordered'])
          : null,
    );
  }

  factory UnifiedCustomerOrder.fromFirestore(Map<String, dynamic> data, String docId) {
    return UnifiedCustomerOrder.fromMap({...data, 'id': docId});
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'customer_name': customerName,
      'store_id': storeId,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'delivery_status': deliveryStatus,
      'order_date': Timestamp.fromDate(orderDate),
      'delivery_date': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
      if (orderNumber != null) 'order_number': orderNumber,
      if (deliveryCharges != null) 'delivery_charges': deliveryCharges,
      if (grandTotal != null) 'grand_total': grandTotal,
      if (remarks != null) 'remarks': remarks,
      if (orderStatus != null) 'order_status': orderStatus,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (deliveryMode != null) 'delivery_mode': deliveryMode,
      if (subscriptionFlag != null) 'subscription_flag': subscriptionFlag,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (deliverySlot != null) 'delivery_slot': deliverySlot,
      if (deliveryPersonId != null) 'delivery_person_id': deliveryPersonId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (walletUsed != null) 'wallet_used': walletUsed,
      if (subscriptionPlan != null) 'subscription_plan': subscriptionPlan,
      if (productsOrdered != null) 'products_ordered': productsOrdered,
    };
  }

  Map<String, dynamic> toFirestore() => toMap();
}

// ============================================================================
// UNIFIED METRIC MODEL
// ============================================================================

class UnifiedMetric {
  final String id;
  final String name;
  final String category;
  final String type;
  final dynamic value;
  final String unit;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic> dimensions;
  final Map<String, dynamic> metadata;

  UnifiedMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.source,
    this.dimensions = const {},
    this.metadata = const {},
  });

  factory UnifiedMetric.fromMap(Map<String, dynamic> data) {
    return UnifiedMetric(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      value: data['value'],
      unit: data['unit'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      source: data['source'] ?? '',
      dimensions: Map<String, dynamic>.from(data['dimensions'] ?? {}),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': Timestamp.fromDate(timestamp),
      'source': source,
      'dimensions': dimensions,
      'metadata': metadata,
    };
  }
}

// ============================================================================
// UNIFIED CUSTOMER PROFILE MODEL
// ============================================================================

class UnifiedCustomerProfile {
  final String id;
  final String customerId;
  final String fullName;
  final String mobileNumber;
  final String? email;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final DateTime? dateOfBirth;
  final String gender;
  final String loyaltyTier;
  final double totalSpent;
  final int totalOrders;
  final double averageOrderValue;
  final DateTime? lastVisit;
  final bool isActive;
  final String customerSegment;
  final String preferredContactMode;
  final String? preferredStoreId;
  final bool marketingOptIn;
  final String? referralCode;
  final String? referredBy;
  final List<String> supportTickets;
  final List<String> feedbackNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  UnifiedCustomerProfile({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.mobileNumber,
    this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.dateOfBirth,
    required this.gender,
    required this.loyaltyTier,
    required this.totalSpent,
    required this.totalOrders,
    required this.averageOrderValue,
    this.lastVisit,
    this.isActive = true,
    required this.customerSegment,
    required this.preferredContactMode,
    this.preferredStoreId,
    required this.marketingOptIn,
    this.referralCode,
    this.referredBy,
    this.supportTickets = const [],
    this.feedbackNotes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory UnifiedCustomerProfile.fromMap(Map<String, dynamic> data) {
    return UnifiedCustomerProfile(
      id: data['id'] ?? '',
      customerId: data['customer_id'] ?? '',
      fullName: data['full_name'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      email: data['email'],
      addressLine1: data['address_line1'] ?? '',
      addressLine2: data['address_line2'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postal_code'] ?? '',
      dateOfBirth: data['date_of_birth'] != null 
          ? (data['date_of_birth'] as Timestamp).toDate() 
          : null,
      gender: data['gender'] ?? '',
      loyaltyTier: data['loyalty_tier'] ?? 'Bronze',
      totalSpent: (data['total_spent'] ?? 0).toDouble(),
      totalOrders: data['total_orders'] ?? 0,
      averageOrderValue: (data['average_order_value'] ?? 0).toDouble(),
      lastVisit: data['last_visit'] != null 
          ? (data['last_visit'] as Timestamp).toDate() 
          : null,
      isActive: data['is_active'] ?? true,
      customerSegment: data['customer_segment'] ?? 'Regular',
      preferredContactMode: data['preferred_contact_mode'] ?? 'SMS',
      preferredStoreId: data['preferred_store_id'],
      marketingOptIn: data['marketing_opt_in'] ?? false,
      referralCode: data['referral_code'],
      referredBy: data['referred_by'],
      supportTickets: List<String>.from(data['support_tickets'] ?? []),
      feedbackNotes: List<String>.from(data['feedback_notes'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'email': email,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'date_of_birth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'loyalty_tier': loyaltyTier,
      'total_spent': totalSpent,
      'total_orders': totalOrders,
      'average_order_value': averageOrderValue,
      'last_visit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'is_active': isActive,
      'customer_segment': customerSegment,
      'preferred_contact_mode': preferredContactMode,
      'preferred_store_id': preferredStoreId,
      'marketing_opt_in': marketingOptIn,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'support_tickets': supportTickets,
      'feedback_notes': feedbackNotes,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  factory UnifiedCustomerProfile.fromFirestore(Map<String, dynamic> data, String docId) {
    return UnifiedCustomerProfile.fromMap({
      ...data,
      'id': docId,
    });
  }

  // Compatibility getters for legacy code
  String get customerName => fullName;
  int get loyaltyPoints => metadata['loyalty_points'] ?? 0;
}

// ============================================================================
// UNIFIED INVENTORY RECORD MODEL
// ============================================================================

class UnifiedInventoryRecord {
  final String id;
  final String productId;
  final String productName;
  final int quantityAvailable;
  final int quantityOnOrder;
  final int quantityReserved;
  final int quantityDamaged;
  final int quantityReturned;
  final int reorderPoint;
  final int safetyStockLevel;
  final double averageDailyUsage;
  final double stockTurnoverRatio;
  final String storageLocation;
  final String storeLocation;
  final String batchNumber;
  final String entryMode;
  final String addedBy;
  final bool autoRestockEnabled;
  final String fifoLifoFlag;
  final String stockStatus;
  final bool auditFlag;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  // Additional properties for compatibility
  final int maximumQuantity;
  final String location;
  final double costPrice;

  UnifiedInventoryRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityAvailable,
    required this.quantityOnOrder,
    required this.quantityReserved,
    required this.quantityDamaged,
    required this.quantityReturned,
    required this.reorderPoint,
    required this.safetyStockLevel,
    required this.averageDailyUsage,
    required this.stockTurnoverRatio,
    required this.storageLocation,
    required this.storeLocation,
    required this.batchNumber,
    required this.entryMode,
    required this.addedBy,
    required this.autoRestockEnabled,
    required this.fifoLifoFlag,
    required this.stockStatus,
    required this.auditFlag,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    required this.maximumQuantity,
    required this.location,
    required this.costPrice,
  });

  factory UnifiedInventoryRecord.fromMap(Map<String, dynamic> data) {
    return UnifiedInventoryRecord(
      id: data['id'] ?? '',
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantityAvailable: data['quantity_available'] ?? 0,
      quantityOnOrder: data['quantity_on_order'] ?? 0,
      quantityReserved: data['quantity_reserved'] ?? 0,
      quantityDamaged: data['quantity_damaged'] ?? 0,
      quantityReturned: data['quantity_returned'] ?? 0,
      reorderPoint: data['reorder_point'] ?? 0,
      safetyStockLevel: data['safety_stock_level'] ?? 0,
      averageDailyUsage: (data['average_daily_usage'] ?? 0).toDouble(),
      stockTurnoverRatio: (data['stock_turnover_ratio'] ?? 0).toDouble(),
      storageLocation: data['storage_location'] ?? '',
      storeLocation: data['store_location'] ?? '',
      batchNumber: data['batch_number'] ?? '',
      entryMode: data['entry_mode'] ?? '',
      addedBy: data['added_by'] ?? '',
      autoRestockEnabled: data['auto_restock_enabled'] ?? false,
      fifoLifoFlag: data['fifo_lifo_flag'] ?? '',
      stockStatus: data['stock_status'] ?? '',
      auditFlag: data['audit_flag'] ?? false,
      remarks: data['remarks'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      maximumQuantity: data['maximum_quantity'] ?? 0,
      location: data['location'] ?? data['storage_location'] ?? '',
      costPrice: (data['cost_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity_available': quantityAvailable,
      'quantity_on_order': quantityOnOrder,
      'quantity_reserved': quantityReserved,
      'quantity_damaged': quantityDamaged,
      'quantity_returned': quantityReturned,
      'reorder_point': reorderPoint,
      'safety_stock_level': safetyStockLevel,
      'average_daily_usage': averageDailyUsage,
      'stock_turnover_ratio': stockTurnoverRatio,
      'storage_location': storageLocation,
      'store_location': storeLocation,
      'batch_number': batchNumber,
      'entry_mode': entryMode,
      'added_by': addedBy,
      'auto_restock_enabled': autoRestockEnabled,
      'fifo_lifo_flag': fifoLifoFlag,
      'stock_status': stockStatus,
      'audit_flag': auditFlag,
      'remarks': remarks,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
      'maximum_quantity': maximumQuantity,
      'location': location,
      'cost_price': costPrice,
    };
  }
}

// ============================================================================
// UNIFIED CART ITEM MODEL
// ============================================================================

class UnifiedCartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discount;
  final String? notes;
  final Map<String, dynamic> metadata;

  // Compatibility getters
  double get taxAmount => 0.0; // Default tax amount
  double get discountAmount => discount ?? 0.0;

  UnifiedCartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discount,
    this.notes,
    this.metadata = const {},
  });

  factory UnifiedCartItem.fromMap(Map<String, dynamic> data) {
    return UnifiedCartItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      discount: data['discount']?.toDouble(),
      notes: data['notes'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

// ============================================================================
// UNIFIED TRANSACTION ITEM MODEL
// ============================================================================

class UnifiedTransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double taxAmount;
  final double discountAmount;
  final String status;
  final Map<String, dynamic> metadata;

  UnifiedTransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.status = 'Completed',
    this.metadata = const {},
  });

  factory UnifiedTransactionItem.fromMap(Map<String, dynamic> data) {
    return UnifiedTransactionItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      discountAmount: (data['discount_amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Completed',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'status': status,
      'metadata': metadata,
    };
  }
}

// ============================================================================
// UNIFIED RETURN ITEM MODEL
// ============================================================================

class UnifiedReturnItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalRefund;
  final String reason;
  final String status;
  final DateTime returnDate;
  final Map<String, dynamic> metadata;

  UnifiedReturnItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalRefund,
    required this.reason,
    this.status = 'Pending',
    required this.returnDate,
    this.metadata = const {},
  });

  factory UnifiedReturnItem.fromMap(Map<String, dynamic> data) {
    return UnifiedReturnItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      totalRefund: (data['total_refund'] ?? 0).toDouble(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'Pending',
      returnDate: (data['return_date'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_refund': totalRefund,
      'reason': reason,
      'status': status,
      'return_date': Timestamp.fromDate(returnDate),
      'metadata': metadata,
    };
  }
}

// ============================================================================
// UNIFIED RECEIVED ITEM MODEL
// ============================================================================

class UnifiedReceivedItem {
  final String productId;
  final String productName;
  final int orderedQuantity;
  final int receivedQuantity;
  final int rejectedQuantity;
  final double unitPrice;
  final double totalValue;
  final String status;
  final String? rejectionReason;
  final DateTime receivedDate;
  final String receivedBy;
  final String fromLocation;
  final String toLocation;
  final String initiatedBy;
  final Map<String, dynamic> metadata;

  UnifiedReceivedItem({
    required this.productId,
    required this.productName,
    required this.orderedQuantity,
    required this.receivedQuantity,
    this.rejectedQuantity = 0,
    required this.unitPrice,
    required this.totalValue,
    this.status = 'Received',
    this.rejectionReason,
    required this.receivedDate,
    required this.receivedBy,
    required this.fromLocation,
    required this.toLocation,
    required this.initiatedBy,
    this.metadata = const {},
  });

  factory UnifiedReceivedItem.fromMap(Map<String, dynamic> data) {
    return UnifiedReceivedItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      orderedQuantity: data['ordered_quantity'] ?? 0,
      receivedQuantity: data['received_quantity'] ?? 0,
      rejectedQuantity: data['rejected_quantity'] ?? 0,
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      totalValue: (data['total_value'] ?? 0).toDouble(),
      status: data['status'] ?? 'Received',
      rejectionReason: data['rejection_reason'],
      receivedDate: (data['received_date'] as Timestamp).toDate(),
      receivedBy: data['received_by'] ?? '',
      fromLocation: data['from_location'] ?? '',
      toLocation: data['to_location'] ?? '',
      initiatedBy: data['initiated_by'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'ordered_quantity': orderedQuantity,
      'received_quantity': receivedQuantity,
      'rejected_quantity': rejectedQuantity,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'status': status,
      'rejection_reason': rejectionReason,
      'received_date': Timestamp.fromDate(receivedDate),
      'received_by': receivedBy,
      'from_location': fromLocation,
      'to_location': toLocation,
      'initiated_by': initiatedBy,
      'metadata': metadata,
    };
  }
}

// ============================================================================
// TYPE ALIASES FOR BACKWARD COMPATIBILITY
// ============================================================================

typedef Product = UnifiedProduct;
typedef CustomerProfile = UnifiedCustomerProfile;
typedef Supplier = UnifiedSupplier;
typedef InventoryItem = UnifiedInventoryItem;
typedef InventoryRecord = UnifiedInventoryRecord;
typedef CartItem = UnifiedCartItem;
typedef PurchaseOrder = UnifiedPurchaseOrder;
typedef PosTransaction = UnifiedPOSTransaction;
typedef CustomerOrder = UnifiedCustomerOrder;
