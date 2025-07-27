import 'package:cloud_firestore/cloud_firestore.dart';

// InventoryItem class for backward compatibility
class InventoryItem {
  final String itemId;
  final String itemName;
  final String? sku;
  final String? category;
  final int currentStock;
  final int minStockLevel;
  final double costPrice;
  final double salePrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productId;
  final String storeId;
  final int availableStock;
  final int maxStockLevel;
  final int reservedStock;
  final String status;
  final DateTime? lastUpdated;

  InventoryItem({
    required this.itemId,
    required this.itemName,
    this.sku,
    this.category,
    required this.currentStock,
    required this.minStockLevel,
    required this.costPrice,
    required this.salePrice,
    required this.createdAt,
    required this.updatedAt,
    required this.productId,
    required this.storeId,
    required this.availableStock,
    required this.maxStockLevel,
    required this.reservedStock,
    required this.status,
    this.lastUpdated,
  });

  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      itemId: doc.id,
      itemName: data['item_name'] ?? '',
      sku: data['sku'],
      category: data['category'],
      currentStock: data['current_stock'] ?? 0,
      minStockLevel: data['min_stock_level'] ?? 0,
      costPrice: (data['cost_price'] ?? 0).toDouble(),
      salePrice: (data['sale_price'] ?? 0).toDouble(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productId: data['product_id'] ?? '',
      storeId: data['store_id'] ?? '',
      availableStock: data['available_stock'] ?? 0,
      maxStockLevel: data['max_stock_level'] ?? 100,
      reservedStock: data['reserved_stock'] ?? 0,
      status: data['status'] ?? 'active',
      lastUpdated: (data['last_updated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_name': itemName,
      'sku': sku,
      'category': category,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'product_id': productId,
      'store_id': storeId,
      'available_stock': availableStock,
      'max_stock_level': maxStockLevel,
      'reserved_stock': reservedStock,
      'status': status,
      'last_updated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }
}

// Enum for inventory movement types
enum MovementType {
  inbound,
  outbound,
  transfer,
  adjustment,
  damaged,
  returned
}

class InventoryRecord {
  final String inventoryId;
  final String productId;
  final String storeLocation;
  final String? supplierId;
  final String? purchaseOrderId;
  final num quantityAvailable;
  final num quantityReserved;
  final num quantityOnOrder;
  final num quantityDamaged;
  final num quantityReturned;
  final num reorderPoint;
  final String batchNumber;
  final DateTime? expiryDate;
  final DateTime? manufactureDate;
  final String storageLocation;
  final String entryMode;
  final Timestamp lastUpdated;
  final String stockStatus;
  final String addedBy;
  final String remarks;
  final String fifoLifoFlag;
  final bool auditFlag;
  final bool autoRestockEnabled;
  final DateTime? lastSoldDate;
  final num safetyStockLevel;
  final num averageDailyUsage;
  final num stockTurnoverRatio;
  
  // Enhanced product details
  final String? productName;
  final String? sku;
  final String? category;
  final num? unitCost;
  final String? supplierName;

  InventoryRecord({
    required this.inventoryId,
    required this.productId,
    required this.storeLocation,
    this.supplierId,
    this.purchaseOrderId,
    required this.quantityAvailable,
    required this.quantityReserved,
    required this.quantityOnOrder,
    required this.quantityDamaged,
    required this.quantityReturned,
    required this.reorderPoint,
    required this.batchNumber,
    this.expiryDate,
    this.manufactureDate,
    required this.storageLocation,
    required this.entryMode,
    required this.lastUpdated,
    required this.stockStatus,
    required this.addedBy,
    required this.remarks,
    required this.fifoLifoFlag,
    required this.auditFlag,
    required this.autoRestockEnabled,
    this.lastSoldDate,
    required this.safetyStockLevel,
    required this.averageDailyUsage,
    required this.stockTurnoverRatio,
    // Enhanced product details
    this.productName,
    this.sku,
    this.category,
    this.unitCost,
    this.supplierName,
  });

  factory InventoryRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryRecord(
      inventoryId: doc.id,
      productId: data['product_id'] ?? '',
      storeLocation: data['store_location'] ?? '',
      supplierId: data['supplier_id'],
      purchaseOrderId: data['purchase_order_id'],
      quantityAvailable: data['quantity_available'] ?? 0,
      quantityReserved: data['quantity_reserved'] ?? 0,
      quantityOnOrder: data['quantity_on_order'] ?? 0,
      quantityDamaged: data['quantity_damaged'] ?? 0,
      quantityReturned: data['quantity_returned'] ?? 0,
      reorderPoint: data['reorder_point'] ?? 0,
      batchNumber: data['batch_number'] ?? '',
      expiryDate: (data['expiry_date'] as Timestamp?)?.toDate(),
      manufactureDate: (data['manufacture_date'] as Timestamp?)?.toDate(),
      storageLocation: data['storage_location'] ?? '',
      entryMode: data['entry_mode'] ?? '',
      lastUpdated: data['last_updated'] ?? Timestamp.now(),
      stockStatus: data['stock_status'] ?? '',
      addedBy: data['added_by'] ?? '',
      remarks: data['remarks'] ?? '',
      fifoLifoFlag: data['fifo_lifo_flag'] ?? '',
      auditFlag: data['audit_flag'] ?? false,
      autoRestockEnabled: data['auto_restock_enabled'] ?? false,
      lastSoldDate: (data['last_sold_date'] as Timestamp?)?.toDate(),
      safetyStockLevel: data['safety_stock_level'] ?? 0,
      averageDailyUsage: data['average_daily_usage'] ?? 0,
      stockTurnoverRatio: data['stock_turnover_ratio'] ?? 0,
      // Enhanced product details
      productName: data['product_name'],
      sku: data['sku'],
      category: data['category'],
      unitCost: data['unit_cost'],
      supplierName: data['supplier_name'],
    );
  }

  factory InventoryRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return InventoryRecord(
      inventoryId: id ?? map['inventory_id'] ?? '',
      productId: map['product_id'] ?? '',
      storeLocation: map['store_location'] ?? '',
      quantityAvailable: map['quantity_available'] ?? 0,
      quantityReserved: map['quantity_reserved'] ?? 0,
      quantityOnOrder: map['quantity_on_order'] ?? 0,
      quantityDamaged: map['quantity_damaged'] ?? 0,
      quantityReturned: map['quantity_returned'] ?? 0,
      reorderPoint: map['reorder_point'] ?? 0,
      batchNumber: map['batch_number'] ?? '',
      expiryDate: (map['expiry_date'] as Timestamp?)?.toDate(),
      manufactureDate: (map['manufacture_date'] as Timestamp?)?.toDate(),
      storageLocation: map['storage_location'] ?? '',
      entryMode: map['entry_mode'] ?? '',
      lastUpdated: map['last_updated'] ?? Timestamp.now(),
      stockStatus: map['stock_status'] ?? '',
      addedBy: map['added_by'] ?? '',
      remarks: map['remarks'] ?? '',
      fifoLifoFlag: map['fifo_lifo_flag'] ?? '',
      auditFlag: map['audit_flag'] ?? false,
      autoRestockEnabled: map['auto_restock_enabled'] ?? false,
      lastSoldDate: (map['last_sold_date'] as Timestamp?)?.toDate(),
      safetyStockLevel: map['safety_stock_level'] ?? 0,
      averageDailyUsage: map['average_daily_usage'] ?? 0,
      stockTurnoverRatio: map['stock_turnover_ratio'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'product_id': productId,
        'store_location': storeLocation,
        'quantity_available': quantityAvailable,
        'quantity_reserved': quantityReserved,
        'quantity_on_order': quantityOnOrder,
        'quantity_damaged': quantityDamaged,
        'quantity_returned': quantityReturned,
        'reorder_point': reorderPoint,
        'batch_number': batchNumber,
        'expiry_date': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        'manufacture_date': manufactureDate != null ? Timestamp.fromDate(manufactureDate!) : null,
        'storage_location': storageLocation,
        'entry_mode': entryMode,
        'last_updated': lastUpdated,
        'stock_status': stockStatus,
        'added_by': addedBy,
        'remarks': remarks,
        'fifo_lifo_flag': fifoLifoFlag,
        'audit_flag': auditFlag,
        'auto_restock_enabled': autoRestockEnabled,
        'last_sold_date': lastSoldDate != null ? Timestamp.fromDate(lastSoldDate!) : null,
        'safety_stock_level': safetyStockLevel,
        'average_daily_usage': averageDailyUsage,
        'stock_turnover_ratio': stockTurnoverRatio,
        // Enhanced product details
        'supplier_id': supplierId,
        'purchase_order_id': purchaseOrderId,
        'product_name': productName,
        'sku': sku,
        'category': category,
        'unit_cost': unitCost,
        'supplier_name': supplierName,
      };

  // Enhanced getters for POS integration compatibility
  num get currentQuantity => quantityAvailable;
  num get minimumQuantity => reorderPoint;
  num get actualUnitCost => unitCost ?? 0; // Use actual unit cost if available
  String get actualProductName => productName ?? productId; // Use actual product name if available

  // CopyWith method for updating inventory
  InventoryRecord copyWith({
    String? inventoryId,
    String? productId,
    String? storeLocation,
    String? supplierId,
    String? purchaseOrderId,
    num? quantityAvailable,
    num? quantityReserved,
    num? quantityOnOrder,
    num? quantityDamaged,
    num? quantityReturned,
    num? reorderPoint,
    String? batchNumber,
    DateTime? expiryDate,
    DateTime? manufactureDate,
    String? storageLocation,
    String? entryMode,
    Timestamp? lastUpdated,
    String? stockStatus,
    String? addedBy,
    String? remarks,
    String? fifoLifoFlag,
    bool? auditFlag,
    bool? autoRestockEnabled,
    DateTime? lastSoldDate,
    num? safetyStockLevel,
    num? averageDailyUsage,
    num? stockTurnoverRatio,
    // Enhanced product details
    String? productName,
    String? sku,
    String? category,
    num? unitCost,
    String? supplierName,
  }) {
    return InventoryRecord(
      inventoryId: inventoryId ?? this.inventoryId,
      productId: productId ?? this.productId,
      storeLocation: storeLocation ?? this.storeLocation,
      supplierId: supplierId ?? this.supplierId,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityReserved: quantityReserved ?? this.quantityReserved,
      quantityOnOrder: quantityOnOrder ?? this.quantityOnOrder,
      quantityDamaged: quantityDamaged ?? this.quantityDamaged,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      storageLocation: storageLocation ?? this.storageLocation,
      entryMode: entryMode ?? this.entryMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      stockStatus: stockStatus ?? this.stockStatus,
      addedBy: addedBy ?? this.addedBy,
      remarks: remarks ?? this.remarks,
      fifoLifoFlag: fifoLifoFlag ?? this.fifoLifoFlag,
      auditFlag: auditFlag ?? this.auditFlag,
      autoRestockEnabled: autoRestockEnabled ?? this.autoRestockEnabled,
      lastSoldDate: lastSoldDate ?? this.lastSoldDate,
      safetyStockLevel: safetyStockLevel ?? this.safetyStockLevel,
      averageDailyUsage: averageDailyUsage ?? this.averageDailyUsage,
      stockTurnoverRatio: stockTurnoverRatio ?? this.stockTurnoverRatio,
      // Enhanced product details
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      unitCost: unitCost ?? this.unitCost,
      supplierName: supplierName ?? this.supplierName,
    );
  }
}

class InventoryMovementLog {
  final String movementId;
  final String productId;
  final String fromLocation;
  final String toLocation;
  final num quantity;
  final String movementType;
  final String initiatedBy;
  final String? verifiedBy;
  final Timestamp timestamp;

  InventoryMovementLog({
    required this.movementId,
    required this.productId,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.movementType,
    required this.initiatedBy,
    this.verifiedBy,
    required this.timestamp,
  });

  factory InventoryMovementLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryMovementLog(
      movementId: doc.id,
      productId: data['product_id'] ?? '',
      fromLocation: data['from_location'] ?? '',
      toLocation: data['to_location'] ?? '',
      quantity: data['quantity'] ?? 0,
      movementType: data['movement_type'] ?? '',
      initiatedBy: data['initiated_by'] ?? '',
      verifiedBy: data['verified_by'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'product_id': productId,
        'from_location': fromLocation,
        'to_location': toLocation,
        'quantity': quantity,
        'movement_type': movementType,
        'initiated_by': initiatedBy,
        'verified_by': verifiedBy,
        'timestamp': timestamp,
      };
}
