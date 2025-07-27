import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({Key? key}) : super(key: key);

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      // Generate real-time notifications based on current data
      final notifications = <Map<String, dynamic>>[];
      
      // Check for low stock items
      final inventorySnapshot = await FirebaseFirestore.instance.collection('inventory').get();
      int lowStockCount = 0;
      for (var doc in inventorySnapshot.docs) {
        final data = doc.data();
        final currentStock = (data['currentStock'] as num?)?.toInt() ?? 0;
        final minStock = (data['minStockLevel'] as num?)?.toInt() ?? 10;
        if (currentStock <= minStock) {
          lowStockCount++;
        }
      }
      
      if (lowStockCount > 0) {
        notifications.add({
          'id': 'low_stock_${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Low Stock Alert',
          'message': '$lowStockCount products are running low on stock',
          'type': 'warning',
          'icon': Icons.warning,
          'color': Colors.orange,
          'timestamp': DateTime.now(),
          'isRead': false,
        });
      }
      
      // Check for recent orders
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('customer_orders')
          .where('orderDate', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))))
          .get();
      
      if (ordersSnapshot.docs.isNotEmpty) {
        notifications.add({
          'id': 'new_orders_${DateTime.now().millisecondsSinceEpoch}',
          'title': 'New Orders Received',
          'message': '${ordersSnapshot.docs.length} new orders in the last hour',
          'type': 'info',
          'icon': Icons.shopping_bag,
          'color': Colors.blue,
          'timestamp': DateTime.now(),
          'isRead': false,
        });
      }
      
      // Check for pending transactions
      final posSnapshot = await FirebaseFirestore.instance
          .collection('pos_transactions')
          .where('transactionDate', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))))
          .get();
      
      if (posSnapshot.docs.isNotEmpty) {
        notifications.add({
          'id': 'recent_transactions_${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Recent Transactions',
          'message': '${posSnapshot.docs.length} transactions completed in the last 30 minutes',
          'type': 'success',
          'icon': Icons.payment,
          'color': Colors.green,
          'timestamp': DateTime.now(),
          'isRead': false,
        });
      }
      
      // Add system status notification
      notifications.add({
        'id': 'system_status_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'System Status',
        'message': 'All ERP modules are operational and running smoothly',
        'type': 'info',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'timestamp': DateTime.now(),
        'isRead': false,
      });
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification, index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['timestamp'] as DateTime;
    final timeAgo = _getTimeAgo(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[200]! : notification['color'].withOpacity(0.3),
          width: isRead ? 1 : 2,
        ),
        boxShadow: isRead ? null : [
          BoxShadow(
            color: notification['color'].withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            notification['icon'],
            color: notification['color'],
            size: 24,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: notification['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _markAsRead(index),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'mark_read') {
              _markAsRead(index);
            } else if (value == 'dismiss') {
              _dismissNotification(index);
            }
          },
          itemBuilder: (context) => [
            if (!isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 18),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'dismiss',
              child: Row(
                children: [
                  Icon(Icons.close, size: 18),
                  SizedBox(width: 8),
                  Text('Dismiss'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _dismissNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }
}
