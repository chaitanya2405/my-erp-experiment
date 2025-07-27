// Enhanced Unified Data Models for Ravali Software ERP
// This file contains the unified, consolidated data models that replace
// the fragmented models throughout the original codebase.

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// UNIFIED POS TRANSACTION ITEM MODEL (Base item class)
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
}

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
  });

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
    );
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
    };
  }
}

// Type aliases for backward compatibility
typedef Product = UnifiedProduct;
typedef CustomerProfile = UnifiedCustomerProfile;
typedef PosTransaction = UnifiedPOSTransaction;
typedef CustomerOrder = UnifiedCustomerOrder;
