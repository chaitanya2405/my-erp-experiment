import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/index.dart';

class COMScreen extends StatefulWidget {
  const COMScreen({super.key});

  @override
  State<COMScreen> createState() => _COMScreenState();
}

class _COMScreenState extends State<COMScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COM - Communication Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.email), text: 'Messages'),
            Tab(icon: Icon(Icons.phone), text: 'Call Log'),
            Tab(icon: Icon(Icons.event), text: 'Meetings'),
            Tab(icon: Icon(Icons.task), text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesTab(),
          _buildCallLogTab(),
          _buildMeetingsTab(),
          _buildTasksTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewCommunicationDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Communication'),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        // Search and Compose Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search messages...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _composeMessage,
                icon: const Icon(Icons.create),
                label: const Text('Compose'),
              ),
            ],
          ),
        ),
        // Messages List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('communications')
                .where('type', isEqualTo: 'email')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final messages = snapshot.data?.docs ?? [];
              final filteredMessages = messages.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final subject = data['subject']?.toString().toLowerCase() ?? '';
                final sender = data['sender']?.toString().toLowerCase() ?? '';
                final query = _searchQuery.toLowerCase();
                return subject.contains(query) || sender.contains(query);
              }).toList();

              if (filteredMessages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No messages found', style: TextStyle(fontSize: 18)),
                      Text('Send your first message to get started'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final message = filteredMessages[index].data() as Map<String, dynamic>;
                  final docId = filteredMessages[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: message['direction'] == 'incoming' ? Colors.blue : Colors.green,
                        child: Icon(
                          message['direction'] == 'incoming' ? Icons.call_received : Icons.call_made,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(message['subject'] ?? 'No Subject'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${message['direction'] == 'incoming' ? 'From' : 'To'}: ${message['contact'] ?? 'Unknown'}'),
                          Text('${_formatDateTime(message['timestamp'])}'),
                          if (message['status'] != null)
                            Chip(
                              label: Text(message['status'], style: const TextStyle(fontSize: 10)),
                              backgroundColor: _getStatusColor(message['status']).withOpacity(0.2),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'reply':
                              _replyToMessage(message);
                              break;
                            case 'forward':
                              _forwardMessage(message);
                              break;
                            case 'delete':
                              _deleteCommunication(docId);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'reply', child: Text('Reply')),
                          const PopupMenuItem(value: 'forward', child: Text('Forward')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                      onTap: () => _showMessageDetails(message),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallLogTab() {
    return Column(
      children: [
        // Call Actions Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _makeCall,
                  icon: const Icon(Icons.phone),
                  label: const Text('Make Call'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _makeCall,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule Call'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        // Call Log List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('communications')
                .where('type', isEqualTo: 'call')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final calls = snapshot.data?.docs ?? [];

              if (calls.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No calls found', style: TextStyle(fontSize: 18)),
                      Text('Make your first call to get started'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: calls.length,
                itemBuilder: (context, index) {
                  final call = calls[index].data() as Map<String, dynamic>;
                  final docId = calls[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCallStatusColor(call['status'] ?? 'completed'),
                        child: Icon(
                          call['direction'] == 'incoming' ? Icons.call_received : Icons.call_made,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(call['contact'] ?? 'Unknown Contact'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${call['direction'] == 'incoming' ? 'Incoming' : 'Outgoing'} call'),
                          Text('Duration: ${call['duration'] ?? 0} minutes'),
                          Text('${_formatDateTime(call['timestamp'])}'),
                          if (call['notes'] != null && call['notes'].isNotEmpty)
                            Text('Notes: ${call['notes']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'callback':
                              _makeCallback(call);
                              break;
                            case 'add_notes':
                              _addCallNotes(docId, call);
                              break;
                            case 'delete':
                              _deleteCommunication(docId);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'callback', child: Text('Call Back')),
                          const PopupMenuItem(value: 'add_notes', child: Text('Add Notes')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingsTab() {
    return Column(
      children: [
        // Meeting Actions Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scheduleMeeting,
                  icon: const Icon(Icons.event),
                  label: const Text('Schedule Meeting'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _joinMeeting,
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Meeting'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ),
        // Meetings List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('communications')
                .where('type', isEqualTo: 'meeting')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final meetings = snapshot.data?.docs ?? [];

              if (meetings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No meetings found', style: TextStyle(fontSize: 18)),
                      Text('Schedule your first meeting to get started'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index].data() as Map<String, dynamic>;
                  final docId = meetings[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getMeetingStatusColor(meeting['status'] ?? 'scheduled'),
                        child: const Icon(Icons.event, color: Colors.white),
                      ),
                      title: Text(meeting['subject'] ?? 'No Subject'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('With: ${meeting['participants'] ?? 'No participants'}'),
                          Text('${_formatDateTime(meeting['timestamp'])}'),
                          Text('Duration: ${meeting['duration'] ?? 60} minutes'),
                          if (meeting['location'] != null)
                            Text('Location: ${meeting['location']}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'reschedule':
                              _rescheduleMeeting(docId, meeting);
                              break;
                            case 'add_notes':
                              _addMeetingNotes(docId, meeting);
                              break;
                            case 'cancel':
                              _cancelMeeting(docId);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
                          const PopupMenuItem(value: 'add_notes', child: Text('Add Notes')),
                          const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTasksTab() {
    return Column(
      children: [
        // Task Actions Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createTask,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Create Task'),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  // Implement task filtering
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Tasks')),
                  const PopupMenuItem(value: 'pending', child: Text('Pending')),
                  const PopupMenuItem(value: 'completed', child: Text('Completed')),
                  const PopupMenuItem(value: 'overdue', child: Text('Overdue')),
                ],
              ),
            ],
          ),
        ),
        // Tasks List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('communications')
                .where('type', isEqualTo: 'task')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data?.docs ?? [];

              if (tasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No tasks found', style: TextStyle(fontSize: 18)),
                      Text('Create your first task to get started'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index].data() as Map<String, dynamic>;
                  final docId = tasks[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Checkbox(
                        value: task['completed'] ?? false,
                        onChanged: (value) => _toggleTaskCompletion(docId, value ?? false),
                      ),
                      title: Text(
                        task['subject'] ?? 'No Subject',
                        style: TextStyle(
                          decoration: (task['completed'] ?? false) ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Priority: ${task['priority'] ?? 'Medium'}'),
                          Text('Due: ${_formatDate(task['dueDate'])}'),
                          if (task['assignedTo'] != null)
                            Text('Assigned to: ${task['assignedTo']}'),
                          Chip(
                            label: Text(
                              task['status'] ?? 'pending',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getTaskStatusColor(task['status'] ?? 'pending').withOpacity(0.2),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _editTask(docId, task);
                              break;
                            case 'delete':
                              _deleteCommunication(docId);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      case 'read':
        return Colors.purple;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCallStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'busy':
        return Colors.orange;
      case 'no_answer':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getMeetingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTaskStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'No date';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No date';
    if (date is Timestamp) {
      final d = date.toDate();
      return '${d.day}/${d.month}/${d.year}';
    }
    return date.toString();
  }

  void _showNewCommunicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Communication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.pop(context);
                _composeMessage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Make Call'),
              onTap: () {
                Navigator.pop(context);
                _makeCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Schedule Meeting'),
              onTap: () {
                Navigator.pop(context);
                _scheduleMeeting();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Create Task'),
              onTap: () {
                Navigator.pop(context);
                _createTask();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _composeMessage() {
    // Implementation for composing message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email composition feature coming soon')),
    );
  }

  void _makeCall() {
    // Implementation for making call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call feature coming soon')),
    );
  }

  void _scheduleMeeting() {
    // Implementation for scheduling meeting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meeting scheduling feature coming soon')),
    );
  }

  void _createTask() {
    // Implementation for creating task
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task creation feature coming soon')),
    );
  }

  void _replyToMessage(Map<String, dynamic> message) {
    // Implementation for replying to message
  }

  void _forwardMessage(Map<String, dynamic> message) {
    // Implementation for forwarding message
  }

  void _showMessageDetails(Map<String, dynamic> message) {
    // Implementation for showing message details
  }

  void _makeCallback(Map<String, dynamic> call) {
    // Implementation for making callback
  }

  void _addCallNotes(String docId, Map<String, dynamic> call) {
    // Implementation for adding call notes
  }

  void _joinMeeting() {
    // Implementation for joining meeting
  }

  void _rescheduleMeeting(String docId, Map<String, dynamic> meeting) {
    // Implementation for rescheduling meeting
  }

  void _addMeetingNotes(String docId, Map<String, dynamic> meeting) {
    // Implementation for adding meeting notes
  }

  void _cancelMeeting(String docId) {
    // Implementation for canceling meeting
  }

  void _toggleTaskCompletion(String docId, bool completed) async {
    await FirebaseFirestore.instance.collection('communications').doc(docId).update({
      'completed': completed,
      'status': completed ? 'completed' : 'pending',
      'completedAt': completed ? Timestamp.now() : null,
    });
  }

  void _editTask(String docId, Map<String, dynamic> task) {
    // Implementation for editing task
  }

  void _deleteCommunication(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Communication'),
        content: const Text('Are you sure you want to delete this communication?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('communications').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Communication deleted successfully')),
      );
    }
  }
}
