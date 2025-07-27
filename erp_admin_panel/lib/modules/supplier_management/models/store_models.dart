// Store-related models for supplier management
class StoreInfo {
  final String storeId;
  final String storeName;
  final String address;
  final String contactNumber;
  final String managerName;

  const StoreInfo({
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.contactNumber,
    required this.managerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'address': address,
      'contactNumber': contactNumber,
      'managerName': managerName,
    };
  }

  factory StoreInfo.fromMap(Map<String, dynamic> map) {
    return StoreInfo(
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      address: map['address'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      managerName: map['managerName'] ?? '',
    );
  }
}

class StoreSupplierAssociation {
  final String storeId;
  final String supplierId;
  final DateTime associatedDate;
  final bool isActive;

  const StoreSupplierAssociation({
    required this.storeId,
    required this.supplierId,
    required this.associatedDate,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'supplierId': supplierId,
      'associatedDate': associatedDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory StoreSupplierAssociation.fromMap(Map<String, dynamic> map) {
    return StoreSupplierAssociation(
      storeId: map['storeId'] ?? '',
      supplierId: map['supplierId'] ?? '',
      associatedDate: DateTime.parse(map['associatedDate'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }
}
