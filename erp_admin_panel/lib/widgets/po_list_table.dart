import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';
import 'po_status_chip.dart';

class PoListTable extends StatefulWidget {
  const PoListTable({Key? key}) : super(key: key);

  @override
  State<PoListTable> createState() => _PoListTableState();
}

class _PoListTableState extends State<PoListTable> {
  final PurchaseOrderService _service = PurchaseOrderService();
  late Future<List<PurchaseOrder>> _futurePOs;
  String _search = '';
  String _statusFilter = 'All';
  final List<String> _statusOptions = ['All', 'Draft', 'Pending', 'Approved', 'Rejected'];
  Set<String> _selectedPOs = {};

  @override
  void initState() {
    super.initState();
    _futurePOs = _service.fetchPurchaseOrders();
  }

  List<PurchaseOrder> _applyFilters(List<PurchaseOrder> pos) {
    return pos.where((po) {
      final matchesSearch = _search.isEmpty ||
        po.id.toLowerCase().contains(_search.toLowerCase()) ||
        po.supplierId.toLowerCase().contains(_search.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || po.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _exportToCSV(List<PurchaseOrder> pos) async {
    final headers = ['PO #', 'Supplier', 'Date', 'Status', 'Total'];
    final rows = pos.map((po) => [
      po.id,
      po.supplierId,
      po.date.toLocal().toString().split(' ')[0],
      po.status,
      po.totalAmount.toStringAsFixed(2),
    ]).toList();
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(row.map((e) => '"$e"').join(','));
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/purchase_orders.csv');
    await file.writeAsString(csv.toString());
    await Share.shareFiles([file.path], text: 'Purchase Orders Export');
  }

  void _toggleSelect(String poId, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedPOs.add(poId);
      } else {
        _selectedPOs.remove(poId);
      }
    });
  }

  Future<void> _bulkUpdateStatus(String status) async {
    final service = PurchaseOrderService();
    for (final poId in _selectedPOs) {
      await service.updatePurchaseOrder(poId, {'status': status});
    }
    setState(() {
      _futurePOs = _service.fetchPurchaseOrders();
      _selectedPOs.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk $status complete')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by PO # or Supplier',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _statusFilter,
                items: _statusOptions.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _statusFilter = val);
                },
                hint: const Text('Status'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final pos = _applyFilters(await _futurePOs);
                  await _exportToCSV(pos);
                },
                icon: const Icon(Icons.download),
                label: const Text('Export CSV'),
              ),
            ],
          ),
        ),
        FutureBuilder<List<PurchaseOrder>>(
          future: _futurePOs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No Purchase Orders found.'));
            }
            final filtered = _applyFilters(snapshot.data!);
            if (filtered.isEmpty) {
              return const Center(child: Text('No Purchase Orders match your filters.'));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Checkbox(
                      value: _selectedPOs.length == filtered.length && filtered.isNotEmpty,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedPOs = filtered.map((po) => po.id).toSet();
                          } else {
                            _selectedPOs.clear();
                          }
                        });
                      },
                    ),
                  ),
                  const DataColumn(label: Text('PO #')),
                  const DataColumn(label: Text('Supplier')),
                  const DataColumn(label: Text('Date')),
                  const DataColumn(label: Text('Status')),
                  const DataColumn(label: Text('Total')),
                  const DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map((po) => DataRow(
                  selected: _selectedPOs.contains(po.id),
                  onSelectChanged: (selected) => _toggleSelect(po.id, selected),
                  cells: [
                    DataCell(Checkbox(
                      value: _selectedPOs.contains(po.id),
                      onChanged: (selected) => _toggleSelect(po.id, selected),
                    )),
                    DataCell(Text(po.id)),
                    DataCell(Text(po.supplierId)),
                    DataCell(Text(po.date.toLocal().toString().split(' ')[0])),
                    DataCell(POStatusChip(status: po.status)),
                    DataCell(Text(po.totalAmount.toStringAsFixed(2))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: 'View',
                          onPressed: () {
                            Navigator.pushNamed(context, '/po/detail', arguments: po.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () {
                            Navigator.pushNamed(context, '/po/edit', arguments: po.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle),
                          tooltip: 'Approve',
                          onPressed: po.status == 'Approved' ? null : () async {
                            await _service.updatePurchaseOrder(po.id, {'status': 'Approved'});
                            setState(() => _futurePOs = _service.fetchPurchaseOrders());
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PO Approved')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          tooltip: 'Reject',
                          onPressed: po.status == 'Rejected' ? null : () async {
                            await _service.updatePurchaseOrder(po.id, {'status': 'Rejected'});
                            setState(() => _futurePOs = _service.fetchPurchaseOrders());
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PO Rejected')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          tooltip: 'Communicate',
                          onPressed: () {
                            // Open Communication tab for this PO
                            Navigator.pushNamed(context, '/po/communicate', arguments: po.id);
                          },
                        ),
                      ],
                    )),
                  ],
                )).toList(),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (_selectedPOs.isNotEmpty) ...[
                ElevatedButton(
                  onPressed: () => _bulkUpdateStatus('Approved'),
                  child: const Text('Bulk Approve'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _bulkUpdateStatus('Rejected'),
                  child: const Text('Bulk Reject'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final pos = _applyFilters(await _futurePOs)
                        .where((po) => _selectedPOs.contains(po.id))
                        .toList();
                    await _exportToCSV(pos);
                  },
                  child: const Text('Export Selected'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
