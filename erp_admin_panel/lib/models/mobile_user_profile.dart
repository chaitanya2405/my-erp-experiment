import 'package:cloud_firestore/cloud_firestore.dart';

/// MobileUserProfile for customer/supplier app (minimal, permitted fields only)
class MobileUserProfile {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? photoUrl;
  final String? role;
  final String userType; // 'customer' or 'supplier'
  final bool isActive;
  final List<String> modulesAccess;
  final Map<String, dynamic> fieldLevelRestrictions;

  MobileUserProfile({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoUrl,
    this.role,
    required this.userType,
    required this.isActive,
    required this.modulesAccess,
    required this.fieldLevelRestrictions,
  });

  factory MobileUserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return MobileUserProfile(
      uid: uid,
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      role: map['role'],
      userType: map['userType'] ?? 'customer',
      isActive: map['isActive'] ?? true,
      modulesAccess: List<String>.from(map['modulesAccess'] ?? []),
      fieldLevelRestrictions: Map<String, dynamic>.from(map['fieldLevelRestrictions'] ?? {}),
    );
  }
}
