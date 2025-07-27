import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  final snap = await firestore.collection('products').get();
  print('Found ${snap.docs.length} products');
}