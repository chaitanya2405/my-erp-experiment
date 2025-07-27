import 'package:flutter/foundation.dart';
import '../../../core/models/unified_models.dart';
import '../../../services/pos_service.dart';
import '../../../models/pos_transaction.dart' as legacy_models;

class PosProvider with ChangeNotifier {
  List<UnifiedPOSTransaction> _transactions = [];
  UnifiedPOSTransaction? _currentTransaction;
  bool _isLoading = false;
  String? _error;
  String _selectedStore = '';
  Map<String, dynamic> _analytics = {};
  List<UnifiedPOSTransaction> _offlineTransactions = [];
  bool _isOfflineMode = false;

  // ======================== MODULE INTEGRATION PROPERTIES ========================
  List<UnifiedProduct> _availableProducts = [];
  List<UnifiedCustomerProfile> _customers = [];
  UnifiedProduct? _selectedProduct;
  UnifiedCustomerProfile? _selectedCustomer;
  bool _isLoadingProducts = false;
  bool _isLoadingCustomers = false;

  // Getters
  List<UnifiedPOSTransaction> get transactions => _transactions;
  UnifiedPOSTransaction? get currentTransaction => _currentTransaction;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStore => _selectedStore;
  Map<String, dynamic> get analytics => _analytics;
  List<UnifiedPOSTransaction> get offlineTransactions => _offlineTransactions;
  bool get isOfflineMode => _isOfflineMode;

  // Additional getters for integration
  List<UnifiedProduct> get availableProducts => _availableProducts;
  List<UnifiedCustomerProfile> get customers => _customers;
  UnifiedProduct? get selectedProduct => _selectedProduct;
  UnifiedCustomerProfile? get selectedCustomer => _selectedCustomer;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCustomers => _isLoadingCustomers;

  // Set selected store
  void setSelectedStore(String storeId) {
    _selectedStore = storeId;
    notifyListeners();
    if (storeId.isNotEmpty) {
      loadTransactions();
    }
  }

  // Force refresh transactions
  void refreshTransactions() {
    if (_selectedStore.isNotEmpty) {
      loadTransactions();
    }
  }

  // Set offline mode
  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    notifyListeners();
  }

  // Load transactions for the selected store
  void loadTransactions() {
    if (_selectedStore.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    PosService.getTransactionsByStore(_selectedStore).listen(
      (transactions) {
        _transactions = transactions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Create a new transaction (now uses integrated approach)
  Future<String?> createTransaction(UnifiedPOSTransaction transaction) async {
    return await createIntegratedTransaction(transaction);
  }

  // Update transaction
  Future<bool> updateTransaction(String transactionId, UnifiedPOSTransaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_isOfflineMode) {
        // Update offline transaction
        final index = _offlineTransactions.indexWhere((t) => t.transactionId == transactionId);
        if (index != -1) {
          _offlineTransactions[index] = transaction;
        }
      } else {
        await PosService.updateTransaction(transactionId, _convertToLegacyTransaction(transaction));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get transaction by ID
  Future<UnifiedPOSTransaction?> getTransaction(String transactionId) async {
    try {
      if (_isOfflineMode) {
        return _offlineTransactions.firstWhere(
          (t) => t.transactionId == transactionId,
          orElse: () => throw Exception('Transaction not found'),
        );
      } else {
        return await PosService.getTransaction(transactionId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Load analytics (now uses integrated analytics)
  Future<void> loadAnalytics(DateTime startDate, DateTime endDate) async {
    return await loadIntegratedAnalytics(startDate, endDate);
  }

  // Search transactions by invoice number
  Future<UnifiedPOSTransaction?> searchByInvoiceNumber(String invoiceNumber) async {
    try {
      if (_isOfflineMode) {
        return _offlineTransactions.firstWhere(
          (t) => t.invoiceNumber == invoiceNumber,
          orElse: () => throw Exception('Invoice not found'),
        );
      } else {
        return await PosService.getTransactionByInvoiceNumber(invoiceNumber);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Process refund
  Future<bool> processRefund(String transactionId, double refundAmount, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await PosService.processRefund(transactionId, refundAmount, reason);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sync offline transactions
  Future<bool> syncOfflineTransactions() async {
    if (_offlineTransactions.isEmpty) return true;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final legacyTransactions = _offlineTransactions.map((t) => _convertToLegacyTransaction(t)).toList();
      await PosService.syncOfflineTransactions(legacyTransactions);
      _offlineTransactions.clear();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Generate invoice number
  Future<String> generateInvoiceNumber() async {
    try {
      return await PosService.generateInvoiceNumber(_selectedStore);
    } catch (e) {
      // Fallback invoice number
      return 'POS-${_selectedStore.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Set current transaction for editing
  void setCurrentTransaction(UnifiedPOSTransaction? transaction) {
    _currentTransaction = transaction;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filter transactions by date range
  List<UnifiedPOSTransaction> filterTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactions.where((transaction) {
      final transactionDate = transaction.transactionTime;
      return transactionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transactionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Filter transactions by payment mode
  List<UnifiedPOSTransaction> filterTransactionsByPaymentMode(String paymentMode) {
    return _transactions.where((transaction) {
      return transaction.paymentMode == paymentMode;
    }).toList();
  }

  // Get transactions by cashier
  List<UnifiedPOSTransaction> getTransactionsByCashier(String cashierId) {
    return _transactions.where((transaction) {
      return transaction.cashierId == cashierId;
    }).toList();
  }

  // Calculate daily sales summary
  Map<String, dynamic> getDailySalesSummary(DateTime date) {
    final dayTransactions = _transactions.where((transaction) {
      final transactionDate = transaction.transactionTime;
      return transactionDate.year == date.year &&
             transactionDate.month == date.month &&
             transactionDate.day == date.day;
    }).toList();

    double totalSales = 0;
    double totalDiscount = 0;
    int totalTransactions = dayTransactions.length;

    for (final transaction in dayTransactions) {
      totalSales += transaction.totalAmount;
      totalDiscount += transaction.discountApplied;
    }

    return {
      'total_sales': totalSales,
      'total_discount': totalDiscount,
      'total_transactions': totalTransactions,
      'average_bill_value': totalTransactions > 0 ? totalSales / totalTransactions : 0,
    };
  }

  // Get top selling products
  Map<String, int> getTopSellingProducts(int limit) {
    Map<String, int> productSales = {};

    for (final transaction in _transactions) {
      for (final item in transaction.productItems) {
        final productName = item.productName;
        final quantity = item.quantity;
        productSales[productName] = (productSales[productName] ?? 0) + quantity;
      }
    }

    // Sort by quantity and return top items
    final sortedEntries = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(limit));
  }

  // ======================== PRODUCT INTEGRATION METHODS ========================

  // Load products from Product Management module
  Future<void> loadProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      _availableProducts = await PosService.getAvailableProducts();
      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // Search products by name, barcode, or SKU
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    _isLoadingProducts = true;
    notifyListeners();

    try {
      _availableProducts = await PosService.searchProducts(query);
      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search products: $e';
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // Get product by barcode scan
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final product = await PosService.getProductByBarcode(barcode);
      if (product != null) {
        _selectedProduct = product;
        notifyListeners();
      }
      return product;
    } catch (e) {
      _error = 'Failed to find product by barcode: $e';
      notifyListeners();
      return null;
    }
  }

  // Check inventory before adding to cart
  Future<bool> checkInventoryAvailability(String productId, int quantity) async {
    try {
      return await PosService.checkInventoryAvailability(productId, quantity);
    } catch (e) {
      _error = 'Failed to check inventory: $e';
      notifyListeners();
      return false;
    }
  }

  // Select product for current transaction
  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // ======================== CUSTOMER INTEGRATION METHODS ========================

  // Load customers from CRM module
  Future<void> loadCustomers() async {
    _isLoadingCustomers = true;
    notifyListeners();

    try {
      // This would need to be implemented in CustomerProfileService
      _customers = []; // await PosService.getAllCustomers();
      _isLoadingCustomers = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customers: $e';
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  // Search customers by phone, email, or name
  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      _customers = [];
      notifyListeners();
      return;
    }

    _isLoadingCustomers = true;
    notifyListeners();

    try {
      _customers = await PosService.searchCustomers(query);
      _isLoadingCustomers = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search customers: $e';
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  // Get customer profile for transaction
  Future<CustomerProfile?> getCustomerProfile(String customerId) async {
    try {
      final customer = await PosService.getCustomerProfile(customerId);
      if (customer != null) {
        _selectedCustomer = customer;
        notifyListeners();
      }
      return customer;
    } catch (e) {
      _error = 'Failed to get customer profile: $e';
      notifyListeners();
      return null;
    }
  }

  // Select customer for current transaction
  void setSelectedCustomer(CustomerProfile? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // ======================== INTEGRATED TRANSACTION METHODS ========================

  // Create transaction with full module integration
  Future<String?> createIntegratedTransaction(UnifiedPOSTransaction transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String transactionId;
      
      if (_isOfflineMode) {
        // Store offline transaction
        transactionId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        transaction = transaction.copyWith(
          posTransactionId: transactionId,
          syncedToServer: false,
        );
        _offlineTransactions.add(transaction);
      } else {
        // Create integrated transaction (updates inventory, customer, orders)
        transactionId = await PosService.createIntegratedTransaction(_convertToLegacyTransaction(transaction));
        
        // Refresh the transaction list to show the new transaction immediately
        if (_selectedStore.isNotEmpty) {
          loadTransactions();
        }
      }

      // Clear selected items after successful transaction
      _selectedProduct = null;
      _selectedCustomer = null;
      
      _isLoading = false;
      notifyListeners();
      return transactionId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Load integrated analytics
  Future<void> loadIntegratedAnalytics(DateTime startDate, DateTime endDate) async {
    if (_selectedStore.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analytics = await PosService.getIntegratedAnalytics(_selectedStore, startDate, endDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync POS data with all modules
  Future<void> syncWithAllModules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await PosService.syncWithAllModules();
      
      // Reload data after sync
      await loadProducts();
      await loadCustomers();
      loadTransactions();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Sync failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize POS with all module data
  Future<void> initializePOS() async {
    await loadProducts();
    await loadCustomers();
    if (_selectedStore.isNotEmpty) {
      loadTransactions();
    }
  }

  // Helper method to convert UnifiedPOSTransaction to legacy PosTransaction
  legacy_models.PosTransaction _convertToLegacyTransaction(UnifiedPOSTransaction unifiedTransaction) {
    return legacy_models.PosTransaction(
      posTransactionId: unifiedTransaction.posTransactionId,
      storeId: unifiedTransaction.storeId ?? 'default_store',
      terminalId: unifiedTransaction.terminalId,
      cashierId: unifiedTransaction.cashierId,
      customerId: unifiedTransaction.customerId,
      transactionTime: unifiedTransaction.createdAt,
      productItems: unifiedTransaction.productItems.map((item) => legacy_models.PosProductItem(
        productId: item.productId,
        productName: item.productName,
        sku: item.sku,
        quantity: item.quantity,
        mrp: item.mrp,
        sellingPrice: item.sellingPrice,
        finalPrice: item.finalPrice,
        batchNumber: item.batchNumber,
        discountAmount: item.discountAmount,
        taxAmount: item.taxAmount,
        taxSlab: item.taxSlab,
      )).toList(),
      pricingEngineSnapshot: unifiedTransaction.pricingEngineSnapshot,
      subTotal: unifiedTransaction.subTotal,
      discountApplied: unifiedTransaction.discountApplied,
      promoCode: null,
      loyaltyPointsUsed: unifiedTransaction.loyaltyPointsUsed,
      loyaltyPointsEarned: unifiedTransaction.loyaltyPointsEarned,
      taxBreakup: unifiedTransaction.taxBreakup,
      totalAmount: unifiedTransaction.totalAmount,
      paymentMode: unifiedTransaction.paymentMode,
      changeReturned: unifiedTransaction.changeReturned,
      walletUsed: unifiedTransaction.walletUsed,
      roundOffAmount: unifiedTransaction.roundOffAmount,
      invoiceNumber: unifiedTransaction.invoiceNumber,
      invoiceUrl: null,
      invoiceType: unifiedTransaction.invoiceType,
      refundStatus: unifiedTransaction.refundStatus,
      remarks: null,
      isOfflineMode: unifiedTransaction.isOfflineMode,
      syncedToServer: unifiedTransaction.syncedToServer,
      syncedToFinance: unifiedTransaction.syncedToFinance,
      syncedToInventory: unifiedTransaction.syncedToInventory,
      auditLogId: null,
      createdAt: unifiedTransaction.createdAt,
      updatedAt: unifiedTransaction.updatedAt,
    );
  }
}
