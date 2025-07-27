import 'package:cloud_firestore/cloud_firestore.dart';

class PosTransaction {
  final String posTransactionId;
  final String storeId;
  final String terminalId;
  final String cashierId;
  final String? customerId;
  final DateTime transactionTime;
  final List<PosProductItem> productItems;
  final Map<String, dynamic> pricingEngineSnapshot;
  final double subTotal;
  final double discountApplied;
  final String? promoCode;
  final int loyaltyPointsUsed;
  final int loyaltyPointsEarned;
  final Map<String, dynamic> taxBreakup;
  final double totalAmount;
  final String paymentMode;
  final double changeReturned;
  final double walletUsed;
  final double roundOffAmount;
  final String invoiceNumber;
  final String? invoiceUrl;
  final String invoiceType;
  final String refundStatus;
  final String? remarks;
  final bool isOfflineMode;
  final bool syncedToServer;
  final bool syncedToFinance;
  final bool syncedToInventory;
  final String? auditLogId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional properties for compatibility
  String get transactionId => posTransactionId;
  String get customerName => customerId ?? 'Walk-in Customer';
  String get customerPhone => '';
  String get customerEmail => '';
  String get customerTier => 'Regular';
  double get finalAmount => totalAmount;
  double get subtotal => subTotal;
  double get totalDiscount => discountApplied;
  double get totalGst => taxBreakup['total_gst']?.toDouble() ?? 0.0;
  String get staffId => cashierId;
  String get status => refundStatus.isEmpty ? 'completed' : refundStatus;
  String get channel => isOfflineMode ? 'offline' : 'online';
  List<PosProductItem> get items => productItems;
  double get subtotalAmount => subTotal;
  double get taxAmount => totalGst;
  String get transactionStatus => status;
  String get notes => remarks ?? ''; // Use remarks field as notes
  double get discountAmount => discountApplied; // Use discountApplied as discountAmount

  const PosTransaction({
    required this.posTransactionId,
    required this.storeId,
    required this.terminalId,
    required this.cashierId,
    this.customerId,
    required this.transactionTime,
    required this.productItems,
    required this.pricingEngineSnapshot,
    required this.subTotal,
    required this.discountApplied,
    this.promoCode,
    required this.loyaltyPointsUsed,
    required this.loyaltyPointsEarned,
    required this.taxBreakup,
    required this.totalAmount,
    required this.paymentMode,
    required this.changeReturned,
    required this.walletUsed,
    required this.roundOffAmount,
    required this.invoiceNumber,
    this.invoiceUrl,
    required this.invoiceType,
    required this.refundStatus,
    this.remarks,
    required this.isOfflineMode,
    required this.syncedToServer,
    required this.syncedToFinance,
    required this.syncedToInventory,
    this.auditLogId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PosTransaction.fromFirestore(Map<String, dynamic> data, String id) {
    return PosTransaction(
      posTransactionId: id,
      storeId: data['store_id'] ?? '',
      terminalId: data['terminal_id'] ?? '',
      cashierId: data['cashier_id'] ?? '',
      customerId: data['customer_id'],
      transactionTime: (data['transaction_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productItems: (data['product_items'] as List<dynamic>?)
          ?.map((item) => PosProductItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      pricingEngineSnapshot: data['pricing_engine_snapshot'] ?? {},
      subTotal: (data['sub_total'] ?? 0).toDouble(),
      discountApplied: (data['discount_applied'] ?? 0).toDouble(),
      promoCode: data['promo_code'],
      loyaltyPointsUsed: data['loyalty_points_used'] ?? 0,
      loyaltyPointsEarned: data['loyalty_points_earned'] ?? 0,
      taxBreakup: data['tax_breakup'] ?? {},
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      paymentMode: data['payment_mode'] ?? 'Cash',
      changeReturned: (data['change_returned'] ?? 0).toDouble(),
      walletUsed: (data['wallet_used'] ?? 0).toDouble(),
      roundOffAmount: (data['round_off_amount'] ?? 0).toDouble(),
      invoiceNumber: data['invoice_number'] ?? '',
      invoiceUrl: data['invoice_url'],
      invoiceType: data['invoice_type'] ?? 'Tax Invoice',
      refundStatus: data['refund_status'] ?? 'Not Requested',
      remarks: data['remarks'],
      isOfflineMode: data['is_offline_mode'] ?? false,
      syncedToServer: data['synced_to_server'] ?? true,
      syncedToFinance: data['synced_to_finance'] ?? false,
      syncedToInventory: data['synced_to_inventory'] ?? false,
      auditLogId: data['audit_log_id'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'store_id': storeId,
      'terminal_id': terminalId,
      'cashier_id': cashierId,
      'customer_id': customerId,
      'transaction_time': Timestamp.fromDate(transactionTime),
      'product_items': productItems.map((item) => item.toMap()).toList(),
      'pricing_engine_snapshot': pricingEngineSnapshot,
      'sub_total': subTotal,
      'discount_applied': discountApplied,
      'promo_code': promoCode,
      'loyalty_points_used': loyaltyPointsUsed,
      'loyalty_points_earned': loyaltyPointsEarned,
      'tax_breakup': taxBreakup,
      'total_amount': totalAmount,
      'payment_mode': paymentMode,
      'change_returned': changeReturned,
      'wallet_used': walletUsed,
      'round_off_amount': roundOffAmount,
      'invoice_number': invoiceNumber,
      'invoice_url': invoiceUrl,
      'invoice_type': invoiceType,
      'refund_status': refundStatus,
      'remarks': remarks,
      'is_offline_mode': isOfflineMode,
      'synced_to_server': syncedToServer,
      'synced_to_finance': syncedToFinance,
      'synced_to_inventory': syncedToInventory,
      'audit_log_id': auditLogId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  PosTransaction copyWith({
    String? posTransactionId,
    String? storeId,
    String? terminalId,
    String? cashierId,
    String? customerId,
    DateTime? transactionTime,
    List<PosProductItem>? productItems,
    Map<String, dynamic>? pricingEngineSnapshot,
    double? subTotal,
    double? discountApplied,
    String? promoCode,
    int? loyaltyPointsUsed,
    int? loyaltyPointsEarned,
    Map<String, dynamic>? taxBreakup,
    double? totalAmount,
    String? paymentMode,
    double? changeReturned,
    double? walletUsed,
    double? roundOffAmount,
    String? invoiceNumber,
    String? invoiceUrl,
    String? invoiceType,
    String? refundStatus,
    String? remarks,
    bool? isOfflineMode,
    bool? syncedToServer,
    bool? syncedToFinance,
    bool? syncedToInventory,
    String? auditLogId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PosTransaction(
      posTransactionId: posTransactionId ?? this.posTransactionId,
      storeId: storeId ?? this.storeId,
      terminalId: terminalId ?? this.terminalId,
      cashierId: cashierId ?? this.cashierId,
      customerId: customerId ?? this.customerId,
      transactionTime: transactionTime ?? this.transactionTime,
      productItems: productItems ?? this.productItems,
      pricingEngineSnapshot: pricingEngineSnapshot ?? this.pricingEngineSnapshot,
      subTotal: subTotal ?? this.subTotal,
      discountApplied: discountApplied ?? this.discountApplied,
      promoCode: promoCode ?? this.promoCode,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      taxBreakup: taxBreakup ?? this.taxBreakup,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      changeReturned: changeReturned ?? this.changeReturned,
      walletUsed: walletUsed ?? this.walletUsed,
      roundOffAmount: roundOffAmount ?? this.roundOffAmount,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      invoiceType: invoiceType ?? this.invoiceType,
      refundStatus: refundStatus ?? this.refundStatus,
      remarks: remarks ?? this.remarks,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      syncedToServer: syncedToServer ?? this.syncedToServer,
      syncedToFinance: syncedToFinance ?? this.syncedToFinance,
      syncedToInventory: syncedToInventory ?? this.syncedToInventory,
      auditLogId: auditLogId ?? this.auditLogId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PosProductItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double mrp;
  final double sellingPrice;
  final double finalPrice;
  final String? batchNumber;
  final double discountAmount;
  final double taxAmount;
  final String taxSlab;

  const PosProductItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.mrp,
    required this.sellingPrice,
    required this.finalPrice,
    this.batchNumber,
    required this.discountAmount,
    required this.taxAmount,
    required this.taxSlab,
  });

  factory PosProductItem.fromMap(Map<String, dynamic> data) {
    return PosProductItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      sku: data['sku'] ?? '',
      quantity: data['quantity'] ?? 1,
      mrp: (data['mrp'] ?? 0).toDouble(),
      sellingPrice: (data['selling_price'] ?? 0).toDouble(),
      finalPrice: (data['final_price'] ?? 0).toDouble(),
      batchNumber: data['batch_number'],
      discountAmount: (data['discount_amount'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      taxSlab: data['tax_slab'] ?? '18%',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'quantity': quantity,
      'mrp': mrp,
      'selling_price': sellingPrice,
      'final_price': finalPrice,
      'batch_number': batchNumber,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'tax_slab': taxSlab,
    };
  }

  double get totalAmount => finalPrice * quantity;

  // Compatibility getters for integration services
  double get unitPrice => sellingPrice;
  double get totalPrice => finalPrice * quantity;
  double get discount => discountAmount;
  String get category => 'General'; // Default category, can be enhanced later

  // Support for bracket operator to access properties like a Map
  dynamic operator [](String key) {
    switch (key) {
      case 'product_id':
      case 'productId':
        return productId;
      case 'product_name':
      case 'productName':
        return productName;
      case 'sku':
        return sku;
      case 'quantity':
        return quantity;
      case 'mrp':
        return mrp;
      case 'selling_price':
      case 'sellingPrice':
        return sellingPrice;
      case 'final_price':
      case 'finalPrice':
        return finalPrice;
      case 'batch_number':
      case 'batchNumber':
        return batchNumber;
      case 'discount_amount':
      case 'discountAmount':
        return discountAmount;
      case 'tax_amount':
      case 'taxAmount':
        return taxAmount;
      case 'tax_slab':
      case 'taxSlab':
        return taxSlab;
      case 'total_amount':
      case 'totalAmount':
        return totalAmount;
      default:
        return null;
    }
  }
}
