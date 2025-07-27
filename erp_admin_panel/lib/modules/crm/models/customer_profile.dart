import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfile {
  final String customerId;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String gender;
  final DateTime? dob;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String preferredStoreId;
  final int loyaltyPoints;
  final int totalOrders;
  final double totalPurchases; // Total amount spent by customer
  final Timestamp? lastOrderDate;
  final double averageOrderValue;
  final String customerSegment;
  final String preferredContactMode;
  final String referralCode;
  final String referredBy;
  final List<Map<String, dynamic>> supportTickets;
  final bool marketingOptIn;
  final String feedbackNotes;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // Add these fields to your model if not present:
  final DateTime? firstOrderDate;
  final DateTime? lastActivityDate;
  final double? churnRiskScore;
  final List<String>? campaignResponses; // e.g., ['Diwali2024', 'SummerSale']
  final String? feedbackSentiment;
  final String? preferredChannel; // e.g., 'App', 'Web', 'Offline'

  CustomerProfile({
    required this.customerId,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.gender,
    this.dob,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.preferredStoreId,
    required this.loyaltyPoints,
    required this.totalOrders,
    required this.totalPurchases,
    this.lastOrderDate,
    required this.averageOrderValue,
    required this.customerSegment,
    required this.preferredContactMode,
    required this.referralCode,
    required this.referredBy,
    required this.supportTickets,
    required this.marketingOptIn,
    required this.feedbackNotes,
    required this.createdAt,
    required this.updatedAt,
    this.firstOrderDate,
    this.lastActivityDate,
    this.churnRiskScore,
    this.campaignResponses,
    this.feedbackSentiment,
    this.preferredChannel,
  });

  factory CustomerProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return CustomerProfile(
      customerId: id,
      fullName: data['full_name'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      addressLine1: data['address_line1'] ?? '',
      addressLine2: data['address_line2'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postal_code'] ?? '',
      preferredStoreId: data['preferred_store_id'] ?? '',
      loyaltyPoints: data['loyalty_points'] ?? 0,
      totalOrders: data['total_orders'] ?? 0,
      totalPurchases: (data['total_purchases'] ?? 0).toDouble(),
      lastOrderDate: data['last_order_date'],
      averageOrderValue: (data['average_order_value'] ?? 0).toDouble(),
      customerSegment: data['customer_segment'] ?? 'New',
      preferredContactMode: data['preferred_contact_mode'] ?? 'SMS',
      referralCode: data['referral_code'] ?? '',
      referredBy: data['referred_by'] ?? '',
      supportTickets: List<Map<String, dynamic>>.from(data['support_tickets'] ?? []),
      marketingOptIn: data['marketing_opt_in'] ?? false,
      feedbackNotes: data['feedback_notes'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      firstOrderDate: data['first_order_date'] != null ? (data['first_order_date'] as Timestamp).toDate() : null,
      lastActivityDate: data['last_activity_date'] != null ? (data['last_activity_date'] as Timestamp).toDate() : null,
      churnRiskScore: data['churn_risk_score']?.toDouble(),
      campaignResponses: List<String>.from(data['campaign_responses'] ?? []),
      feedbackSentiment: data['feedback_sentiment'],
      preferredChannel: data['preferred_channel'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'email': email,
      'gender': gender,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'preferred_store_id': preferredStoreId,
      'loyalty_points': loyaltyPoints,
      'total_orders': totalOrders,
      'total_purchases': totalPurchases,
      'last_order_date': lastOrderDate,
      'average_order_value': averageOrderValue,
      'customer_segment': customerSegment,
      'preferred_contact_mode': preferredContactMode,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'support_tickets': supportTickets,
      'marketing_opt_in': marketingOptIn,
      'feedback_notes': feedbackNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'first_order_date': firstOrderDate != null ? Timestamp.fromDate(firstOrderDate!) : null,
      'last_activity_date': lastActivityDate != null ? Timestamp.fromDate(lastActivityDate!) : null,
      'churn_risk_score': churnRiskScore,
      'campaign_responses': campaignResponses,
      'feedback_sentiment': feedbackSentiment,
      'preferred_channel': preferredChannel,
    };
  }

  // Helper getters for backward compatibility and POS integration
  String get customerName => fullName;
  String get contactInfo => email;
  String get phoneNumber => mobileNumber;
  DateTime? get lastPurchaseDate => lastOrderDate?.toDate();
  double get totalSpent => totalPurchases;
  String get firstName => fullName.split(' ').first;
  String get lastName => fullName.split(' ').length > 1 ? fullName.split(' ').last : '';
  
  // Loyalty tier calculation based on points
  String get loyaltyTier {
    if (loyaltyPoints >= 1000) return 'PLATINUM';
    if (loyaltyPoints >= 500) return 'GOLD';
    if (loyaltyPoints >= 200) return 'SILVER';
    return 'BRONZE';
  }

  // CopyWith method for updating customer profile
  CustomerProfile copyWith({
    String? customerId,
    String? fullName,
    String? mobileNumber,
    String? email,
    String? gender,
    DateTime? dob,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? preferredStoreId,
    int? loyaltyPoints,
    int? totalOrders,
    double? totalPurchases,
    Timestamp? lastOrderDate,
    double? averageOrderValue,
    String? customerSegment,
    String? preferredContactMode,
    String? referralCode,
    String? referredBy,
    List<Map<String, dynamic>>? supportTickets,
    bool? marketingOptIn,
    String? feedbackNotes,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    DateTime? firstOrderDate,
    DateTime? lastActivityDate,
    double? churnRiskScore,
    List<String>? campaignResponses,
    String? feedbackSentiment,
    String? preferredChannel,
  }) {
    return CustomerProfile(
      customerId: customerId ?? this.customerId,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      preferredStoreId: preferredStoreId ?? this.preferredStoreId,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalOrders: totalOrders ?? this.totalOrders,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      customerSegment: customerSegment ?? this.customerSegment,
      preferredContactMode: preferredContactMode ?? this.preferredContactMode,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      supportTickets: supportTickets ?? this.supportTickets,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      feedbackNotes: feedbackNotes ?? this.feedbackNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstOrderDate: firstOrderDate ?? this.firstOrderDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      churnRiskScore: churnRiskScore ?? this.churnRiskScore,
      campaignResponses: campaignResponses ?? this.campaignResponses,
      feedbackSentiment: feedbackSentiment ?? this.feedbackSentiment,
      preferredChannel: preferredChannel ?? this.preferredChannel,
    );
  }
}