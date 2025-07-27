import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/unified_models.dart';

class CustomerProfileService {
  static const String collection = 'customer_profiles';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new customer profile
  static Future<String> createProfile(UnifiedCustomerProfile profile) async {
    try {
      final docRef = await _db.collection(collection).add(profile.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create customer profile: $e');
    }
  }

  /// Get customer profile by ID
  static Future<UnifiedCustomerProfile?> getProfile(String profileId) async {
    try {
      final doc = await _db.collection(collection).doc(profileId).get();
      if (doc.exists && doc.data() != null) {
        return UnifiedCustomerProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer profile: $e');
    }
  }

  /// Update customer profile
  static Future<void> updateProfile(String profileId, UnifiedCustomerProfile profile) async {
    try {
      await _db.collection(collection).doc(profileId).update(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update customer profile: $e');
    }
  }

  /// Delete customer profile
  static Future<void> deleteProfile(String profileId) async {
    try {
      await _db.collection(collection).doc(profileId).delete();
    } catch (e) {
      throw Exception('Failed to delete customer profile: $e');
    }
  }

  /// Get all customer profiles
  static Future<List<UnifiedCustomerProfile>> getAllProfiles() async {
    try {
      final snapshot = await _db.collection(collection).get();
      return snapshot.docs
          .map((doc) => UnifiedCustomerProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer profiles: $e');
    }
  }

  /// Search customer profiles by mobile number
  static Future<List<UnifiedCustomerProfile>> searchByMobile(String mobileNumber) async {
    try {
      final snapshot = await _db
          .collection(collection)
          .where('mobile_number', isEqualTo: mobileNumber)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customer profiles: $e');
    }
  }

  /// Search customer profiles by email
  static Future<List<UnifiedCustomerProfile>> searchByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection(collection)
          .where('email', isEqualTo: email)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search customer profiles: $e');
    }
  }

  /// Get customer profiles by loyalty tier
  static Future<List<UnifiedCustomerProfile>> getByLoyaltyTier(String tier) async {
    try {
      final snapshot = await _db
          .collection(collection)
          .where('loyalty_tier', isEqualTo: tier)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer profiles by loyalty tier: $e');
    }
  }

  /// Get top customers by total spent
  static Future<List<UnifiedCustomerProfile>> getTopCustomers(int limit) async {
    try {
      final snapshot = await _db
          .collection(collection)
          .orderBy('total_spent', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => UnifiedCustomerProfile.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get top customers: $e');
    }
  }

  /// Add or update customer profile (convenience method)
  static Future<String> addOrUpdateCustomer(UnifiedCustomerProfile profile) async {
    try {
      // Check if profile exists by ID
      if (profile.id.isNotEmpty) {
        final existing = await getProfile(profile.id);
        if (existing != null) {
          await updateProfile(profile.id, profile);
          return profile.id;
        }
      }
      
      // Create new profile
      return await createProfile(profile);
    } catch (e) {
      throw Exception('Failed to add or update customer profile: $e');
    }
  }
}
