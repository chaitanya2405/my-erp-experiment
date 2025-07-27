// 🌐 WEB-REAL MAIN ENTRY POINT
// Entry point for testing real Firestore integration

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import web-only models
import 'models/web_models.dart';

// Import real web providers
import 'providers/web_cart_provider.dart';
import 'providers/web_customer_state_provider_real.dart';
import 'providers/web_product_provider_real.dart';
import 'providers/web_order_provider_real.dart';

// Import screens for full functionality
import 'screens/web_dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for real integration testing
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const CustomerAppWebReal());
}

class CustomerAppWebReal extends StatelessWidget {
  const CustomerAppWebReal({super.key});

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
        title: 'ERP Customer App - Real Integration',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const WebDashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
