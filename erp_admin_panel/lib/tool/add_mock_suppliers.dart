import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/supplier.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  final uuid = Uuid();

  // Fetch all product IDs from Firestore
  final productSnap = await firestore.collection('products').get();
  final productIds = productSnap.docs.map((d) => d.id).toList();
  if (productIds.isEmpty) {
    print('No products found. Please add products first.');
    return;
  }

  final supplierTypes = ['Manufacturer', 'Wholesaler', 'Distributor', 'Local Vendor'];
  final paymentModes = ['UPI', 'Bank Transfer', 'Cheque', 'Cash'];
  final currencies = ['INR', 'USD', 'EUR'];
  final random = Random();

  for (int i = 1; i <= 20; i++) {
    final id = uuid.v4();
    final code = 'SUP${i.toString().padLeft(3, '0')}';
    final type = supplierTypes[random.nextInt(supplierTypes.length)];
    final productsSupplied = List<String>.from(productIds..shuffle()).take(random.nextInt(5) + 1).toList();
    final now = DateTime.now();
    final contractStart = now.subtract(Duration(days: random.nextInt(365)));
    final contractEnd = contractStart.add(Duration(days: 365 + random.nextInt(365)));
    final rating = (random.nextDouble() * 4 + 1).toStringAsFixed(1);
    final onTime = (random.nextDouble() * 100).toStringAsFixed(1);
    final leadTime = random.nextInt(15) + 1;
    final totalOrders = random.nextInt(100) + 1;
    final totalValue = (random.nextDouble() * 100000).toStringAsFixed(2);
    final isPreferred = random.nextBool();
    final status = ['Active', 'Inactive', 'Blacklisted'][random.nextInt(3)];
    final complianceDocs = [
      'https://example.com/gstin_${code}.pdf',
      'https://example.com/fssai_${code}.pdf',
    ];
    final supplier = Supplier(
      supplierId: id,
      supplierCode: code,
      supplierName: 'Supplier $i Pvt Ltd',
      contactPersonName: 'Contact $i',
      contactPersonMobile: '90000000${i.toString().padLeft(2, '0')}',
      alternateContactNumber: '80000000${i.toString().padLeft(2, '0')}',
      email: 'supplier$i@email.com',
      addressLine1: 'Address Line 1, $i',
      addressLine2: 'Address Line 2, $i',
      city: 'City $i',
      state: 'State $i',
      postalCode: '5000${i.toString().padLeft(2, '0')}',
      country: 'India',
      gstin: 'GSTIN${i.toString().padLeft(4, '0')}',
      panNumber: 'PAN${i.toString().padLeft(4, '0')}',
      supplierType: type,
      businessRegistrationNo: 'BRN${i.toString().padLeft(4, '0')}',
      website: 'https://supplier$i.com',
      bankAccountNumber: '1234567890${i.toString().padLeft(2, '0')}',
      bankIfscCode: 'IFSC000${i.toString().padLeft(3, '0')}',
      bankName: 'Bank $i',
      upiId: 'supplier$i@upi',
      paymentTerms: 'Net ${[15, 30, 45][random.nextInt(3)]}',
      preferredPaymentMode: paymentModes[random.nextInt(paymentModes.length)],
      creditLimit: random.nextInt(100000) + 10000,
      defaultCurrency: currencies[random.nextInt(currencies.length)],
      productsSupplied: productsSupplied,
      contractStartDate: contractStart,
      contractEndDate: contractEnd,
      rating: double.parse(rating),
      onTimeDeliveryRate: double.parse(onTime),
      averageLeadTimeDays: leadTime,
      lastSuppliedDate: now.subtract(Duration(days: random.nextInt(60))),
      totalOrdersSupplied: totalOrders,
      totalOrderValue: double.parse(totalValue),
      complianceDocuments: complianceDocs,
      isPreferredSupplier: isPreferred,
      notes: 'Notes for supplier $i',
      status: status,
      createdAt: Timestamp.fromDate(now.subtract(Duration(days: random.nextInt(365)))),
      updatedAt: Timestamp.fromDate(now),
    );
    await firestore.collection('suppliers').doc(id).set(supplier.toFirestore());
    print('Added supplier $code');
  }
  print('Mock suppliers added!');
}
