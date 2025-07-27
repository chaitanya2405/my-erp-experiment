// 🎫 TICKET DETAIL SCREEN
// Support ticket details and conversation

import 'package:flutter/material.dart';

class TicketDetailScreen extends StatefulWidget {
  final String? ticketId;

  const TicketDetailScreen({super.key, this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'message': 'Hello, I have an issue with my recent order #12345. The product arrived damaged.',
      'isCustomer': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'sent',
    },
    {
      'id': '2',
      'message': 'Hi there! I\'m sorry to hear about the damaged product. We\'ll look into this immediately and get back to you with a solution.',
      'isCustomer': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      'status': 'sent',
      'agentName': 'Sarah (Support Team)',
    },
    {
      'id': '3',
      'message': 'Thank you for the quick response. When can I expect a replacement?',
      'isCustomer': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'sent',
    },
    {
      'id': '4',
      'message': 'We\'ve processed a replacement order for you. You should receive it within 2-3 business days. Here\'s your replacement order tracking: #REP789',
      'isCustomer': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'sent',
      'agentName': 'Sarah (Support Team)',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketId = widget.ticketId ?? 
        ModalRoute.of(context)?.settings.arguments as String? ?? 'TIC001';

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #$ticketId'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'close':
                  _showCloseTicketDialog();
                  break;
                case 'escalate':
                  _escalateTicket();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'escalate',
                child: Row(
                  children: [
                    Icon(Icons.priority_high),
                    SizedBox(width: 8),
                    Text('Escalate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'close',
                child: Row(
                  children: [
                    Icon(Icons.close),
                    SizedBox(width: 8),
                    Text('Close Ticket'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Ticket Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'OPEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Delivery Issue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Created: ${_formatDate(DateTime.now().subtract(const Duration(hours: 2)))}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.support_agent, color: Colors.green),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: Implement attach file
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File attachment coming soon')),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCustomer = message['isCustomer'] as bool;
    final timestamp = message['timestamp'] as DateTime;
    final messageText = message['message'] as String;
    final agentName = message['agentName'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCustomer) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.support_agent, size: 16, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCustomer ? Theme.of(context).primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isCustomer ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isCustomer ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCustomer && agentName != null) ...[
                    Text(
                      agentName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    messageText,
                    style: TextStyle(
                      color: isCustomer ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isCustomer ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCustomer) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': messageText,
        'isCustomer': true,
        'timestamp': DateTime.now(),
        'status': 'sent',
      });
    });

    _messageController.clear();

    // Simulate auto-response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'message': 'Thank you for your message. Our support team will review this and get back to you shortly.',
            'isCustomer': false,
            'timestamp': DateTime.now(),
            'status': 'sent',
            'agentName': 'Support Bot',
          });
        });
      }
    });
  }

  void _showCloseTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Ticket'),
        content: const Text(
          'Are you sure you want to close this support ticket? You can always create a new ticket if you need further assistance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket closed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Close Ticket'),
          ),
        ],
      ),
    );
  }

  void _escalateTicket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escalate Ticket'),
        content: const Text(
          'This will escalate your ticket to a senior support agent. You should receive a response within 2 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket escalated to senior support'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Escalate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $amPm';
  }
}
