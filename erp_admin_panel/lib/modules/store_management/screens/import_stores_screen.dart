import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/store_models.dart';
import '../services/store_service.dart';

/// 📁 Import Stores Screen
/// Bulk import stores from CSV/Excel files
class ImportStoresScreen extends StatefulWidget {
  @override
  _ImportStoresScreenState createState() => _ImportStoresScreenState();
}

class _ImportStoresScreenState extends State<ImportStoresScreen> {
  bool _isLoading = false;
  String? _fileName;
  Uint8List? _fileData;
  List<Map<String, dynamic>> _previewData = [];
  List<String> _validationErrors = [];
  bool _showPreview = false;
  int _totalRecords = 0;
  int _validRecords = 0;
  int _invalidRecords = 0;

  @override
  void initState() {
    super.initState();
    print('📁 Initializing Import Stores Screen...');
    print('  📊 Setting up CSV/Excel import functionality');
    print('  ✅ Preparing data validation and preview');
    print('  🎯 Ready for bulk store import');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.upload_file, color: Colors.indigo, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Import Stores',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _downloadTemplate,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Template'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            if (!_showPreview) ...[
              // Instructions Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.info, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Import Instructions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Follow these steps to import stores:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionStep(
                        '1',
                        'Download Template',
                        'Use the template file to ensure correct format',
                        Icons.download,
                        Colors.green,
                      ),
                      _buildInstructionStep(
                        '2',
                        'Fill Store Data',
                        'Add your store information to the template',
                        Icons.edit,
                        Colors.blue,
                      ),
                      _buildInstructionStep(
                        '3',
                        'Upload File',
                        'Select your CSV or Excel file for import',
                        Icons.upload,
                        Colors.orange,
                      ),
                      _buildInstructionStep(
                        '4',
                        'Review & Import',
                        'Preview data and confirm import',
                        Icons.check_circle,
                        Colors.purple,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.yellow[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Important Notes:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('• Store codes must be unique'),
                            const Text('• All required fields must be filled'),
                            const Text('• Supported formats: CSV, Excel (.xlsx)'),
                            const Text('• Maximum file size: 10MB'),
                            const Text('• GPS coordinates should be in decimal format'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Upload Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Store Data',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // File Upload Area
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _fileName != null ? Colors.green : Colors.grey[300]!,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: _fileName != null ? Colors.green[50] : Colors.grey[50],
                        ),
                        child: InkWell(
                          onTap: _isLoading ? null : _selectFile,
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _fileName != null ? Icons.check_circle : Icons.cloud_upload,
                                size: 48,
                                color: _fileName != null ? Colors.green : Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _fileName ?? 'Click to select file or drag and drop',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _fileName != null ? Colors.green[700] : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _fileName != null 
                                    ? 'File selected successfully'
                                    : 'Supports CSV and Excel files (max 10MB)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Row(
                        children: [
                          if (_fileName != null) ...[
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _clearFile,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_fileName != null && !_isLoading) ? _processFile : null,
                              icon: _isLoading 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.preview),
                              label: Text(_isLoading ? 'Processing...' : 'Preview Data'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Preview Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.preview, color: Colors.indigo, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Data Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _showPreview = false),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Summary Stats
                      Row(
                        children: [
                          _buildStatCard('Total Records', _totalRecords.toString(), Colors.blue),
                          const SizedBox(width: 16),
                          _buildStatCard('Valid Records', _validRecords.toString(), Colors.green),
                          const SizedBox(width: 16),
                          _buildStatCard('Invalid Records', _invalidRecords.toString(), Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Validation Errors
                      if (_validationErrors.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Validation Errors:',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._validationErrors.take(5).map((error) => Text('• $error')),
                              if (_validationErrors.length > 5)
                                Text('... and ${_validationErrors.length - 5} more errors'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Data Table
                      if (_previewData.isNotEmpty) ...[
                        const Text(
                          'Preview (First 5 records):',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Store Code')),
                              DataColumn(label: Text('Store Name')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('City')),
                              DataColumn(label: Text('State')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _previewData.take(5).map((store) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(store['store_code'] ?? '')),
                                  DataCell(Text(store['store_name'] ?? '')),
                                  DataCell(Text(store['store_type'] ?? '')),
                                  DataCell(Text(store['city'] ?? '')),
                                  DataCell(Text(store['state'] ?? '')),
                                  DataCell(Text(store['status'] ?? '')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Import Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_validRecords > 0 && !_isLoading) ? _importStores : null,
                              icon: _isLoading 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.upload),
                              label: Text(_isLoading ? 'Importing...' : 'Import $_validRecords Stores'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _fileName = result.files.single.name;
          _fileData = result.files.single.bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFile() {
    setState(() {
      _fileName = null;
      _fileData = null;
      _showPreview = false;
      _previewData.clear();
      _validationErrors.clear();
    });
  }

  Future<void> _processFile() async {
    if (_fileData == null) return;

    setState(() => _isLoading = true);

    try {
      // Simulate file processing
      await Future.delayed(const Duration(seconds: 2));

      // Mock data for demo
      _previewData = [
        {
          'store_code': 'STR001',
          'store_name': 'Downtown Store',
          'store_type': 'Retail',
          'city': 'Mumbai',
          'state': 'Maharashtra',
          'status': 'Active',
          'contact_person': 'John Doe',
          'contact_number': '+91 9876543210',
          'email': 'downtown@store.com',
        },
        {
          'store_code': 'STR002',
          'store_name': 'Mall Outlet',
          'store_type': 'Retail',
          'city': 'Delhi',
          'state': 'Delhi',
          'status': 'Active',
          'contact_person': 'Jane Smith',
          'contact_number': '+91 9876543211',
          'email': 'mall@store.com',
        },
        // Add more mock data as needed
      ];

      _totalRecords = _previewData.length;
      _validRecords = _previewData.length - 1; // Simulate one invalid record
      _invalidRecords = 1;

      _validationErrors = [
        'Row 3: Store code STR003 already exists',
      ];

      setState(() {
        _showPreview = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importStores() async {
    setState(() => _isLoading = true);

    try {
      // Simulate import process
      await Future.delayed(const Duration(seconds: 3));

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported $_validRecords stores'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _clearFile();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing stores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadTemplate() {
    // In a real app, this would download a CSV template
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template download would start here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
