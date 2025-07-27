import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productId;
  final String productName;
  final String productSlug;
  final String category;
  final String? subcategory;
  final String? brand;
  final String? variant;
  final String unit;
  final String? description;
  final String sku;
  final String? barcode;
  final String? hsnCode;
  final double mrp;
  final double costPrice;
  final double sellingPrice;
  final double marginPercent;
  final double taxPercent;
  final String taxCategory;
  final DocumentReference? defaultSupplierRef;
  final int minStockLevel;
  final int maxStockLevel;
  final int? leadTimeDays;
  final int? shelfLifeDays;
  final String productStatus;
  final String productType;
  final List<String>? productImageUrls;
  final List<String>? tags;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? deletedAt;
  final String? createdBy;
  final String? updatedBy;

  Product({
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.category,
    this.subcategory,
    this.brand,
    this.variant,
    required this.unit,
    this.description,
    required this.sku,
    this.barcode,
    this.hsnCode,
    required this.mrp,
    required this.costPrice,
    required this.sellingPrice,
    required this.marginPercent,
    required this.taxPercent,
    required this.taxCategory,
    this.defaultSupplierRef,
    required this.minStockLevel,
    required this.maxStockLevel,
    this.leadTimeDays,
    this.shelfLifeDays,
    required this.productStatus,
    required this.productType,
    this.productImageUrls,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      productSlug: data['product_slug'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      brand: data['brand'],
      variant: data['variant'],
      unit: data['unit'] ?? '',
      description: data['description'],
      sku: data['sku'] ?? '',
      barcode: data['barcode'],
      hsnCode: data['hsn_code'],
      mrp: (data['mrp'] ?? 0).toDouble(),
      costPrice: (data['cost_price'] ?? 0).toDouble(),
      sellingPrice: (data['selling_price'] ?? 0).toDouble(),
      marginPercent: (data['margin_percent'] ?? 0).toDouble(),
      taxPercent: (data['tax_percent'] ?? 0).toDouble(),
      taxCategory: data['tax_category'] ?? '',
      defaultSupplierRef: data['default_supplier_ref'],
      minStockLevel: data['min_stock_level'] ?? 0,
      maxStockLevel: data['max_stock_level'] ?? 0,
      leadTimeDays: data['lead_time_days'],
      shelfLifeDays: data['shelf_life_days'],
      productStatus: data['product_status'] ?? '',
      productType: data['product_type'] ?? '',
      productImageUrls: data['product_image_urls'] == null ? null : List<String>.from(data['product_image_urls']),
      tags: data['tags'] == null ? null : List<String>.from(data['tags']),
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_slug': productSlug,
      'category': category,
      'subcategory': subcategory,
      'brand': brand,
      'variant': variant,
      'unit': unit,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'hsn_code': hsnCode,
      'mrp': mrp,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'margin_percent': marginPercent,
      'tax_percent': taxPercent,
      'tax_category': taxCategory,
      'default_supplier_ref': defaultSupplierRef,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'lead_time_days': leadTimeDays,
      'shelf_life_days': shelfLifeDays,
      'product_status': productStatus,
      'product_type': productType,
      'product_image_urls': productImageUrls,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  // Firestore serialization method (alias for toMap for compatibility)
  Map<String, dynamic> toFirestore() => toMap();
}
