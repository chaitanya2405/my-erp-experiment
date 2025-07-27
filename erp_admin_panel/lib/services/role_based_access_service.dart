import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum StaffRole {
  admin,
  manager,
  cashier,
  salesperson,
  auditor,
  viewer,
}

enum PosPermission {
  // Transaction permissions
  createTransaction,
  editTransaction,
  deleteTransaction,
  refundTransaction,
  viewTransactions,
  
  // Product permissions
  addProduct,
  editProduct,
  deleteProduct,
  viewProducts,
  scanBarcode,
  
  // Discount permissions
  applyDiscount,
  approveDiscount,
  viewDiscountRules,
  editDiscountRules,
  
  // Payment permissions
  processCash,
  processCard,
  processUPI,
  processWallet,
  
  // Analytics permissions
  viewAnalytics,
  exportData,
  viewReports,
  
  // System permissions
  manageUsers,
  manageSettings,
  viewAuditLogs,
  backupData,
  
  // Advanced features
  expressMode,
  bulkOperations,
  priceOverride,
  taxExemption,
}

class StaffUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final StaffRole role;
  final List<PosPermission> customPermissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> metadata;

  StaffUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.customPermissions = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString(),
      'customPermissions': customPermissions.map((p) => p.toString()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory StaffUser.fromMap(Map<String, dynamic> map) {
    return StaffUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: StaffRole.values.firstWhere(
        (r) => r.toString() == map['role'],
        orElse: () => StaffRole.viewer,
      ),
      customPermissions: (map['customPermissions'] as List<dynamic>?)
          ?.map((p) => PosPermission.values.firstWhere(
                (perm) => perm.toString() == p,
                orElse: () => PosPermission.viewProducts,
              ))
          .toList() ?? [],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.parse(map['lastLoginAt']) 
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

class RoleBasedAccessService {
  static RoleBasedAccessService? _instance;
  static RoleBasedAccessService get instance => _instance ??= RoleBasedAccessService._();
  RoleBasedAccessService._();

  StaffUser? _currentUser;
  final Map<StaffRole, List<PosPermission>> _defaultRolePermissions = {
    StaffRole.admin: PosPermission.values, // All permissions
    StaffRole.manager: [
      PosPermission.createTransaction,
      PosPermission.editTransaction,
      PosPermission.refundTransaction,
      PosPermission.viewTransactions,
      PosPermission.addProduct,
      PosPermission.editProduct,
      PosPermission.viewProducts,
      PosPermission.scanBarcode,
      PosPermission.applyDiscount,
      PosPermission.approveDiscount,
      PosPermission.viewDiscountRules,
      PosPermission.processCash,
      PosPermission.processCard,
      PosPermission.processUPI,
      PosPermission.processWallet,
      PosPermission.viewAnalytics,
      PosPermission.exportData,
      PosPermission.viewReports,
      PosPermission.viewAuditLogs,
      PosPermission.expressMode,
      PosPermission.priceOverride,
    ],
    StaffRole.cashier: [
      PosPermission.createTransaction,
      PosPermission.viewTransactions,
      PosPermission.viewProducts,
      PosPermission.scanBarcode,
      PosPermission.applyDiscount,
      PosPermission.processCash,
      PosPermission.processCard,
      PosPermission.processUPI,
      PosPermission.processWallet,
      PosPermission.expressMode,
    ],
    StaffRole.salesperson: [
      PosPermission.createTransaction,
      PosPermission.viewTransactions,
      PosPermission.viewProducts,
      PosPermission.scanBarcode,
      PosPermission.applyDiscount,
      PosPermission.processCash,
      PosPermission.processCard,
      PosPermission.processUPI,
    ],
    StaffRole.auditor: [
      PosPermission.viewTransactions,
      PosPermission.viewProducts,
      PosPermission.viewAnalytics,
      PosPermission.viewReports,
      PosPermission.viewAuditLogs,
      PosPermission.exportData,
    ],
    StaffRole.viewer: [
      PosPermission.viewTransactions,
      PosPermission.viewProducts,
      PosPermission.viewAnalytics,
    ],
  };

  /// Get current logged-in user
  StaffUser? get currentUser => _currentUser;

  /// Login user and set current context
  Future<bool> loginUser(String email, String password) async {
    try {
      // In a real app, this would authenticate with your backend
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('staff_users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);
      
      final userMap = usersList.firstWhere(
        (u) => u['email'] == email && u['isActive'] == true,
        orElse: () => null,
      );
      
      if (userMap != null) {
        _currentUser = StaffUser.fromMap(userMap);
        
        // Update last login time
        _currentUser = StaffUser(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          customPermissions: _currentUser!.customPermissions,
          isActive: _currentUser!.isActive,
          createdAt: _currentUser!.createdAt,
          lastLoginAt: DateTime.now(),
          metadata: _currentUser!.metadata,
        );
        
        await _saveCurrentUser();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  /// Check if current user has specific permission
  bool hasPermission(PosPermission permission) {
    if (_currentUser == null) return false;
    
    // Check custom permissions first
    if (_currentUser!.customPermissions.contains(permission)) {
      return true;
    }
    
    // Check role-based permissions
    final rolePermissions = _defaultRolePermissions[_currentUser!.role] ?? [];
    return rolePermissions.contains(permission);
  }

  /// Check if current user has any of the specified permissions
  bool hasAnyPermission(List<PosPermission> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  /// Check if current user has all specified permissions
  bool hasAllPermissions(List<PosPermission> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  /// Get all permissions for current user
  List<PosPermission> getUserPermissions() {
    if (_currentUser == null) return [];
    
    final rolePermissions = _defaultRolePermissions[_currentUser!.role] ?? [];
    final customPermissions = _currentUser!.customPermissions;
    
    return [...rolePermissions, ...customPermissions].toSet().toList();
  }

  /// Check if user can perform transaction operations
  bool canProcessTransactions() {
    return hasAnyPermission([
      PosPermission.createTransaction,
      PosPermission.editTransaction,
    ]);
  }

  /// Check if user can handle payments
  bool canProcessPayments() {
    return hasAnyPermission([
      PosPermission.processCash,
      PosPermission.processCard,
      PosPermission.processUPI,
      PosPermission.processWallet,
    ]);
  }

  /// Check if user can apply discounts
  bool canApplyDiscounts() {
    return hasPermission(PosPermission.applyDiscount);
  }

  /// Check if user can approve high-value discounts
  bool canApproveDiscounts() {
    return hasPermission(PosPermission.approveDiscount);
  }

  /// Check if user can override prices
  bool canOverridePrices() {
    return hasPermission(PosPermission.priceOverride);
  }

  /// Check if user can use express mode
  bool canUseExpressMode() {
    return hasPermission(PosPermission.expressMode);
  }

  /// Create a new staff user (admin only)
  Future<bool> createStaffUser(StaffUser user) async {
    if (!hasPermission(PosPermission.manageUsers)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('staff_users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);
      
      usersList.add(user.toMap());
      await prefs.setString('staff_users', jsonEncode(usersList));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update staff user permissions (admin/manager only)
  Future<bool> updateUserPermissions(String userId, List<PosPermission> permissions) async {
    if (!hasAnyPermission([PosPermission.manageUsers, PosPermission.approveDiscount])) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('staff_users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);
      
      final userIndex = usersList.indexWhere((u) => u['id'] == userId);
      if (userIndex != -1) {
        usersList[userIndex]['customPermissions'] = 
            permissions.map((p) => p.toString()).toList();
        await prefs.setString('staff_users', jsonEncode(usersList));
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get all staff users (admin/manager only)
  Future<List<StaffUser>> getAllStaffUsers() async {
    if (!hasAnyPermission([PosPermission.manageUsers, PosPermission.viewAuditLogs])) {
      return [];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('staff_users') ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);
      
      return usersList.map((u) => StaffUser.fromMap(u)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save current user to preferences
  Future<void> _saveCurrentUser() async {
    if (_currentUser == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_currentUser!.toMap()));
  }

  /// Load current user from preferences
  Future<void> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = StaffUser.fromMap(userMap);
      }
    } catch (e) {
      _currentUser = null;
    }
  }

  /// Initialize with default admin user if no users exist
  Future<void> initializeDefaultUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('staff_users');
      
      if (usersJson == null || usersJson.isEmpty || usersJson == '[]') {
        // Create default admin user
        final adminUser = StaffUser(
          id: 'admin_001',
          name: 'System Administrator',
          email: 'admin@company.com',
          phone: '+91-9999999999',
          role: StaffRole.admin,
          createdAt: DateTime.now(),
          metadata: {'isDefault': true},
        );
        
        // Create default manager user
        final managerUser = StaffUser(
          id: 'manager_001',
          name: 'Store Manager',
          email: 'manager@company.com',
          phone: '+91-8888888888',
          role: StaffRole.manager,
          createdAt: DateTime.now(),
          metadata: {'isDefault': true},
        );
        
        // Create default cashier user
        final cashierUser = StaffUser(
          id: 'cashier_001',
          name: 'Main Cashier',
          email: 'cashier@company.com',
          phone: '+91-7777777777',
          role: StaffRole.cashier,
          createdAt: DateTime.now(),
          metadata: {'isDefault': true},
        );
        
        final defaultUsers = [adminUser, managerUser, cashierUser];
        await prefs.setString('staff_users', 
            jsonEncode(defaultUsers.map((u) => u.toMap()).toList()));
      }
    } catch (e) {
      // Handle initialization error
    }
  }

  /// Require permission for action - throws exception if not authorized
  void requirePermission(PosPermission permission, [String? action]) {
    if (!hasPermission(permission)) {
      final actionText = action ?? permission.toString();
      throw UnauthorizedAccessException(
        'User does not have permission to $actionText'
      );
    }
  }

  /// Require any of the permissions
  void requireAnyPermission(List<PosPermission> permissions, [String? action]) {
    if (!hasAnyPermission(permissions)) {
      final actionText = action ?? 'perform this action';
      throw UnauthorizedAccessException(
        'User does not have required permissions to $actionText'
      );
    }
  }
}

class UnauthorizedAccessException implements Exception {
  final String message;
  UnauthorizedAccessException(this.message);
  
  @override
  String toString() => 'UnauthorizedAccessException: $message';
}
