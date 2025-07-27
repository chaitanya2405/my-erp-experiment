// Original models from the existing Ravali Software project
// These models match the existing Firestore structure and data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Export all original models for use throughout the enhanced system
export 'package:cloud_firestore/cloud_firestore.dart';

// Product model (matches existing Firestore structure)
class Product {
  final String productId;
  final String productName;
  final String productSlug;
  final String category;
  final String? subcategory;
  final String? brand;
  final String? variant;
  final String unit;
  final String? description;
  final String sku;
  final String? barcode;
  final String? hsnCode;
  final double mrp;
  final double costPrice;
  final double sellingPrice;
  final double marginPercent;
  final double taxPercent;
  final String taxCategory;
  final DocumentReference? defaultSupplierRef;
  final int minStockLevel;
  final int maxStockLevel;
  final int? leadTimeDays;
  final int? shelfLifeDays;
  final String productStatus;
  final String productType;
  final List<String>? productImageUrls;
  final List<String>? tags;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? deletedAt;
  final String? createdBy;
  final String? updatedBy;

  // Computed property for current stock (to be fetched from inventory)
  int get currentStock => 0; // Default to 0, should be updated with actual inventory data

  Product({
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.category,
    this.subcategory,
    this.brand,
    this.variant,
    required this.unit,
    this.description,
    required this.sku,
    this.barcode,
    this.hsnCode,
    required this.mrp,
    required this.costPrice,
    required this.sellingPrice,
    required this.marginPercent,
    required this.taxPercent,
    required this.taxCategory,
    this.defaultSupplierRef,
    required this.minStockLevel,
    required this.maxStockLevel,
    this.leadTimeDays,
    this.shelfLifeDays,
    required this.productStatus,
    required this.productType,
    this.productImageUrls,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      productId: doc.id,
      productName: data['product_name'] ?? '',
      productSlug: data['product_slug'] ?? '',
      category: data['category'] ?? 'Uncategorized',
      subcategory: data['subcategory'],
      brand: data['brand'],
      variant: data['variant'],
      unit: data['unit'] ?? 'pcs',
      description: data['description'],
      sku: data['sku'] ?? '',
      barcode: data['barcode'],
      hsnCode: data['hsn_code'],
      mrp: (data['mrp'] ?? 0).toDouble(),
      costPrice: (data['cost_price'] ?? 0).toDouble(),
      sellingPrice: (data['selling_price'] ?? 0).toDouble(),
      marginPercent: (data['margin_percent'] ?? 0).toDouble(),
      taxPercent: (data['tax_percent'] ?? 0).toDouble(),
      taxCategory: data['tax_category'] ?? 'Standard',
      defaultSupplierRef: data['default_supplier_ref'],
      minStockLevel: data['min_stock_level'] ?? 10,
      maxStockLevel: data['max_stock_level'] ?? 100,
      leadTimeDays: data['lead_time_days'],
      shelfLifeDays: data['shelf_life_days'],
      productStatus: data['product_status'] ?? 'active',
      productType: data['product_type'] ?? 'simple',
      productImageUrls: data['product_image_urls'] != null ? 
        List<String>.from(data['product_image_urls']) : null,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'product_slug': productSlug,
      'category': category,
      'subcategory': subcategory,
      'brand': brand,
      'variant': variant,
      'unit': unit,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'hsn_code': hsnCode,
      'mrp': mrp,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'margin_percent': marginPercent,
      'tax_percent': taxPercent,
      'tax_category': taxCategory,
      'default_supplier_ref': defaultSupplierRef,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'lead_time_days': leadTimeDays,
      'shelf_life_days': shelfLifeDays,
      'product_status': productStatus,
      'product_type': productType,
      'product_image_urls': productImageUrls,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}

// Customer Order model (matches existing Firestore structure)
class CustomerOrder {
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String storeId;
  final Timestamp orderDate;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMode;
  final String deliveryMode;
  final Map<String, dynamic>? deliveryAddress;
  final List<Map<String, dynamic>> productsOrdered;
  final double totalAmount;
  final double discount;
  final double taxAmount;
  final double deliveryCharges;
  final double grandTotal;
  final bool subscriptionFlag;
  final String? subscriptionPlan;
  final double walletUsed;
  final String? deliverySlot;
  final String? deliveryPersonId;
  final String? invoiceId;
  final String? remarks;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CustomerOrder({
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.storeId,
    required this.orderDate,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMode,
    required this.deliveryMode,
    this.deliveryAddress,
    required this.productsOrdered,
    required this.totalAmount,
    required this.discount,
    required this.taxAmount,
    required this.deliveryCharges,
    required this.grandTotal,
    required this.subscriptionFlag,
    this.subscriptionPlan,
    required this.walletUsed,
    this.deliverySlot,
    this.deliveryPersonId,
    this.invoiceId,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to parse delivery address - handles both string and Map formats
  static Map<String, dynamic>? _parseDeliveryAddress(dynamic address) {
    if (address == null) return null;
    
    if (address is Map<String, dynamic>) {
      return address;
    } else if (address is String) {
      // Convert string address to Map format
      return {
        'address': address,
        'city': '',
        'state': '',
        'pincode': '',
      };
    }
    
    return null;
  }

  factory CustomerOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerOrder(
      orderId: doc.id,
      orderNumber: data['order_number'] ?? '',
      customerId: data['customer_id'] ?? '',
      storeId: data['store_id'] ?? '',
      orderDate: data['order_date'] ?? Timestamp.now(),
      orderStatus: data['order_status'] ?? 'pending',
      paymentStatus: data['payment_status'] ?? 'pending',
      paymentMode: data['payment_mode'] ?? 'cash',
      deliveryMode: data['delivery_mode'] ?? 'pickup',
      deliveryAddress: _parseDeliveryAddress(data['delivery_address']),
      productsOrdered: data['products_ordered'] != null ? 
        List<Map<String, dynamic>>.from(data['products_ordered']) : [],
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      deliveryCharges: (data['delivery_charges'] ?? 0).toDouble(),
      grandTotal: (data['grand_total'] ?? 0).toDouble(),
      subscriptionFlag: data['subscription_flag'] ?? false,
      subscriptionPlan: data['subscription_plan'],
      walletUsed: (data['wallet_used'] ?? 0).toDouble(),
      deliverySlot: data['delivery_slot'],
      deliveryPersonId: data['delivery_person_id'],
      invoiceId: data['invoice_id'],
      remarks: data['remarks'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_number': orderNumber,
      'customer_id': customerId,
      'store_id': storeId,
      'order_date': orderDate,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'payment_mode': paymentMode,
      'delivery_mode': deliveryMode,
      'delivery_address': deliveryAddress,
      'products_ordered': productsOrdered,
      'total_amount': totalAmount,
      'discount': discount,
      'tax_amount': taxAmount,
      'delivery_charges': deliveryCharges,
      'grand_total': grandTotal,
      'subscription_flag': subscriptionFlag,
      'subscription_plan': subscriptionPlan,
      'wallet_used': walletUsed,
      'delivery_slot': deliverySlot,
      'delivery_person_id': deliveryPersonId,
      'invoice_id': invoiceId,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  CustomerOrder copyWith({
    String? orderId,
    String? orderNumber,
    String? customerId,
    String? storeId,
    Timestamp? orderDate,
    String? orderStatus,
    String? paymentStatus,
    String? paymentMode,
    String? deliveryMode,
    Map<String, dynamic>? deliveryAddress,
    List<Map<String, dynamic>>? productsOrdered,
    double? totalAmount,
    double? discount,
    double? taxAmount,
    double? deliveryCharges,
    double? grandTotal,
    bool? subscriptionFlag,
    String? subscriptionPlan,
    double? walletUsed,
    String? deliverySlot,
    String? deliveryPersonId,
    String? invoiceId,
    String? remarks,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return CustomerOrder(
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      orderDate: orderDate ?? this.orderDate,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      productsOrdered: productsOrdered ?? this.productsOrdered,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      grandTotal: grandTotal ?? this.grandTotal,
      subscriptionFlag: subscriptionFlag ?? this.subscriptionFlag,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      walletUsed: walletUsed ?? this.walletUsed,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      invoiceId: invoiceId ?? this.invoiceId,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Purchase Order model (matches existing Firestore structure)
class POItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final String? remarks;

  POItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.remarks,
  });

  factory POItem.fromMap(Map<String, dynamic> map) {
    return POItem(
      productId: map['product_id'] ?? '',
      productName: map['product_name'] ?? '',
      sku: map['sku'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitCost: (map['unit_cost'] ?? 0).toDouble(),
      totalCost: (map['total_cost'] ?? 0).toDouble(),
      remarks: map['remarks'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'quantity': quantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'remarks': remarks,
    };
  }
}

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

  factory PurchaseOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PurchaseOrder(
      poId: doc.id,
      poNumber: data['po_number'] ?? '',
      supplierId: data['supplier_id'] ?? '',
      storeId: data['store_id'] ?? '',
      orderDate: _parseTimestamp(data['order_date']),
      expectedDelivery: _parseTimestamp(data['expected_delivery']),
      status: data['status'] ?? 'draft',
      totalItems: data['total_items'] ?? 0,
      totalValue: (data['total_value'] ?? 0).toDouble(),
      createdBy: data['created_by'] ?? '',
      approvedBy: data['approved_by'],
      remarks: data['remarks'],
      lineItems: (data['line_items'] as List<dynamic>?)
          ?.map((item) => POItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      paymentTerms: data['payment_terms'],
      deliveryTerms: data['delivery_terms'],
      invoiceNumber: data['invoice_number'],
      receivedDate: data['received_date'] != null ? 
        _parseTimestamp(data['received_date']) : null,
      deliveryStatus: data['delivery_status'] ?? 'pending',
      documentsAttached: data['documents_attached'] != null ? 
        List<String>.from(data['documents_attached']) : [],
      approvalHistory: data['approval_history'] != null ? 
        List<Map<String, dynamic>>.from(data['approval_history']) : [],
      billingAddress: data['billing_address'] ?? '',
      shippingAddress: data['shipping_address'] ?? '',
    );
  }

  // Helper method to safely parse Timestamp fields
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    
    if (timestamp is DateTime) {
      return timestamp;
    }
    
    // Try to parse string timestamps if needed
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now(); // Default fallback
  }

  Map<String, dynamic> toMap() {
    return {
      'po_number': poNumber,
      'supplier_id': supplierId,
      'store_id': storeId,
      'order_date': Timestamp.fromDate(orderDate),
      'expected_delivery': Timestamp.fromDate(expectedDelivery),
      'status': status,
      'total_items': totalItems,
      'total_value': totalValue,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'remarks': remarks,
      'line_items': lineItems.map((item) => item.toMap()).toList(),
      'payment_terms': paymentTerms,
      'delivery_terms': deliveryTerms,
      'invoice_number': invoiceNumber,
      'received_date': receivedDate != null ? Timestamp.fromDate(receivedDate!) : null,
      'delivery_status': deliveryStatus,
      'documents_attached': documentsAttached,
      'approval_history': approvalHistory,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress,
    };
  }
}

// Supplier model (matches existing Firestore structure)
class Supplier {
  final String supplierId;
  final String supplierName;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String gstNumber;
  final String panNumber;
  final String bankDetails;
  final String supplierType;
  final String supplierStatus;
  final double creditLimit;
  final int paymentTerms;
  final List<String> productCategories;
  final double supplierRating;
  final String? notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Supplier({
    required this.supplierId,
    required this.supplierName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.gstNumber,
    required this.panNumber,
    required this.bankDetails,
    required this.supplierType,
    required this.supplierStatus,
    required this.creditLimit,
    required this.paymentTerms,
    required this.productCategories,
    required this.supplierRating,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Supplier(
      supplierId: doc.id,
      supplierName: data['supplier_name'] ?? '',
      contactPerson: data['contact_person'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      pincode: data['pincode'] ?? '',
      gstNumber: data['gst_number'] ?? '',
      panNumber: data['pan_number'] ?? '',
      bankDetails: data['bank_details'] ?? '',
      supplierType: data['supplier_type'] ?? 'regular',
      supplierStatus: data['supplier_status'] ?? 'active',
      creditLimit: (data['credit_limit'] ?? 0).toDouble(),
      paymentTerms: _parsePaymentTerms(data['payment_terms']),
      productCategories: data['product_categories'] != null ? 
        List<String>.from(data['product_categories']) : [],
      supplierRating: (data['supplier_rating'] ?? 0).toDouble(),
      notes: data['notes'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  // Helper method to parse payment terms from various formats
  static int _parsePaymentTerms(dynamic paymentTerms) {
    if (paymentTerms == null) return 30;
    
    if (paymentTerms is int) return paymentTerms;
    
    if (paymentTerms is String) {
      // Extract numbers from strings like "Net 30", "30 days", etc.
      final regex = RegExp(r'\d+');
      final match = regex.firstMatch(paymentTerms);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 30;
      }
      return 30;
    }
    
    return 30; // Default fallback
  }

  Map<String, dynamic> toMap() {
    return {
      'supplier_name': supplierName,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'bank_details': bankDetails,
      'supplier_type': supplierType,
      'supplier_status': supplierStatus,
      'credit_limit': creditLimit,
      'payment_terms': paymentTerms,
      'product_categories': productCategories,
      'supplier_rating': supplierRating,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Customer Profile model (matches existing Firestore structure)
class CustomerProfile {
  final String customerId;
  final String customerName;
  final String email;
  final String phone;
  final String? altPhone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String customerType;
  final String customerStatus;
  final double creditLimit;
  final double walletBalance;
  final int loyaltyPoints;
  final String? gstNumber;
  final String? companyName;
  final Timestamp dateOfBirth;
  final String gender;
  final List<String> preferredCategories;
  final Map<String, dynamic>? preferences;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // Computed property for loyalty tier based on points
  String get loyaltyTier {
    if (loyaltyPoints >= 10000) return 'Platinum';
    if (loyaltyPoints >= 5000) return 'Gold';
    if (loyaltyPoints >= 1000) return 'Silver';
    return 'Bronze';
  }

  CustomerProfile({
    required this.customerId,
    required this.customerName,
    required this.email,
    required this.phone,
    this.altPhone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    required this.customerType,
    required this.customerStatus,
    required this.creditLimit,
    required this.walletBalance,
    required this.loyaltyPoints,
    this.gstNumber,
    this.companyName,
    required this.dateOfBirth,
    required this.gender,
    required this.preferredCategories,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerProfile(
      customerId: doc.id,
      customerName: data['customer_name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      altPhone: data['alt_phone'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      pincode: data['pincode'],
      customerType: data['customer_type'] ?? 'regular',
      customerStatus: data['customer_status'] ?? 'active',
      creditLimit: (data['credit_limit'] ?? 0).toDouble(),
      walletBalance: (data['wallet_balance'] ?? 0).toDouble(),
      loyaltyPoints: data['loyalty_points'] ?? 0,
      gstNumber: data['gst_number'],
      companyName: data['company_name'],
      dateOfBirth: data['date_of_birth'] ?? Timestamp.now(),
      gender: data['gender'] ?? 'other',
      preferredCategories: data['preferred_categories'] != null ? 
        List<String>.from(data['preferred_categories']) : [],
      preferences: data['preferences'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_name': customerName,
      'email': email,
      'phone': phone,
      'alt_phone': altPhone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'customer_type': customerType,
      'customer_status': customerStatus,
      'credit_limit': creditLimit,
      'wallet_balance': walletBalance,
      'loyalty_points': loyaltyPoints,
      'gst_number': gstNumber,
      'company_name': companyName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'preferred_categories': preferredCategories,
      'preferences': preferences,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// POS Transaction model (matches existing Firestore structure)
class PosTransaction {
  final String transactionId;
  final String storeId;
  final String? customerId;
  final String cashierId;
  final Timestamp transactionDate;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String transactionStatus;
  final String? receiptNumber;
  final Map<String, dynamic>? customerInfo;
  final String? notes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PosTransaction({
    required this.transactionId,
    required this.storeId,
    this.customerId,
    required this.cashierId,
    required this.transactionDate,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.transactionStatus,
    this.receiptNumber,
    this.customerInfo,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PosTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PosTransaction(
      transactionId: doc.id,
      storeId: data['store_id'] ?? '',
      customerId: data['customer_id'],
      cashierId: data['cashier_id'] ?? '',
      transactionDate: data['transaction_date'] ?? Timestamp.now(),
      items: data['items'] != null ? 
        List<Map<String, dynamic>>.from(data['items']) : [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      discountAmount: (data['discount_amount'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      paymentMethod: data['payment_method'] ?? 'cash',
      transactionStatus: data['transaction_status'] ?? 'completed',
      receiptNumber: data['receipt_number'],
      customerInfo: data['customer_info'],
      notes: data['notes'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_id': storeId,
      'customer_id': customerId,
      'cashier_id': cashierId,
      'transaction_date': transactionDate,
      'items': items,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'transaction_status': transactionStatus,
      'receipt_number': receiptNumber,
      'customer_info': customerInfo,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Inventory model (matches existing Firestore structure)
class InventoryItem {
  final String inventoryId;
  final String productId;
  final String storeId;
  final int currentStock;
  final int reservedStock;
  final int availableStock;
  final int minStockLevel;
  final int maxStockLevel;
  final String? location;
  final String? batchNumber;
  final DateTime? expiryDate;
  final double costPrice;
  final String status;
  final Timestamp lastUpdated;
  final String? lastUpdatedBy;

  InventoryItem({
    required this.inventoryId,
    required this.productId,
    required this.storeId,
    required this.currentStock,
    required this.reservedStock,
    required this.availableStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    this.location,
    this.batchNumber,
    this.expiryDate,
    required this.costPrice,
    required this.status,
    required this.lastUpdated,
    this.lastUpdatedBy,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InventoryItem(
      inventoryId: doc.id,
      productId: data['product_id'] ?? '',
      storeId: data['store_id'] ?? '',
      currentStock: data['current_stock'] ?? 0,
      reservedStock: data['reserved_stock'] ?? 0,
      availableStock: data['available_stock'] ?? 0,
      minStockLevel: data['min_stock_level'] ?? 0,
      maxStockLevel: data['max_stock_level'] ?? 0,
      location: data['location'],
      batchNumber: data['batch_number'],
      expiryDate: data['expiry_date'] != null ? 
        (data['expiry_date'] as Timestamp).toDate() : null,
      costPrice: (data['cost_price'] ?? 0).toDouble(),
      status: data['status'] ?? 'active',
      lastUpdated: data['last_updated'] ?? Timestamp.now(),
      lastUpdatedBy: data['last_updated_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'store_id': storeId,
      'current_stock': currentStock,
      'reserved_stock': reservedStock,
      'available_stock': availableStock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'location': location,
      'batch_number': batchNumber,
      'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'cost_price': costPrice,
      'status': status,
      'last_updated': lastUpdated,
      'last_updated_by': lastUpdatedBy,
    };
  }
}
