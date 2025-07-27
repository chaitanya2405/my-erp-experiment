// Enhanced ERP System - Enhanced Customer Service
// Provides intelligent customer management with loyalty, analytics, and personalization

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../services/customer_profile_service.dart';
import '../events/erp_events.dart';
import '../events/erp_event_bus.dart';
import '../orchestration/transaction_orchestrator.dart';
import '../models/index.dart';
import 'enhanced_service_base.dart';

class EnhancedCustomerService extends EnhancedERPService 
    with TransactionCapable, RealTimeSyncCapable, AnalyticsCapable {
  
  static EnhancedCustomerService? _instance;
  
  EnhancedCustomerService._(ERPEventBus eventBus, TransactionOrchestrator orchestrator)
      : super(eventBus, orchestrator);

  static EnhancedCustomerService getInstance(ERPEventBus eventBus, TransactionOrchestrator orchestrator) {
    _instance ??= EnhancedCustomerService._(eventBus, orchestrator);
    return _instance!;
  }

  @override
  Future<void> setupEventListeners() async {
    // Listen to POS transactions for loyalty updates
    listenToEvent<POSTransactionCreatedEvent>(_handlePOSTransaction);
    
    // Listen to loyalty updates
    listenToEvent<CustomerLoyaltyUpdatedEvent>(_handleLoyaltyUpdate);
    
    // Listen to return events for loyalty adjustments
    listenToEvent<POSReturnProcessedEvent>(_handleReturn);
    
    // Setup real-time sync
    setupRealTimeSync();
  }

  @override
  void listenToDataChanges() {
    // Listen to customer behavior patterns
    listenToEvent<CustomerBehaviorEvent>(_trackCustomerBehavior);
  }

  /// Enhanced customer profile creation with business intelligence
  Future<String> createEnhancedCustomerProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String preferredCommunication = 'email',
    Map<String, dynamic> preferences = const {},
    Map<String, dynamic> metadata = const {},
  }) async {
    return await executeInTransaction(
      'create_customer_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        // Generate customer ID
        final customerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';

        // Create customer profile with enhanced data
        final customerProfile = UnifiedCustomerProfile(
          id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
          customerId: customerId,
          fullName: name,
          mobileNumber: phone ?? '',
          email: email,
          addressLine1: '',
          addressLine2: '',
          city: '',
          state: '',
          postalCode: '',
          gender: '',
          loyaltyTier: 'Bronze',
          totalSpent: 0.0,
          totalOrders: 0,
          averageOrderValue: 0.0,
          customerSegment: 'New',
          preferredContactMode: 'SMS',
          marketingOptIn: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to database - Using Firestore directly since CustomerProfileService uses old model
        await FirebaseFirestore.instance.collection('customers').doc(customerId).set(customerProfile.toMap());

        // Emit customer created event
        emitEvent(CustomerProfileCreatedEvent(
          eventId: 'customer_created_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedCustomerService',
          customerId: customerId,
          customerData: customerProfile.toMap(),
          metadata: metadata,
        ));

        // Track analytics
        trackMetric('customers.created', 1.0, tags: {
          'acquisition_channel': metadata['source'] ?? 'direct',
          'has_phone': (phone != null).toString(),
          'has_email': email.isNotEmpty.toString(),
        });

        debugPrint('✅ Customer profile created: $customerId ($name)');
        return customerId;
      },
      affectedModules: ['customers', 'analytics', 'marketing'],
      metadata: metadata,
    );
  }

  /// Calculate initial customer segment
  String _calculateInitialSegment(String email, String? phone) {
    if (email.contains('@')) {
      final domain = email.split('@').last.toLowerCase();
      if (['gmail.com', 'yahoo.com', 'hotmail.com'].contains(domain)) {
        return 'consumer';
      } else {
        return 'business';
      }
    }
    return 'unknown';
  }

  /// Handle POS transactions for customer analytics
  Future<void> _handlePOSTransaction(POSTransactionCreatedEvent event) async {
    if (event.customerId == null) return;

    try {
      // Update customer spending and visit data
      final items = event.items.map((item) => UnifiedPOSTransactionItem.fromMap(item)).toList();
      await _updateCustomerPurchaseData(
        event.customerId!,
        event.totalAmount,
        items,
        event.metadata,
      );

      // Emit customer behavior event
      emitEvent(CustomerBehaviorEvent(
        eventId: 'customer_behavior_${DateTime.now().millisecondsSinceEpoch}',
        source: 'EnhancedCustomerService',
        customerId: event.customerId!,
        behaviorType: 'purchase',
        data: {
          'transaction_id': event.transactionId,
          'amount': event.totalAmount,
          'item_count': event.items.length,
          'store_id': event.storeId,
        },
        timestamp: DateTime.now(),
      ));

      debugPrint('📊 Customer purchase data updated: ${event.customerId}');
    } catch (e) {
      debugPrint('❌ Failed to update customer purchase data: $e');
    }
  }

  /// Update customer purchase data and analytics
  Future<void> _updateCustomerPurchaseData(
    String customerId,
    double transactionAmount,
    List<UnifiedPOSTransactionItem> items,
    Map<String, dynamic> metadata,
  ) async {
    await executeInTransaction(
      'update_customer_data_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        // Get current customer profile
        final customerDoc = await FirebaseFirestore.instance.collection('customers').doc(customerId).get();
        if (!customerDoc.exists) return;
        
        final customerData = customerDoc.data()!;
        final customer = UnifiedCustomerProfile.fromMap(customerData);

        // Calculate new totals
        final newTotalSpent = customer.totalSpent + transactionAmount;
        final newTier = _calculateLoyaltyTier(newTotalSpent);

        // Update customer profile
        final updatedProfile = UnifiedCustomerProfile(
          id: customer.id,
          customerId: customer.customerId,
          fullName: customer.fullName,
          mobileNumber: customer.mobileNumber,
          email: customer.email,
          addressLine1: customer.addressLine1,
          addressLine2: customer.addressLine2,
          city: customer.city,
          state: customer.state,
          postalCode: customer.postalCode,
          dateOfBirth: customer.dateOfBirth,
          gender: customer.gender,
          loyaltyTier: newTier,
          totalSpent: newTotalSpent,
          totalOrders: customer.totalOrders + 1,
          averageOrderValue: newTotalSpent / (customer.totalOrders + 1),
          lastVisit: DateTime.now(),
          isActive: customer.isActive,
          customerSegment: customer.customerSegment,
          preferredContactMode: customer.preferredContactMode,
          preferredStoreId: customer.preferredStoreId,
          marketingOptIn: customer.marketingOptIn,
          referralCode: customer.referralCode,
          referredBy: customer.referredBy,
          supportTickets: customer.supportTickets,
          feedbackNotes: customer.feedbackNotes,
          createdAt: customer.createdAt,
          updatedAt: DateTime.now(),
          metadata: customer.metadata,
        );

        // Save updated profile to database
        await FirebaseFirestore.instance.collection('customers').doc(customerId).update(updatedProfile.toMap());

        // Emit customer profile updated event
        emitEvent(CustomerProfileUpdatedEvent(
          eventId: 'customer_updated_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedCustomerService',
          customerId: customerId,
          updatedFields: {
            'total_spent': newTotalSpent,
            'loyalty_tier': newTier,
            'last_visit': DateTime.now().toIso8601String(),
          },
          metadata: metadata,
        ));

        // Track tier promotion
        if (newTier != customer.loyaltyTier) {
          emitEvent(CustomerTierPromotedEvent(
            eventId: 'tier_promotion_${DateTime.now().millisecondsSinceEpoch}',
            source: 'EnhancedCustomerService',
            customerId: customerId,
            previousTier: customer.loyaltyTier,
            newTier: newTier,
            totalSpent: newTotalSpent,
          ));

          trackMetric('customers.tier_promotion', 1.0, tags: {
            'previous_tier': customer.loyaltyTier,
            'new_tier': newTier,
            'customer_id': customerId,
          });
        }
      },
      affectedModules: ['customers', 'analytics'],
      metadata: metadata,
    );
  }

  /// Calculate loyalty tier based on total spending
  String _calculateLoyaltyTier(double totalSpent) {
    if (totalSpent >= 10000) return 'Platinum';
    if (totalSpent >= 5000) return 'Gold';
    if (totalSpent >= 1000) return 'Silver';
    return 'Bronze';
  }

  /// Handle loyalty point updates
  Future<void> _handleLoyaltyUpdate(CustomerLoyaltyUpdatedEvent event) async {
    try {
      final customerDoc = await FirebaseFirestore.instance.collection('customers').doc(event.customerId).get();
      if (!customerDoc.exists) return;
      
      final customerData = customerDoc.data()!;
      final customer = UnifiedCustomerProfile.fromMap(customerData);

      // Update customer profile with new loyalty tier calculation based on total spent
      final newTier = _calculateLoyaltyTier(customer.totalSpent);
      
      final updatedProfile = UnifiedCustomerProfile(
        id: customer.id,
        customerId: customer.customerId,
        fullName: customer.fullName,
        mobileNumber: customer.mobileNumber,
        email: customer.email,
        addressLine1: customer.addressLine1,
        addressLine2: customer.addressLine2,
        city: customer.city,
        state: customer.state,
        postalCode: customer.postalCode,
        dateOfBirth: customer.dateOfBirth,
        gender: customer.gender,
        loyaltyTier: newTier,
        totalSpent: customer.totalSpent,
        totalOrders: customer.totalOrders,
        averageOrderValue: customer.averageOrderValue,
        lastVisit: customer.lastVisit,
        isActive: customer.isActive,
        customerSegment: customer.customerSegment,
        preferredContactMode: customer.preferredContactMode,
        preferredStoreId: customer.preferredStoreId,
        marketingOptIn: customer.marketingOptIn,
        referralCode: customer.referralCode,
        referredBy: customer.referredBy,
        supportTickets: customer.supportTickets,
        feedbackNotes: customer.feedbackNotes,
        createdAt: customer.createdAt,
        updatedAt: DateTime.now(),
        metadata: {
          ...customer.metadata,
          'loyalty_updated': DateTime.now().toIso8601String(),
        },
      );

      // Save updated profile
      await FirebaseFirestore.instance.collection('customers').doc(event.customerId).update(updatedProfile.toMap());

      trackMetric('customers.loyalty_tier_updated', 1.0, tags: {
        'customer_id': event.customerId,
        'tier': newTier,
      });

      debugPrint('🎯 Customer loyalty tier updated: ${event.customerId} -> $newTier');
    } catch (e) {
      debugPrint('❌ Failed to update loyalty points: $e');
    }
  }

  /// Handle returns for loyalty adjustments
  Future<void> _handleReturn(POSReturnProcessedEvent event) async {
    // Find original transaction customer
    try {
      // TODO: Get original transaction details to find customer
      // For now, just track return metrics
      trackMetric('customers.return_processed', event.refundAmount, tags: {
        'reason': event.reason,
        'processed_by': event.processedBy,
      });
    } catch (e) {
      debugPrint('❌ Failed to process customer return adjustments: $e');
    }
  }

  /// Track customer behavior patterns
  Future<void> _trackCustomerBehavior(CustomerBehaviorEvent event) async {
    trackMetric('customers.behavior_tracked', 1.0, tags: {
      'customer_id': event.customerId,
      'behavior_type': event.behaviorType,
    });

    // Analyze behavior patterns for personalization
    await _analyzeCustomerPreferences(event);
  }

  /// Analyze customer preferences for personalization
  Future<void> _analyzeCustomerPreferences(CustomerBehaviorEvent event) async {
    if (event.behaviorType == 'purchase') {
      // TODO: Implement ML-based preference analysis
      // For now, simple category tracking
      debugPrint('🧠 Analyzing customer preferences for: ${event.customerId}');
    }
  }

  /// Get enhanced customer profile stream
  Stream<List<UnifiedCustomerProfile>> getEnhancedCustomerStream() {
    return FirebaseFirestore.instance.collection('customers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UnifiedCustomerProfile.fromMap(data);
      }).toList();
    });
  }

  /// Send personalized offers based on customer data
  Future<void> sendPersonalizedOffer({
    required String customerId,
    required String offerType,
    required Map<String, dynamic> offerData,
    Map<String, dynamic> metadata = const {},
  }) async {
    await executeInTransaction(
      'send_offer_${DateTime.now().millisecondsSinceEpoch}',
      () async {
        emitEvent(CustomerOfferSentEvent(
          eventId: 'offer_sent_${DateTime.now().millisecondsSinceEpoch}',
          source: 'EnhancedCustomerService',
          customerId: customerId,
          offerType: offerType,
          offerData: offerData,
          sentDate: DateTime.now(),
          metadata: metadata,
        ));

        trackMetric('customers.offer_sent', 1.0, tags: {
          'customer_id': customerId,
          'offer_type': offerType,
        });

        debugPrint('📧 Personalized offer sent to: $customerId ($offerType)');
      },
      affectedModules: ['customers', 'marketing', 'analytics'],
      metadata: metadata,
    );
  }

  /// Calculate customer lifetime value prediction
  Future<double> calculateLifetimeValue(String customerId) async {
    try {
      final customerDoc = await FirebaseFirestore.instance.collection('customers').doc(customerId).get();
      if (!customerDoc.exists) return 0.0;
      
      final customerData = customerDoc.data()!;
      final customer = UnifiedCustomerProfile.fromMap(customerData);

      // Simple CLV calculation: average transaction value * frequency * lifespan
      final avgTransactionValue = customer.averageOrderValue;
      final transactionCount = customer.totalOrders;
      
      if (transactionCount == 0) return 0.0;

      final customerAge = DateTime.now().difference(customer.createdAt).inDays;
      final purchaseFrequency = transactionCount / (customerAge / 30.0); // per month
      
      // Predict 24-month CLV
      final predictedCLV = avgTransactionValue * purchaseFrequency * 24;

      return predictedCLV;
    } catch (e) {
      debugPrint('Error calculating CLV: $e');
      return 0.0;
    }
  }

  /// Get customer insights and recommendations
  Future<Map<String, dynamic>> getCustomerInsights(String customerId) async {
    final customerDoc = await FirebaseFirestore.instance.collection('customers').doc(customerId).get();
    if (!customerDoc.exists) return {};
    
    final customerData = customerDoc.data()!;
    final customer = UnifiedCustomerProfile.fromMap(customerData);

    final clv = await calculateLifetimeValue(customerId);
    final riskLevel = _calculateRiskLevel(customer);
    final satisfactionScore = _calculateSatisfactionScore(customer);
    
    return {
      'customer_id': customerId,
      'lifetime_value': clv,
      'risk_level': riskLevel,
      'satisfaction_score': satisfactionScore,
      'tier': customer.loyaltyTier,
      'total_spent': customer.totalSpent,
      'loyalty_points': customer.metadata['loyalty_points'] ?? 0,
      'days_since_last_visit': customer.lastVisit != null 
          ? DateTime.now().difference(customer.lastVisit!).inDays 
          : null,
      'recommended_actions': _getRecommendedActions(customer, riskLevel, clv),
    };
  }

  List<String> _getRecommendedActions(CustomerProfile customer, String riskLevel, double clv) {
    final actions = <String>[];
    
    if (riskLevel == 'high') {
      actions.add('Send win-back campaign');
      actions.add('Offer special discount');
    } else if (riskLevel == 'medium') {
      actions.add('Send re-engagement email');
      actions.add('Personalized product recommendations');
    }
    
    if (clv > 1000 && customer.loyaltyTier != 'Platinum') {
      actions.add('Consider tier upgrade');
    }
    
    // Note: Loyalty points system can be added to metadata if needed
    final loyaltyPoints = customer.metadata['loyalty_points'] ?? 0;
    if (loyaltyPoints > 500) {
      actions.add('Suggest point redemption');
    }
    
    return actions;
  }

  /// Calculate customer risk level based on activity
  String _calculateRiskLevel(UnifiedCustomerProfile customer) {
    final daysSinceLastVisit = customer.lastVisit != null 
        ? DateTime.now().difference(customer.lastVisit!).inDays 
        : 9999;
    
    if (daysSinceLastVisit > 365) return 'high'; // Churned
    if (daysSinceLastVisit > 90) return 'medium'; // At risk
    return 'low'; // Active
  }

  /// Calculate customer satisfaction score
  double _calculateSatisfactionScore(UnifiedCustomerProfile customer) {
    // Simple scoring based on order frequency and recency
    final daysSinceLastVisit = customer.lastVisit != null 
        ? DateTime.now().difference(customer.lastVisit!).inDays 
        : 365;
    
    double score = 5.0; // Base neutral score
    
    // Adjust based on recency
    if (daysSinceLastVisit < 30) score += 2.0;
    else if (daysSinceLastVisit < 90) score += 1.0;
    else if (daysSinceLastVisit > 180) score -= 2.0;
    
    // Adjust based on order frequency
    if (customer.totalOrders > 10) score += 1.0;
    else if (customer.totalOrders < 3) score -= 1.0;
    
    // Clamp between 1.0 and 10.0
    return score.clamp(1.0, 10.0);
  }
}
