// 🏠 WEB DASHBOARD SCREEN
// Main dashboard for web demo with full functionality like the original

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/web_cart_provider.dart';
import '../providers/web_customer_state_provider_real.dart';
import '../providers/web_product_provider_real.dart';
import '../providers/web_order_provider_real.dart';
import '../models/web_models.dart';
import '../services/store_id_migration_service.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize all providers with real Firestore data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    print('🚀 Initializing providers with real Firestore data...');
    
    try {
      // First, run migration to update old store IDs
      print('🔧 Running store ID migration...');
      await StoreIdMigrationService.migrateStoreIds();
      
      // Initialize customer provider with a real customer ID
      final customerProvider = Provider.of<WebCustomerStateProviderReal>(context, listen: false);
      await customerProvider.initialize();
      
      // Initialize product provider to load real products
      final productProvider = Provider.of<WebProductProviderReal>(context, listen: false);
      await productProvider.initialize();
      
      // Initialize order provider with customer ID from customer provider
      final orderProvider = Provider.of<WebOrderProviderReal>(context, listen: false);
      if (customerProvider.currentCustomer != null) {
        await orderProvider.initialize(customerProvider.currentCustomer!.id);
      }
      
      print('✅ All providers initialized with real Firestore data');
    } catch (e) {
      print('❌ Error initializing providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP Customer Portal'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Cart icon with badge
          Consumer<WebCartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2; // Switch to cart tab
                      });
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Profile menu
          Consumer<WebCustomerStateProviderReal>(
            builder: (context, customerProvider, child) {
              final customer = customerProvider.currentCustomer;
              return PopupMenuButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    customer?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(customer?.name ?? 'User'),
                      subtitle: Text(customer?.email ?? ''),
                    ),
                  ),
                  const PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Consumer<WebCartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const _WebHomeTab();
      case 1:
        return const _WebProductsTab();
      case 2:
        return const _WebCartTab();
      case 3:
        return const _WebOrdersTab();
      case 4:
        return const _WebProfileTab();
      default:
        return const _WebHomeTab();
    }
  }
}

// Home Tab
class _WebHomeTab extends StatelessWidget {
  const _WebHomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer3<WebCustomerStateProviderReal, WebProductProviderReal, WebOrderProviderReal>(
      builder: (context, customerProvider, productProvider, orderProvider, child) {
        final customer = customerProvider.currentCustomer;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${customer?.name ?? 'Customer'}! 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Membership: ${customer?.membershipTier ?? 'Silver'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      '${customer?.totalOrders ?? 0}',
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Spent',
                      '₹${customer?.totalSpent.toStringAsFixed(0) ?? '0'}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent Orders
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...customerProvider.recentOrders.take(3).map((order) => 
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order.status),
                      child: const Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: Text('Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}'),
                    subtitle: Text('${order.status.toUpperCase()} • ₹${order.totalAmount}'),
                    trailing: Text(
                      _formatDate(order.orderDate),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              ),
              const SizedBox(height: 16),

              // Featured Products
              const Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProvider.featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.featuredProducts[index];
                    return _buildFeaturedProductCard(context, product);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductCard(BuildContext context, WebProduct product) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '₹${product.price}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<WebCartProvider>().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} added to cart')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
      case 'in_transit':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Products Tab
class _WebProductsTab extends StatelessWidget {
  const _WebProductsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WebProductProviderReal>(
      builder: (context, productProvider, child) {
        return Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        productProvider.searchProducts(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (category) {
                      productProvider.filterByCategory(category == 'all' ? null : category);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'all', child: Text('All Categories')),
                      const PopupMenuItem(value: 'electronics', child: Text('Electronics')),
                      const PopupMenuItem(value: 'furniture', child: Text('Furniture')),
                    ],
                  ),
                ],
              ),
            ),
            
            // Products grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return _buildProductCard(context, product);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, WebProduct product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${product.price}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<WebCartProvider>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Cart Tab
class _WebCartTab extends StatelessWidget {
  const _WebCartTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WebCartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add some products to get started!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.items[index];
                  return _buildCartItem(context, item, cartProvider);
                },
              ),
            ),
            _buildCartSummary(context, cartProvider),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, WebCartItem item, WebCartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${item.price} each',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (item.quantity > 1) {
                      cartProvider.updateQuantity(item.id, item.quantity - 1);
                    } else {
                      cartProvider.removeFromCart(item.id);
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('${item.quantity}'),
                IconButton(
                  onPressed: () {
                    cartProvider.updateQuantity(item.id, item.quantity + 1);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, WebCartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('₹${cartProvider.subtotal.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax:'),
              Text('₹${cartProvider.tax.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping:'),
              Text('₹${cartProvider.shipping.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                '₹${cartProvider.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _proceedToCheckout(context, cartProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, WebCartProvider cartProvider) {
    // Create order
    final orderProvider = context.read<WebOrderProviderReal>();
    final customerProvider = context.read<WebCustomerStateProviderReal>();
    final customer = customerProvider.currentCustomer!;
    
    // Convert cart items to order items
    final orderItems = cartProvider.items.map((cartItem) => WebOrderItem(
      id: cartItem.productId,
      productId: cartItem.productId,
      productName: cartItem.productName,
      productImage: cartItem.productImage,
      price: cartItem.price,
      quantity: cartItem.quantity,
      totalPrice: cartItem.totalPrice,
    )).toList();
    
    // Calculate totals
    final subtotal = cartProvider.subtotal;
    final tax = subtotal * 0.1; // 10% tax
    final shipping = 50.0; // Fixed shipping
    final total = subtotal + tax + shipping;

    orderProvider.createOrder(
      customerId: customer.id,
      customerName: customer.name,
      customerEmail: customer.email,
      items: orderItems,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      shippingAddress: customer.address ?? '',
      paymentMethod: 'card',
      notes: 'Web order',
    );

    // Clear cart
    cartProvider.clearCart();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Orders Tab
class _WebOrdersTab extends StatelessWidget {
  const _WebOrdersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WebOrderProviderReal>(
      builder: (context, orderProvider, child) {
        final orders = orderProvider.orders;

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Your order history will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(context, order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, WebOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total: ₹${order.totalAmount}'),
            Text('Payment: ${order.paymentMethod.toUpperCase()}'),
            Text('Date: ${_formatDate(order.orderDate)}'),
            if (order.expectedDeliveryDate != null)
              Text('Expected: ${_formatDate(order.expectedDeliveryDate!)}'),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
      case 'in_transit':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Profile Tab
class _WebProfileTab extends StatelessWidget {
  const _WebProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WebCustomerStateProviderReal>(
      builder: (context, customerProvider, child) {
        final customer = customerProvider.currentCustomer;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          customer?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        customer?.name ?? 'Demo User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        customer?.email ?? 'demo@example.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Text(
                            '${customer?.membershipTier ?? 'Silver'} Member',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      '${customer?.totalOrders ?? 0}',
                      Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Spent',
                      '₹${customer?.totalSpent.toStringAsFixed(0) ?? '0'}',
                      Icons.currency_rupee,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Menu Items
              Card(
                child: Column(
                  children: [
                    _buildMenuItem(Icons.edit, 'Edit Profile', () {}),
                    _buildMenuItem(Icons.location_on, 'Addresses', () {}),
                    _buildMenuItem(Icons.payment, 'Payment Methods', () {}),
                    _buildMenuItem(Icons.notifications, 'Notifications', () {}),
                    _buildMenuItem(Icons.help, 'Help & Support', () {}),
                    _buildMenuItem(Icons.logout, 'Logout', () {}),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
