import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/purchase_order.dart';

class PurchaseOrderService {
  final CollectionReference poCollection =
      FirebaseFirestore.instance.collection('purchase_orders');

  Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
    final snapshot = await poCollection.get();
    return snapshot.docs.map((doc) => PurchaseOrder.fromFirestore(doc)).toList();
  }

  Future<void> createPurchaseOrder(PurchaseOrder po) async {
    await poCollection.add(po.toMap());
  }

  Future<void> updatePurchaseOrder(String id, Map<String, dynamic> data) async {
    await poCollection.doc(id).update(data);
  }

  Future<void> deletePurchaseOrder(String id) async {
    await poCollection.doc(id).delete();
  }
}
