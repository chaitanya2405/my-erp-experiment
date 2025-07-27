import 'package:cloud_firestore/cloud_firestore.dart';
import 'supplier.dart';

class SupplierService {
  final _collection = FirebaseFirestore.instance.collection('suppliers');

  Stream<List<Supplier>> streamSuppliers() {
    return _collection.snapshots().map((snap) => snap.docs
        .map((doc) => Supplier.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Future<List<Supplier>> getSuppliers() async {
    final snap = await _collection.get();
    return snap.docs.map((doc) => Supplier.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<Supplier?> getSupplierById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Supplier.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _collection.doc(supplier.supplierId).set(supplier.toFirestore());
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _collection.doc(supplier.supplierId).update(supplier.toFirestore());
  }

  Future<void> deleteSupplier(String id) async {
    await _collection.doc(id).delete();
  }
}
