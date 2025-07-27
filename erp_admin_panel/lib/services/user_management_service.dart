import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Simple User Management Service for Universal Bridge Integration
class UserManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching users: $e');
      }
      return [];
    }
  }

  /// Get user activity  
  static Future<List<Map<String, dynamic>>> getUserActivity([String? userId]) async {
    try {
      Query query = _firestore.collection('user_activity');
      if (userId != null) {
        query = query.where('user_id', isEqualTo: userId);
      }
      
      final snapshot = await query.limit(100).get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user activity: $e');
      }
      return [];
    }
  }

  /// Create new user
  static Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(_collection).add({
        ...userData,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating user: $e');
      }
      return false;
    }
  }

  /// Update user
  static Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        ...userData,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating user: $e');
      }
      return false;
    }
  }

  /// Log user activity
  static Future<void> logActivity(String userId, String action, String module, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('user_activity').add({
        'user_id': userId,
        'action': action,
        'module': module,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging activity: $e');
      }
    }
  }
  
  /// Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user by ID: $e');
      }
      return null;
    }
  }
  
  /// Get recent activity for all users
  static Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('user_activity')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching recent activity: $e');
      }
      return [];
    }
  }
  
  /// Get user sessions
  static Future<List<Map<String, dynamic>>> getUserSessions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_sessions')
          .where('user_id', isEqualTo: userId)
          .orderBy('login_time', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user sessions: $e');
      }
      return [];
    }
  }
  
  /// Get active sessions
  static Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 24)); // Active within 24 hours
      
      final snapshot = await _firestore
          .collection('user_sessions')
          .where('last_activity', isGreaterThan: Timestamp.fromDate(cutoff))
          .orderBy('last_activity', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching active sessions: $e');
      }
      return [];
    }
  }
  
  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection(_collection).get();
      final totalUsers = usersSnapshot.docs.length;
      
      // Get active users (logged in within last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final activeUsersSnapshot = await _firestore
          .collection(_collection)
          .where('last_login', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();
      
      final activeUsers = activeUsersSnapshot.docs.length;
      
      // Get user roles breakdown
      final roleBreakdown = <String, int>{};
      for (var doc in usersSnapshot.docs) {
        final role = doc.data()['role'] ?? 'user';
        roleBreakdown[role] = (roleBreakdown[role] ?? 0) + 1;
      }
      
      return {
        'total_users': totalUsers,
        'active_users': activeUsers,
        'inactive_users': totalUsers - activeUsers,
        'role_breakdown': roleBreakdown,
        'activity_rate': totalUsers > 0 ? (activeUsers / totalUsers * 100).round() : 0,
        'status': 'success'
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating user stats: $e');
      }
      return {
        'total_users': 0,
        'active_users': 0,
        'inactive_users': 0,
        'role_breakdown': {},
        'activity_rate': 0,
        'status': 'error',
        'error': e.toString()
      };
    }
  }
}
