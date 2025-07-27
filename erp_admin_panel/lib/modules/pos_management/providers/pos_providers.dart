import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pos_transaction.dart';

// State class for POS management
class PosState {
  final List<PosTransaction> transactions;
  final List<PosTransaction> offlineTransactions;
  final bool isLoading;
  final bool isOfflineMode;
  final String? error;
  final PosTransaction? currentTransaction;
  final Map<String, dynamic> analytics;
  final String selectedStore;

  const PosState({
    this.transactions = const [],
    this.offlineTransactions = const [],
    this.isLoading = false,
    this.isOfflineMode = false,
    this.error,
    this.currentTransaction,
    this.analytics = const {},
    this.selectedStore = 'STORE_001',
  });

  PosState copyWith({
    List<PosTransaction>? transactions,
    List<PosTransaction>? offlineTransactions,
    bool? isLoading,
    bool? isOfflineMode,
    String? error,
    PosTransaction? currentTransaction,
    Map<String, dynamic>? analytics,
    String? selectedStore,
  }) {
    return PosState(
      transactions: transactions ?? this.transactions,
      offlineTransactions: offlineTransactions ?? this.offlineTransactions,
      isLoading: isLoading ?? this.isLoading,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      error: error ?? this.error,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      analytics: analytics ?? this.analytics,
      selectedStore: selectedStore ?? this.selectedStore,
    );
  }
}

// StateNotifier for POS management
class PosStateNotifier extends StateNotifier<PosState> {
  PosStateNotifier() : super(const PosState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setOfflineMode(bool offline) {
    state = state.copyWith(isOfflineMode: offline);
  }

  void setTransactions(List<PosTransaction> transactions) {
    state = state.copyWith(transactions: transactions);
  }

  void setOfflineTransactions(List<PosTransaction> offlineTransactions) {
    state = state.copyWith(offlineTransactions: offlineTransactions);
  }

  void setCurrentTransaction(PosTransaction? transaction) {
    state = state.copyWith(currentTransaction: transaction);
  }

  void addTransaction(PosTransaction transaction) {
    state = state.copyWith(
      transactions: [...state.transactions, transaction],
    );
  }

  void addOfflineTransaction(PosTransaction transaction) {
    state = state.copyWith(
      offlineTransactions: [...state.offlineTransactions, transaction],
    );
  }

  void removeTransaction(String transactionId) {
    final updatedList = state.transactions
        .where((transaction) => transaction.transactionId != transactionId)
        .toList();
    
    state = state.copyWith(transactions: updatedList);
  }

  Future<void> refreshTransactions() async {
    setLoading(true);
    try {
      // Simulate API call or actual data refresh
      await Future.delayed(const Duration(milliseconds: 500));
      // Here you would call your actual service to refresh data
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  // Generate invoice number
  Future<String> generateInvoiceNumber() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'INV-${timestamp.toString().substring(7)}';
  }

  // Create new transaction
  Future<String?> createTransaction(dynamic transaction) async {
    setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // Add transaction to state
      // Here you would convert dynamic to PosTransaction and add it
      setLoading(false);
      return 'created';
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return null;
    }
  }

  // Update existing transaction
  Future<bool> updateTransaction(dynamic updatedTransaction) async {
    setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // Update transaction in state
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  // Load analytics data
  Future<void> loadAnalytics(DateTime startDate, DateTime endDate) async {
    setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock analytics data
      final analytics = {
        'total_sales': 125000.50,
        'total_transactions': 145,
        'average_bill_value': 862.07,
        'total_discount': 8750.25,
        'payment_modes': {
          'Cash': 65,
          'Card': 45,
          'UPI': 35,
        },
      };
      
      state = state.copyWith(analytics: analytics);
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  // Get top selling products
  Map<String, int> getTopSellingProducts(int limit) {
    // Mock data for top selling products
    return {
      'Rice (1kg)': 45,
      'Wheat Flour (1kg)': 38,
      'Sugar (1kg)': 32,
      'Tea Powder (250g)': 28,
      'Cooking Oil (1L)': 25,
    };
  }

  // Set selected store
  void setSelectedStore(String storeId) {
    state = state.copyWith(selectedStore: storeId);
  }
}

// Providers
final posStateProvider = StateNotifierProvider<PosStateNotifier, PosState>((ref) {
  return PosStateNotifier();
});
