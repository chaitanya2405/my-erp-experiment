import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_models.dart';
import '../services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];
  List<InventoryRecord> _inventoryRecords = [];
  bool _isLoading = false;
  String? _error;

  List<InventoryItem> get items => _items;
  List<InventoryRecord> get inventoryRecords => _inventoryRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load inventory records from the service
      final stream = InventoryService.getInventoryStream();
      
      // Listen to the stream and convert to InventoryItem format
      stream.listen((records) {
        _inventoryRecords = records;
        _items = records.map((record) => _convertRecordToItem(record)).toList();
        _isLoading = false;
        notifyListeners();
      }).onError((error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Convert InventoryItem to InventoryRecord for storage
      final record = _convertItemToRecord(item);
      await InventoryService.addInventory(record);
      
      // The stream will automatically update the items list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Find the corresponding record to get the inventory ID
      final existingRecord = _inventoryRecords.firstWhere(
        (record) => record.productId == item.itemId,
        orElse: () => throw Exception('Item not found for update'),
      );

      // Convert InventoryItem to InventoryRecord for storage
      final record = _convertItemToRecord(item, existingRecord.inventoryId);
      await InventoryService.updateInventory(existingRecord.inventoryId, record);
      
      // The stream will automatically update the items list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Find the corresponding record to get the inventory ID
      final existingRecord = _inventoryRecords.firstWhere(
        (record) => record.productId == itemId,
        orElse: () => throw Exception('Item not found for deletion'),
      );

      await InventoryService.deleteInventory(existingRecord.inventoryId);
      
      // The stream will automatically update the items list
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Helper method to convert InventoryRecord to InventoryItem
  InventoryItem _convertRecordToItem(InventoryRecord record) {
    return InventoryItem(
      itemId: record.productId,
      itemName: 'Product ${record.productId}', // Default name since it's not in InventoryRecord
      sku: record.productId, // Use productId as SKU fallback
      category: 'General', // Default category
      currentStock: record.quantityAvailable.toInt(),
      minStockLevel: record.reorderPoint.toInt(),
      costPrice: 0.0, // Default cost price since not in InventoryRecord
      salePrice: 0.0, // Default sale price since not in InventoryRecord
      createdAt: record.lastUpdated.toDate(),
      updatedAt: record.lastUpdated.toDate(),
      productId: record.productId,
      storeId: record.storeLocation,
      availableStock: record.quantityAvailable.toInt(),
      maxStockLevel: (record.reorderPoint * 10).toInt(), // Default max as 10x reorder point
      reservedStock: record.quantityReserved.toInt(),
      status: record.stockStatus.isEmpty ? 'active' : record.stockStatus,
      lastUpdated: record.lastUpdated.toDate(),
    );
  }

  // Helper method to convert InventoryItem to InventoryRecord
  InventoryRecord _convertItemToRecord(InventoryItem item, [String? inventoryId]) {
    return InventoryRecord(
      inventoryId: inventoryId ?? 'inv_${DateTime.now().millisecondsSinceEpoch}',
      productId: item.productId,
      storeLocation: item.storeId,
      quantityAvailable: item.currentStock,
      quantityReserved: item.reservedStock,
      quantityOnOrder: 0, // Default value
      quantityDamaged: 0, // Default value
      quantityReturned: 0, // Default value
      reorderPoint: item.minStockLevel,
      batchNumber: '', // Default empty batch number
      expiryDate: null, // No expiry date
      manufactureDate: null, // No manufacture date
      storageLocation: item.storeId, // Use store as storage location
      entryMode: 'manual', // Default entry mode
      lastUpdated: item.lastUpdated != null ? Timestamp.fromDate(item.lastUpdated!) : Timestamp.now(),
      stockStatus: item.status,
      addedBy: 'system', // Default added by
      remarks: '', // Default empty remarks
      fifoLifoFlag: 'FIFO', // Default FIFO
      auditFlag: false, // Default no audit
      autoRestockEnabled: false, // Default no auto restock
      lastSoldDate: null, // No last sold date
      safetyStockLevel: item.minStockLevel, // Use min stock as safety stock
      averageDailyUsage: 0, // Default usage
      stockTurnoverRatio: 0, // Default turnover ratio
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
