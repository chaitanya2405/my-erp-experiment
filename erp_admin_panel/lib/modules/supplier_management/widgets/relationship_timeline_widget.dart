import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/supplier.dart';

class RelationshipTimelineWidget extends StatefulWidget {
  const RelationshipTimelineWidget({Key? key}) : super(key: key);

  @override
  State<RelationshipTimelineWidget> createState() => _RelationshipTimelineWidgetState();
}

class _RelationshipTimelineWidgetState extends State<RelationshipTimelineWidget> {
  String? selectedSupplierId;
  String? filterType; // For event type filtering

  final List<Map<String, dynamic>> eventTypes = [
    {'type': 'contract', 'label': 'Contract', 'icon': Icons.assignment_turned_in, 'color': Colors.blue},
    {'type': 'order', 'label': 'Order', 'icon': Icons.shopping_cart, 'color': Colors.green},
    {'type': 'compliance', 'label': 'Compliance', 'icon': Icons.verified_user, 'color': Colors.orange},
    {'type': 'rating', 'label': 'Rating', 'icon': Icons.star, 'color': Colors.amber},
    {'type': 'custom', 'label': 'Custom', 'icon': Icons.event, 'color': Colors.grey},
  ];

  void _showAddOrEditEventDialog(BuildContext context, {Map<String, dynamic>? event, int? index}) {
    String? eventType = event?['type'] ?? eventTypes.first['type'];
    DateTime eventDate = event != null && event['date'] != null
        ? DateTime.tryParse(event['date']) ?? DateTime.now()
        : DateTime.now();
    final descController = TextEditingController(text: event?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Add Timeline Event' : 'Edit Timeline Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: eventType,
              items: eventTypes
                  .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                        value: e['type'] as String,
                        child: Text(e['label'] as String),
                      ))
                  .toList(),
              onChanged: (val) => eventType = val,
              decoration: const InputDecoration(labelText: 'Event Type'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              children: [
                const Text('Date:'),
                const SizedBox(width: 8),
                Text(DateFormat('yyyy-MM-dd').format(eventDate)),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: eventDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        eventDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (event != null)
            TextButton(
              onPressed: () async {
                // Delete event
                if (selectedSupplierId != null) {
                  final docRef = FirebaseFirestore.instance.collection('suppliers').doc(selectedSupplierId);
                  await docRef.update({
                    'timeline': FieldValue.arrayRemove([event])
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
                final newEvent = {
                  'date': eventDate.toIso8601String(),
                  'type': eventType,
                  'description': descController.text,
                };
                if (event == null) {
                  // Add event
                  await docRef.update({
                    'timeline': FieldValue.arrayUnion([newEvent])
                  });
                } else {
                  // Edit event: remove old, add new
                  await docRef.update({
                    'timeline': FieldValue.arrayRemove([event])
                  });
                  await docRef.update({
                    'timeline': FieldValue.arrayUnion([newEvent])
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(event == null ? 'Add' : 'Save'),
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
                  final supplier = Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(supplier.supplierName),
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
                  label: const Text('Add Event'),
                  onPressed: () => _showAddOrEditEventDialog(context),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: filterType,
                  hint: const Text('Filter by Type'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...eventTypes.map((e) => DropdownMenuItem(
                          value: e['type'],
                          child: Text(e['label']),
                        )),
                  ],
                  onChanged: (val) => setState(() => filterType = val),
                ),
              ],
            ),
          ),
        const Divider(),
        // Timeline with connectors
        Expanded(
          child: selectedSupplierId == null
              ? const Center(child: Text('Select a supplier to view timeline.'))
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('suppliers')
                      .doc(selectedSupplierId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    List<dynamic> timeline = data['timeline'] ?? [];

                    // Filter by type if needed
                    if (filterType != null) {
                      timeline = timeline.where((e) => e['type'] == filterType).toList();
                    }

                    if (timeline.isEmpty) {
                      return const Center(child: Text('No events found for this supplier.'));
                    }

                    // Sort events by date descending
                    timeline.sort((a, b) {
                      final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
                      final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
                      return bDate.compareTo(aDate);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: timeline.length,
                      itemBuilder: (context, index) {
                        final event = timeline[index];
                        final date = event['date'] ?? '';
                        final type = event['type'] ?? '';
                        final desc = event['description'] ?? '';
                        final typeInfo = eventTypes.firstWhere(
                          (e) => e['type'] == type,
                          orElse: () => eventTypes.last,
                        );
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline connector
                            Column(
                              children: [
                                // Top connector
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
                                // Bottom connector
                                if (index != timeline.length - 1)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.grey.shade400,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
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
                                        _showAddOrEditEventDialog(context, event: event, index: index);
                                      } else if (value == 'delete') {
                                        // Delete event
                                        if (selectedSupplierId != null) {
                                          final docRef = FirebaseFirestore.instance.collection('suppliers').doc(selectedSupplierId);
                                          docRef.update({
                                            'timeline': FieldValue.arrayRemove([event])
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