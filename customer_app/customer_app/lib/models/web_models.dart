// 🌐 WEB-ONLY MODELS
// Simplified models for web builds without Firebase Auth dependencies

class WebProduct {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String categoryId;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final bool isFeatured;
  final bool isNew;
  final bool isOnSale;
  final int stockQuantity;
  final double? rating;
  final int? reviewCount;
  final DateTime? createdAt;

  WebProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.isNew = false,
    this.isOnSale = false,
    this.stockQuantity = 0,
    this.rating,
    this.reviewCount,
    this.createdAt,
  });

  WebProduct copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    String? categoryId,
    String? description,
    String? imageUrl,
    bool? isActive,
    bool? isFeatured,
    bool? isNew,
    bool? isOnSale,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return WebProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isOnSale: isOnSale ?? this.isOnSale,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WebCategory {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  WebCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });
}

class WebCartItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final Map<String, dynamic> selectedVariants;
  final DateTime addedAt;

  WebCartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.selectedVariants = const {},
    required this.addedAt,
  });

  double get totalPrice => price * quantity;

  WebCartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    Map<String, dynamic>? selectedVariants,
    DateTime? addedAt,
  }) {
    return WebCartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class WebOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double totalPrice;
  final Map<String, dynamic> selectedVariants;

  WebOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    this.selectedVariants = const {},
  });
}

class WebOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<WebOrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? deliveryDate;
  final String? shippingAddress;
  final String? notes;

  WebOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    required this.paymentMethod,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.deliveryDate,
    this.shippingAddress,
    this.notes,
  });

  WebOrder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<WebOrderItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? totalAmount,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    DateTime? deliveryDate,
    String? shippingAddress,
    String? notes,
  }) {
    return WebOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
    );
  }
}

class WebCustomer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? profileImageUrl;
  final bool isActive;
  final String membershipTier;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final DateTime createdAt;

  WebCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.profileImageUrl,
    this.isActive = true,
    this.membershipTier = 'Silver',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.lastOrderDate,
    required this.createdAt,
  });

  WebCustomer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
    bool? isActive,
    String? membershipTier,
    int? totalOrders,
    double? totalSpent,
    DateTime? lastOrderDate,
    DateTime? createdAt,
  }) {
    return WebCustomer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      membershipTier: membershipTier ?? this.membershipTier,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
