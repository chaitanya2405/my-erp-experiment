import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB9g3Ku_faWmuXKYVjI2S0qieXHf5OM2hQ',
      appId: '1:526643219487:web:6e3205e5f2102e6740192a',
      messagingSenderId: '526643219487',
      projectId: 'ravali-software',
      authDomain: 'ravali-software.firebaseapp.com',
      storageBucket: 'ravali-software.appspot.com',
      measurementId: 'G-76L52S3HV0',
    ),
  );

  final firestore = FirebaseFirestore.instance;
  final uuid = Uuid();

  // 1. Delete all existing products and inventory
  for (final col in ['products', 'inventory']) {
    final snap = await firestore.collection(col).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // 2. Create 100 products
  List<Map<String, dynamic>> products = List.generate(100, (i) => {
    'product_id': 'PROD-$i',
    'name': 'Product $i',
    'sku': 'SKU-$i',
    'category': i % 2 == 0 ? 'Dairy' : 'Bakery',
    'brand': i % 2 == 0 ? 'BrandA' : 'BrandB',
    'unit': '1kg',
    'created_at': DateTime.now(),
    'selling_price': 10.0 + i,
    'min_stock_level': 5,
    'max_stock_level': 100,
    'product_status': 'active',
  });

  // 3. Add products to Firestore
  for (final p in products) {
    await firestore.collection('products').doc(p['product_id']).set(p);
  }

  // 4. For each product, create 10 inventory records (10 locations)
  final locations = List.generate(10, (i) => 'Warehouse ${String.fromCharCode(65 + i)}');
  for (final p in products) {
    for (final location in locations) {
      await firestore.collection('inventory').add({
        'inventory_id': uuid.v4(),
        'product_id': p['product_id'],
        'store_location': location,
        'quantity_available': 20 + (p['product_id'].hashCode % 30),
        'expiry_date': DateTime.now().add(Duration(days: 90 + (p['product_id'].hashCode % 180))),
        'manufacture_date': DateTime.now().subtract(Duration(days: 30 + (p['product_id'].hashCode % 60))),
        'last_updated': DateTime.now(),
        'stock_status': 'In Stock',
      });
    }
  }

  print('Created 100 products and 1000 inventory records, all linked!');
}