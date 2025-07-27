// 🎯 WEB MODELS (REAL DATA VERSION)
// Extended models for real Firestore data compatibility

import '../models/web_models.dart';

// Updated WebOrderItem for real data compatibility
class WebOrderItemReal {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  WebOrderItemReal({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  // Convert to original WebOrderItem for UI compatibility
  WebOrderItem toWebOrderItem() {
    return WebOrderItem(
      id: productId,
      productId: productId,
      productName: productName,
      productImage: imageUrl,
      price: price,
      quantity: quantity,
      totalPrice: price * quantity,
    );
  }
}

// Updated WebOrder for real data compatibility
class WebOrderReal {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final List<WebOrderItemReal> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String status;
  final DateTime orderDate;
  final WebAddress? deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final String? notes;

  WebOrderReal({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.orderDate,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    this.trackingNumber,
    this.estimatedDelivery,
    this.notes,
  });

  // Convert to original WebOrder for UI compatibility
  WebOrder toWebOrder() {
    return WebOrder(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: '', // Not used in real data
      items: items.map((item) => item.toWebOrderItem()).toList(),
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      totalAmount: total,
      status: status,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      orderDate: orderDate,
      expectedDeliveryDate: estimatedDelivery,
      deliveryDate: status == 'delivered' ? DateTime.now() : null,
      shippingAddress: deliveryAddress?.toString(),
      notes: notes,
    );
  }

  WebOrderReal copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    List<WebOrderItemReal>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? total,
    String? status,
    DateTime? orderDate,
    WebAddress? deliveryAddress,
    String? paymentMethod,
    String? paymentStatus,
    String? trackingNumber,
    DateTime? estimatedDelivery,
    String? notes,
  }) {
    return WebOrderReal(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      notes: notes ?? this.notes,
    );
  }
}

// WebAddress for delivery addresses
class WebAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  WebAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'India',
  });

  @override
  String toString() {
    return '$street, $city, $state $zipCode, $country';
  }
}
