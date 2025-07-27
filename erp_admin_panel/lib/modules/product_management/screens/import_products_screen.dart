import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImportProductsScreen extends StatefulWidget {
  @override
  _ImportProductsScreenState createState() => _ImportProductsScreenState();
}

class _ImportProductsScreenState extends State<ImportProductsScreen> {
  String? _fileName;
  String? _feedbackMessage;
  Color _feedbackColor = Colors.green;
  List<List<dynamic>>? _csvRows;
  List<String> _requiredColumns = [
    'product_name',
    'category',
    'selling_price',
    'product_status',
    // add other required columns here
  ];

  Future<void> _pickFile() async {
    setState(() {
      _feedbackMessage = null;
      _csvRows = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.bytes != null) {
      final content = utf8.decode(result.files.single.bytes!);
      final rows = const CsvToListConverter().convert(content);
      setState(() {
        _fileName = result.files.single.name;
        _csvRows = rows;
      });

      // Normalize headers for robust matching
      final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
      print('Detected headers: $headers'); // Debug print

      final required = _requiredColumns.map((e) => e.trim().toLowerCase()).toList();
      final missing = required.where((col) => !headers.contains(col)).toList();
      if (missing.isNotEmpty) {
        setState(() {
          _feedbackMessage = 'Missing columns: ${missing.join(', ')}';
          _feedbackColor = Colors.red;
        });
        return;
      }

      setState(() {
        _feedbackMessage = 'File loaded successfully!';
        _feedbackColor = Colors.green;
      });
    } else {
      setState(() {
        _feedbackMessage = 'No file selected or file is empty.';
        _feedbackColor = Colors.red;
      });
    }
  }

  Future<void> _importToFirestore() async {
    if (_csvRows == null) return;
    final headers = _csvRows!.first.map((e) => e.toString().trim().toLowerCase()).toList();
    int imported = 0, failed = 0;

    for (var row in _csvRows!.skip(1)) {
      try {
        final product = <String, dynamic>{};
        for (int i = 0; i < headers.length; i++) {
          product[headers[i]] = row[i].toString();
        }
        product['product_id'] ??= FirebaseFirestore.instance.collection('products').doc().id;

        // Optional: Check for duplicates by product_name
        final dup = await FirebaseFirestore.instance
            .collection('products')
            .where('product_name', isEqualTo: product['product_name'])
            .get();
        if (dup.docs.isNotEmpty) continue;

        await FirebaseFirestore.instance.collection('products').doc(product['product_id']).set(product);
        imported++;
      } catch (e) {
        failed++;
      }
    }

    setState(() {
      _feedbackMessage = 'Import complete: $imported imported, $failed failed.';
      _feedbackColor = Colors.green;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import Products')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload a CSV file to import products.', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text('Change File'),
              onPressed: _pickFile,
            ),
            if (_fileName != null) ...[
              SizedBox(height: 8),
              Text('Selected: $_fileName'),
            ],
            if (_feedbackMessage != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                color: _feedbackColor.withOpacity(0.2),
                child: Text(_feedbackMessage!, style: TextStyle(color: _feedbackColor)),
              ),
            ],
            if (_csvRows != null && _feedbackColor == Colors.green) ...[
              SizedBox(height: 24),
              Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _csvRows!.first
                        .map<DataColumn>((e) => DataColumn(label: Text(e.toString())))
                        .toList(),
                    rows: _csvRows!
                        .skip(1)
                        .take(10)
                        .map<DataRow>((row) => DataRow(
                              cells: row
                                  .map<DataCell>((cell) => DataCell(Text(cell.toString())))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _importToFirestore,
                child: Text('Import to Firestore'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}