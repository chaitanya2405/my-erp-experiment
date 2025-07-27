import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class MockDataService {
  static Future<void> regenerateMockData() async {
    final firestore = FirebaseFirestore.instance;
    final uuid = Uuid();
    final random = Random();

    // --- Clear all mock data collections ---
    await _clearCollection('products');
    await _clearCollection('inventory');
    await _clearCollection('suppliers');
    await _clearCollection('purchase_orders');

    // --- Categories ---
    final categories = ['Dairy', 'Newspaper', 'Vegetables', 'Fruits'];

    // --- Suppliers ---
    final List<Map<String, dynamic>> suppliers = [];
    for (int i = 1; i <= 8; i++) {
      final cat = categories[(i - 1) % categories.length];
      final id = uuid.v4();
      suppliers.add({
        'supplier_id': id,
        'supplier_code': 'SUP${i.toString().padLeft(3, '0')}',
        'supplier_name': '$cat Supplier $i Pvt Ltd',
        'contact_person_name': 'Contact $i',
        'contact_person_mobile': '90000000${i.toString().padLeft(2, '0')}',
        'alternate_contact_number': '90000000${(i + 10).toString().padLeft(2, '0')}',
        'email': 'supplier$i@email.com',
        'address_line1': 'Address Line 1, $i',
        'address_line2': 'Address Line 2, $i',
        'city': 'City $i',
        'state': 'State $i',
        'postal_code': '5600${i}0',
        'country': 'India',
        'gstin': 'GSTIN${i.toString().padLeft(4, '0')}',
        'pan_number': 'PAN${i.toString().padLeft(4, '0')}',
        'supplier_type': cat,
        'business_registration_no': 'BRN${i.toString().padLeft(4, '0')}',
        'website': 'https://supplier$i.com',
        'bank_account_number': '1234567890$i',
        'bank_ifsc_code': 'IFSC000$i',
        'bank_name': 'Bank $i',
        'upi_id': 'supplier$i@upi',
        'payment_terms': 'Net 30',
        'preferred_payment_mode': 'Bank Transfer',
        'credit_limit': 100000 + i * 10000,
        'default_currency': 'INR',
        'products_supplied': <String>[],
        'contract_start_date': DateTime.now().subtract(Duration(days: 365)),
        'contract_end_date': DateTime.now().add(Duration(days: 365)),
        'rating': random.nextInt(5) + 1,
        'on_time_delivery_rate': 90 + random.nextInt(10),
        'average_lead_time_days': 2 + random.nextInt(5),
        'last_supplied_date': DateTime.now().subtract(Duration(days: random.nextInt(30))),
        'total_orders_supplied': 10 + random.nextInt(50),
        'total_order_value': 100000 + random.nextInt(500000),
        'compliance_documents': ['doc1.pdf', 'doc2.pdf'],
        'is_preferred_supplier': i % 2 == 0,
        'notes': 'Preferred for $cat',
        'status': 'Active',
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
      });
    }

    // --- Products ---
    final List<Map<String, dynamic>> products = [];
    int prodCount = 0;
    for (final cat in categories) {
      for (int i = 1; i <= 10; i++) {
        final sku = 'SKU-${cat.substring(0, 3).toUpperCase()}-$i';
        final prodId = 'PROD-${cat.substring(0, 3).toUpperCase()}-$i';
        final supplierIdx = prodCount % suppliers.length;
        products.add({
          'product_id': prodId,
          'product_name': '$cat Product $i',
          'product_slug': '$cat-product-$i'.toLowerCase().replaceAll(' ', '-'),
          'category': cat,
          'subcategory': null,
          'brand': 'Brand${i % 3 + 1}',
          'variant': null,
          'unit': cat == 'Dairy' ? '1L' : '1kg',
          'description': 'Description for $cat Product $i',
          'sku': sku,
          'barcode': 'BARCODE${i * 1000}',
          'hsn_code': 'HSN${i * 10}',
          'mrp': 20.0 + i,
          'cost_price': 15.0 + i,
          'selling_price': 18.0 + i,
          'margin_percent': 10 + i,
          'tax_percent': 5 + i,
          'tax_category': 'GST',
          'default_supplier_id': suppliers[supplierIdx]['supplier_id'],
          'min_stock_level': 5,
          'max_stock_level': 100,
          'lead_time_days': 2 + i % 5,
          'shelf_life_days': 30 + i % 10,
          'product_status': 'Active',
          'product_type': 'Standard',
          'product_image_urls': ['https://picsum.photos/seed/$prodId/200/200'],
          'tags': [cat, 'Tag${i % 3 + 1}'],
          'created_at': DateTime.now(),
          'updated_at': DateTime.now(),
          'deleted_at': null,
          'created_by': 'admin',
          'updated_by': 'admin',
        });
        suppliers[supplierIdx]['products_supplied'].add(sku);
        prodCount++;
      }
    }

    // --- Write suppliers ---
    final supplierCol = firestore.collection('suppliers');
    for (final s in suppliers) {
      await supplierCol.doc(s['supplier_id']).set(s);
    }

    // --- Write products ---
    final productCol = firestore.collection('products');
    for (final p in products) {
      await productCol.doc(p['product_id']).set(p);
    }

    // --- Inventory for each product at 3 locations ---
    final locations = ['Warehouse A', 'Warehouse B', 'Warehouse C'];
    final inventoryCol = firestore.collection('inventory');
    for (final p in products) {
      for (final location in locations) {
        await inventoryCol.add({
          'inventory_id': uuid.v4(),
          'product_id': p['product_id'],
          'store_location': location,
          'quantity_available': 20 + random.nextInt(30),
          'quantity_reserved': random.nextInt(10),
          'quantity_on_order': random.nextInt(5),
          'quantity_damaged': random.nextInt(3),
          'quantity_returned': random.nextInt(2),
          'reorder_point': 10,
          'batch_number': 'BATCH${random.nextInt(1000)}',
          'expiry_date': DateTime.now().add(Duration(days: 90 + random.nextInt(180))),
          'manufacture_date': DateTime.now().subtract(Duration(days: 30 + random.nextInt(60))),
          'storage_location': location,
          'entry_mode': 'Manual',
          'last_updated': DateTime.now(),
          'stock_status': 'In Stock',
          'added_by': 'admin',
          'remarks': 'Stock for $location',
          'fifo_lifo_flag': random.nextBool() ? 'FIFO' : 'LIFO',
          'audit_flag': random.nextBool(),
          'auto_restock_enabled': random.nextBool(),
          'last_sold_date': DateTime.now().subtract(Duration(days: random.nextInt(30))),
          'safety_stock_level': 5,
          'average_daily_usage': 2 + random.nextInt(5),
          'stock_turnover_ratio': 1.5 + random.nextDouble(),
        });
      }
    }

    // --- Purchase Orders (POs) ---
    final poCol = firestore.collection('purchase_orders');
    for (int i = 1; i <= 12; i++) {
      final supplier = suppliers[random.nextInt(suppliers.length)];
      final poId = uuid.v4();
      final poNumber = 'PO-${i.toString().padLeft(4, '0')}';
      final orderDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));
      final statusOptions = ['Pending', 'Approved', 'Rejected', 'Delivered'];
      final status = statusOptions[random.nextInt(statusOptions.length)];
      final lineItems = <Map<String, dynamic>>[];
      double totalValue = 0.0;
      // Each PO has 2-4 products
      for (int j = 0; j < 2 + random.nextInt(3); j++) {
        final prod = products[random.nextInt(products.length)];
        final qty = 1 + random.nextInt(10);
        final price = prod['selling_price'] ?? 10.0;
        final itemTotal = price * qty;
        totalValue += itemTotal;
        lineItems.add({
          'sku': prod['sku'],
          'quantity': qty,
          'price': price,
          'discount': 0.0,
          'tax': 18.0,
        });
      }
      // Approval history
      final approvalHistory = [
        {
          'status': 'Pending',
          'user': 'Manager',
          'comment': 'Auto-generated',
          'timestamp': orderDate.subtract(const Duration(hours: 2)),
        },
        if (status != 'Pending')
          {
            'status': status,
            'user': 'Admin',
            'comment': 'Auto-approved',
            'timestamp': orderDate.add(const Duration(hours: 2)),
          }
      ];
      await poCol.doc(poId).set({
        'poId': poId,
        'poNumber': poNumber,
        'supplierId': supplier['supplier_id'],
        'storeId': 'Store1',
        'orderDate': orderDate,
        'expectedDelivery': orderDate.add(const Duration(days: 7)),
        'status': status,
        'totalItems': lineItems.length,
        'totalValue': totalValue,
        'createdBy': 'admin',
        'approvedBy': status == 'Approved' ? 'admin' : null,
        'remarks': null,
        'lineItems': lineItems,
        'paymentTerms': 'Net 30',
        'deliveryTerms': 'Standard',
        'invoiceNumber': null,
        'receivedDate': null,
        'deliveryStatus': status == 'Delivered' ? 'Delivered' : 'Not Delivered',
        'documentsAttached': [],
        'approvalHistory': approvalHistory,
        'created_at': orderDate,
      });
    }
  }

  static Future<void> _clearCollection(String collection) async {
    final firestore = FirebaseFirestore.instance;
    final snapshots = await firestore.collection(collection).get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
