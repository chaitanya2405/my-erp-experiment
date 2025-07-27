// 🏪 WEB-ONLY CUSTOMER STATE PROVIDER
// Customer state management for web builds using REAL Firestore data

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/web_models.dart';

class WebCustomerStateProviderReal extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  WebCustomer? _currentCustomer;
  bool _isLoading = false;
  String? _error;
  List<WebOrder> _recentOrders = [];

  // Getters
  WebCustomer? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WebOrder> get recentOrders => _recentOrders;
  bool get hasCustomer => _currentCustomer != null;

  // Load real customer data from Firestore (John or any customer)
  Future<void> loadRealCustomer({String? email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('👤 Loading real customer from Firestore...');
      
      // Try to find John first, or any customer
      QuerySnapshot customerQuery;
      if (email != null) {
        customerQuery = await _firestore
            .collection('customers')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
      } else {
        // Look for common demo customers
        customerQuery = await _firestore
            .collection('customers')
            .where('email', whereIn: ['john@example.com', 'john.doe@example.com', 'demo@example.com'])
            .limit(1)
            .get();
      }

      if (customerQuery.docs.isEmpty) {
        // If no specific customer found, get any customer
        customerQuery = await _firestore
            .collection('customers')
            .limit(1)
            .get();
      }

      if (customerQuery.docs.isNotEmpty) {
        final doc = customerQuery.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        
        _currentCustomer = WebCustomer(
          id: doc.id,
          name: data['customer_name'] ?? data['name'] ?? 'Customer',
          email: data['email'] ?? 'customer@example.com',
          phone: data['mobile_number'] ?? data['phone'] ?? '+91 9876543210',
          address: data['address'] ?? '123 Main Street',
          membershipTier: data['membership_tier'] ?? 'Gold',
          totalOrders: data['total_orders'] ?? 0,
          totalSpent: (data['total_spent'] ?? 0).toDouble(),
          createdAt: data['created_at'] != null 
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
          isActive: data['is_active'] ?? true,
        );

        print('✅ Loaded real customer: ${_currentCustomer!.name} (${_currentCustomer!.email})');
        
        // Load customer's recent orders
        await _loadCustomerOrders();
        
      } else {
        // Create a fallback demo customer if no real customer found
        _currentCustomer = WebCustomer(
          id: 'demo-customer-1',
          name: 'Demo Customer',
          email: 'demo@example.com',
          phone: '+91 9876543210',
          address: '123 Demo Street, Demo City',
          membershipTier: 'Gold',
          totalOrders: 5,
          totalSpent: 1250.0,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          isActive: true,
        );
        print('⚠️ No real customer found, using demo customer');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customer: $e';
      _isLoading = false;
      print('❌ Error loading customer: $e');
      notifyListeners();
    }
  }

  // Load customer's recent orders from Firestore
  Future<void> _loadCustomerOrders() async {
    if (_currentCustomer == null) return;

    try {
      print('📋 Loading customer orders...');
      final ordersQuery = await _firestore
          .collection('customer_orders')
          .where('customer_id', isEqualTo: _currentCustomer!.id)
          .limit(5)
          .get();

      _recentOrders = ordersQuery.docs.map((doc) {
        final data = doc.data();
        return WebOrder(
          id: doc.id,
          customerId: data['customer_id'] ?? '',
          customerName: '', // Not stored in orders
          customerEmail: '', // Not stored in orders  
          customerPhone: '', // Not stored in orders
          items: [], // We'll load items separately if needed
          subtotal: (data['total_amount'] ?? 0).toDouble(),
          tax: (data['tax_amount'] ?? 0).toDouble(),
          shipping: (data['delivery_charges'] ?? 0).toDouble(),
          totalAmount: (data['grand_total'] ?? 0).toDouble(),
          status: data['order_status'] ?? 'pending',
          paymentStatus: data['payment_status'] ?? 'pending',
          paymentMethod: data['payment_mode'] ?? 'cash',
          orderDate: data['order_date'] != null 
              ? (data['order_date'] as Timestamp).toDate()
              : (data['created_at'] != null 
                  ? (data['created_at'] as Timestamp).toDate()
                  : DateTime.now()),
          shippingAddress: data['delivery_address']?.toString() ?? '',
        );
      }).toList();

      // Sort by date in memory (newest first)
      _recentOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      print('✅ Loaded ${_recentOrders.length} customer orders');
    } catch (e) {
      print('❌ Error loading customer orders: $e');
      // Continue without orders
    }
  }

  // Set customer manually
  void setCustomer(WebCustomer customer) {
    _currentCustomer = customer;
    _error = null;
    notifyListeners();
  }

  // Clear customer data
  void clearCustomer() {
    _currentCustomer = null;
    _recentOrders.clear();
    _error = null;
    notifyListeners();
  }

  // Initialize with real data
  Future<void> initialize() async {
    await loadRealCustomer();
  }

  // Backward compatibility method
  void createDemoCustomer() {
    loadRealCustomer();
  }
}
