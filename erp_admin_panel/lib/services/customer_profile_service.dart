import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/customer_profile.dart'; // <-- Corrected import

class CustomerProfileService {
  final _collection = FirebaseFirestore.instance.collection('customers');

  Future<void> addOrUpdateCustomer(CustomerProfile profile) async {
    await _collection.doc(profile.customerId).set(profile.toFirestore());
  }

  Future<void> deleteCustomer(String customerId) async {
    await _collection.doc(customerId).delete();
  }

  Future<CustomerProfile?> getCustomer(String customerId) async {
    final doc = await _collection.doc(customerId).get();
    if (!doc.exists) return null;
    return CustomerProfile.fromFirestore(doc.data()!, doc.id);
  }

  Stream<List<CustomerProfile>> streamCustomers() {
    return _collection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => CustomerProfile.fromFirestore(doc.data()!, doc.id)).toList()
    );
  }

  Future<List<CustomerProfile>> getAllCustomers() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => CustomerProfile.fromFirestore(doc.data()!, doc.id)).toList();
  }

  // ======================== POS INTEGRATION METHODS ========================
  
  // Get customer profile (alias for getCustomer)
  static Future<CustomerProfile?> getProfile(String customerId) async {
    final service = CustomerProfileService();
    return await service.getCustomer(customerId);
  }

  // Update customer profile
  static Future<void> updateProfile(String customerId, CustomerProfile profile) async {
    final service = CustomerProfileService();
    await service.addOrUpdateCustomer(profile);
  }

  // Search customers by phone, email, or name
  static Future<List<CustomerProfile>> searchCustomers(String query) async {
    try {
      final service = CustomerProfileService();
      final allCustomers = await service.getAllCustomers();
      
      return allCustomers.where((customer) {
        final name = customer.customerName.toLowerCase();
        final email = customer.contactInfo.toLowerCase();
        final phone = customer.phoneNumber.toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || 
               email.contains(searchQuery) || 
               phone.contains(searchQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Add loyalty points to customer
  static Future<void> addLoyaltyPoints(String customerId, int points) async {
    try {
      debugPrint('🎁 Updating customer loyalty points:');
      debugPrint('  • Customer ID: $customerId');
      debugPrint('  • Points to add: $points');
      
      final service = CustomerProfileService();
      final customer = await service.getCustomer(customerId);
      if (customer != null) {
        final oldPoints = customer.loyaltyPoints;
        final newPoints = oldPoints + points;
        
        debugPrint('  • Previous points: $oldPoints');
        debugPrint('  • New total points: $newPoints');
        
        final updatedCustomer = customer.copyWith(
          loyaltyPoints: newPoints,
          lastOrderDate: Timestamp.fromDate(DateTime.now()),
          totalOrders: customer.totalOrders + 1,
        );
        
        await service.addOrUpdateCustomer(updatedCustomer);
        debugPrint('  ✅ Customer loyalty profile updated in CRM');
        
        // Check for tier upgrade
        final newTier = _calculateLoyaltyTier(newPoints);
        if (newTier != customer.loyaltyTier) {
          debugPrint('  🎉 LOYALTY TIER UPGRADE: ${customer.loyaltyTier} → $newTier');
        }
      } else {
        debugPrint('  ❌ Customer not found: $customerId');
      }
    } catch (e) {
      debugPrint('❌ Error updating customer loyalty points: $e');
    }
  }
  
  // Helper method to calculate loyalty tier
  static String _calculateLoyaltyTier(int points) {
    if (points >= 1000) return 'PLATINUM';
    if (points >= 500) return 'GOLD';
    if (points >= 200) return 'SILVER';
    return 'BRONZE';
  }

  // Get customer statistics for analytics
  static Future<Map<String, dynamic>> getCustomerStats(DateTime startDate, DateTime endDate) async {
    try {
      final service = CustomerProfileService();
      final allCustomers = await service.getAllCustomers();
      
      final newCustomers = allCustomers.where((customer) {
        return customer.createdAt.toDate().isAfter(startDate) && customer.createdAt.toDate().isBefore(endDate);
      }).length;
      
      final returningCustomers = allCustomers.where((customer) {
        return customer.lastPurchaseDate != null &&
               customer.lastPurchaseDate!.isAfter(startDate) &&
               customer.lastPurchaseDate!.isBefore(endDate) &&
               customer.totalOrders > 1;
      }).length;
      
      return {
        'new_customers': newCustomers,
        'returning_customers': returningCustomers,
        'total_customers': allCustomers.length,
      };
    } catch (e) {
      return {
        'new_customers': 0,
        'returning_customers': 0,
        'total_customers': 0,
      };
    }
  }

  // Sync customer data
  static Future<void> syncCustomerData() async {
    // Implementation for syncing customer data across modules
    // This could include syncing with external CRM systems, etc.
  }

  // Update customer loyalty points after a purchase with full business logic
  static Future<void> updateLoyaltyPoints(String customerId, double purchaseAmount, double totalSpent) async {
    try {
      if (kDebugMode) {
        print('🎯 CRM Update: Processing loyalty for customer $customerId');
        print('  • Purchase amount: \$${purchaseAmount.toStringAsFixed(2)}');
        print('  • Total amount spent: \$${totalSpent.toStringAsFixed(2)}');
      }

      final service = CustomerProfileService();
      final customer = await service.getCustomer(customerId);
      
      if (customer != null) {
        // Calculate points (1 point per dollar spent)
        final pointsToAdd = purchaseAmount.round();
        final oldPoints = customer.loyaltyPoints;
        final newPoints = oldPoints + pointsToAdd;
        
        if (kDebugMode) {
          print('  • Points to add: $pointsToAdd');
          print('  • Previous points: $oldPoints');
          print('  • New total points: $newPoints');
        }
        
        final updatedCustomer = customer.copyWith(
          loyaltyPoints: newPoints,
          lastOrderDate: Timestamp.fromDate(DateTime.now()),
          totalOrders: customer.totalOrders + 1,
          totalPurchases: totalSpent,
        );
        
        await service.addOrUpdateCustomer(updatedCustomer);
        
        if (kDebugMode) {
          print('  ✅ CRM record updated successfully');
          
          // Check for tier upgrade
          final newTier = _calculateLoyaltyTier(newPoints);
          if (newTier != customer.loyaltyTier) {
            print('  🎉 LOYALTY TIER UPGRADE: ${customer.loyaltyTier} → $newTier');
            print('    • Customer: ${customer.firstName} ${customer.lastName}');
            print('    • New benefits available!');
          } else {
            print('  • Current tier: ${customer.loyaltyTier} (maintained)');
          }
          
          print('  • Updated customer profile:');
          print('    • Total orders: ${customer.totalOrders} → ${customer.totalOrders + 1}');
          print('    • Loyalty points: $oldPoints → $newPoints (+$pointsToAdd)');
          print('    • Total spent: \$${customer.totalSpent.toStringAsFixed(2)} → \$${totalSpent.toStringAsFixed(2)}');
        }
      } else {
        if (kDebugMode) {
          print('  ❌ Customer not found in CRM: $customerId');
          print('  • Loyalty points update skipped');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CRM loyalty update failed for customer $customerId: $e');
      }
    }
  }
}