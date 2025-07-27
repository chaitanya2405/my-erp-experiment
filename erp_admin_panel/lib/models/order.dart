import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CustomerOrder {
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String storeId;
  final Timestamp orderDate;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMode;
  final String deliveryMode;
  final Map<String, dynamic>? deliveryAddress;
  final List<Map<String, dynamic>> productsOrdered;
  final double totalAmount;
  final double discount;
  final double taxAmount;
  final double deliveryCharges;
  final double grandTotal;
  final bool subscriptionFlag;
  final String? subscriptionPlan;
  final double walletUsed;
  final String? deliverySlot;
  final String? deliveryPersonId;
  final String? invoiceId;
  final String? remarks;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  CustomerOrder({
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.storeId,
    required this.orderDate,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMode,
    required this.deliveryMode,
    this.deliveryAddress,
    required this.productsOrdered,
    required this.totalAmount,
    required this.discount,
    required this.taxAmount,
    required this.deliveryCharges,
    required this.grandTotal,
    required this.subscriptionFlag,
    this.subscriptionPlan,
    required this.walletUsed,
    this.deliverySlot,
    this.deliveryPersonId,
    this.invoiceId,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerOrder.fromFirestore(Map<String, dynamic> data, String id) {
    return CustomerOrder(
      orderId: id,
      orderNumber: data['order_number'] ?? '',
      customerId: data['customer_id'] ?? '',
      storeId: data['store_id'] ?? '',
      orderDate: data['order_date'] ?? Timestamp.now(),
      orderStatus: data['order_status'] ?? 'New',
      paymentStatus: data['payment_status'] ?? 'Unpaid',
      paymentMode: data['payment_mode'] ?? '',
      deliveryMode: data['delivery_mode'] ?? '',
      deliveryAddress: data['delivery_address'],
      productsOrdered: List<Map<String, dynamic>>.from(data['products_ordered'] ?? []),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      taxAmount: (data['tax_amount'] ?? 0).toDouble(),
      deliveryCharges: (data['delivery_charges'] ?? 0).toDouble(),
      grandTotal: (data['grand_total'] ?? 0).toDouble(),
      subscriptionFlag: data['subscription_flag'] ?? false,
      subscriptionPlan: data['subscription_plan'],
      walletUsed: (data['wallet_used'] ?? 0).toDouble(),
      deliverySlot: data['delivery_slot'],
      deliveryPersonId: data['delivery_person_id'],
      invoiceId: data['invoice_id'],
      remarks: data['remarks'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static String generateOrderId() => const Uuid().v4();
}
