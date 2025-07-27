import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pos_transaction.dart';
import '../services/pos_service.dart';

class OfflineSyncService {
  static const String _offlineTransactionsKey = 'offline_pos_transactions';
  static const String _lastSyncKey = 'last_pos_sync';
  static const String _offlineModeKey = 'pos_offline_mode';

  // Save transaction offline
  static Future<void> saveOfflineTransaction(PosTransaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_offlineTransactionsKey) ?? '[]';
      final List<dynamic> transactions = json.decode(existingData);
      
      transactions.add(transaction.toFirestore());
      
      await prefs.setString(_offlineTransactionsKey, json.encode(transactions));
      debugPrint('Transaction saved offline: ${transaction.invoiceNumber}');
    } catch (e) {
      debugPrint('Error saving offline transaction: $e');
      rethrow;
    }
  }

  // Get all offline transactions
  static Future<List<PosTransaction>> getOfflineTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_offlineTransactionsKey) ?? '[]';
      final List<dynamic> transactionData = json.decode(data);
      
      return transactionData.map((item) {
        return PosTransaction.fromFirestore(
          item as Map<String, dynamic>,
          item['transaction_id'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting offline transactions: $e');
      return [];
    }
  }

  // Clear offline transactions after successful sync
  static Future<void> clearOfflineTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineTransactionsKey);
      debugPrint('Offline transactions cleared');
    } catch (e) {
      debugPrint('Error clearing offline transactions: $e');
    }
  }

  // Sync offline transactions to server
  static Future<bool> syncOfflineTransactions() async {
    try {
      final offlineTransactions = await getOfflineTransactions();
      
      if (offlineTransactions.isEmpty) {
        debugPrint('No offline transactions to sync');
        return true;
      }

      debugPrint('Syncing ${offlineTransactions.length} offline transactions...');
      
      // Update transactions to mark them as synced
      final updatedTransactions = offlineTransactions.map((transaction) {
        return transaction.copyWith(
          syncedToServer: true,
          updatedAt: DateTime.now(),
        );
      }).toList();

      await PosService.syncOfflineTransactions(updatedTransactions);
      await clearOfflineTransactions();
      await updateLastSyncTime();
      
      debugPrint('Offline transactions synced successfully');
      return true;
    } catch (e) {
      debugPrint('Error syncing offline transactions: $e');
      return false;
    }
  }

  // Update offline transaction
  static Future<void> updateOfflineTransaction(
    String transactionId,
    PosTransaction updatedTransaction,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_offlineTransactionsKey) ?? '[]';
      final List<dynamic> transactions = json.decode(existingData);
      
      final index = transactions.indexWhere(
        (item) => item['transaction_id'] == transactionId,
      );
      
      if (index != -1) {
        transactions[index] = updatedTransaction.toFirestore();
        await prefs.setString(_offlineTransactionsKey, json.encode(transactions));
        debugPrint('Offline transaction updated: $transactionId');
      }
    } catch (e) {
      debugPrint('Error updating offline transaction: $e');
      rethrow;
    }
  }

  // Delete offline transaction
  static Future<void> deleteOfflineTransaction(String transactionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_offlineTransactionsKey) ?? '[]';
      final List<dynamic> transactions = json.decode(existingData);
      
      transactions.removeWhere(
        (item) => item['transaction_id'] == transactionId,
      );
      
      await prefs.setString(_offlineTransactionsKey, json.encode(transactions));
      debugPrint('Offline transaction deleted: $transactionId');
    } catch (e) {
      debugPrint('Error deleting offline transaction: $e');
    }
  }

  // Set offline mode
  static Future<void> setOfflineMode(bool isOffline) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineModeKey, isOffline);
      debugPrint('Offline mode set to: $isOffline');
    } catch (e) {
      debugPrint('Error setting offline mode: $e');
    }
  }

  // Get offline mode status
  static Future<bool> isOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_offlineModeKey) ?? false;
    } catch (e) {
      debugPrint('Error getting offline mode: $e');
      return false;
    }
  }

  // Update last sync time
  static Future<void> updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error updating last sync time: $e');
    }
  }

  // Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncTimeString = prefs.getString(_lastSyncKey);
      
      if (syncTimeString != null) {
        return DateTime.parse(syncTimeString);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
      return null;
    }
  }

  // Auto-sync functionality
  static Future<void> autoSync() async {
    try {
      final isOffline = await isOfflineMode();
      if (isOffline) {
        debugPrint('Auto-sync skipped: Device is in offline mode');
        return;
      }

      final lastSync = await getLastSyncTime();
      final now = DateTime.now();
      
      // Auto-sync every 5 minutes if there are offline transactions
      if (lastSync == null || now.difference(lastSync).inMinutes >= 5) {
        final hasOfflineTransactions = (await getOfflineTransactions()).isNotEmpty;
        
        if (hasOfflineTransactions) {
          debugPrint('Auto-sync triggered');
          await syncOfflineTransactions();
        }
      }
    } catch (e) {
      debugPrint('Auto-sync error: $e');
    }
  }

  // Export offline data for backup
  static Future<String> exportOfflineData() async {
    try {
      final transactions = await getOfflineTransactions();
      final lastSync = await getLastSyncTime();
      
      final exportData = {
        'export_time': DateTime.now().toIso8601String(),
        'last_sync_time': lastSync?.toIso8601String(),
        'transactions_count': transactions.length,
        'transactions': transactions.map((t) => t.toFirestore()).toList(),
      };
      
      return json.encode(exportData);
    } catch (e) {
      debugPrint('Error exporting offline data: $e');
      return '{}';
    }
  }

  // Import offline data from backup
  static Future<bool> importOfflineData(String jsonData) async {
    try {
      final Map<String, dynamic> importData = json.decode(jsonData);
      final List<dynamic> transactionData = importData['transactions'] ?? [];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_offlineTransactionsKey, json.encode(transactionData));
      
      final lastSyncString = importData['last_sync_time'] as String?;
      if (lastSyncString != null) {
        await prefs.setString(_lastSyncKey, lastSyncString);
      }
      
      debugPrint('Offline data imported successfully');
      return true;
    } catch (e) {
      debugPrint('Error importing offline data: $e');
      return false;
    }
  }

  // Get sync statistics
  static Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final offlineTransactions = await getOfflineTransactions();
      final lastSync = await getLastSyncTime();
      final isOffline = await isOfflineMode();
      
      return {
        'offline_transactions_count': offlineTransactions.length,
        'last_sync_time': lastSync?.toIso8601String(),
        'is_offline_mode': isOffline,
        'total_offline_amount': offlineTransactions.fold<double>(
          0,
          (sum, transaction) => sum + transaction.totalAmount,
        ),
        'needs_sync': offlineTransactions.isNotEmpty && !isOffline,
      };
    } catch (e) {
      debugPrint('Error getting sync stats: $e');
      return {};
    }
  }

  // Check network connectivity and auto-switch mode
  static Future<bool> checkConnectivity() async {
    try {
      // This is a simplified connectivity check
      // In a real app, you'd use connectivity_plus package
      // For now, we'll assume connectivity is available
      return true;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return false;
    }
  }

  // Intelligent sync based on network conditions
  static Future<void> intelligentSync() async {
    try {
      final hasConnectivity = await checkConnectivity();
      
      if (!hasConnectivity) {
        await setOfflineMode(true);
        debugPrint('No connectivity detected, switching to offline mode');
        return;
      }

      final isCurrentlyOffline = await isOfflineMode();
      if (isCurrentlyOffline) {
        // Coming back online, sync pending transactions
        debugPrint('Connectivity restored, syncing offline transactions');
        await setOfflineMode(false);
        await syncOfflineTransactions();
      } else {
        // Regular auto-sync
        await autoSync();
      }
    } catch (e) {
      debugPrint('Intelligent sync error: $e');
    }
  }

  // Clean up old offline data (older than 30 days)
  static Future<void> cleanupOldData() async {
    try {
      final transactions = await getOfflineTransactions();
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      
      final filteredTransactions = transactions.where((transaction) {
        return transaction.createdAt.isAfter(cutoffDate);
      }).toList();
      
      if (filteredTransactions.length != transactions.length) {
        final prefs = await SharedPreferences.getInstance();
        final transactionData = filteredTransactions.map((t) => t.toFirestore()).toList();
        await prefs.setString(_offlineTransactionsKey, json.encode(transactionData));
        
        final removedCount = transactions.length - filteredTransactions.length;
        debugPrint('Cleaned up $removedCount old offline transactions');
      }
    } catch (e) {
      debugPrint('Error cleaning up old data: $e');
    }
  }
}
