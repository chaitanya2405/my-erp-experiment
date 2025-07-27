import 'package:flutter/material.dart';

class PoApprovalTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> approvalHistory;

  const PoApprovalTimeline({Key? key, required this.approvalHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (approvalHistory.isEmpty) {
      return const Center(child: Text('No approval history.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: approvalHistory.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = approvalHistory[index];
        final status = entry['status'] ?? 'Unknown';
        final user = entry['user'] ?? 'Unknown';
        final comment = entry['comment'] ?? '';
        final timestamp = entry['timestamp'];
        final dateStr = timestamp != null
            ? (timestamp is DateTime
                ? timestamp
                : (timestamp is String
                    ? DateTime.tryParse(timestamp)
                    : null))
                ?.toLocal()
                .toString()
                .split('.')[0]
            : '';

        return ListTile(
          leading: Icon(
            status == 'Approved'
                ? Icons.check_circle
                : status == 'Rejected'
                    ? Icons.cancel
                    : Icons.info,
            color: status == 'Approved'
                ? Colors.green
                : status == 'Rejected'
                    ? Colors.red
                    : Colors.blue,
          ),
          title: Text('$status by $user'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comment.isNotEmpty) Text('Comment: $comment'),
              if (dateStr != null && dateStr.isNotEmpty) Text('At: $dateStr'),
            ],
          ),
        );
      },
    );
  }
}
