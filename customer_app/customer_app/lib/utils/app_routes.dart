// 🛣️ APP ROUTES - CUSTOMER ERP NAVIGATION
// Complete routing system for customer app

import 'package:flutter/material.dart';
import 'package:shared_erp_package/shared_erp_package.dart';

// Import all screens
import '../screens/auth/customer_auth_screen.dart';
import '../screens/dashboard/customer_dashboard_screen.dart';
import '../screens/products/product_catalog_screen.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/cart/shopping_cart_screen.dart';
import '../screens/profile/customer_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/support/customer_support_screen.dart';
import '../screens/support/ticket_detail_screen.dart';
import '../screens/settings/app_settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  // Route names
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String productDetail = '/product-detail';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String support = '/support';
  static const String ticketDetail = '/ticket-detail';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Route map
  static Map<String, WidgetBuilder> get routes {
    return {
      auth: (context) => const CustomerAuthScreen(),
      dashboard: (context) => const CustomerDashboardScreen(),
      products: (context) => const ProductCatalogScreen(),
      productDetail: (context) => const ProductDetailScreen(),
      orders: (context) => const OrderHistoryScreen(),
      orderDetail: (context) => const OrderDetailScreen(),
      cart: (context) => const ShoppingCartScreen(),
      profile: (context) => const CustomerProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      support: (context) => const CustomerSupportScreen(),
      ticketDetail: (context) => const TicketDetailScreen(),
      settings: (context) => const AppSettingsScreen(),
      notifications: (context) => const NotificationsScreen(),
    };
  }

  // Generate route for dynamic routing
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productDetail:
        final product = settings.arguments as Product?;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        );
        
      case orderDetail:
        final order = settings.arguments as Order?;
        return MaterialPageRoute(
          builder: (context) => OrderDetailScreen(order: order),
        );
        
      case ticketDetail:
        final ticketId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => TicketDetailScreen(ticketId: ticketId),
        );
        
      default:
        return MaterialPageRoute(
          builder: (context) => const _NotFoundScreen(),
        );
    }
  }

  // Navigation helpers
  static void pushDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      dashboard,
      (route) => false,
    );
  }

  static void pushAuth(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      auth,
      (route) => false,
    );
  }

  static void pushProduct(BuildContext context, String productId) {
    Navigator.pushNamed(
      context,
      productDetail,
      arguments: productId,
    );
  }

  static void pushOrder(BuildContext context, String orderId) {
    Navigator.pushNamed(
      context,
      orderDetail,
      arguments: orderId,
    );
  }

  static void pushCart(BuildContext context) {
    Navigator.pushNamed(context, cart);
  }

  static void pushSupport(BuildContext context) {
    Navigator.pushNamed(context, support);
  }
}

// 404 Screen
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The page you requested could not be found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
