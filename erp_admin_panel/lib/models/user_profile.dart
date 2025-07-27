import 'package:cloud_firestore/cloud_firestore.dart';

/// UserProfile model for User Management & RBAC
class UserProfile {
  final String uid;
  final String? username;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? photoUrl;
  final List<String> roles; // e.g. ['admin', 'staff', 'customer']
  final String? role; // Single role (for dropdown)
  final List<String> stores; // Store IDs user has access to
  final List<String> assignedStoreIds; // Store/Warehouse UUIDs
  final String? employmentType; // Full-time / Part-time / Contractor / External App User
  final String? accessLevel; // Full / Limited / Read-Only
  final List<String> modulesAccess; // Allowed ERP modules
  final Map<String, dynamic> fieldLevelRestrictions; // Module/field-level restrictions
  final String? dataScope; // All Stores / Assigned Stores / Own Data Only
  final Map<String, dynamic> allowedActions; // Allowed actions per module
  final bool? apiAccessFlag; // API access for external apps
  final DateTime? lastLogin;
  final int? loginAttempts;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final List<String> auditTrail; // List of audit log IDs or descriptions
  final List<String> loginIpHistory;
  final bool? twoFaEnabled;
  final bool? biometricLoginEnabled;
  final Map<String, dynamic> shiftTimings;
  final Map<String, dynamic> geoRestrictionZone;

  UserProfile({
    required this.uid,
    this.username,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoUrl,
    required this.roles,
    this.role,
    required this.stores,
    required this.assignedStoreIds,
    this.employmentType,
    this.accessLevel,
    required this.modulesAccess,
    required this.fieldLevelRestrictions,
    this.dataScope,
    required this.allowedActions,
    this.apiAccessFlag,
    this.lastLogin,
    this.loginAttempts,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.auditTrail,
    required this.loginIpHistory,
    this.twoFaEnabled,
    this.biometricLoginEnabled,
    required this.shiftTimings,
    required this.geoRestrictionZone,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      username: map['username'],
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      roles: List<String>.from(map['roles'] ?? []),
      role: map['role'],
      stores: List<String>.from(map['stores'] ?? []),
      assignedStoreIds: List<String>.from(map['assignedStoreIds'] ?? []),
      employmentType: map['employmentType'],
      accessLevel: map['accessLevel'],
      modulesAccess: List<String>.from(map['modulesAccess'] ?? []),
      fieldLevelRestrictions: Map<String, dynamic>.from(map['fieldLevelRestrictions'] ?? {}),
      dataScope: map['dataScope'],
      allowedActions: Map<String, dynamic>.from(map['allowedActions'] ?? {}),
      apiAccessFlag: map['apiAccessFlag'],
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
      loginAttempts: map['loginAttempts'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      auditTrail: List<String>.from(map['auditTrail'] ?? []),
      loginIpHistory: List<String>.from(map['loginIpHistory'] ?? []),
      twoFaEnabled: map['twoFaEnabled'],
      biometricLoginEnabled: map['biometricLoginEnabled'],
      shiftTimings: Map<String, dynamic>.from(map['shiftTimings'] ?? {}),
      geoRestrictionZone: Map<String, dynamic>.from(map['geoRestrictionZone'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'roles': roles,
      'role': role,
      'stores': stores,
      'assignedStoreIds': assignedStoreIds,
      'employmentType': employmentType,
      'accessLevel': accessLevel,
      'modulesAccess': modulesAccess,
      'fieldLevelRestrictions': fieldLevelRestrictions,
      'dataScope': dataScope,
      'allowedActions': allowedActions,
      'apiAccessFlag': apiAccessFlag,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'loginAttempts': loginAttempts,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'auditTrail': auditTrail,
      'loginIpHistory': loginIpHistory,
      'twoFaEnabled': twoFaEnabled,
      'biometricLoginEnabled': biometricLoginEnabled,
      'shiftTimings': shiftTimings,
      'geoRestrictionZone': geoRestrictionZone,
    };
  }
}
