import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_models.dart';

class InventoryService {
  final _inventoryRef = FirebaseFirestore.instance.collection('inventory');
  final _movementRef = FirebaseFirestore.instance.collection('inventory_movements');

  Stream<List<InventoryRecord>> getInventoryStream() {
    return _inventoryRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InventoryRecord.fromFirestore(doc)).toList());
  }

  Future<void> addInventory(InventoryRecord record) async {
    await _inventoryRef.doc(record.inventoryId).set(record.toFirestore());
  }

  Future<void> updateInventory(InventoryRecord record) async {
    await _inventoryRef.doc(record.inventoryId).update(record.toFirestore());
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
