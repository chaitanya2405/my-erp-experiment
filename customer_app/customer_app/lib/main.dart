// � WEB-ONLY MAIN ENTRY POINT
// Firebase-Auth-free entry point for web builds with full featured dashboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import web-only models
import 'models/web_models.dart';

// Import web-only providers (real data)
import 'providers/web_cart_provider.dart';
import 'providers/web_customer_state_provider_real.dart';
import 'providers/web_product_provider_real.dart';
import 'providers/web_order_provider_real.dart';

// Import screens for full functionality
import 'screens/web_dashboard_screen.dart';
import 'utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your real project
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Connected to real Firebase project: ravali-software');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    // Continue without Firebase for demo
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
        ChangeNotifierProvider(create: (_) => WebCustomerStateProviderReal()),
        ChangeNotifierProvider(create: (_) => WebProductProviderReal()),
        ChangeNotifierProvider(create: (_) => WebOrderProviderReal()),
      ],
      child: MaterialApp(
        title: 'ERP Customer App - Web Demo',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const WebAppWrapper(),
      ),
    );
  }
}

class WebAppWrapper extends StatefulWidget {
  const WebAppWrapper({super.key});

  @override
  State<WebAppWrapper> createState() => _WebAppWrapperState();
}

class _WebAppWrapperState extends State<WebAppWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDemo();
    });
  }

  Future<void> _initializeDemo() async {
    // Load real customer and data from Firestore
    final customerProvider = context.read<WebCustomerStateProviderReal>();
    final productProvider = context.read<WebProductProviderReal>();
    final orderProvider = context.read<WebOrderProviderReal>();

    try {
      print('🔄 Loading real data from Firestore...');
      
      // Load customer first (John or fallback)
      await customerProvider.initialize();
      
      // Load products from Firestore
      await productProvider.loadProducts();

      // Load orders for the current customer
      if (customerProvider.currentCustomer != null) {
        await orderProvider.initialize(customerProvider.currentCustomer!.id);
        print('✅ Real data loaded for customer: ${customerProvider.currentCustomer!.name}');
      } else {
        print('⚠️ No customer found, using fallback data');
      }
    } catch (e) {
      print('❌ Error loading real data: $e');
      // App will continue with fallback/demo data if real data fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebCustomerStateProviderReal>(
      builder: (context, customerProvider, child) {
        if (customerProvider.currentCustomer != null) {
          // Show dashboard if customer is logged in
          return const WebDashboardScreen();
        } else {
          // Show simple loading for now, could be a login screen
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Demo...'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
