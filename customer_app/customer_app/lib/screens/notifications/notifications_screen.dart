// 🔔 NOTIFICATIONS SCREEN
// User notifications and alerts

import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Order Shipped',
      'message': 'Your order #12345 has been shipped and is on its way to you.',
      'type': 'order',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'isRead': false,
      'icon': Icons.local_shipping,
      'color': Colors.blue,
    },
    {
      'id': '2',
      'title': 'New Product Alert',
      'message': 'New products have been added to your favorite category "Electronics".',
      'type': 'product',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'icon': Icons.new_releases,
      'color': Colors.orange,
    },
    {
      'id': '3',
      'title': 'Order Delivered',
      'message': 'Your order #12344 has been successfully delivered. Rate your experience!',
      'type': 'order',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'isRead': true,
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'id': '4',
      'title': 'Special Offer',
      'message': 'Get 20% off on all electronics. Limited time offer!',
      'type': 'promotion',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'icon': Icons.local_offer,
      'color': Colors.purple,
    },
    {
      'id': '5',
      'title': 'Support Ticket Update',
      'message': 'Your support ticket #TIC001 has been resolved.',
      'type': 'support',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'icon': Icons.support,
      'color': Colors.teal,
    },
    {
      'id': '6',
      'title': 'Payment Confirmation',
      'message': 'Payment of ₹2,499 for order #12343 has been successfully processed.',
      'type': 'payment',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'icon': Icons.payment,
      'color': Colors.indigo,
    },
  ];

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.all(16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'All'),
                _buildFilterChip('order', 'Orders'),
                _buildFilterChip('product', 'Products'),
                _buildFilterChip('promotion', 'Offers'),
                _buildFilterChip('support', 'Support'),
                _buildFilterChip('payment', 'Payments'),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationTile(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['timestamp'] as DateTime;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (notification['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            notification['icon'] as IconData,
            color: notification['color'] as Color,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'] as String,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'] as String,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        onTap: () {
          _handleNotificationTap(notification);
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                _markAsRead(notification['id'] as String);
                break;
              case 'delete':
                _deleteNotification(notification['id'] as String);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
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
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'No notifications yet'
                : 'No ${_getFilterLabel(_selectedFilter)} notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something important happens',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    if (_selectedFilter == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n['type'] == _selectedFilter).toList();
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'order':
        return 'order';
      case 'product':
        return 'product';
      case 'promotion':
        return 'offer';
      case 'support':
        return 'support';
      case 'payment':
        return 'payment';
      default:
        return filter;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read when tapped
    if (!notification['isRead']) {
      _markAsRead(notification['id'] as String);
    }

    // Navigate based on notification type
    final type = notification['type'] as String;
    switch (type) {
      case 'order':
        Navigator.pushNamed(context, '/orders');
        break;
      case 'product':
        Navigator.pushNamed(context, '/products');
        break;
      case 'promotion':
        Navigator.pushNamed(context, '/products');
        break;
      case 'support':
        Navigator.pushNamed(context, '/support');
        break;
      case 'payment':
        Navigator.pushNamed(context, '/orders');
        break;
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
