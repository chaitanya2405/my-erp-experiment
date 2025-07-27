import 'package:flutter/material.dart';
import 'activity_tracker.dart';

/// Navigation wrapper that automatically tracks screen transitions and file usage
class TrackedNavigator {
  static final ActivityTracker _tracker = ActivityTracker();

  /// Push a new screen with automatic tracking
  static Future<T?> push<T extends Object?>(
    BuildContext context, {
    required Widget screen,
    required String screenName,
    required List<String> relatedFiles,
    Map<String, dynamic>? parameters,
    String? routeName,
  }) {
    // Track navigation
    _tracker.trackNavigation(
      screenName: screenName,
      routeName: routeName ?? '/$screenName',
      parameters: parameters,
      relatedFiles: relatedFiles,
    );

    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => TrackedScreen(
          screenName: screenName,
          relatedFiles: relatedFiles,
          child: screen,
        ),
        settings: RouteSettings(name: routeName ?? '/$screenName'),
      ),
    );
  }

  /// Push and replace with tracking
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context, {
    required Widget screen,
    required String screenName,
    required List<String> relatedFiles,
    Map<String, dynamic>? parameters,
    String? routeName,
    TO? result,
  }) {
    _tracker.trackNavigation(
      screenName: screenName,
      routeName: routeName ?? '/$screenName',
      parameters: parameters,
      relatedFiles: relatedFiles,
    );

    return Navigator.of(context).pushReplacement<T, TO>(
      MaterialPageRoute(
        builder: (_) => TrackedScreen(
          screenName: screenName,
          relatedFiles: relatedFiles,
          child: screen,
        ),
        settings: RouteSettings(name: routeName ?? '/$screenName'),
      ),
      result: result,
    );
  }

  /// Push named route with tracking
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context, {
    required String routeName,
    required String screenName,
    required List<String> relatedFiles,
    Object? arguments,
  }) {
    _tracker.trackNavigation(
      screenName: screenName,
      routeName: routeName,
      parameters: arguments is Map<String, dynamic> ? arguments : null,
      relatedFiles: relatedFiles,
    );

    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pop with tracking
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    _tracker.trackInteraction(
      action: 'navigation_back',
      element: 'back_button',
    );
    Navigator.of(context).pop<T>(result);
  }
}

/// Screen wrapper that tracks interactions within the screen
class TrackedScreen extends StatefulWidget {
  final String screenName;
  final List<String> relatedFiles;
  final Widget child;

  const TrackedScreen({
    Key? key,
    required this.screenName,
    required this.relatedFiles,
    required this.child,
  }) : super(key: key);

  @override
  _TrackedScreenState createState() => _TrackedScreenState();
}

class _TrackedScreenState extends State<TrackedScreen> {
  final ActivityTracker _tracker = ActivityTracker();

  @override
  void initState() {
    super.initState();
    // Additional screen initialization tracking if needed
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Button wrapper that tracks interactions
class TrackedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String actionName;
  final String? elementId;
  final List<String>? filesInvolved;
  final Map<String, dynamic>? additionalData;

  const TrackedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.actionName,
    this.elementId,
    this.filesInvolved,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed != null ? () {
        ActivityTracker().trackInteraction(
          action: actionName,
          element: elementId,
          data: additionalData,
          filesInvolved: filesInvolved,
        );
        onPressed!();
      } : null,
      child: child,
    );
  }
}

/// ElevatedButton with tracking
class TrackedElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String actionName;
  final String? elementId;
  final List<String>? filesInvolved;
  final Map<String, dynamic>? additionalData;
  final ButtonStyle? style;

  const TrackedElevatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.actionName,
    this.elementId,
    this.filesInvolved,
    this.additionalData,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed != null ? () {
        ActivityTracker().trackInteraction(
          action: actionName,
          element: elementId,
          data: additionalData,
          filesInvolved: filesInvolved,
        );
        onPressed!();
      } : null,
      child: child,
    );
  }
}

/// Service call wrapper that tracks data operations
class TrackedService {
  static final ActivityTracker _tracker = ActivityTracker();

  /// Track Firestore operations
  static T trackFirestoreOperation<T>(
    String operation,
    T Function() serviceCall, {
    String? collection,
    String? documentId,
    Map<String, dynamic>? queryParams,
    required List<String> serviceFiles,
  }) {
    _tracker.trackDataOperation(
      operation: operation,
      collection: collection,
      documentId: documentId,
      queryParams: queryParams,
      serviceFiles: serviceFiles,
    );

    try {
      return serviceCall();
    } catch (e) {
      _tracker.trackError(
        error: e.toString(),
        affectedFiles: serviceFiles,
      );
      rethrow;
    }
  }

  /// Track async Firestore operations
  static Future<T> trackAsyncFirestoreOperation<T>(
    String operation,
    Future<T> Function() serviceCall, {
    String? collection,
    String? documentId,
    Map<String, dynamic>? queryParams,
    required List<String> serviceFiles,
  }) async {
    _tracker.trackDataOperation(
      operation: operation,
      collection: collection,
      documentId: documentId,
      queryParams: queryParams,
      serviceFiles: serviceFiles,
    );

    try {
      return await serviceCall();
    } catch (e) {
      _tracker.trackError(
        error: e.toString(),
        affectedFiles: serviceFiles,
      );
      rethrow;
    }
  }
}

/// File mapping constants for easy reference
class FileMapping {
  // Screen files
  static const String unifiedDashboard = 'lib/screens/unified_dashboard_screen.dart';
  static const String customerApp = 'lib/screens/customer_app_screen.dart';
  static const String supplierPortal = 'lib/screens/supplier_portal_screen.dart';
  
  // Module screen files
  static const String inventoryManagement = 'lib/modules/inventory_management/screens/inventory_management_screen.dart';
  static const String posModule = 'lib/modules/pos_management/screens/pos_module_screen.dart';
  static const String customerOrderModule = 'lib/modules/customer_order_management/screens/customer_order_module_screen.dart';
  static const String purchaseOrderModule = 'lib/modules/purchase_order_management/screens/purchase_order_module_screen.dart';
  static const String productManagement = 'lib/modules/product_management/screens/product_management_dashboard.dart';
  static const String storeManagement = 'lib/modules/store_management/screens/store_management_dashboard.dart';
  static const String crm = 'lib/modules/crm/screens/crm_screen.dart';
  static const String analytics = 'lib/modules/analytics/screens/analytics_screen.dart';
  
  // Service files
  static const String posService = 'lib/services/pos_service.dart';
  static const String inventoryService = 'lib/services/inventory_service.dart';
  static const String customerService = 'lib/services/customer_profile_service.dart';
  static const String productService = 'lib/services/product_service.dart';
  static const String storeService = 'lib/services/store_service.dart';
  static const String purchaseOrderService = 'lib/services/purchase_order_service.dart';
  
  // Modular service files
  static const String posModuleService = 'lib/modules/pos_management/services/pos_service.dart';
  static const String inventoryModuleService = 'lib/modules/inventory_management/services/inventory_service.dart';
  static const String customerModuleService = 'lib/modules/crm/services/customer_profile_service.dart';
  static const String productModuleService = 'lib/modules/product_management/services/product_service.dart';
  static const String storeModuleService = 'lib/modules/store_management/services/store_service.dart';
  
  // Provider files
  static const String appStateProvider = 'lib/providers/app_state_provider.dart';
  static const String posProvider = 'lib/providers/pos_provider.dart';
  
  // Model files
  static const String models = 'lib/models/';
  static const String posTransaction = 'lib/models/pos_transaction.dart';
  static const String inventoryItem = 'lib/models/inventory_item.dart';
  static const String customerProfile = 'lib/models/customer_profile.dart';
  static const String product = 'lib/models/product.dart';
  static const String store = 'lib/models/store_models.dart';
  static const String purchaseOrder = 'lib/models/purchase_order.dart';
  
  // Core files
  static const String main = 'lib/main.dart';
  static const String adminTools = 'lib/core/admin_tools.dart';
  static const String activityTracker = 'lib/core/activity_tracker.dart';
  static const String appServices = 'lib/app_services.dart';

  /// Get related files for a screen
  static List<String> getFilesForScreen(String screenName) {
    switch (screenName) {
      case 'UnifiedDashboard':
        return [unifiedDashboard, appStateProvider, posService, inventoryService];
      case 'InventoryManagement':
        return [inventoryManagement, inventoryModuleService, inventoryItem, appStateProvider];
      case 'POSModule':
        return [posModule, posModuleService, posTransaction, posProvider];
      case 'CustomerOrderModule':
        return [customerOrderModule, customerModuleService, customerProfile];
      case 'PurchaseOrderModule':
        return [purchaseOrderModule, purchaseOrderService, purchaseOrder];
      case 'ProductManagement':
        return [productManagement, productModuleService, product];
      case 'StoreManagement':
        return [storeManagement, storeModuleService, store];
      case 'CRM':
        return [crm, customerModuleService, customerProfile];
      case 'Analytics':
        return [analytics, posService, inventoryService, customerService];
      case 'CustomerApp':
        return [customerApp, customerService, customerProfile];
      case 'SupplierPortal':
        return [supplierPortal, purchaseOrderService, purchaseOrder];
      default:
        return [];
    }
  }
}
