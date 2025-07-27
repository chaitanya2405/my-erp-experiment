// 🏪 SUPPLIER APP - MAIN ENTRY POINT
// Dedicated supplier business portal
// All supplier-specific functionality preserved from original system

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_erp_package/shared_erp_package.dart';
import 'screens/supplier_auth_screen.dart';
import 'screens/supplier_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const SupplierApp());
}

class SupplierApp extends StatelessWidget {
  const SupplierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers for supplier state management
        ChangeNotifierProvider(create: (_) => SupplierAppState()),
      ],
      child: MaterialApp(
        title: 'ERP Supplier Portal',
        theme: SharedERPThemes.lightTheme.copyWith(
          // Supplier-specific theme customizations
          colorScheme: SharedERPThemes.lightTheme.colorScheme.copyWith(
            primary: SharedERPDesignSystem.accentCyan,
          ),
        ),
        darkTheme: SharedERPThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        
        // Check if supplier is already signed in
        home: const SupplierAppWrapper(),
      ),
    );
  }
}

// App Wrapper to handle authentication state
class SupplierAppWrapper extends StatelessWidget {
  const SupplierAppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SharedLoadingWidget(message: 'Loading Supplier Portal...'),
          );
        }
        
        if (snapshot.hasData) {
          // User is signed in, show dashboard
          return const SupplierDashboardScreen();
        } else {
          // User is not signed in, show auth screen
          return const SupplierAuthScreen();
        }
      },
    );
  }
}

// Supplier App State Management
class SupplierAppState extends ChangeNotifier {
  Supplier? _currentSupplier;
  List<PurchaseOrder> _purchaseOrders = [];
  List<PurchaseOrder> _pendingOrders = [];
  bool _isLoading = false;

  // Getters
  Supplier? get currentSupplier => _currentSupplier;
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  List<PurchaseOrder> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;

  // Set current supplier
  void setCurrentSupplier(Supplier supplier) {
    _currentSupplier = supplier;
    notifyListeners();
  }

  // Load supplier purchase orders
  Future<void> loadPurchaseOrders() async {
    if (_currentSupplier == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _purchaseOrders = await PurchaseOrdersService.getSupplierPurchaseOrders(_currentSupplier!.supplierId);
      _pendingOrders = await PurchaseOrdersService.getPendingPurchaseOrders(_currentSupplier!.supplierId);
    } catch (e) {
      debugPrint('Error loading purchase orders: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Update purchase order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? remarks,
    DateTime? expectedDeliveryDate,
  }) async {
    final success = await PurchaseOrdersService.updatePurchaseOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      remarks: remarks,
      expectedDeliveryDate: expectedDeliveryDate,
    );
    
    if (success) {
      // Refresh orders
      await loadPurchaseOrders();
    }
    
    return success;
  }

  // Sign out supplier
  Future<void> signOut() async {
    await SupplierAuthService.signOut();
    _currentSupplier = null;
    _purchaseOrders = [];
    _pendingOrders = [];
    notifyListeners();
  }
}
