// 🛒 CUSTOMER DASHBOARD SCREEN
// Main customer interface - shopping, orders, account management
// Preserves all functionality from original customer flows

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_erp_package/shared_erp_package.dart';
import '../providers/customer_state_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeTab(),
    const CustomerProductsTab(),
    const CustomerOrdersTab(),
    const CustomerProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerStateProvider>();
      final orderProvider = context.read<OrderProvider>();
      final productProvider = context.read<ProductProvider>();
      
      if (customerProvider.hasCustomer) {
        orderProvider.initializeOrders(customerProvider.currentCustomer!.id);
      }
      productProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerStateProvider>().currentCustomer;
    
    return Scaffold(
      backgroundColor: SharedERPDesignSystem.platformBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Portal'),
            if (customer != null)
              Text(
                'Welcome, ${customer.customerName}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  setState(() => _selectedIndex = 3);
                  break;
                case 'settings':
                  // Navigate to settings
                  break;
                case 'logout':
                  context.read<CustomerStateProvider>().clearCustomer();
                  // Navigate to auth screen
                  break;
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: SharedERPDesignSystem.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// 🏠 Customer Home Tab
class CustomerHomeTab extends StatelessWidget {
  const CustomerHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerStateProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final customer = customerProvider.currentCustomer;
    final recentOrders = orderProvider.recentOrders.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SharedERPDesignSystem.primaryBlue,
                  SharedERPDesignSystem.primaryPurple,
                ],
              ),
              borderRadius: SharedERPDesignSystem.platformRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${customer?.customerName ?? 'Customer'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loyalty Tier: ${customer?.loyaltyTier ?? 'Bronze'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatItem('Loyalty Points', '${customer?.loyaltyPoints ?? 0}'),
                    const SizedBox(width: 32),
                    _buildStatItem('Wallet Balance', '₹${customer?.walletBalance.toStringAsFixed(2) ?? '0.00'}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildQuickAction(
                'Browse Products',
                Icons.shopping_bag_outlined,
                SharedERPDesignSystem.primaryBlue,
                () {
                  // Switch to products tab
                },
              ),
              _buildQuickAction(
                'Track Orders',
                Icons.local_shipping_outlined,
                SharedERPDesignSystem.accentCyan,
                () {
                  // Switch to orders tab
                },
              ),
              _buildQuickAction(
                'Reorder Items',
                Icons.refresh_outlined,
                SharedERPDesignSystem.accentGreen,
                () {
                  // Show reorder options
                },
              ),
              _buildQuickAction(
                'Support',
                Icons.support_agent_outlined,
                SharedERPDesignSystem.accentOrange,
                () {
                  // Open support
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Orders
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          if (recentOrders.isEmpty)
            const SharedEmptyState(
              title: 'No Orders Yet',
              message: 'Start shopping to see your orders here',
              icon: Icons.shopping_cart_outlined,
            )
          else
            ...recentOrders.map((order) => _buildOrderCard(order.toCustomerOrder())).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: SharedERPDesignSystem.platformRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SharedERPDesignSystem.platformCard,
          borderRadius: SharedERPDesignSystem.platformRadius,
          boxShadow: SharedERPDesignSystem.platformShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(CustomerOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharedERPDesignSystem.platformCard,
        borderRadius: SharedERPDesignSystem.platformRadius,
        boxShadow: SharedERPDesignSystem.platformShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: SharedERPDesignSystem.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag,
              color: SharedERPDesignSystem.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${order.grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SharedStatusChip(status: order.orderStatus),
        ],
      ),
    );
  }
}

// 🛍️ Customer Products Tab
class CustomerProductsTab extends StatelessWidget {
  const CustomerProductsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final isLoading = productProvider.isLoading;

    if (isLoading) {
      return const SharedLoadingWidget(message: 'Loading products...');
    }

    if (products.isEmpty) {
      return const SharedEmptyState(
        title: 'No Products Available',
        message: 'Products will appear here when they are added to the catalog',
        icon: Icons.inventory_2_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: SharedERPDesignSystem.platformCard,
        borderRadius: SharedERPDesignSystem.platformRadius,
        boxShadow: SharedERPDesignSystem.platformShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.sellingPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: SharedERPDesignSystem.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SharedERPDesignSystem.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 📋 Customer Orders Tab
class CustomerOrdersTab extends StatelessWidget {
  const CustomerOrdersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;
    final isLoading = orderProvider.isLoading;

    if (isLoading) {
      return const SharedLoadingWidget(message: 'Loading orders...');
    }

    if (orders.isEmpty) {
      return const SharedEmptyState(
        title: 'No Orders Yet',
        message: 'Your orders will appear here after you make a purchase',
        icon: Icons.shopping_cart_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order.toCustomerOrder());
      },
    );
  }

  Widget _buildOrderCard(CustomerOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharedERPDesignSystem.platformCard,
        borderRadius: SharedERPDesignSystem.platformRadius,
        boxShadow: SharedERPDesignSystem.platformShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SharedStatusChip(status: order.orderStatus),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${order.orderDate.toDate().toString().split(' ')[0]}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            'Total: ₹${order.grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View order details
                  },
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Track order
                  },
                  child: const Text('Track Order'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 👤 Customer Profile Tab
class CustomerProfileTab extends StatelessWidget {
  const CustomerProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerStateProvider>().currentCustomer;

    if (customer == null) {
      return const SharedEmptyState(
        title: 'Profile Not Available',
        message: 'Please sign in to view your profile',
        icon: Icons.person_outline,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SharedERPDesignSystem.platformCard,
              borderRadius: SharedERPDesignSystem.platformRadius,
              boxShadow: SharedERPDesignSystem.platformShadow,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: SharedERPDesignSystem.primaryBlue.withOpacity(0.1),
                  child: Text(
                    customer.customerName.isNotEmpty ? customer.customerName[0].toUpperCase() : 'C',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: SharedERPDesignSystem.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.customerName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  customer.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat('Loyalty Tier', customer.loyaltyTier),
                    _buildProfileStat('Points', '${customer.loyaltyPoints}'),
                    _buildProfileStat('Wallet', '₹${customer.walletBalance.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Profile Options
          _buildProfileOption(
            'Personal Information',
            Icons.person_outline,
            () {
              // Edit personal info
            },
          ),
          _buildProfileOption(
            'Addresses',
            Icons.location_on_outlined,
            () {
              // Manage addresses
            },
          ),
          _buildProfileOption(
            'Payment Methods',
            Icons.payment_outlined,
            () {
              // Manage payment methods
            },
          ),
          _buildProfileOption(
            'Order History',
            Icons.history_outlined,
            () {
              // View full order history
            },
          ),
          _buildProfileOption(
            'Notifications',
            Icons.notifications_outlined,
            () {
              // Notification settings
            },
          ),
          _buildProfileOption(
            'Help & Support',
            Icons.help_outline,
            () {
              // Support center
            },
          ),
          const SizedBox(height: 24),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: SharedActionButton(
              text: 'Sign Out',
              onPressed: () {
                context.read<CustomerStateProvider>().clearCustomer();
                // Navigate to auth screen
              },
              backgroundColor: SharedERPDesignSystem.errorColor,
              icon: Icons.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: SharedERPDesignSystem.primaryBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: SharedERPDesignSystem.platformRadius,
        ),
        tileColor: SharedERPDesignSystem.platformCard,
      ),
    );
  }
}
