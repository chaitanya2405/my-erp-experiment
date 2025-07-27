import 'package:flutter/material.dart';

/// Common UI utilities and components for the Enhanced ERP System
class ERPUtils {
  
  /// Loading indicator widget
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Error widget with retry option
  static Widget errorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  /// Empty state widget
  static Widget emptyState({
    required String message,
    required IconData icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  /// Success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Format currency
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'received':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
      case 'overdue':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Get status icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'received':
      case 'paid':
        return Icons.check_circle;
      case 'pending':
      case 'processing':
        return Icons.schedule;
      case 'cancelled':
      case 'failed':
        return Icons.cancel;
      case 'draft':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  /// Responsive breakpoints
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Search functionality helper
  static bool matchesSearchQuery(String text, String query) {
    if (query.isEmpty) return true;
    return text.toLowerCase().contains(query.toLowerCase());
  }

  /// Calculate inventory value
  static double calculateInventoryValue(List<dynamic> products) {
    return products.fold(0.0, (sum, product) {
      final price = (product['price'] ?? 0.0) as double;
      final quantity = (product['quantity'] ?? 0) as int;
      return sum + (price * quantity);
    });
  }

  /// Get inventory status
  static String getInventoryStatus(int quantity, int? minStock) {
    if (quantity == 0) return 'Out of Stock';
    if (minStock != null && quantity <= minStock) return 'Low Stock';
    return 'In Stock';
  }

  /// Get inventory status color
  static Color getInventoryStatusColor(int quantity, int? minStock) {
    if (quantity == 0) return Colors.red;
    if (minStock != null && quantity <= minStock) return Colors.orange;
    return Colors.green;
  }

  /// Generate transaction ID
  static String generateTransactionId() {
    final now = DateTime.now();
    return 'TXN${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  /// Generate purchase order ID
  static String generatePurchaseOrderId() {
    final now = DateTime.now();
    return 'PO${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// Calculate discount amount
  static double calculateDiscountAmount(double total, double discountPercent) {
    return total * (discountPercent / 100);
  }

  /// Calculate tax amount
  static double calculateTaxAmount(double amount, double taxPercent) {
    return amount * (taxPercent / 100);
  }

  /// Get business insights text
  static String getBusinessInsight(String metric, double value) {
    switch (metric) {
      case 'revenue':
        if (value > 100000) return 'Excellent revenue performance!';
        if (value > 50000) return 'Good revenue growth';
        return 'Revenue needs attention';
      case 'orders':
        if (value > 100) return 'High order volume!';
        if (value > 50) return 'Steady order flow';
        return 'Low order activity';
      case 'customers':
        if (value > 500) return 'Large customer base!';
        if (value > 100) return 'Growing customer base';
        return 'Focus on customer acquisition';
      default:
        return 'Monitor this metric closely';
    }
  }
}

/// Custom page route with slide animation
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;

  SlidePageRoute({
    required this.page,
    this.beginOffset = const Offset(1.0, 0.0),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
