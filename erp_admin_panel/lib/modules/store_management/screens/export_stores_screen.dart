import 'package:flutter/material.dart';
import '../models/store_models.dart';
import '../services/store_service.dart';
import '../services/file_download_service.dart';

/// 📤 Export Stores Screen
/// Export stores data to various formats (CSV, Excel, PDF)
class ExportStoresScreen extends StatefulWidget {
  @override
  _ExportStoresScreenState createState() => _ExportStoresScreenState();
}

class _ExportStoresScreenState extends State<ExportStoresScreen> {
  String _selectedFormat = 'CSV';
  String _selectedStoreType = 'All';
  String _selectedStatus = 'All';
  String _selectedFields = 'All Fields';
  bool _isLoading = false;
  bool _includePerformanceData = false;
  bool _includeTransferHistory = false;
  
  List<Store> _stores = [];
  int _totalRecords = 0;
  
  final List<String> _formats = ['CSV', 'Excel', 'PDF'];
  final List<String> _storeTypes = ['All', 'Retail', 'Warehouse', 'Distribution Center'];
  final List<String> _statusOptions = ['All', 'Active', 'Inactive', 'Under Renovation'];
  final List<String> _fieldOptions = [
    'All Fields',
    'Basic Info Only',
    'Contact Details',
    'Location Data',
    'Business Data',
  ];

  @override
  void initState() {
    super.initState();
    _loadStores();
    
    print('📤 Initializing Export Stores Screen...');
    print('  📊 Loading store data for export');
    print('  🎯 Setting up export format options');
    print('  📋 Preparing customizable field selection');
    print('  ✅ Ready for data export');
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    
    try {
      final storesStream = StoreService.getStoresStream();
      final storesSnapshot = await storesStream.first;
      
      setState(() {
        _stores = storesSnapshot;
        _totalRecords = _getFilteredStores().length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading stores: $e');
    }
  }

  List<Store> _getFilteredStores() {
    return _stores.where((store) {
      // Type filter
      if (_selectedStoreType != 'All' && store.storeType != _selectedStoreType) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus != 'All' && store.storeStatus != _selectedStatus) {
        return false;
      }
      
      return true;
    }).toList();
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
                const Icon(Icons.download, color: Colors.indigo, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Export Stores',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                if (_totalRecords > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo[200]!),
                    ),
                    child: Text(
                      '$_totalRecords stores selected',
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Configuration Panel
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Export Configuration',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Format Selection
                          const Text(
                            'Export Format',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _formats.map((format) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFormatOption(format),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          
                          // Filters
                          const Text(
                            'Data Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStoreType,
                                  decoration: InputDecoration(
                                    labelText: 'Store Type',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  items: _storeTypes.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )).toList(),
                                  onChanged: (value) => setState(() {
                                    _selectedStoreType = value!;
                                    _totalRecords = _getFilteredStores().length;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  items: _statusOptions.map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  )).toList(),
                                  onChanged: (value) => setState(() {
                                    _selectedStatus = value!;
                                    _totalRecords = _getFilteredStores().length;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Field Selection
                          const Text(
                            'Field Selection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedFields,
                            decoration: InputDecoration(
                              labelText: 'Fields to Export',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _fieldOptions.map((fields) => DropdownMenuItem(
                              value: fields,
                              child: Text(fields),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedFields = value!),
                          ),
                          const SizedBox(height: 24),
                          
                          // Additional Options
                          const Text(
                            'Additional Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            title: const Text('Include Performance Data'),
                            subtitle: const Text('Add sales and transaction metrics'),
                            value: _includePerformanceData,
                            onChanged: (value) => setState(() => _includePerformanceData = value!),
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Include Transfer History'),
                            subtitle: const Text('Add inter-store transfer records'),
                            value: _includeTransferHistory,
                            onChanged: (value) => setState(() => _includeTransferHistory = value!),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 32),
                          
                          // Export Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (_totalRecords > 0 && !_isLoading) ? _exportData : null,
                              icon: _isLoading 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(_isLoading 
                                  ? 'Exporting...' 
                                  : 'Export $_totalRecords Stores'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                
                // Preview Panel
                Expanded(
                  flex: 3,
                  child: Card(
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
                                'Export Preview',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => setState(() {
                                  _totalRecords = _getFilteredStores().length;
                                }),
                                icon: const Icon(Icons.refresh),
                                tooltip: 'Refresh Preview',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Preview Stats
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPreviewStat('Total Stores', '$_totalRecords'),
                                    _buildPreviewStat('Format', _selectedFormat),
                                    _buildPreviewStat('Filters', _getFilterDescription()),
                                  ],
                                ),
                                if (_includePerformanceData || _includeTransferHistory) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (_includePerformanceData)
                                        const Chip(
                                          label: Text('+ Performance Data'),
                                          backgroundColor: Colors.green,
                                          labelStyle: TextStyle(color: Colors.white),
                                        ),
                                      if (_includePerformanceData && _includeTransferHistory)
                                        const SizedBox(width: 8),
                                      if (_includeTransferHistory)
                                        const Chip(
                                          label: Text('+ Transfer History'),
                                          backgroundColor: Colors.orange,
                                          labelStyle: TextStyle(color: Colors.white),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Field Preview
                          const Text(
                            'Fields to be exported:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _getFieldsToExport().map((field) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check, size: 16, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(field),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Sample Data
                          if (_getFilteredStores().isNotEmpty) ...[
                            const Text(
                              'Sample Data (First 3 records):',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 24,
                                columns: const [
                                  DataColumn(label: Text('Store Code')),
                                  DataColumn(label: Text('Store Name')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('City')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: _getFilteredStores().take(3).map((store) {
                                  return DataRow(cells: [
                                    DataCell(Text(store.storeCode)),
                                    DataCell(Text(store.storeName)),
                                    DataCell(Text(store.storeType)),
                                    DataCell(Text(store.city)),
                                    DataCell(_buildStatusChip(store.storeStatus)),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(String format) {
    final isSelected = _selectedFormat == format;
    IconData icon;
    Color color;
    
    switch (format) {
      case 'CSV':
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      case 'Excel':
        icon = Icons.grid_on;
        color = Colors.blue;
        break;
      case 'PDF':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      default:
        icon = Icons.file_copy;
        color = Colors.grey;
    }
    
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              format,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Active':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'Inactive':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'Under Renovation':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getFilterDescription() {
    List<String> filters = [];
    if (_selectedStoreType != 'All') filters.add(_selectedStoreType);
    if (_selectedStatus != 'All') filters.add(_selectedStatus);
    return filters.isEmpty ? 'None' : filters.join(', ');
  }

  List<String> _getFieldsToExport() {
    switch (_selectedFields) {
      case 'Basic Info Only':
        return ['Store Code', 'Store Name', 'Store Type', 'Status'];
      case 'Contact Details':
        return ['Store Code', 'Store Name', 'Contact Person', 'Phone', 'Email'];
      case 'Location Data':
        return ['Store Code', 'Store Name', 'Address', 'City', 'State', 'Country', 'GPS Coordinates'];
      case 'Business Data':
        return ['Store Code', 'Store Name', 'Type', 'Area', 'Operating Hours', 'GST Number', 'Manager'];
      default:
        return [
          'Store Code', 'Store Name', 'Store Type', 'Status', 'Contact Person',
          'Phone', 'Email', 'Address', 'City', 'State', 'Country', 'Operating Hours',
          'Area (sq ft)', 'GST Number', 'Manager', 'Created Date'
        ];
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));
      
      final filteredStores = _getFilteredStores();
      
      // In a real app, this would generate the actual file
      switch (_selectedFormat) {
        case 'CSV':
          await _exportToCSV(filteredStores);
          break;
        case 'Excel':
          await _exportToExcel(filteredStores);
          break;
        case 'PDF':
          await _exportToPDF(filteredStores);
          break;
      }
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully exported ${filteredStores.length} stores to $_selectedFormat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToCSV(List<Store> stores) async {
    // In a real app, this would use the FileDownloadService to generate and download CSV
    print('Exporting ${stores.length} stores to CSV...');
  }

  Future<void> _exportToExcel(List<Store> stores) async {
    // In a real app, this would use the FileDownloadService to generate and download Excel
    print('Exporting ${stores.length} stores to Excel...');
  }

  Future<void> _exportToPDF(List<Store> stores) async {
    // In a real app, this would use the FileDownloadService to generate and download PDF
    print('Exporting ${stores.length} stores to PDF...');
  }
}
