// 🌐 WEB-ONLY MAIN ENTRY POINT
// Firebase-Auth-free entry point for web builds with full featured dashboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import web-only models
import 'models/web_models.dart';

// Import web-only providers
import 'providers/web_cart_provider.dart';
import 'providers/web_customer_state_provider.dart';
import 'providers/web_product_provider.dart';
import 'providers/web_order_provider.dart';

// Import web-compatible services
import 'services/web_local_service.dart';

// Import screens for full functionality
import 'screens/web_dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize web-compatible service (local demo)
  try {
    await WebCompatibleFirebaseService.initialize();
  } catch (e) {
    print('⚠️ Service initialization failed: $e');
    // Continue without service for demo
  }

  runApp(const CustomerAppWeb());
}

class CustomerAppWeb extends StatelessWidget {
  const CustomerAppWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebCartProvider()),
        ChangeNotifierProvider(create: (_) => WebCustomerStateProvider()),
        ChangeNotifierProvider(create: (_) => WebProductProvider()),
        ChangeNotifierProvider(create: (_) => WebOrderProvider()),
      ],
      child: MaterialApp(
        title: 'ERP Customer App - Web Demo',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const WebAppInitializer(),
      ),
    );
  }
}

class WebAppInitializer extends StatefulWidget {
  const WebAppInitializer({super.key});

  @override
  State<WebAppInitializer> createState() => _WebAppInitializerState();
}

class _WebAppInitializerState extends State<WebAppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebDemo();
    });
  }

  void _initializeWebDemo() {
    final productProvider = Provider.of<WebProductProvider>(context, listen: false);
    final customerProvider = Provider.of<WebCustomerStateProvider>(context, listen: false);
    final orderProvider = Provider.of<WebOrderProvider>(context, listen: false);

    // Initialize providers like we had before
    productProvider.initialize();
    customerProvider.createDemoCustomer(); // This will create "John" like before
    orderProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebCustomerStateProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Customer App...'),
                ],
              ),
            ),
          );
        }

        // Auto-login demo customer (like John) and go to dashboard
        if (customerProvider.hasCustomer) {
          return const WebDashboardScreen();
        }

        // Fallback login screen
        return const WebLoginScreen();
      },
    );
  }
}

class WebLoginScreen extends StatelessWidget {
  const WebLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Customer ERP Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Web Demo Version',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Create demo customer like John
                    context.read<WebCustomerStateProvider>().createDemoCustomer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Enter as Demo Customer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebDemoHome extends StatefulWidget {
  const WebDemoHome({super.key});

  @override
  State<WebDemoHome> createState() => _WebDemoHomeState();
}

class _WebDemoHomeState extends State<WebDemoHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    final productProvider = Provider.of<WebProductProvider>(context, listen: false);
    final customerProvider = Provider.of<WebCustomerStateProvider>(context, listen: false);
    final orderProvider = Provider.of<WebOrderProvider>(context, listen: false);

    // Initialize providers
    productProvider.initialize();
    customerProvider.createDemoCustomer();
    orderProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP Customer App - Web Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer3<WebProductProvider, WebCustomerStateProvider, WebCartProvider>(
        builder: (context, productProvider, customerProvider, cartProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 80,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '🌐 Web Demo Mode',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Firebase Auth Web plugin compatibility issues resolved!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Status Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        'Products Loaded',
                        '${productProvider.allProducts.length}',
                        Icons.inventory,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatusCard(
                        'Cart Items',
                        '${cartProvider.itemCount}',
                        Icons.shopping_cart,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatusCard(
                        'Customer',
                        customerProvider.hasCustomer ? 'Active' : 'None',
                        Icons.person,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Featured Products
                const Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productProvider.featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.featuredProducts[index];
                      return _buildProductCard(product, cartProvider);
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Demo Features
                const Text(
                  'Demo Features Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✅ Product browsing and management'),
                        SizedBox(height: 5),
                        Text('✅ Shopping cart functionality'),
                        SizedBox(height: 5),
                        Text('✅ Order processing'),
                        SizedBox(height: 5),
                        Text('✅ Customer state management'),
                        SizedBox(height: 5),
                        Text('✅ Firestore data operations'),
                        SizedBox(height: 5),
                        Text('✅ Web-compatible authentication stub'),
                        SizedBox(height: 5),
                        Text('✅ All providers functional with local models'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildProductCard(WebProduct product, WebCartProvider cartProvider) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'SKU: ${product.sku}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cartProvider.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
