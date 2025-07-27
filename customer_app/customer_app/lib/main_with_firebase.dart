// 👤 CUSTOMER APP - MAIN ENTRY POINT
// Dedicated customer shopping experience
// All customer-specific functionality preserved from original system

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_erp_package/shared_erp_package.dart';
import 'screens/customer_auth_screen.dart';
import 'screens/customer_dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for demo purposes
  }
  
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers for customer state management
        ChangeNotifierProvider(create: (_) => CustomerAppState()),
      ],
      child: MaterialApp(
        title: 'ERP Customer Portal',
        theme: SharedERPThemes.lightTheme,
        darkTheme: SharedERPThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        
        // Check if customer is already signed in
        home: const CustomerAppWrapper(),
      ),
    );
  }
}

// App Wrapper to handle authentication state
class CustomerAppWrapper extends StatelessWidget {
  const CustomerAppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SharedLoadingWidget(message: 'Loading Customer Portal...'),
          );
        }
        
        if (snapshot.hasData) {
          // User is signed in, show dashboard
          return const CustomerDashboardScreen();
        } else {
          // User is not signed in, show auth screen
          return const CustomerAuthScreen();
        }
      },
    );
  }
}

// Customer App State Management
class CustomerAppState extends ChangeNotifier {
  CustomerProfile? _currentCustomer;
  List<CustomerOrder> _customerOrders = [];
  List<Product> _products = [];
  bool _isLoading = false;

  // Getters
  CustomerProfile? get currentCustomer => _currentCustomer;
  List<CustomerOrder> get customerOrders => _customerOrders;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Set current customer
  void setCurrentCustomer(CustomerProfile customer) {
    _currentCustomer = customer;
    notifyListeners();
  }

  // Load customer orders
  Future<void> loadCustomerOrders() async {
    if (_currentCustomer == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _customerOrders = await CustomerOrdersService.getCustomerOrders(_currentCustomer!.customerId);
    } catch (e) {
      debugPrint('Error loading customer orders: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Load products for shopping
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await ProductsService.getAllProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Sign out customer
  Future<void> signOut() async {
    await CustomerAuthService.signOut();
    _currentCustomer = null;
    _customerOrders = [];
    _products = [];
    notifyListeners();
  }
}
