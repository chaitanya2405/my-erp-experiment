import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/inventory_models.dart';
import '../models/inventory_service.dart';

class InventoryDetailScreen extends StatefulWidget {
  final InventoryRecord record;
  const InventoryDetailScreen({required this.record, Key? key}) : super(key: key);

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  late final InventoryService _service;
  DocumentSnapshot? _productSnapshot;
  bool _loadingProduct = true;

  @override
  void initState() {
    super.initState();
    _service = InventoryService();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() => _loadingProduct = true);
    final snap = await FirebaseFirestore.instance.collection('products').doc(widget.record.productId).get();
    setState(() {
      _productSnapshot = snap.exists ? snap : null;
      _loadingProduct = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Detail', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple.shade700,
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(),
            _buildMovementLogsTab(),
            _buildAuditTrailTab(),
            _buildAnalyticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_loadingProduct)
          const Center(child: CircularProgressIndicator()),
        if (!_loadingProduct && _productSnapshot != null)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.shopping_bag, size: 40, color: Colors.deepPurple),
              title: Text(_productSnapshot!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('SKU: \\${_productSnapshot!['sku'] ?? ''}\nCategory: \\${_productSnapshot!['category'] ?? ''}'),
            ),
          ),
        if (!_loadingProduct && _productSnapshot == null)
          const Text('Product details not found.', style: TextStyle(color: Colors.red)),
        Text('Product ID: \${widget.record.productId}'),
        Text('Category: \${widget.record.category ?? ''}'),
        Text('Brand: \${widget.record.brand ?? ''}'),
        Text('Location: \${widget.record.storeLocation}'),
        Text('Batch: \${widget.record.batchNumber}'),
        Text('Status: \${widget.record.stockStatus}'),
        Text('Expiry: \${widget.record.expiryDate?.toString().split(' ').first ?? ''}'),
        Text('Qty Available: \${widget.record.quantityAvailable}'),
        Text('Qty Reserved: \${widget.record.quantityReserved}'),
        Text('Qty On Order: \${widget.record.quantityOnOrder}'),
        Text('Qty Damaged: \${widget.record.quantityDamaged}'),
        Text('Qty Returned: \${widget.record.quantityReturned}'),
        Text('Reorder Point: \${widget.record.reorderPoint}'),
        Text('Storage Location: \${widget.record.storageLocation}'),
        Text('Entry Mode: \${widget.record.entryMode}'),
        Text('Last Updated: \${widget.record.lastUpdated.toDate().toString()}'),
        Text('Added By: \${widget.record.addedBy}'),
        Text('Remarks: \${widget.record.remarks}'),
        Text('FIFO/LIFO: \${widget.record.fifoLifoFlag}'),
        Text('Audit Flag: \${widget.record.auditFlag}'),
        Text('Auto Restock: \${widget.record.autoRestockEnabled}'),
        Text('Last Sold: \${widget.record.lastSoldDate?.toString().split(' ').first ?? ''}'),
        Text('Safety Stock: \${widget.record.safetyStockLevel}'),
        Text('Avg Daily Usage: \${widget.record.averageDailyUsage}'),
        Text('Turnover Ratio: \${widget.record.stockTurnoverRatio}'),
      ],
    );
  }

  Widget _buildMovementLogsTab() {
    return StreamBuilder<List<InventoryMovementLog>>(
      stream: _service.getMovementsForProduct(widget.record.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text('No movement logs.'));
        }
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final log = logs[i];
            return ListTile(
              title: Text('Type: \\${log.movementType} | Qty: \\${log.quantity}'),
              subtitle: Text('From: \\${log.fromLocation} To: \\${log.toLocation}\nBy: \\${log.initiatedBy}'),
              trailing: Text(log.timestamp.toDate().toString()),
            );
          },
        );
      },
    );
  }

  Widget _buildAuditTrailTab() {
    // For demo, reuse movement logs as audit trail
    return StreamBuilder<List<InventoryMovementLog>>(
      stream: _service.getMovementsForProduct(widget.record.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text('No audit trail.'));
        }
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final log = logs[i];
            return ListTile(
              title: Text('Action: \\${log.movementType}'),
              subtitle: Text('By: \\${log.initiatedBy} | Verified: \\${log.verifiedBy ?? '-'}'),
              trailing: Text(log.timestamp.toDate().toString()),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Center(child: Text('Analytics coming soon'));
  }
}
