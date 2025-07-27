// Customer App Interface - Customer-centric ordering flow
// This simulates a customer mobile app for placing orders

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/customer_auth_service.dart';
import '../services/enhanced_customer_orders_service.dart';
import '../services/enhanced_services.dart';
import '../models/original_models.dart';

class CustomerAppScreen extends StatefulWidget {
  const CustomerAppScreen({Key? key}) : super(key: key);

  @override
  State<CustomerAppScreen> createState() => _CustomerAppScreenState();
}

class _CustomerAppScreenState extends State<CustomerAppScreen> {
  int _selectedTab = 0;
  CustomerProfile? _currentCustomer;
  final List<Product> _availableProducts = [];
  final List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await EnhancedProductService.getAllProducts();
      setState(() {
        _availableProducts.clear();
        _availableProducts.addAll(products);
      });
    } catch (e) {
      _showError('Failed to load products: $e');
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Customer App'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          if (_currentCustomer != null) ...[
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  if (_cartItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => setState(() => _selectedTab = 2),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ],
      ),
      body: _currentCustomer == null 
          ? _buildAuthSection()
          : _buildMainApp(),
      bottomNavigationBar: _currentCustomer != null
          ? BottomNavigationBar(
              currentIndex: _selectedTab,
              onTap: (index) => setState(() => _selectedTab = index),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Products',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildAuthSection() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.blue.shade50,
            child: const TabBar(
              tabs: [
                Tab(text: 'Sign In'),
                Tab(text: 'Sign Up'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSignIn(),
                _buildSignUp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignIn() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Text(
            '👋 Welcome Back!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _signIn(emailController.text, passwordController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _demoSignIn(),
            child: const Text('🎯 Demo Sign In (john@example.com)'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _testCustomerQuery,
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('🧪 Debug: Test Customer Query'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _recreateDemoCustomer,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('🔨 Force Recreate Demo Customer'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _fixMissingCustomerDocument,
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
            ),
            child: const Text('🔗 Fix Missing Customer Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              '🎉 Join Us Today!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: pincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _signUp(
                nameController.text,
                emailController.text,
                phoneController.text,
                passwordController.text,
                addressController.text,
                cityController.text,
                stateController.text,
                pincodeController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainApp() {
    switch (_selectedTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildProductsTab();
      case 2:
        return _buildCartTab();
      case 3:
        return _buildOrdersTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      _currentCustomer!.customerName.isNotEmpty 
                          ? _currentCustomer!.customerName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${_currentCustomer!.customerName}!',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('${_currentCustomer!.loyaltyTier} Member'),
                        Text('${_currentCustomer!.loyaltyPoints} Loyalty Points'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🏪 Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.store, size: 32, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Browse Products'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 3),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 32, color: Colors.green),
                          SizedBox(height: 8),
                          Text('Order History'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: const Row(
            children: [
              Icon(Icons.store, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Available Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _availableProducts.length,
            itemBuilder: (context, index) {
              final product = _availableProducts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      product.productName.isNotEmpty 
                          ? product.productName[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(product.productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹${product.sellingPrice.toStringAsFixed(2)}'),
                      Text('Stock: ${product.currentStock} ${product.unit}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCart(product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    if (_cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your cart is empty'),
            Text('Add some products to get started!'),
          ],
        ),
      );
    }

    double total = 0.0;
    for (final item in _cartItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Cart (${_cartItems.length} items)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text('₹${item['price']} x ${item['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateCartQuantity(index, -1),
                      ),
                      Text('${item['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateCartQuantity(index, 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFromCart(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cartItems.isNotEmpty ? _placeOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Place Order - ₹${total.toStringAsFixed(2)}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return FutureBuilder<List<CustomerOrder>>(
      future: EnhancedCustomerOrdersService.getOrdersByCustomerId(_currentCustomer!.customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No orders yet'),
                Text('Place your first order!'),
              ],
            ),
          );
        }

        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(order.orderStatus),
                  child: const Icon(Icons.receipt, color: Colors.white),
                ),
                title: Text(order.orderNumber),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${order.orderStatus}'),
                    Text('Total: ₹${order.grandTotal.toStringAsFixed(2)}'),
                    Text('Date: ${order.orderDate.toDate().toString().split(' ')[0]}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showOrderDetails(order),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      _currentCustomer!.customerName.isNotEmpty 
                          ? _currentCustomer!.customerName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentCustomer!.customerName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(_currentCustomer!.email),
                  Text(_currentCustomer!.phone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Loyalty Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tier: ${_currentCustomer!.loyaltyTier}'),
                      Text('Points: ${_currentCustomer!.loyaltyPoints}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addToCart(Product product) {
    // Check if product already in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item['product_id'] == product.productId,
    );

    if (existingIndex >= 0) {
      // Update quantity
      setState(() {
        _cartItems[existingIndex]['quantity'] = 
            (_cartItems[existingIndex]['quantity'] as int) + 1;
      });
    } else {
      // Add new item
      setState(() {
        _cartItems.add({
          'product_id': product.productId,
          'product_name': product.productName,
          'quantity': 1,
          'price': product.sellingPrice,
        });
      });
    }

    _showSuccess('${product.productName} added to cart');
  }

  void _updateCartQuantity(int index, int change) {
    setState(() {
      final newQuantity = (_cartItems[index]['quantity'] as int) + change;
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('🛒 Starting order placement process...');
      debugPrint('Customer ID: ${_currentCustomer!.customerId}');
      debugPrint('Customer Name: ${_currentCustomer!.customerName}');
      debugPrint('Cart Items: ${_cartItems.length}');
      
      final result = await EnhancedCustomerOrdersService.placeCustomerOrder(
        customerId: _currentCustomer!.customerId,
        items: _cartItems,
        paymentMode: 'UPI', // Default payment mode
        deliveryMode: 'home-delivery',
        deliveryAddress: {
          'address': _currentCustomer!.address,
          'city': _currentCustomer!.city,
          'state': _currentCustomer!.state,
          'pincode': _currentCustomer!.pincode,
        },
      );

      debugPrint('🛒 Order placement result: $result');

      if (result != null && result['success'] == true) {
        setState(() {
          _cartItems.clear();
          _selectedTab = 3; // Switch to orders tab
        });

        _showSuccess(
          'Order placed successfully!\n'
          'Order: ${result['orderNumber']}\n'
          'Invoice: ${result['invoiceId'] ?? 'Pending'}\n'
          'Loyalty Points Earned: ${result['loyaltyPointsEarned'] ?? 0}'
        );
      } else {
        debugPrint('❌ Order placement failed: ${result?['error']}');
        _showError(result?['error'] ?? 'Failed to place order');
      }
    } catch (e) {
      debugPrint('❌ Exception in order placement: $e');
      _showError('Error placing order: $e');
    }

    setState(() => _isLoading = false);
  }

  void _showOrderDetails(CustomerOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${order.orderStatus}'),
              Text('Payment: ${order.paymentStatus}'),
              Text('Total: ₹${order.grandTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.productsOrdered.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '• ${item['product_name']} x ${item['quantity']} = ₹${item['total']}'
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await CustomerAuthService.signInCustomer(
        email: email,
        password: password,
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _currentCustomer = result['customerProfile'];
        });
        _showSuccess('Welcome back, ${_currentCustomer!.customerName}!');
      } else {
        _showError(result?['error'] ?? 'Sign in failed');
      }
    } catch (e) {
      _showError('Error signing in: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _demoSignIn() async {
    // Try to sign in with demo account
    await _signIn('john@example.com', 'password123');
  }

  Future<void> _signUp(
    String name,
    String email,
    String phone,
    String password,
    String address,
    String city,
    String state,
    String pincode,
  ) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await CustomerAuthService.createCustomer(
        customerName: name,
        email: email,
        password: password,
        mobileNumber: phone,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _currentCustomer = result['customerProfile'];
        });
        _showSuccess('Account created successfully! Welcome, $name!');
      } else {
        _showError(result?['error'] ?? 'Sign up failed');
      }
    } catch (e) {
      _showError('Error creating account: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await CustomerAuthService.signOut();
    setState(() {
      _currentCustomer = null;
      _cartItems.clear();
      _selectedTab = 0;
    });
    _showSuccess('Logged out successfully');
  }

  // Debug method to test customer query
  Future<void> _testCustomerQuery() async {
    try {
      debugPrint('🧪 Testing customer query for demo email...');
      final customer = await CustomerAuthService.getCustomerByEmail('john@example.com');
      
      if (customer != null) {
        _showSuccess('✅ Customer found: ${customer.customerName}');
        debugPrint('Customer ID: ${customer.customerId}');
        debugPrint('Email: ${customer.email}');
      } else {
        _showError('❌ Customer not found in Firestore');
      }
    } catch (e) {
      _showError('Error testing query: $e');
    }
  }

  // Force recreate demo customer
  Future<void> _recreateDemoCustomer() async {
    try {
      setState(() => _isLoading = true);
      _showSuccess('🔨 Recreating demo customer...');
      
      // Step 1: Delete existing customer documents
      final existingDocs = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: 'john@example.com')
          .get();
      
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Deleted existing customer doc: ${doc.id}');
      }
      
      // Step 2: Try to sign in to Firebase Auth and delete the account
      try {
        // Sign in to get access to the Firebase Auth user
        final auth = FirebaseAuth.instance;
        final userCredential = await auth.signInWithEmailAndPassword(
          email: 'john@example.com',
          password: 'password123',
        );
        
        if (userCredential.user != null) {
          debugPrint('🔐 Signed into Firebase Auth to delete user');
          // Delete the Firebase Auth user
          await userCredential.user!.delete();
          debugPrint('🗑️ Deleted Firebase Auth user');
        }
      } catch (authError) {
        debugPrint('⚠️ Auth deletion error (might be okay): $authError');
      }
      
      // Step 3: Wait a moment for Firebase to sync
      await Future.delayed(const Duration(seconds: 1));
      
      // Step 4: Create new demo customer
      final result = await CustomerAuthService.createCustomer(
        customerName: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        mobileNumber: '+91 9876543210',
        address: '123 Demo Street, Demo Colony',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        dateOfBirth: DateTime(1990, 5, 15),
      );
      
      if (result != null && result['success'] == true) {
        _showSuccess('✅ Demo customer recreated successfully!');
        debugPrint('New customer ID: ${result['customerProfile'].customerId}');
      } else {
        _showError('❌ Failed to recreate: ${result?['error']}');
      }
    } catch (e) {
      _showError('Error recreating customer: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fix missing customer document for existing Firebase Auth user
  Future<void> _fixMissingCustomerDocument() async {
    try {
      setState(() => _isLoading = true);
      _showSuccess('🔗 Creating missing customer document...');
      
      // Check if Firebase Auth user exists
      final auth = FirebaseAuth.instance;
      try {
        final userCredential = await auth.signInWithEmailAndPassword(
          email: 'john@example.com',
          password: 'password123',
        );
        
        if (userCredential.user != null) {
          debugPrint('✅ Firebase Auth user exists');
          
          // Create the missing Firestore document directly
          final customerId = 'DEMO_${DateTime.now().millisecondsSinceEpoch}';
          final now = Timestamp.now();
          
          final customerData = {
            'customer_name': 'John Doe',
            'email': 'john@example.com',
            'phone': '+91 9876543210',
            'alt_phone': null,
            'address': '123 Demo Street, Demo Colony',
            'city': 'Mumbai',
            'state': 'Maharashtra',
            'pincode': '400001',
            'customer_type': 'regular',
            'customer_status': 'active',
            'credit_limit': 0.0,
            'wallet_balance': 0.0,
            'loyalty_points': 500,
            'gst_number': null,
            'company_name': null,
            'date_of_birth': Timestamp.fromDate(DateTime(1990, 5, 15)),
            'gender': 'other',
            'preferred_categories': [],
            'preferences': {
              'notifications': true,
              'email_marketing': true,
              'sms_marketing': true,
              'created_via': 'customer_app_fix',
            },
            'created_at': now,
            'updated_at': now,
          };
          
          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(customerId)
              .set(customerData);
          
          debugPrint('✅ Created customer document: $customerId');
          _showSuccess('✅ Customer document created successfully!');
          
          // Sign out to clean up
          await auth.signOut();
          
        } else {
          _showError('❌ Firebase Auth user not found');
        }
      } catch (authError) {
        _showError('❌ Firebase Auth error: $authError');
      }
      
    } catch (e) {
      _showError('Error fixing customer document: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
