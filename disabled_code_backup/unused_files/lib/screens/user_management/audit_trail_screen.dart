import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Audit Trail Screen: View user activity and changes
class AuditTrailScreen extends StatelessWidget {
  final bool showAppBar;
  const AuditTrailScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Recent User Activity', style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('audit_trail').orderBy('timestamp', descending: true).limit(100).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No audit trail entries found.'));
              }
              final entries = snapshot.data!.docs;
              return ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final data = entries[i].data() as Map<String, dynamic>;
                  final user = data['userDisplayName'] ?? data['userId'] ?? 'Unknown';
                  final action = data['action'] ?? 'Action';
                  final module = data['module'] ?? '';
                  final ts = data['timestamp'] as Timestamp?;
                  final time = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch) : null;
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('$action${module.isNotEmpty ? ' ($module)' : ''}'),
                    subtitle: Text('By: $user\n${time != null ? time.toLocal().toString() : ''}'),
                    isThreeLine: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Audit Trail'),
        ),
        body: body,
      );
    } else {
      return body;
    }
  }
}
