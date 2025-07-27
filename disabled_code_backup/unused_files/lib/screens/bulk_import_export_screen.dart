import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../models/inventory_service.dart';

class BulkImportExportScreen extends StatefulWidget {
  const BulkImportExportScreen({Key? key}) : super(key: key);

  @override
  State<BulkImportExportScreen> createState() => _BulkImportExportScreenState();
}

class _BulkImportExportScreenState extends State<BulkImportExportScreen> {
  final InventoryService _service = InventoryService();
  String? _importStatus;
  String? _exportStatus;

  Future<void> _importCSV() async {
    setState(() => _importStatus = null);
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null && result.files.single.bytes != null) {
      final csv = utf8.decode(result.files.single.bytes!);
      final lines = const LineSplitter().convert(csv);
      if (lines.isEmpty) return;
      final headers = lines.first.split(',');
      for (var i = 1; i < lines.length; i++) {
        final values = lines[i].split(',');
        if (values.length != headers.length) continue;
        final data = Map<String, String>.fromIterables(headers, values);
        final record = InventoryRecord(
          inventoryId: data['inventory_id'] ?? '',
          productId: data['product_id'] ?? '',
          storeLocation: data['store_location'] ?? '',
          quantityAvailable: num.tryParse(data['quantity_available'] ?? '0') ?? 0,
          quantityReserved: num.tryParse(data['quantity_reserved'] ?? '0') ?? 0,
          quantityOnOrder: num.tryParse(data['quantity_on_order'] ?? '0') ?? 0,
          quantityDamaged: num.tryParse(data['quantity_damaged'] ?? '0') ?? 0,
          quantityReturned: num.tryParse(data['quantity_returned'] ?? '0') ?? 0,
          reorderPoint: num.tryParse(data['reorder_point'] ?? '0') ?? 0,
          batchNumber: data['batch_number'] ?? '',
          expiryDate: data['expiry_date'] != null && data['expiry_date']!.isNotEmpty ? DateTime.tryParse(data['expiry_date']!) : null,
          manufactureDate: data['manufacture_date'] != null && data['manufacture_date']!.isNotEmpty ? DateTime.tryParse(data['manufacture_date']!) : null,
          storageLocation: data['storage_location'] ?? '',
          entryMode: data['entry_mode'] ?? '',
          lastUpdated: Timestamp.now(),
          stockStatus: data['stock_status'] ?? '',
          addedBy: data['added_by'] ?? '',
          remarks: data['remarks'] ?? '',
          fifoLifoFlag: data['fifo_lifo_flag'] ?? '',
          auditFlag: data['audit_flag'] == 'true',
          autoRestockEnabled: data['auto_restock_enabled'] == 'true',
          lastSoldDate: data['last_sold_date'] != null && data['last_sold_date']!.isNotEmpty ? DateTime.tryParse(data['last_sold_date']!) : null,
          safetyStockLevel: num.tryParse(data['safety_stock_level'] ?? '0') ?? 0,
          averageDailyUsage: num.tryParse(data['average_daily_usage'] ?? '0') ?? 0,
          stockTurnoverRatio: num.tryParse(data['stock_turnover_ratio'] ?? '0') ?? 0,
        );
        await _service.addInventory(record);
      }
      setState(() => _importStatus = 'Import complete!');
    }
  }

  Future<void> _exportCSV() async {
    setState(() => _exportStatus = null);
    final snapshot = await FirebaseFirestore.instance.collection('inventory').get();
    final records = snapshot.docs.map((doc) => InventoryRecord.fromFirestore(doc));
    final headers = [
      'inventory_id','product_id','store_location','quantity_available','quantity_reserved','quantity_on_order','quantity_damaged','quantity_returned','reorder_point','batch_number','expiry_date','manufacture_date','storage_location','entry_mode','last_updated','stock_status','added_by','remarks','fifo_lifo_flag','audit_flag','auto_restock_enabled','last_sold_date','safety_stock_level','average_daily_usage','stock_turnover_ratio'
    ];
    final rows = [headers.join(',')];
    for (final r in records) {
      rows.add([
        r.inventoryId,
        r.productId,
        r.storeLocation,
        r.quantityAvailable,
        r.quantityReserved,
        r.quantityOnOrder,
        r.quantityDamaged,
        r.quantityReturned,
        r.reorderPoint,
        r.batchNumber,
        r.expiryDate?.toIso8601String() ?? '',
        r.manufactureDate?.toIso8601String() ?? '',
        r.storageLocation,
        r.entryMode,
        r.lastUpdated.toDate().toIso8601String(),
        r.stockStatus,
        r.addedBy,
        r.remarks,
        r.fifoLifoFlag,
        r.auditFlag,
        r.autoRestockEnabled,
        r.lastSoldDate?.toIso8601String() ?? '',
        r.safetyStockLevel,
        r.averageDailyUsage,
        r.stockTurnoverRatio,
      ].join(','));
    }
    final csv = rows.join('\n');
    // TODO: Save csv to file or share
    setState(() => _exportStatus = 'Export complete!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Import/Export', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.deepPurple.shade700),
      body: Center(
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.upload_file, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text('Drag and drop CSV/Excel file here', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _importCSV,
                  child: const Text('Import'),
                ),
                if (_importStatus != null) Text(_importStatus!, style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _exportCSV,
                  child: const Text('Export'),
                ),
                if (_exportStatus != null) Text(_exportStatus!, style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
