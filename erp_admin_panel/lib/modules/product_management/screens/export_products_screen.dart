import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/file_download_service.dart';

class ExportProductsScreen extends StatefulWidget {
  const ExportProductsScreen({Key? key}) : super(key: key);

  @override
  State<ExportProductsScreen> createState() => _ExportProductsScreenState();
}

class _ExportProductsScreenState extends State<ExportProductsScreen> {
  bool _exporting = false;
  String? _exportResult;

  Future<void> _exportProducts() async {
    setState(() { _exporting = true; _exportResult = null; });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        setState(() { _exporting = false; _exportResult = 'No products to export.'; });
        return;
      }
      final headers = docs.first.data().keys.toList();
      final rows = [headers];
      for (final doc in docs) {
        final data = doc.data();
        rows.add(headers.map((h) => (data[h] ?? '').toString()).toList());
      }
      final csv = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csv));
      await FileDownloadService.downloadFile(bytes, 'products_export.csv');
      setState(() { _exporting = false; _exportResult = 'Export successful!'; });
    } catch (e) {
      setState(() { _exporting = false; _exportResult = 'Export failed: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, size: 64, color: Colors.deepPurple),
          const SizedBox(height: 16),
          const Text('Export Products', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Download all products as a CSV file.'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: _exporting ? const Text('Exporting...') : const Text('Export Now'),
            onPressed: _exporting ? null : _exportProducts,
          ),
          if (_exporting) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
          if (_exportResult != null) ...[
            const SizedBox(height: 16),
            Text(_exportResult!, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }
}
