import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommunicationLogWidget extends StatefulWidget {
  const CommunicationLogWidget({Key? key}) : super(key: key);

  @override
  State<CommunicationLogWidget> createState() => _CommunicationLogWidgetState();
}

class _CommunicationLogWidgetState extends State<CommunicationLogWidget> {
  String? selectedSupplierId;
  String? filterType;

  final List<Map<String, dynamic>> commTypes = [
    {'type': 'call', 'label': 'Call', 'icon': Icons.phone, 'color': Colors.green},
    {'type': 'email', 'label': 'Email', 'icon': Icons.email, 'color': Colors.blue},
    {'type': 'meeting', 'label': 'Meeting', 'icon': Icons.people, 'color': Colors.purple},
    {'type': 'note', 'label': 'Note', 'icon': Icons.note, 'color': Colors.orange},
    {'type': 'custom', 'label': 'Custom', 'icon': Icons.event, 'color': Colors.grey},
  ];

  void _showAddOrEditCommDialog(BuildContext context, {Map<String, dynamic>? comm, int? index}) {
    String? commType = comm?['type'] ?? commTypes.first['type'];
    DateTime commDate = comm != null && comm['date'] != null
        ? DateTime.tryParse(comm['date']) ?? DateTime.now()
        : DateTime.now();
    final descController = TextEditingController(text: comm?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(comm == null ? 'Add Communication' : 'Edit Communication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: commType,
              items: commTypes
                  .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                        value: e['type'] as String,
                        child: Text(e['label'] as String),
                      ))
                  .toList(),
              onChanged: (val) => commType = val,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Notes/Description'),
            ),
            Row(
              children: [
                const Text('Date:'),
                const SizedBox(width: 8),
                Text(DateFormat('yyyy-MM-dd').format(commDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: commDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        commDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (comm != null)
            TextButton(
              onPressed: () async {
                // Delete comm
                if (selectedSupplierId != null) {
                  final docRef = FirebaseFirestore.instance.collection('suppliers').doc(selectedSupplierId);
                  await docRef.update({
                    'communications': FieldValue.arrayRemove([comm])
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (selectedSupplierId != null && descController.text.isNotEmpty) {
                final docRef = FirebaseFirestore.instance.collection('suppliers').doc(selectedSupplierId);
                final newComm = {
                  'date': commDate.toIso8601String(),
                  'type': commType,
                  'description': descController.text,
                };
                if (comm == null) {
                  // Add comm
                  await docRef.update({
                    'communications': FieldValue.arrayUnion([newComm])
                  });
                } else {
                  // Edit comm: remove old, add new
                  await docRef.update({
                    'communications': FieldValue.arrayRemove([comm])
                  });
                  await docRef.update({
                    'communications': FieldValue.arrayUnion([newComm])
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(comm == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Supplier dropdown
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text('No suppliers found.');
              return DropdownButton<String>(
                value: selectedSupplierId,
                hint: const Text('Select Supplier'),
                isExpanded: true,
                items: docs.map<DropdownMenuItem<String>>((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(data['supplierName'] ?? 'No Name'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSupplierId = value;
                  });
                },
              );
            },
          ),
        ),
        if (selectedSupplierId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Communication'),
                  onPressed: () => _showAddOrEditCommDialog(context),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: filterType,
                  hint: const Text('Filter by Type'),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All')),
                    ...commTypes.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                          value: e['type'] as String,
                          child: Text(e['label'] as String),
                        )),
                  ],
                  onChanged: (val) => setState(() => filterType = val),
                ),
              ],
            ),
          ),
        const Divider(),
        // Communication log with connectors
        Expanded(
          child: selectedSupplierId == null
              ? const Center(child: Text('Select a supplier to view communication log.'))
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('suppliers')
                      .doc(selectedSupplierId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    List<dynamic> comms = data['communications'] ?? [];

                    // Filter by type if needed
                    if (filterType != null) {
                      comms = comms.where((e) => e['type'] == filterType).toList();
                    }

                    if (comms.isEmpty) {
                      return const Center(child: Text('No communications found for this supplier.'));
                    }

                    // Sort by date descending
                    comms.sort((a, b) {
                      final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
                      final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
                      return bDate.compareTo(aDate);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: comms.length,
                      itemBuilder: (context, index) {
                        final comm = comms[index];
                        final date = comm['date'] ?? '';
                        final type = comm['type'] ?? '';
                        final desc = comm['description'] ?? '';
                        final typeInfo = commTypes.firstWhere(
                          (e) => e['type'] == type,
                          orElse: () => commTypes.last,
                        );
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline connector
                            Column(
                              children: [
                                if (index != 0)
                                  Container(
                                    width: 2,
                                    height: 20,
                                    color: Colors.grey.shade400,
                                  ),
                                CircleAvatar(
                                  backgroundColor: typeInfo['color'],
                                  child: Icon(typeInfo['icon'], color: Colors.white, size: 18),
                                  radius: 18,
                                ),
                                if (index != comms.length - 1)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.grey.shade400,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  title: Text(desc),
                                  subtitle: Text(date.isNotEmpty
                                      ? DateFormat('yyyy-MM-dd').format(DateTime.tryParse(date) ?? DateTime(2000))
                                      : ''),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showAddOrEditCommDialog(context, comm: comm, index: index);
                                      } else if (value == 'delete') {
                                        // Delete comm
                                        if (selectedSupplierId != null) {
                                          final docRef = FirebaseFirestore.instance.collection('suppliers').doc(selectedSupplierId);
                                          docRef.update({
                                            'communications': FieldValue.arrayRemove([comm])
                                          });
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}