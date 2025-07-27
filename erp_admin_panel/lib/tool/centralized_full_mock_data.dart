import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final firestore = FirebaseFirestore.instance;
  final uuid = Uuid();
  final random = Random();

  // --- Clear old data ---
  for (final col in ['products', 'inventory', 'suppliers', 'purchase_orders', 'orders', 'customers']) {
    final snap = await firestore.collection(col).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // --- Categories ---
  final categories = ['Dairy', 'Newspaper', 'Vegetables', 'Fruits'];

  // --- Suppliers ---
  final List<Map<String, dynamic>> suppliers = [];
  for (int i = 1; i <= 50; i++) {
    final cat = categories[(i - 1) % categories.length];
    final id = uuid.v4();
    suppliers.add({
      'supplier_id': id,
      'supplier_code': 'SUP${i.toString().padLeft(3, '0')}',
      'supplier_name': '$cat Supplier $i Pvt Ltd',
      'contact_person_name': 'Contact $i',
      'contact_person_mobile': '90000000${i.toString().padLeft(2, '0')}',
      'alternate_contact_number': '90000000${(i+10).toString().padLeft(2, '0')}',
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
      'contract_start_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 365))),
      'contract_end_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 365))),
      'rating': random.nextInt(5) + 1,
      'on_time_delivery_rate': 90 + random.nextInt(10),
      'average_lead_time_days': 2 + random.nextInt(5),
      'last_supplied_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: random.nextInt(30)))),
      'total_orders_supplied': 10 + random.nextInt(50),
      'total_order_value': 100000 + random.nextInt(500000),
      'compliance_documents': ['doc1.pdf', 'doc2.pdf'],
      'is_preferred_supplier': i % 2 == 0,
      'notes': 'Preferred for $cat',
      'status': 'Active',
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
      // --- Advanced analytics fields ---
      'tags': [if (i % 2 == 0) 'Preferred', if (i % 3 == 0) 'Reliable', if (i % 4 == 0) 'High Spend'],
      'totalSpend': 100000 + random.nextInt(500000) + random.nextDouble(),
      'orderVolume': 10 + random.nextInt(100),
      'averageLeadTime': 2.0 + random.nextDouble() * 5,
    });
  }

  // --- Products ---
  final List<Map<String, dynamic>> products = [];
  int prodCount = 0;
  for (final cat in categories) {
    for (int i = 1; i <= 25; i++) {
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
        'default_supplier_ref': firestore.collection('suppliers').doc(suppliers[supplierIdx]['supplier_id']),
        'min_stock_level': 5,
        'max_stock_level': 100,
        'lead_time_days': 2 + i % 5,
        'shelf_life_days': 30 + i % 10,
        'product_status': 'Active',
        'product_type': 'Standard',
        'product_image_urls': ['https://picsum.photos/seed/$prodId/200/200'],
        'tags': [cat, 'Tag${i % 3 + 1}'],
        'created_at': Timestamp.now(),
        'updated_at': Timestamp.now(),
        'deleted_at': null,
        'created_by': 'admin',
        'updated_by': 'admin',
      });
      suppliers[supplierIdx]['products_supplied'].add(sku);
      prodCount++;
    }
  }

  // --- Write suppliers ---
  for (final s in suppliers) {
    await firestore.collection('suppliers').doc(s['supplier_id']).set(s);
  }

  // --- Write products ---
  for (final p in products) {
    await firestore.collection('products').doc(p['product_id']).set(p);
  }

  // --- Inventory for each product at 3-5 locations ---
  final locations = ['Warehouse A', 'Warehouse B', 'Warehouse C', 'Warehouse D', 'Warehouse E'];
  int inventoryCount = 0;
  for (final p in products) {
    for (final location in locations) {
      await firestore.collection('inventory').add({
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
        'expiry_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 90 + random.nextInt(180)))),
        'manufacture_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 30 + random.nextInt(60)))),
        'storage_location': location,
        'entry_mode': 'Manual',
        'last_updated': Timestamp.now(),
        'stock_status': 'In Stock',
        'added_by': 'admin',
        'remarks': 'Stock for $location',
        'fifo_lifo_flag': random.nextBool() ? 'FIFO' : 'LIFO',
        'audit_flag': random.nextBool(),
        'auto_restock_enabled': random.nextBool(),
        'last_sold_date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: random.nextInt(30)))),
        'safety_stock_level': 5,
        'average_daily_usage': 2 + random.nextInt(5),
        'stock_turnover_ratio': 1.5 + random.nextDouble(),
        'cost_price': p['cost_price'],
      });
      inventoryCount++;
    }
  }

  // --- Customer Profiles ---
  final List<Map<String, dynamic>> customerProfiles = [];
  final customerSegments = ['Platinum', 'Gold', 'Silver', 'New', 'Inactive'];
  final contactModes = ['SMS', 'Email', 'WhatsApp', 'App Push'];
  final genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final cities = ['Bangalore', 'Chennai', 'Hyderabad', 'Mumbai'];
  final states = ['Karnataka', 'Tamil Nadu', 'Telangana', 'Maharashtra'];
  final campaignList = ['Diwali2024', 'SummerSale', 'ReferralBonus', 'FestivePush', 'LoyaltyUpgrade'];
  final preferredChannels = ['App', 'Web', 'Offline'];

  for (int i = 1; i <= 1000; i++) {
    final segment = customerSegments[i % customerSegments.length];
    final now = DateTime.now();
    final firstOrder = now.subtract(Duration(days: 60 + random.nextInt(300)));
    final lastOrder = now.subtract(Duration(days: random.nextInt(60)));
    final totalOrders = 1 + random.nextInt(20);
    final avgOrderValue = 100 + random.nextInt(900) + random.nextDouble();
    final loyaltyPoints = random.nextInt(2000);
    final feedback = i % 3 == 0 ? 'Great service!' : '';
    final supportTickets = i % 4 == 0
        ? [
            {
              'ticket_id': 'TKT${i}A',
              'issue': 'Late delivery',
              'status': 'Resolved',
              'created_at': Timestamp.fromDate(now.subtract(Duration(days: 10))),
              'resolved_at': Timestamp.fromDate(now.subtract(Duration(days: 8))),
            }
          ]
        : [];
    final campaignResponses = campaignList.where((c) => random.nextBool()).toList();
    final gender = genders[i % genders.length];
    final city = cities[i % cities.length];
    final state = states[i % states.length];
    final preferredContact = contactModes[i % contactModes.length];
    final preferredChannel = preferredChannels[i % preferredChannels.length];

    customerProfiles.add({
      'customer_id': 'CUST${i.toString().padLeft(4, '0')}',
      'full_name': 'Customer $i',
      'mobile_number': '900000${i.toString().padLeft(4, '0')}',
      'email': 'customer$i@email.com',
      'gender': gender,
      'dob': Timestamp.fromDate(now.subtract(Duration(days: 7000 + i * 100))),
      'address_line1': 'Address Line 1, $i',
      'address_line2': 'Address Line 2, $i',
      'city': city,
      'state': state,
      'postal_code': '5600${i}0',
      'preferred_store_id': 'Store${(i % 5) + 1}',
      'loyalty_points': loyaltyPoints,
      'total_orders': totalOrders,
      'last_order_date': Timestamp.fromDate(lastOrder),
      'average_order_value': avgOrderValue,
      'customer_segment': segment,
      'preferred_contact_mode': preferredContact,
      'referral_code': 'REF${i * 100}',
      'referred_by': i % 5 == 0 ? 'REF${(i - 1) * 100}' : '',
      'support_tickets': supportTickets,
      'marketing_opt_in': i % 2 == 0,
      'feedback_notes': feedback,
      'created_at': Timestamp.fromDate(now.subtract(Duration(days: 365 + i * 10))),
      'updated_at': Timestamp.now(),
      // Advanced analytics fields
      'first_order_date': Timestamp.fromDate(firstOrder),
      'last_activity_date': Timestamp.fromDate(now.subtract(Duration(days: random.nextInt(30)))),
      'churn_risk_score': random.nextDouble(),
      'campaign_responses': campaignResponses,
      'feedback_sentiment': feedback.isNotEmpty ? 'positive' : null,
      'preferred_channel': preferredChannel,
    });
  }

  // --- Write customer profiles ---
  for (final c in customerProfiles) {
    await firestore.collection('customers').doc(c['customer_id']).set(c);
  }

  // --- Purchase Orders (POs) ---
  for (int i = 1; i <= 200; i++) {
    final supplier = suppliers[random.nextInt(suppliers.length)];
    final poId = uuid.v4();
    final poNumber = 'PO-${i.toString().padLeft(4, '0')}';
    final orderDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));
    final statusOptions = ['Pending', 'Approved', 'Rejected', 'Delivered'];
    final status = statusOptions[random.nextInt(statusOptions.length)];
    final lineItems = <Map<String, dynamic>>[];
    double totalValue = 0.0;
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
    await firestore.collection('purchase_orders').doc(poId).set({
      'poId': poId,
      'poNumber': poNumber,
      'supplierId': supplier['supplier_id'],
      'storeId': 'Store${(i % 5) + 1}',
      'orderDate': Timestamp.fromDate(orderDate),
      'expectedDelivery': Timestamp.fromDate(orderDate.add(const Duration(days: 7))),
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
      'billingAddress': supplier['address_line1'],
      'shippingAddress': supplier['address_line1'],
      'created_at': Timestamp.fromDate(orderDate),
    });
  }

  // --- Customer Orders ---
  for (int i = 1; i <= 500; i++) {
    final orderId = uuid.v4();
    final orderNumber = 'ORD-${i.toString().padLeft(5, '0')}';
    final customer = customerProfiles[random.nextInt(customerProfiles.length)];
    final customerId = customer['customer_id'];
    final storeId = customer['preferred_store_id'];
    final orderDate = Timestamp.fromDate(DateTime.now().subtract(Duration(days: random.nextInt(30))));
    final orderStatusOptions = ['New', 'Confirmed', 'Packed', 'Out for Delivery', 'Completed', 'Cancelled'];
    final orderStatus = orderStatusOptions[random.nextInt(orderStatusOptions.length)];
    final paymentStatusOptions = ['Paid', 'Unpaid', 'Refunded'];
    final paymentStatus = paymentStatusOptions[random.nextInt(paymentStatusOptions.length)];
    final paymentModeOptions = ['UPI', 'Card', 'COD', 'Wallet'];
    final paymentMode = paymentModeOptions[random.nextInt(paymentModeOptions.length)];
    final deliveryModeOptions = ['Home Delivery', 'Store Pickup'];
    final deliveryMode = deliveryModeOptions[random.nextInt(deliveryModeOptions.length)];
    final deliveryAddress = {
      'line1': customer['address_line1'],
      'line2': customer['address_line2'],
      'city': customer['city'],
      'state': customer['state'],
      'postal_code': customer['postal_code'],
      'country': 'India',
    };
    final productsOrdered = [
      for (int j = 0; j < 2 + random.nextInt(3); j++)
        () {
          final prod = products[random.nextInt(products.length)];
          return {
            'name': prod['product_name'],
            'sku': prod['sku'],
            'quantity': 1 + random.nextInt(3),
            'price': prod['selling_price'],
          };
        }()
    ];
    final totalAmount = productsOrdered.fold<double>(0, (sum, p) => sum + (p['price'] as double) * (p['quantity'] as int));
    final discount = random.nextInt(50).toDouble();
    final taxAmount = totalAmount * 0.05;
    final deliveryCharges = 20.0;
    final grandTotal = totalAmount - discount + taxAmount + deliveryCharges;
    final subscriptionFlag = i % 4 == 0;
    final subscriptionPlan = subscriptionFlag ? 'Monthly' : null;
    final walletUsed = subscriptionFlag ? 50.0 : 0.0;
    final deliverySlot = '9:00 AM - 11:00 AM';
    final deliveryPersonId = 'DEL${(i % 5) + 1}';
    final invoiceId = 'INV${i.toString().padLeft(4, '0')}';
    final remarks = i % 3 == 0 ? 'Leave at door' : null;
    final now = Timestamp.now();

    await firestore.collection('orders').doc(orderId).set({
      'order_number': orderNumber,
      'customer_id': customerId,
      'store_id': storeId,
      'order_date': orderDate,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'payment_mode': paymentMode,
      'delivery_mode': deliveryMode,
      'delivery_address': deliveryAddress,
      'products_ordered': productsOrdered,
      'total_amount': totalAmount,
      'discount': discount,
      'tax_amount': taxAmount,
      'delivery_charges': deliveryCharges,
      'grand_total': grandTotal,
      'subscription_flag': subscriptionFlag,
      'subscription_plan': subscriptionPlan,
      'wallet_used': walletUsed,
      'delivery_slot': deliverySlot,
      'delivery_person_id': deliveryPersonId,
      'invoice_id': invoiceId,
      'remarks': remarks,
      'created_at': now,
      'updated_at': now,
    });
  }

  print('Centralized full mock data created for products, inventory, suppliers, purchase orders, and customer orders!');
}