// Supplier Portal Interface - Supplier-centric purchase order management
// This simulates a supplier portal for managing purchase orders, inventory, and deliveries

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/supplier_auth_service.dart';
import '../services/supplier_purchase_orders_service.dart';
import '../services/enhanced_services.dart';
import '../models/original_models.dart';

class SupplierPortalScreen extends StatefulWidget {
  const SupplierPortalScreen({Key? key}) : super(key: key);

  @override
  State<SupplierPortalScreen> createState() => _SupplierPortalScreenState();
}

class _SupplierPortalScreenState extends State<SupplierPortalScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  Supplier? _currentSupplier;
  final List<PurchaseOrder> _purchaseOrders = [];
  final List<PurchaseOrder> _pendingOrders = [];
  bool _isLoading = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadSupplierData() async {
    if (_currentSupplier == null) return;
    
    setState(() => _isLoading = true);
    try {
      // Load purchase orders
      final orders = await SupplierPurchaseOrdersService.getSupplierPurchaseOrders(_currentSupplier!.supplierId);
      final pending = await SupplierPurchaseOrdersService.getPendingPurchaseOrders(_currentSupplier!.supplierId);
      
      setState(() {
        _purchaseOrders.clear();
        _purchaseOrders.addAll(orders);
        _pendingOrders.clear();
        _pendingOrders.addAll(pending);
      });
    } catch (e) {
      _showError('Failed to load supplier data: $e');
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
        title: const Text('🏭 Supplier Portal'),
        backgroundColor: Colors.orange.shade700,
        actions: [
          if (_currentSupplier != null) ...[
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (_pendingOrders.isNotEmpty)
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
                          '${_pendingOrders.length}',
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
              onPressed: () => setState(() => _selectedTab = 1),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ],
      ),
      body: _currentSupplier == null 
          ? _buildAuthSection()
          : _buildMainPortal(),
      bottomNavigationBar: _currentSupplier != null
          ? BottomNavigationBar(
              currentIndex: _selectedTab,
              onTap: (index) => setState(() => _selectedTab = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.orange.shade700,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Purchase Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory),
                  label: 'Inventory',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping),
                  label: 'Deliveries',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Analytics',
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
            color: Colors.orange.shade50,
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
            '🏭 Supplier Portal',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to your supplier dashboard',
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          // Quick access buttons for demo
          const Text('Quick Access (Demo)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),              Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _signIn('supplier1@email.com', 'password'),
                  child: const Text('Demo Supplier 1'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _signIn('supplier2@email.com', 'password'),
                  child: const Text('Demo Supplier 2'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final supplierNameController = TextEditingController();
    final contactPersonController = TextEditingController();
    final mobileController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();
    final gstinController = TextEditingController();
    
    String selectedSupplierType = 'Manufacturer';
    final supplierTypes = ['Manufacturer', 'Distributor', 'Wholesaler', 'Retailer', 'Service Provider'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              '📝 Supplier Registration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: supplierNameController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contactPersonController,
              decoration: const InputDecoration(
                labelText: 'Contact Person Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setStateLocal) => DropdownButtonFormField<String>(
                value: selectedSupplierType,
                decoration: const InputDecoration(
                  labelText: 'Supplier Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: supplierTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  setStateLocal(() => selectedSupplierType = value!);
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: stateController,
                    decoration: const InputDecoration(
                      labelText: 'State *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Pincode *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: gstinController,
                    decoration: const InputDecoration(
                      labelText: 'GSTIN (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _signUp(
                email: emailController.text,
                password: passwordController.text,
                supplierName: supplierNameController.text,
                contactPerson: contactPersonController.text,
                mobile: mobileController.text,
                supplierType: selectedSupplierType,
                address: addressController.text,
                city: cityController.text,
                state: stateController.text,
                pincode: pincodeController.text,
                gstin: gstinController.text.isEmpty ? null : gstinController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Register as Supplier', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPortal() {
    switch (_selectedTab) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildPurchaseOrders();
      case 2:
        return _buildInventory();
      case 3:
        return _buildDeliveries();
      case 4:
        return _buildAnalytics();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '👋 Welcome back!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentSupplier?.supplierName ?? 'Supplier',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${_currentSupplier?.supplierId ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Orders',
                  '${_pendingOrders.length}',
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Orders',
                  '${_purchaseOrders.length}',
                  Icons.shopping_cart,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent purchase orders
          if (_purchaseOrders.isNotEmpty) ...[
            const Text(
              'Recent Purchase Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(_purchaseOrders.take(3).map((order) => _buildOrderCard(order))),
          ],

          // Quick actions
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard('View Purchase Orders', Icons.assignment, () {
                setState(() => _selectedTab = 1);
              }),
              _buildActionCard('Manage Inventory', Icons.inventory, () {
                setState(() => _selectedTab = 2);
              }),
              _buildActionCard('Track Deliveries', Icons.local_shipping, () {
                setState(() => _selectedTab = 3);
              }),
              _buildActionCard('View Analytics', Icons.analytics, () {
                setState(() => _selectedTab = 4);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.orange.shade700),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(PurchaseOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(
            _getStatusIcon(order.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text('PO #${order.poNumber}'),
        subtitle: Text('Total: ₹${order.totalValue.toStringAsFixed(2)}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order.status.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(order.status),
                fontSize: 12,
              ),
            ),
            Text(
              _formatDate(order.orderDate),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showOrderDetails(order),
      ),
    );
  }

  Widget _buildPurchaseOrders() {
    return Column(
      children: [
        // Filter tabs
        Container(
          color: Colors.grey.shade100,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'All (${_purchaseOrders.length})'),
              Tab(text: 'Pending (${_pendingOrders.length})'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(_purchaseOrders),
              _buildOrdersList(_pendingOrders),
              _buildOrdersList(_purchaseOrders.where((o) => o.status == 'completed').toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<PurchaseOrder> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(order.status),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: Colors.white,
                  ),
                ),
                title: Text('PO #${order.poNumber}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${_formatDate(order.orderDate)}'),
                    Text('Total: ₹${order.totalValue.toStringAsFixed(2)}'),
                    Text('Items: ${order.lineItems.length}'),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _showOrderDetails(order),
              ),
              if (order.status == 'pending' || order.status == 'confirmed') ...[
                const Divider(height: 1),
                ButtonBar(
                  children: [
                    if (order.status == 'pending')
                      TextButton.icon(
                        onPressed: () => _updateOrderStatus(order.poId, 'confirmed'),
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                      ),
                    if (order.status == 'pending')
                      TextButton.icon(
                        onPressed: () => _updateOrderStatus(order.poId, 'rejected'),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    if (order.status == 'confirmed')
                      TextButton.icon(
                        onPressed: () => _updateOrderStatus(order.poId, 'shipped'),
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Mark Shipped'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventory() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Inventory Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Coming soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDeliveries() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Delivery Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Coming soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Analytics & Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Coming soon...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Authentication methods
  Future<void> _signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await SupplierAuthService.signInSupplier(
        email: email,
        password: password,
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _currentSupplier = result['supplier'];
        });
        _showSuccess('Welcome back, ${_currentSupplier!.supplierName}!');
        await _loadSupplierData();
      } else {
        _showError(result?['error'] ?? 'Sign in failed');
      }
    } catch (e) {
      _showError('Sign in failed: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _signUp({
    required String email,
    required String password,
    required String supplierName,
    required String contactPerson,
    required String mobile,
    required String supplierType,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? gstin,
  }) async {
    if (email.isEmpty || password.isEmpty || supplierName.isEmpty || 
        contactPerson.isEmpty || mobile.isEmpty || address.isEmpty ||
        city.isEmpty || state.isEmpty || pincode.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await SupplierAuthService.registerSupplier(
        email: email,
        password: password,
        supplierName: supplierName,
        contactPersonName: contactPerson,
        contactPersonMobile: mobile,
        supplierType: supplierType,
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        gstin: gstin,
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _currentSupplier = result['supplier'];
        });
        _showSuccess('Registration successful! Welcome ${_currentSupplier!.supplierName}!');
        await _loadSupplierData();
      } else {
        _showError(result?['error'] ?? 'Registration failed');
      }
    } catch (e) {
      _showError('Registration failed: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    setState(() {
      _currentSupplier = null;
      _purchaseOrders.clear();
      _pendingOrders.clear();
      _selectedTab = 0;
    });
    await FirebaseAuth.instance.signOut();
    _showSuccess('Logged out successfully');
  }

  // Order management methods
  void _showOrderDetails(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PO #${order.poNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${order.status.toUpperCase()}'),
              Text('Date: ${_formatDate(order.orderDate)}'),
              Text('Total: ₹${order.totalValue.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.lineItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• ${item.productName} x ${item.quantity} @ ₹${item.unitCost}'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final success = await SupplierPurchaseOrdersService.updatePurchaseOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        remarks: 'Updated by supplier portal',
      );
      
      if (success) {
        _showSuccess('Order status updated to $newStatus');
        await _loadSupplierData();
      } else {
        _showError('Failed to update order status');
      }
    } catch (e) {
      _showError('Error updating order: $e');
    }
    setState(() => _isLoading = false);
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
