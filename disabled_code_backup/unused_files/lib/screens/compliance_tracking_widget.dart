import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplianceTrackingWidget extends StatelessWidget {
  const ComplianceTrackingWidget({Key? key}) : super(key: key);

  Color getStatusColor(String status) {
    switch (status) {
      case 'Valid':
        return Colors.green;
      case 'Expiring Soon':
        return Colors.orange;
      case 'Missing':
      default:
        return Colors.red;
    }
  }

  Future<void> _showNotificationsDialog(BuildContext context, List<dynamic> notifications) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compliance Notifications'),
        content: SizedBox(
          width: 350,
          child: notifications.isEmpty
              ? const Text('No notifications.')
              : ListView(
                  shrinkWrap: true,
                  children: notifications.map((n) {
                    return ListTile(
                      leading: Icon(
                        n['type'] == 'expiry' ? Icons.warning : Icons.error,
                        color: n['type'] == 'expiry' ? Colors.orange : Colors.red,
                      ),
                      title: Text(n['message'] ?? ''),
                      subtitle: n['date'] != null
                          ? Text('Date: ${n['date']}')
                          : null,
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNotification(String supplierId, Map<String, dynamic> notification) async {
    final docRef = FirebaseFirestore.instance.collection('suppliers').doc(supplierId);
    await docRef.update({
      'complianceNotifications': FieldValue.arrayUnion([notification])
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No suppliers found.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Compliance & Document Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('GSTIN')),
                DataColumn(label: Text('FSSAI')),
                DataColumn(label: Text('PAN')),
                DataColumn(label: Text('Contract')),
                DataColumn(label: Text('Alerts')),
                DataColumn(label: Text('Notifications')),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final supplierId = doc.id;
                final gstinStatus = data['gstinStatus'] ?? 'Missing';
                final fssaiStatus = data['fssaiStatus'] ?? 'Missing';
                final panStatus = data['panStatus'] ?? 'Missing';
                final contractExpiry = data['contractExpiryDate'] != null
                    ? DateTime.tryParse(data['contractExpiryDate'])
                    : null;

                String contractAlert = 'Valid';
                Color contractColor = Colors.green;
                if (contractExpiry != null) {
                  final daysLeft = contractExpiry.difference(DateTime.now()).inDays;
                  if (daysLeft < 0) {
                    contractAlert = 'Expired';
                    contractColor = Colors.red;
                  } else if (daysLeft < 30) {
                    contractAlert = 'Expiring Soon';
                    contractColor = Colors.orange;
                  }
                } else {
                  contractAlert = 'Missing';
                  contractColor = Colors.red;
                }

                // Collect alerts and notifications
                List<String> alerts = [];
                List<Map<String, dynamic>> newNotifications = [];
                if (gstinStatus == 'Missing') {
                  alerts.add('GSTIN');
                  newNotifications.add({
                    'type': 'missing',
                    'message': 'GSTIN document is missing.',
                    'date': DateTime.now().toIso8601String(),
                  });
                }
                if (fssaiStatus == 'Missing') {
                  alerts.add('FSSAI');
                  newNotifications.add({
                    'type': 'missing',
                    'message': 'FSSAI document is missing.',
                    'date': DateTime.now().toIso8601String(),
                  });
                }
                if (panStatus == 'Missing') {
                  alerts.add('PAN');
                  newNotifications.add({
                    'type': 'missing',
                    'message': 'PAN document is missing.',
                    'date': DateTime.now().toIso8601String(),
                  });
                }
                if (contractAlert == 'Expiring Soon') {
                  alerts.add('Contract');
                  newNotifications.add({
                    'type': 'expiry',
                    'message': 'Contract is expiring soon.',
                    'date': DateTime.now().toIso8601String(),
                  });
                }
                if (contractAlert == 'Expired') {
                  alerts.add('Contract');
                  newNotifications.add({
                    'type': 'expiry',
                    'message': 'Contract has expired.',
                    'date': DateTime.now().toIso8601String(),
                  });
                }
                if (contractAlert == 'Missing') {
                  alerts.add('Contract');
                  newNotifications.add({
                    'type': 'missing',
                    'message': 'Contract document is missing.',
                    'date': DateTime.now().toIso8601String(),
                  });
                }

                // Store new notifications if not already present
                final existingNotifications = List<Map<String, dynamic>>.from(data['complianceNotifications'] ?? []);
                for (var notif in newNotifications) {
                  final alreadyExists = existingNotifications.any((n) =>
                      n['type'] == notif['type'] &&
                      n['message'] == notif['message']);
                  if (!alreadyExists) {
                    _addNotification(supplierId, notif);
                  }
                }

                // Notification badge
                final activeNotifications = existingNotifications.where((n) {
                  final notifDate = DateTime.tryParse(n['date'] ?? '');
                  return notifDate == null || notifDate.isAfter(DateTime.now().subtract(const Duration(days: 30)));
                }).toList();

                return DataRow(
                  cells: [
                    DataCell(Text(data['supplierName'] ?? 'No Name')),
                    DataCell(Row(
                      children: [
                        Icon(Icons.circle, color: getStatusColor(gstinStatus), size: 12),
                        const SizedBox(width: 6),
                        Text(gstinStatus),
                        if (gstinStatus != 'Valid')
                          IconButton(
                            icon: const Icon(Icons.upload_file, size: 18, color: Colors.blue),
                            tooltip: 'Upload GSTIN',
                            onPressed: () {
                              // TODO: Implement upload logic
                            },
                          ),
                      ],
                    )),
                    DataCell(Row(
                      children: [
                        Icon(Icons.circle, color: getStatusColor(fssaiStatus), size: 12),
                        const SizedBox(width: 6),
                        Text(fssaiStatus),
                        if (fssaiStatus != 'Valid')
                          IconButton(
                            icon: const Icon(Icons.upload_file, size: 18, color: Colors.blue),
                            tooltip: 'Upload FSSAI',
                            onPressed: () {
                              // TODO: Implement upload logic
                            },
                          ),
                      ],
                    )),
                    DataCell(Row(
                      children: [
                        Icon(Icons.circle, color: getStatusColor(panStatus), size: 12),
                        const SizedBox(width: 6),
                        Text(panStatus),
                        if (panStatus != 'Valid')
                          IconButton(
                            icon: const Icon(Icons.upload_file, size: 18, color: Colors.blue),
                            tooltip: 'Upload PAN',
                            onPressed: () {
                              // TODO: Implement upload logic
                            },
                          ),
                      ],
                    )),
                    DataCell(Row(
                      children: [
                        Icon(Icons.circle, color: contractColor, size: 12),
                        const SizedBox(width: 6),
                        Text(contractAlert),
                        if (contractAlert != 'Valid')
                          IconButton(
                            icon: const Icon(Icons.upload_file, size: 18, color: Colors.blue),
                            tooltip: 'Upload Contract',
                            onPressed: () {
                              // TODO: Implement upload logic
                            },
                          ),
                      ],
                    )),
                    DataCell(
                      alerts.isEmpty
                          ? const Text('All OK', style: TextStyle(color: Colors.green))
                          : Text(alerts.join(', '), style: const TextStyle(color: Colors.red)),
                    ),
                    DataCell(
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () => _showNotificationsDialog(context, existingNotifications),
                          ),
                          if (activeNotifications.isNotEmpty)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${activeNotifications.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}