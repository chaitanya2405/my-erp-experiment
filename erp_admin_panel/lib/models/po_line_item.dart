import 'package:cloud_firestore/cloud_firestore.dart';

class PoLineItem {
  final String itemId;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  PoLineItem({
    required this.itemId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory PoLineItem.fromMap(Map<String, dynamic> map) => PoLineItem(
        itemId: map['itemId'] ?? '',
        description: map['description'] ?? '',
        quantity: map['quantity'] ?? 0,
        unitPrice: (map['unitPrice'] ?? 0).toDouble(),
        total: (map['total'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
      };
}
