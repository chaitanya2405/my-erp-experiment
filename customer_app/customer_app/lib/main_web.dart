// 🌐 WEB-COMPATIBLE MAIN ENTRY POINT
// Simplified entry point that avoids Firebase Auth web compatibility issues

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_erp_package/shared_erp_package.dart';

// Simplified providers without Firebase dependencies
import 'providers/cart_provider.dart';
import 'providers/customer_state_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';

// Simplified screens
import 'screens/dashboard/customer_dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const CustomerERPWebApp());
}

class CustomerERPWebApp extends StatelessWidget {
  const CustomerERPWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerStateProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Customer ERP',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const WebLandingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class WebLandingScreen extends StatelessWidget {
  const WebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer ERP Demo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Customer ERP System',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Web build successfully compiled!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Initialize demo customer
                final customerProvider = context.read<CustomerStateProvider>();
                final demoCustomer = Customer(
                  id: 'demo-customer',
                  name: 'Demo Customer',
                  email: 'demo@example.com', 
                  phone: '1234567890',
                  createdAt: DateTime.now(),
                  addresses: ['Demo Address, Demo City'],
                  loyaltyTier: 'Gold',
                  loyaltyPoints: 1250,
                  walletBalance: 150.0,
                );
                customerProvider.setCustomer(demoCustomer);
                
                // Navigate to dashboard
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const CustomerDashboardScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Enter Demo Dashboard',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This demonstrates the complete provider architecture\nand model integration working successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
