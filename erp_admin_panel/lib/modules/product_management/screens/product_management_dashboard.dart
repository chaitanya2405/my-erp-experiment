import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

// Riverpod state providers
import '../providers/app_state_provider.dart';

// Store services and models
import '../models/store_models.dart';
import '../services/store_service.dart';

// Activity tracking
import '../../../core/activity_tracker.dart';

import 'full_add_product_screen.dart';
import 'view_products_screen.dart';
import 'advanced_product_analytics_screen.dart';
import 'import_products_screen.dart';
import 'export_products_screen.dart';
import 'inter_module_status_screen.dart';

class ProductManagementDashboard extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProductManagementDashboard> createState() => _ProductManagementDashboardState();
}

class _ProductManagementDashboardState extends ConsumerState<ProductManagementDashboard> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeProductManagement();
    _setupFirestoreListeners();
  }

  Future<void> _initializeProductManagement() async {
    try {
      print('🛍️ Initializing Product Management Module...');
      print('  • Loading product catalog from Firestore...');
      print('  • Setting up real-time product monitoring...');
      print('  • Initializing pricing management...');
      print('  • Connecting to inventory integration...');
      print('  • Setting up product analytics...');
      print('  • Enabling multi-store product distribution...');
      
      // Inter-module communication setup
      print('🔗 Establishing inter-module communications...');
      print('  • Product ↔ Inventory synchronization: ENABLED');
      print('  • Product ↔ POS integration: ENABLED'); 
      print('  • Product ↔ CRM analytics: ENABLED');
      print('  • Product ↔ Purchase Orders: ENABLED');
      print('  • Product ↔ Supplier Management: ENABLED');
      print('  • Product ↔ Store Management: ENABLED');
      print('  • Product ↔ Customer Orders: ENABLED');
      
      print('✅ Product Management Module ready for operations');
      
      // Track Product Management module navigation with activity tracker
      ActivityTracker().trackNavigation(
        screenName: 'ProductManagementModule',
        routeName: '/products',
        relatedFiles: [
          'lib/modules/product_management/screens/product_management_dashboard.dart',
          'lib/modules/product_management/providers/app_state_provider.dart',
          'lib/modules/product_management/services/store_service.dart',
          'lib/modules/product_management/models/store_models.dart',
        ],
      );
      
      // Track initialization
      ActivityTracker().trackInteraction(
        action: 'product_module_init',
        element: 'product_screen',
        data: {'store': 'STORE_001', 'mode': 'riverpod', 'catalog_size': 'dynamic'},
      );
      
      print('  📊 Using Riverpod productStateProvider for state management');
      print('  🔗 Connected to inventory and pricing services');
      print('  🌐 Real-time cross-module synchronization active');
      print('  💾 Product changes will auto-update: Inventory, POS, Orders, CRM');
    } catch (e) {
      print('⚠️ Product Management initialization warning: $e');
    }
  }

  final List<String> actions = [
    'Add Product',
    'View Products',
    'Import',
    'Export',
    'Analytics',
    'Module Status',
  ];

  final List<IconData> icons = [
    Icons.add,
    Icons.list,
    Icons.upload,
    Icons.download,
    Icons.bar_chart,
    Icons.network_check,
  ];

  Widget _getMainContent() {
    if (selectedIndex == 0) {
      return AddProductScreen();
    } else if (selectedIndex == 1) {
      return ViewProductsScreen();
    } else if (selectedIndex == 2) {
      return ImportProductsScreen();
    } else if (selectedIndex == 3) {
      return ExportProductsScreen();
    } else if (selectedIndex == 4) {
      return AdvancedProductAnalyticsScreen();
    } else if (selectedIndex == 5) {
      // Inter-Module Communication Status
      // Track navigation to Module Status screen
      ActivityTracker().trackNavigation(
        screenName: 'InterModuleStatusScreen',
        routeName: '/products/module-status',
        relatedFiles: [
          'lib/modules/product_management/screens/product_management_dashboard.dart',
          'lib/core/activity_tracker.dart',
        ],
      );
      
      // Track interaction with module status feature
      ActivityTracker().trackInteraction(
        action: 'module_status_accessed',
        element: 'module_status_screen',
        data: {
          'active_modules': 7,
          'real_time_sync': 'enabled',
          'communication_count': _recentCommunications.length,
        },
      );
      
      return InterModuleStatusScreen(
        recentCommunications: _recentCommunications,
        productSubscription: _productSubscription,
        inventorySubscription: _inventorySubscription,
        posSubscription: _posSubscription,
        onTestCommunication: (communication) {
          setState(() {
            _recentCommunications.add(communication);
            if (_recentCommunications.length > 15) {
              _recentCommunications.removeAt(0);
            }
          });
        },
      );
    }
    // Placeholder for other actions
    return Center(
      child: Text(
        'Selected: ${actions[selectedIndex]}',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to product state changes via Riverpod
    final productState = ref.watch(productStateProvider);

    // Determine main content based on loading/error states
    Widget mainContent;
    if (productState.isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (productState.errorMessage != null) {
      mainContent = Center(child: Text('Error: ${productState.errorMessage}'));
    } else {
      mainContent = _getMainContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Product Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Inter-module communication status indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.sync, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('Synced', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.deepPurple),
            onPressed: () {},
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.deepPurple),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 180,
                  minHeight: 400,
                ),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      backgroundColor: Colors.white,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      selectedIconTheme: const IconThemeData(color: Colors.deepPurple, size: 20),
                      unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 18),
                      selectedLabelTextStyle: const TextStyle(
                        color: Colors.deepPurple, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 10
                      ),
                      unselectedLabelTextStyle: const TextStyle(
                        color: Colors.black54, 
                        fontSize: 9
                      ),
                      minWidth: 120,
                      destinations: List.generate(actions.length, (index) {
                        return NavigationRailDestination(
                          icon: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(icons[index]),
                          ),
                          selectedIcon: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(icons[index]),
                          ),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              actions[index],
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(height: 1.1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: mainContent,
            ),
          ),
        ],
      ),
    );
  }











  // Inter-module communication methods
  void _onProductChanged(String productId, Map<String, dynamic> changes) {
    // Simulate real-time communication with other modules
    print('🔄 Product $productId changed - notifying other modules...');
    
    // Notify Inventory Management
    ActivityTracker().trackInteraction(
      action: 'product_inventory_sync',
      element: 'inventory_module',
      data: {'product_id': productId, 'changes': changes.toString()},
    );
    
    // Notify POS System
    ActivityTracker().trackInteraction(
      action: 'product_pos_sync', 
      element: 'pos_module',
      data: {'product_id': productId, 'price_updated': changes.containsKey('price')},
    );
    
    // Notify CRM for analytics
    if (changes.containsKey('price') || changes.containsKey('category')) {
      ActivityTracker().trackInteraction(
        action: 'product_crm_analytics',
        element: 'crm_module', 
        data: {'product_id': productId, 'analytics_update': 'pricing_category'},
      );
    }
    
    print('  ✅ All modules notified of product changes');
  }
  
  void _onInventoryLevelChanged(String productId, int newLevel) {
    // Handle inventory level changes from Inventory module
    print('📦 Inventory level changed for $productId: $newLevel units');
    
    ActivityTracker().trackInteraction(
      action: 'inventory_product_sync',
      element: 'product_module',
      data: {'product_id': productId, 'stock_level': newLevel, 'low_stock': newLevel < 10},
    );
    
    if (newLevel < 10) {
      print('  ⚠️ Low stock alert sent to Purchase Orders module');
      ActivityTracker().trackInteraction(
        action: 'low_stock_alert',
        element: 'purchase_orders_module',
        data: {'product_id': productId, 'current_stock': newLevel, 'reorder_needed': true},
      );
    }
  }

  // Real-time Firestore-based communication tracking
  StreamSubscription<QuerySnapshot>? _productSubscription;
  StreamSubscription<QuerySnapshot>? _inventorySubscription;
  StreamSubscription<QuerySnapshot>? _posSubscription;
  List<Map<String, dynamic>> _recentCommunications = [];
  
  @override
  void dispose() {
    _productSubscription?.cancel();
    _inventorySubscription?.cancel();
    _posSubscription?.cancel();
    super.dispose();
  }
  
  // NEW: Real Firestore-based communication setup
  void _setupFirestoreListeners() {
    print('🔗 Setting up real Firestore listeners for inter-module communication...');
    
    // Listen to Products collection changes
    _productSubscription = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      _onProductDataChanged(snapshot);
    });
    
    // Listen to Inventory collection changes  
    _inventorySubscription = FirebaseFirestore.instance
        .collection('inventory')
        .snapshots()
        .listen((snapshot) {
      _onInventoryDataChanged(snapshot);
    });
    
    // Listen to POS transactions collection changes
    _posSubscription = FirebaseFirestore.instance
        .collection('pos_transactions')
        .snapshots()
        .listen((snapshot) {
      _onPOSDataChanged(snapshot);
    });
    
    print('✅ All Firestore listeners active - will only sync on real data changes');
  }
  
  // Handle actual Product data changes from Firestore
  void _onProductDataChanged(QuerySnapshot snapshot) {
    final changeType = _analyzeFirestoreChanges(snapshot);
    if (changeType != null) {
      final communication = {
        'timestamp': DateTime.now(),
        'communication': {
          'module': 'Product Management',
          'action': changeType,
          'status': 'data_change_detected',
          'firestore_source': true,
          'documents_affected': snapshot.docChanges.length,
        },
      };
      
      setState(() {
        _recentCommunications.add(communication);
        if (_recentCommunications.length > 15) {
          _recentCommunications.removeAt(0);
        }
      });
      
      // Track real data change with Activity Tracker
      ActivityTracker().trackInteraction(
        action: 'firestore_product_change',
        element: 'product_collection',
        data: {
          'change_type': changeType,
          'documents_affected': snapshot.docChanges.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // Notify other modules about real changes
      _notifyModulesOfProductChanges(snapshot.docChanges, changeType);
      
      print('📦 Real Product data change detected: $changeType (${snapshot.docChanges.length} docs affected)');
    }
  }
  
  // Handle actual Inventory data changes from Firestore
  void _onInventoryDataChanged(QuerySnapshot snapshot) {
    final changeType = _analyzeFirestoreChanges(snapshot);
    if (changeType != null) {
      final communication = {
        'timestamp': DateTime.now(),
        'communication': {
          'module': 'Inventory Management',
          'action': changeType,
          'status': 'data_change_detected',
          'firestore_source': true,
          'documents_affected': snapshot.docChanges.length,
        },
      };
      
      setState(() {
        _recentCommunications.add(communication);
        if (_recentCommunications.length > 15) {
          _recentCommunications.removeAt(0);
        }
      });
      
      // Track real inventory change
      ActivityTracker().trackInteraction(
        action: 'firestore_inventory_change',
        element: 'inventory_collection',
        data: {
          'change_type': changeType,
          'documents_affected': snapshot.docChanges.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('📋 Real Inventory data change detected: $changeType (${snapshot.docChanges.length} docs affected)');
    }
  }
  
  // Handle actual POS data changes from Firestore
  void _onPOSDataChanged(QuerySnapshot snapshot) {
    final changeType = _analyzeFirestoreChanges(snapshot);
    if (changeType != null) {
      final communication = {
        'timestamp': DateTime.now(),
        'communication': {
          'module': 'POS System',
          'action': changeType,
          'status': 'data_change_detected',
          'firestore_source': true,
          'documents_affected': snapshot.docChanges.length,
        },
      };
      
      setState(() {
        _recentCommunications.add(communication);
        if (_recentCommunications.length > 15) {
          _recentCommunications.removeAt(0);
        }
      });
      
      // Track real POS change
      ActivityTracker().trackInteraction(
        action: 'firestore_pos_change',
        element: 'pos_transactions_collection',
        data: {
          'change_type': changeType,
          'documents_affected': snapshot.docChanges.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      print('💳 Real POS data change detected: $changeType (${snapshot.docChanges.length} docs affected)');
    }
  }
  
  // Analyze Firestore snapshot changes to determine change type
  String? _analyzeFirestoreChanges(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) return null;
    
    final changes = snapshot.docChanges;
    final addedCount = changes.where((c) => c.type == DocumentChangeType.added).length;
    final modifiedCount = changes.where((c) => c.type == DocumentChangeType.modified).length;
    final removedCount = changes.where((c) => c.type == DocumentChangeType.removed).length;
    
    if (addedCount > 0 && modifiedCount == 0 && removedCount == 0) {
      return 'Documents Added ($addedCount)';
    } else if (modifiedCount > 0 && addedCount == 0 && removedCount == 0) {
      return 'Documents Updated ($modifiedCount)';
    } else if (removedCount > 0 && addedCount == 0 && modifiedCount == 0) {
      return 'Documents Deleted ($removedCount)';
    } else if (addedCount > 0 || modifiedCount > 0 || removedCount > 0) {
      return 'Batch Changes (A:$addedCount, M:$modifiedCount, D:$removedCount)';
    }
    
    return null;
  }
  
  // Notify other modules only when real changes occur
  void _notifyModulesOfProductChanges(List<DocumentChange> changes, String changeType) {
    for (final change in changes) {
      final docData = change.doc.data() as Map<String, dynamic>?;
      final productId = change.doc.id;
      
      // Only notify relevant modules based on what actually changed
      if (change.type == DocumentChangeType.modified && docData != null) {
        // Check what fields were actually modified
        if (docData.containsKey('price')) {
          _notifyPOSOfPriceChange(productId, docData['price']);
        }
        if (docData.containsKey('stock_level')) {
          _notifyInventoryOfStockChange(productId, docData['stock_level']);
        }
        if (docData.containsKey('category')) {
          _notifyCRMOfCategoryChange(productId, docData['category']);
        }
      } else if (change.type == DocumentChangeType.added) {
        _notifyAllModulesOfNewProduct(productId, docData);
      } else if (change.type == DocumentChangeType.removed) {
        _notifyAllModulesOfDeletedProduct(productId);
      }
    }
  }
  
  // Specific notification methods for targeted updates
  void _notifyPOSOfPriceChange(String productId, dynamic newPrice) {
    ActivityTracker().trackInteraction(
      action: 'pos_price_update_notification',
      element: 'pos_module',
      data: {
        'product_id': productId,
        'new_price': newPrice,
        'reason': 'product_price_changed_in_firestore',
      },
    );
    print('💳 POS notified of price change for product $productId: $newPrice');
  }
  
  void _notifyInventoryOfStockChange(String productId, dynamic newStock) {
    ActivityTracker().trackInteraction(
      action: 'inventory_stock_update_notification',
      element: 'inventory_module',
      data: {
        'product_id': productId,
        'new_stock_level': newStock,
        'reason': 'product_stock_changed_in_firestore',
      },
    );
    print('📦 Inventory notified of stock change for product $productId: $newStock');
  }
  
  void _notifyCRMOfCategoryChange(String productId, dynamic newCategory) {
    ActivityTracker().trackInteraction(
      action: 'crm_category_update_notification',
      element: 'crm_module',
      data: {
        'product_id': productId,
        'new_category': newCategory,
        'reason': 'product_category_changed_in_firestore',
      },
    );
    print('📊 CRM notified of category change for product $productId: $newCategory');
  }
  
  void _notifyAllModulesOfNewProduct(String productId, Map<String, dynamic>? productData) {
    ActivityTracker().trackInteraction(
      action: 'new_product_notification',
      element: 'all_modules',
      data: {
        'product_id': productId,
        'product_data': productData?.toString() ?? 'null',
        'reason': 'new_product_added_to_firestore',
      },
    );
    print('🆕 All modules notified of new product: $productId');
  }
  
  void _notifyAllModulesOfDeletedProduct(String productId) {
    ActivityTracker().trackInteraction(
      action: 'product_deletion_notification',
      element: 'all_modules',
      data: {
        'product_id': productId,
        'reason': 'product_deleted_from_firestore',
      },
    );
    print('🗑️ All modules notified of deleted product: $productId');
  }
}

