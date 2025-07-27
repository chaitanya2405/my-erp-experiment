import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String supplierId;
  final String supplierCode;
  final String supplierName;
  final String contactPersonName;
  final String contactPersonMobile;
  final String? alternateContactNumber;
  final String email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String gstin;
  final String panNumber;
  final String supplierType;
  final String? businessRegistrationNo;
  final String? website;
  final String bankAccountNumber;
  final String bankIfscCode;
  final String bankName;
  final String? upiId;
  final String paymentTerms;
  final String preferredPaymentMode;
  final num creditLimit;
  final String defaultCurrency;
  final List<String> productsSupplied;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final num rating;
  final num onTimeDeliveryRate;
  final num averageLeadTimeDays;
  final DateTime? lastSuppliedDate;
  final int totalOrdersSupplied;
  final num totalOrderValue;
  final List<String> complianceDocuments;
  final bool isPreferredSupplier;
  final String? notes;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> tags;
  final double totalSpend;
  final int orderVolume;
  final double averageLeadTime;

  Supplier({
    required this.supplierId,
    required this.supplierCode,
    required this.supplierName,
    required this.contactPersonName,
    required this.contactPersonMobile,
    this.alternateContactNumber,
    required this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.gstin,
    required this.panNumber,
    required this.supplierType,
    this.businessRegistrationNo,
    this.website,
    required this.bankAccountNumber,
    required this.bankIfscCode,
    required this.bankName,
    this.upiId,
    required this.paymentTerms,
    required this.preferredPaymentMode,
    required this.creditLimit,
    required this.defaultCurrency,
    required this.productsSupplied,
    this.contractStartDate,
    this.contractEndDate,
    required this.rating,
    required this.onTimeDeliveryRate,
    required this.averageLeadTimeDays,
    this.lastSuppliedDate,
    required this.totalOrdersSupplied,
    required this.totalOrderValue,
    required this.complianceDocuments,
    required this.isPreferredSupplier,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.totalSpend = 0.0,
    this.orderVolume = 0,
    this.averageLeadTime = 0.0,
  });

  factory Supplier.fromFirestore(Map<String, dynamic> data, String id) {
    return Supplier(
      supplierId: id,
      supplierCode: data['supplier_code'] ?? '',
      supplierName: data['supplier_name'] ?? '',
      contactPersonName: data['contact_person_name'] ?? '',
      contactPersonMobile: data['contact_person_mobile'] ?? '',
      alternateContactNumber: data['alternate_contact_number'],
      email: data['email'] ?? '',
      addressLine1: data['address_line1'] ?? '',
      addressLine2: data['address_line2'],
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postal_code'] ?? '',
      country: data['country'] ?? '',
      gstin: data['gstin'] ?? '',
      panNumber: data['pan_number'] ?? '',
      supplierType: data['supplier_type'] ?? '',
      businessRegistrationNo: data['business_registration_no'],
      website: data['website'],
      bankAccountNumber: data['bank_account_number'] ?? '',
      bankIfscCode: data['bank_ifsc_code'] ?? '',
      bankName: data['bank_name'] ?? '',
      upiId: data['upi_id'],
      paymentTerms: data['payment_terms'] ?? '',
      preferredPaymentMode: data['preferred_payment_mode'] ?? '',
      creditLimit: data['credit_limit'] ?? 0,
      defaultCurrency: data['default_currency'] ?? 'INR',
      productsSupplied: List<String>.from(data['products_supplied'] ?? []),
      contractStartDate: data['contract_start_date'] != null ? (data['contract_start_date'] as Timestamp).toDate() : null,
      contractEndDate: data['contract_end_date'] != null ? (data['contract_end_date'] as Timestamp).toDate() : null,
      rating: data['rating'] ?? 0,
      onTimeDeliveryRate: data['on_time_delivery_rate'] ?? 0,
      averageLeadTimeDays: data['average_lead_time_days'] ?? 0,
      lastSuppliedDate: data['last_supplied_date'] != null ? (data['last_supplied_date'] as Timestamp).toDate() : null,
      totalOrdersSupplied: data['total_orders_supplied'] ?? 0,
      totalOrderValue: data['total_order_value'] ?? 0,
      complianceDocuments: List<String>.from(data['compliance_documents'] ?? []),
      isPreferredSupplier: data['is_preferred_supplier'] ?? false,
      notes: data['notes'],
      status: data['status'] ?? 'Active',
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      tags: List<String>.from(data['tags'] ?? []),
      totalSpend: (data['totalSpend'] ?? 0).toDouble(),
      orderVolume: (data['orderVolume'] ?? 0) is int ? data['orderVolume'] : int.tryParse(data['orderVolume'].toString()) ?? 0,
      averageLeadTime: (data['averageLeadTime'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplier_code': supplierCode,
      'supplier_name': supplierName,
      'contact_person_name': contactPersonName,
      'contact_person_mobile': contactPersonMobile,
      'alternate_contact_number': alternateContactNumber,
      'email': email,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'gstin': gstin,
      'pan_number': panNumber,
      'supplier_type': supplierType,
      'business_registration_no': businessRegistrationNo,
      'website': website,
      'bank_account_number': bankAccountNumber,
      'bank_ifsc_code': bankIfscCode,
      'bank_name': bankName,
      'upi_id': upiId,
      'payment_terms': paymentTerms,
      'preferred_payment_mode': preferredPaymentMode,
      'credit_limit': creditLimit,
      'default_currency': defaultCurrency,
      'products_supplied': productsSupplied,
      'contract_start_date': contractStartDate != null ? Timestamp.fromDate(contractStartDate!) : null,
      'contract_end_date': contractEndDate != null ? Timestamp.fromDate(contractEndDate!) : null,
      'rating': rating,
      'on_time_delivery_rate': onTimeDeliveryRate,
      'average_lead_time_days': averageLeadTimeDays,
      'last_supplied_date': lastSuppliedDate != null ? Timestamp.fromDate(lastSuppliedDate!) : null,
      'total_orders_supplied': totalOrdersSupplied,
      'total_order_value': totalOrderValue,
      'compliance_documents': complianceDocuments,
      'is_preferred_supplier': isPreferredSupplier,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'tags': tags,
      'totalSpend': totalSpend,
      'orderVolume': orderVolume,
      'averageLeadTime': averageLeadTime,
    };
  }
}
