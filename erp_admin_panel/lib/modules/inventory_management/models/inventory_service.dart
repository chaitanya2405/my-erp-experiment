import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/inventory_models.dart';

class InventoryService {
  final _inventoryRef = FirebaseFirestore.instance.collection('inventory');
  final _movementRef = FirebaseFirestore.instance.collection('inventory_movements');
  final _productsRef = FirebaseFirestore.instance.collection('products');

  Stream<List<InventoryRecord>> getInventoryStream() {
    return _inventoryRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InventoryRecord.fromFirestore(doc)).toList());
  }

  Future<void> addInventory(InventoryRecord record) async {
    // Get product details to include with inventory record
    final productDetails = await _getProductDetails(record.productId);
    
    final inventoryData = record.toFirestore();
    // Add product information for easy display
    inventoryData.addAll({
      'product_name': productDetails['product_name'] ?? productDetails['name'],
      'product_sku': productDetails['sku'],
      'product_category': productDetails['category'],
      'product_brand': productDetails['brand'],
    });
    
    await _inventoryRef.doc(record.inventoryId).set(inventoryData);
  }

  Future<void> updateInventory(InventoryRecord record) async {
    // Get product details to include with inventory record
    final productDetails = await _getProductDetails(record.productId);
    
    final inventoryData = record.toFirestore();
    // Add product information for easy display
    inventoryData.addAll({
      'product_name': productDetails['product_name'] ?? productDetails['name'],
      'product_sku': productDetails['sku'],
      'product_category': productDetails['category'],
      'product_brand': productDetails['brand'],
    });
    
    await _inventoryRef.doc(record.inventoryId).update(inventoryData);
  }

  Future<Map<String, dynamic>> _getProductDetails(String productId) async {
    try {
      final productDoc = await _productsRef.doc(productId).get();
      if (productDoc.exists) {
        return productDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
    return {};
  }

  Future<void> deleteInventory(String inventoryId) async {
    await _inventoryRef.doc(inventoryId).delete();
  }

  Future<void> logMovement(InventoryMovementLog log) async {
    await _movementRef.doc(log.movementId).set(log.toFirestore());
  }

  Stream<List<InventoryMovementLog>> getMovementsForProduct(String productId) {
    return _movementRef.where('product_id', isEqualTo: productId).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => InventoryMovementLog.fromFirestore(doc)).toList());
  }
}
