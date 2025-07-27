import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 🏪 Store Management Data Model
/// Captures and organizes data related to physical store or warehouse locations
/// Acts as a bridge for all location-specific operations such as inventory control,
/// staff roles, point of sale, and customer order fulfillment.
/// 
/// 🎯 Purpose: Enable multi-location operations with clear structure and visibility
/// ✅ Benefits: 
/// - Multi-location operations with clear structure
/// - Location-level access controls for users and modules
/// - Store-level performance, sales, and inventory flow tracking
/// - Centralized contact, compliance, and geolocation data
/// - Seamless integration with Inventory, POS, COM, and Logistics modules
class Store {
  /// Core Store Identity Fields (from PDR)
  final String storeId;           // UUID - Unique identifier for each store
  final String storeCode;         // Text - Short code used internally (e.g., HYD001)
  final String storeName;         // Text - Display name of the store
  final String storeType;         // Dropdown - Retail / Warehouse / Distribution Center
  
  /// Contact Information (from PDR)
  final String contactPerson;     // Text - Primary manager or POC
  final String contactNumber;     // Text - Mobile or landline number
  final String email;             // Email - Store-specific email
  
  /// Address Details (from PDR)
  final String addressLine1;      // Text - Full address line 1
  final String? addressLine2;     // Text - Optional additional line
  final String city;              // Text - City where store is located
  final String state;             // Text - State
  final String postalCode;        // Text - PIN or ZIP code
  final String country;           // Text - Country
  final double? latitude;         // Decimal - Geolocation (lat) for map tracking
  final double? longitude;        // Decimal - Geolocation (long)
  
  /// Operational Details (from PDR)
  final String operatingHours;    // Text - Opening and closing hours
  final double? storeAreaSqft;    // Decimal - Area of the store in square feet/meters
  
  /// Compliance & Legal (from PDR)
  final String? gstRegistrationNumber; // Text - GSTIN specific to this store
  final String? fssaiLicense;     // Text - If handling food items
  
  /// Status & Hierarchy (from PDR)
  final String storeStatus;       // Dropdown - Active / Inactive / Under Renovation
  final String? parentCompany;    // Text - Optional: If managed under a franchise
  
  /// Audit Trail (from PDR)
  final Timestamp createdAt;      // Timestamp - Date the store record was added
  final Timestamp updatedAt;      // Timestamp - Last modification timestamp
  final Timestamp? deletedAt;     // Timestamp - Soft delete timestamp
  final String? createdBy;        // User ID who created the store
  final String? updatedBy;        // User ID who last updated the store

  /// Advanced ERP Integration Fields
  final int? currentStaffCount;   // Current number of staff at this location
  final double? todaysSales;      // Today's sales total for quick dashboard view
  final int? todaysTransactions;  // Today's transaction count
  final int? inventoryItemCount;  // Total inventory items at this location
  final double? averageTransactionValue; // ATV for performance tracking
  final String? managerName;      // Current store manager name
  final bool? isOperational;      // Whether store is currently operational
  
  /// Analytics & Performance Fields
  final double? monthlyTarget;    // Monthly sales target
  final double? monthlyAchieved;  // Monthly sales achieved
  final double? yearlyTarget;     // Yearly sales target
  final double? yearlyAchieved;   // Yearly sales achieved
  final int? customerFootfall;    // Daily customer footfall
  final double? conversionRate;   // Sales conversion rate
  final List<String>? tags;       // Tags for categorization (Premium, Budget, etc.)
  final Map<String, dynamic>? customFields; // Custom fields for extensibility

  Store({
    required this.storeId,
    required this.storeCode,
    required this.storeName,
    required this.storeType,
    required this.contactPerson,
    required this.contactNumber,
    required this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.operatingHours,
    this.storeAreaSqft,
    this.gstRegistrationNumber,
    this.fssaiLicense,
    required this.storeStatus,
    this.parentCompany,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.currentStaffCount,
    this.todaysSales,
    this.todaysTransactions,
    this.inventoryItemCount,
    this.averageTransactionValue,
    this.managerName,
    this.isOperational,
    this.monthlyTarget,
    this.monthlyAchieved,
    this.yearlyTarget,
    this.yearlyAchieved,
    this.customerFootfall,
    this.conversionRate,
    this.tags,
    this.customFields,
  });

  /// Create Store from Firestore document
  factory Store.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Store(
      storeId: doc.id,
      storeCode: data['store_code'] ?? '',
      storeName: data['store_name'] ?? '',
      storeType: data['store_type'] ?? 'Retail',
      contactPerson: data['contact_person'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      email: data['email'] ?? '',
      addressLine1: data['address_line1'] ?? '',
      addressLine2: data['address_line2'],
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postal_code'] ?? '',
      country: data['country'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      operatingHours: data['operating_hours'] ?? '9:00 AM - 9:00 PM',
      storeAreaSqft: data['store_area_sqft']?.toDouble(),
      gstRegistrationNumber: data['gst_registration_number'],
      fssaiLicense: data['fssai_license'],
      storeStatus: data['store_status'] ?? 'Active',
      parentCompany: data['parent_company'],
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      deletedAt: data['deleted_at'],
      createdBy: data['created_by'],
      updatedBy: data['updated_by'],
      currentStaffCount: data['current_staff_count'],
      todaysSales: data['todays_sales']?.toDouble(),
      todaysTransactions: data['todays_transactions'],
      inventoryItemCount: data['inventory_item_count'],
      averageTransactionValue: data['average_transaction_value']?.toDouble(),
      managerName: data['manager_name'],
      isOperational: data['is_operational'],
      monthlyTarget: data['monthly_target']?.toDouble(),
      monthlyAchieved: data['monthly_achieved']?.toDouble(),
      yearlyTarget: data['yearly_target']?.toDouble(),
      yearlyAchieved: data['yearly_achieved']?.toDouble(),
      customerFootfall: data['customer_footfall'],
      conversionRate: data['conversion_rate']?.toDouble(),
      tags: data['tags'] == null ? null : List<String>.from(data['tags']),
      customFields: data['custom_fields'] == null ? null : Map<String, dynamic>.from(data['custom_fields']),
    );
  }

  /// Convert Store to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'store_code': storeCode,
      'store_name': storeName,
      'store_type': storeType,
      'contact_person': contactPerson,
      'contact_number': contactNumber,
      'email': email,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'operating_hours': operatingHours,
      'store_area_sqft': storeAreaSqft,
      'gst_registration_number': gstRegistrationNumber,
      'fssai_license': fssaiLicense,
      'store_status': storeStatus,
      'parent_company': parentCompany,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'current_staff_count': currentStaffCount,
      'todays_sales': todaysSales,
      'todays_transactions': todaysTransactions,
      'inventory_item_count': inventoryItemCount,
      'average_transaction_value': averageTransactionValue,
      'manager_name': managerName,
      'is_operational': isOperational,
      'monthly_target': monthlyTarget,
      'monthly_achieved': monthlyAchieved,
      'yearly_target': yearlyTarget,
      'yearly_achieved': yearlyAchieved,
      'customer_footfall': customerFootfall,
      'conversion_rate': conversionRate,
      'tags': tags,
      'custom_fields': customFields,
    };
  }

  /// Create a copy with updated fields
  Store copyWith({
    String? storeCode,
    String? storeName,
    String? storeType,
    String? contactPerson,
    String? contactNumber,
    String? email,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    String? operatingHours,
    double? storeAreaSqft,
    String? gstRegistrationNumber,
    String? fssaiLicense,
    String? storeStatus,
    String? parentCompany,
    Timestamp? updatedAt,
    Timestamp? deletedAt,
    String? createdBy,
    String? updatedBy,
    int? currentStaffCount,
    double? todaysSales,
    int? todaysTransactions,
    int? inventoryItemCount,
    double? averageTransactionValue,
    String? managerName,
    bool? isOperational,
    double? monthlyTarget,
    double? monthlyAchieved,
    double? yearlyTarget,
    double? yearlyAchieved,
    int? customerFootfall,
    double? conversionRate,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return Store(
      storeId: storeId,
      storeCode: storeCode ?? this.storeCode,
      storeName: storeName ?? this.storeName,
      storeType: storeType ?? this.storeType,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      operatingHours: operatingHours ?? this.operatingHours,
      storeAreaSqft: storeAreaSqft ?? this.storeAreaSqft,
      gstRegistrationNumber: gstRegistrationNumber ?? this.gstRegistrationNumber,
      fssaiLicense: fssaiLicense ?? this.fssaiLicense,
      storeStatus: storeStatus ?? this.storeStatus,
      parentCompany: parentCompany ?? this.parentCompany,
      createdAt: createdAt,
      updatedAt: updatedAt ?? Timestamp.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      currentStaffCount: currentStaffCount ?? this.currentStaffCount,
      todaysSales: todaysSales ?? this.todaysSales,
      todaysTransactions: todaysTransactions ?? this.todaysTransactions,
      inventoryItemCount: inventoryItemCount ?? this.inventoryItemCount,
      averageTransactionValue: averageTransactionValue ?? this.averageTransactionValue,
      managerName: managerName ?? this.managerName,
      isOperational: isOperational ?? this.isOperational,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      monthlyAchieved: monthlyAchieved ?? this.monthlyAchieved,
      yearlyTarget: yearlyTarget ?? this.yearlyTarget,
      yearlyAchieved: yearlyAchieved ?? this.yearlyAchieved,
      customerFootfall: customerFootfall ?? this.customerFootfall,
      conversionRate: conversionRate ?? this.conversionRate,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Get full address as a single string
  String get fullAddress {
    String address = addressLine1;
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      address += ', $addressLine2';
    }
    address += ', $city, $state $postalCode, $country';
    return address;
  }

  /// Check if store is currently open based on operating hours
  bool get isCurrentlyOpen {
    // Simple implementation - can be enhanced with actual time parsing
    return storeStatus == 'Active' && (isOperational ?? true);
  }

  /// Get status color for UI
  Color get statusColor {
    switch (storeStatus) {
      case 'Active':
        return const Color(0xFF4CAF50); // Green
      case 'Inactive':
        return const Color(0xFFF44336); // Red
      case 'Under Renovation':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Get store type icon
  String get storeTypeIcon {
    switch (storeType) {
      case 'Retail':
        return '🏪';
      case 'Warehouse':
        return '🏭';
      case 'Distribution Center':
        return '📦';
      default:
        return '🏢';
    }
  }

  /// Get performance status based on targets
  String get performanceStatus {
    if (monthlyTarget == null || monthlyAchieved == null) return 'No Target Set';
    
    final percentage = (monthlyAchieved! / monthlyTarget!) * 100;
    
    if (percentage >= 100) return 'Exceeding Target';
    if (percentage >= 80) return 'On Track';
    if (percentage >= 50) return 'Below Target';
    return 'Critical Performance';
  }

  /// Get performance color for UI
  Color get performanceColor {
    if (monthlyTarget == null || monthlyAchieved == null) return Colors.grey;
    
    final percentage = (monthlyAchieved! / monthlyTarget!) * 100;
    
    if (percentage >= 100) return const Color(0xFF4CAF50); // Green
    if (percentage >= 80) return const Color(0xFF8BC34A); // Light Green
    if (percentage >= 50) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Get monthly achievement percentage
  double get monthlyAchievementPercentage {
    if (monthlyTarget == null || monthlyAchieved == null || monthlyTarget == 0) return 0.0;
    return (monthlyAchieved! / monthlyTarget!) * 100;
  }

  /// Get yearly achievement percentage
  double get yearlyAchievementPercentage {
    if (yearlyTarget == null || yearlyAchieved == null || yearlyTarget == 0) return 0.0;
    return (yearlyAchieved! / yearlyTarget!) * 100;
  }

  /// Check if store coordinates are available
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  /// Check if store has all required compliance documents
  bool get hasCompleteCompliance {
    return gstRegistrationNumber != null && 
           gstRegistrationNumber!.isNotEmpty &&
           (fssaiLicense != null || storeType != 'Retail');
  }

  /// Get store size category
  String get sizeCategory {
    if (storeAreaSqft == null) return 'Unknown';
    
    if (storeAreaSqft! < 1000) return 'Small';
    if (storeAreaSqft! < 5000) return 'Medium';
    if (storeAreaSqft! < 10000) return 'Large';
    return 'Extra Large';
  }

  /// Get estimated staff requirement based on store area
  int get estimatedStaffRequirement {
    if (storeAreaSqft == null) return 5;
    
    // Basic calculation: 1 staff per 200 sq ft for retail
    if (storeType == 'Retail') {
      return (storeAreaSqft! / 200).ceil();
    }
    
    // For warehouses: 1 staff per 500 sq ft
    if (storeType == 'Warehouse') {
      return (storeAreaSqft! / 500).ceil();
    }
    
    return 5; // Default
  }

  /// Check if store needs attention (low performance, understaffed, etc.)
  bool get needsAttention {
    if (storeStatus != 'Active') return true;
    if (monthlyAchievementPercentage < 50) return true;
    if (currentStaffCount != null && currentStaffCount! < estimatedStaffRequirement) return true;
    if (todaysSales != null && todaysSales! < 1000) return true; // Low daily sales
    
    return false;
  }

  /// Get attention reasons
  List<String> get attentionReasons {
    List<String> reasons = [];
    
    if (storeStatus != 'Active') {
      reasons.add('Store is ${storeStatus.toLowerCase()}');
    }
    
    if (monthlyAchievementPercentage < 50) {
      reasons.add('Below 50% monthly target');
    }
    
    if (currentStaffCount != null && currentStaffCount! < estimatedStaffRequirement) {
      reasons.add('Understaffed (${currentStaffCount}/${estimatedStaffRequirement})');
    }
    
    if (todaysSales != null && todaysSales! < 1000) {
      reasons.add('Low daily sales');
    }
    
    return reasons;
  }

  @override
  String toString() {
    return 'Store(id: $storeId, code: $storeCode, name: $storeName, type: $storeType, status: $storeStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store && other.storeId == storeId;
  }

  @override
  int get hashCode => storeId.hashCode;
}

/// 📊 Store Performance Analytics Model
class StorePerformance {
  final String storeId;
  final String storeCode;
  final String storeName;
  final DateTime date;
  final double totalSales;
  final int totalTransactions;
  final int customerCount;
  final double averageTransactionValue;
  final double grossProfit;
  final double netProfit;
  final int inventoryTurnover;
  final double footfallCount;
  final double conversionRate;
  final Map<String, dynamic> additionalMetrics;

  StorePerformance({
    required this.storeId,
    required this.storeCode,
    required this.storeName,
    required this.date,
    required this.totalSales,
    required this.totalTransactions,
    required this.customerCount,
    required this.averageTransactionValue,
    required this.grossProfit,
    required this.netProfit,
    required this.inventoryTurnover,
    required this.footfallCount,
    required this.conversionRate,
    this.additionalMetrics = const {},
  });

  factory StorePerformance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StorePerformance(
      storeId: data['store_id'] ?? '',
      storeCode: data['store_code'] ?? '',
      storeName: data['store_name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      totalSales: data['total_sales']?.toDouble() ?? 0.0,
      totalTransactions: data['total_transactions'] ?? 0,
      customerCount: data['customer_count'] ?? 0,
      averageTransactionValue: data['average_transaction_value']?.toDouble() ?? 0.0,
      grossProfit: data['gross_profit']?.toDouble() ?? 0.0,
      netProfit: data['net_profit']?.toDouble() ?? 0.0,
      inventoryTurnover: data['inventory_turnover'] ?? 0,
      footfallCount: data['footfall_count']?.toDouble() ?? 0.0,
      conversionRate: data['conversion_rate']?.toDouble() ?? 0.0,
      additionalMetrics: data['additional_metrics'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'store_id': storeId,
      'store_code': storeCode,
      'store_name': storeName,
      'date': Timestamp.fromDate(date),
      'total_sales': totalSales,
      'total_transactions': totalTransactions,
      'customer_count': customerCount,
      'average_transaction_value': averageTransactionValue,
      'gross_profit': grossProfit,
      'net_profit': netProfit,
      'inventory_turnover': inventoryTurnover,
      'footfall_count': footfallCount,
      'conversion_rate': conversionRate,
      'additional_metrics': additionalMetrics,
    };
  }
}

/// 🔄 Store Transfer Model for Inter-store Operations
class StoreTransfer {
  final String transferId;
  final String fromStoreId;
  final String toStoreId;
  final String fromStoreName;
  final String toStoreName;
  final List<Map<String, dynamic>> items;
  final String transferStatus; // Pending, In Transit, Completed, Cancelled
  final String requestedBy;
  final String? approvedBy;
  final Timestamp requestDate;
  final Timestamp? approvalDate;
  final Timestamp? completionDate;
  final String? notes;
  final double totalValue;

  StoreTransfer({
    required this.transferId,
    required this.fromStoreId,
    required this.toStoreId,
    required this.fromStoreName,
    required this.toStoreName,
    required this.items,
    required this.transferStatus,
    required this.requestedBy,
    this.approvedBy,
    required this.requestDate,
    this.approvalDate,
    this.completionDate,
    this.notes,
    required this.totalValue,
  });

  factory StoreTransfer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreTransfer(
      transferId: doc.id,
      fromStoreId: data['from_store_id'] ?? '',
      toStoreId: data['to_store_id'] ?? '',
      fromStoreName: data['from_store_name'] ?? '',
      toStoreName: data['to_store_name'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      transferStatus: data['transfer_status'] ?? 'Pending',
      requestedBy: data['requested_by'] ?? '',
      approvedBy: data['approved_by'],
      requestDate: data['request_date'] ?? Timestamp.now(),
      approvalDate: data['approval_date'],
      completionDate: data['completion_date'],
      notes: data['notes'],
      totalValue: data['total_value']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'from_store_id': fromStoreId,
      'to_store_id': toStoreId,
      'from_store_name': fromStoreName,
      'to_store_name': toStoreName,
      'items': items,
      'transfer_status': transferStatus,
      'requested_by': requestedBy,
      'approved_by': approvedBy,
      'request_date': requestDate,
      'approval_date': approvalDate,
      'completion_date': completionDate,
      'notes': notes,
      'total_value': totalValue,
    };
  }
}
