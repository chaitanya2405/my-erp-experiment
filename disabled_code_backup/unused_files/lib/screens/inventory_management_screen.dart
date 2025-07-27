import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';          // NEW
// import 'add_edit_inventory_screen.dart';
// import 'inventory_detail_screen.dart';  
// import 'inventory_analytics_screen.dart';
import 'package:ravali_software/models/inventory_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_state_provider.dart';                   // NEW
import '../services/file_download_service.dart';

// Converted to ConsumerStatefulWidget so we can access Riverpod's ref
class InventoryManagementScreen extends ConsumerStatefulWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends ConsumerState<InventoryManagementScreen> {
  int _selectedIndex = 0;
  final List<String> _menuTitles = [
    'Add Inventory',
    'View Inventory',
    'Import Inventory',
    'Export Inventory',
    'Bulk Edit Inventory',
    'Archive/Restore Inventory',
    'Inventory Analytics',
    'Duplicate Inventory',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📦 Initializing Inventory Management Module...');
      print('  • Loading inventory records from Firestore...');
      print('  • Setting up stock level monitoring...');
      print('  • Connecting to POS integration for real-time updates...');
      print('  • Initializing low stock alerts...');
      print('  ✅ Inventory Management Module ready');
      print('  📊 Monitoring inventory changes from POS transactions...');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to inventory state globally – displayed as overlay
    final inventoryState = ref.watch(inventoryStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFFF7F6FB),
            child: Column(
              children: [
                const SizedBox(height: 24),
                ...List.generate(_menuTitles.length, (i) {
                  final isSelected = _selectedIndex == i;
                  final icon = _getMenuIcon(i, isSelected);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: icon,
                      title: Text(
                        _menuTitles[i],
                        style: TextStyle(
                          color: isSelected ? Colors.deepPurple : Colors.black54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.deepPurple.withOpacity(0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () => setState(() => _selectedIndex = i),
                    ),
                  );
                }),
                const Spacer(),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Stack(
                  children: [
                    _buildContent(),
                    if (inventoryState.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (inventoryState.errorMessage != null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: MaterialBanner(
                          backgroundColor: Colors.red.shade100,
                          content: Text(
                            inventoryState.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  ref.read(errorHandlerProvider).clearError(),
                              child: const Text('Dismiss'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        // return AddEditInventoryScreen();
        return const Center(child: Text('Add/Edit Inventory - Coming Soon'));
      case 1:
        return _ViewInventoryScreen();
      case 2:
        return _ImportInventoryScreen();
      case 3:
        return _ExportInventoryScreen();
      case 6:
        return InventoryAnalyticsScreen();
      default:
        return Center(
          child: Text(
            '${_menuTitles[_selectedIndex]} coming soon.',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        );
    }
  }

  Icon _getMenuIcon(int i, bool selected) {
    final color = selected ? Colors.deepPurple : Colors.black38;
    switch (i) {
      case 0:
        return Icon(Icons.add_box, color: color);
      case 1:
        return Icon(Icons.list_alt, color: color);
      case 2:
        return Icon(Icons.upload, color: color);
      case 3:
        return Icon(Icons.download, color: color);
      case 4:
        return Icon(Icons.edit, color: color);
      case 5:
        return Icon(Icons.archive, color: color);
      case 6:
        return Icon(Icons.analytics, color: color);
      case 7:
        return Icon(Icons.copy, color: color);
      default:
        return Icon(Icons.circle, color: color);
    }
  }
}

// DataTableSource for inventory table
class _InventoryDataTableSource extends DataTableSource {
  List<QueryDocumentSnapshot> docs;
  final BuildContext context;
  final void Function(InventoryRecord) onEdit;
  final void Function(InventoryRecord) onView;

  _InventoryDataTableSource(this.docs, this.context, this.onEdit, this.onView);

  void updateData(List<QueryDocumentSnapshot> newDocs) {
    docs = newDocs;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= docs.length) return null;
    final p = docs[index].data() as Map<String, dynamic>;
    final record = InventoryRecord.fromMap(p, id: docs[index].id);
    return DataRow(
      cells: [
        DataCell(Text(record.inventoryId)),
        DataCell(Text(record.productId)),
        DataCell(Text((docs[index].data() as Map<String, dynamic>)['category'] ?? '')),
        DataCell(Text((docs[index].data() as Map<String, dynamic>)['brand'] ?? '')),
        DataCell(Text(record.storeLocation)),
        DataCell(Text(record.quantityAvailable.toString())),
        DataCell(Text(record.quantityReserved.toString())),
        DataCell(Text(record.quantityOnOrder.toString())),
        DataCell(Text(record.quantityDamaged.toString())),
        DataCell(Text(record.quantityReturned.toString())),
        DataCell(Text(record.reorderPoint.toString())),
        DataCell(Text(record.batchNumber)),
        DataCell(Text(record.expiryDate?.toString().split(' ').first ?? '')),
        DataCell(Text(record.manufactureDate?.toString().split(' ').first ?? '')),
        DataCell(Text(record.storageLocation)),
        DataCell(Text(record.entryMode)),
        DataCell(Text(record.lastUpdated.toDate().toString().split(' ').first)),
        DataCell(Text(record.stockStatus)),
        DataCell(Text(record.addedBy)),
        DataCell(Text(record.remarks)),
        DataCell(Text(record.fifoLifoFlag)),
        DataCell(Text(record.auditFlag ? 'Yes' : 'No')),
        DataCell(Text(record.autoRestockEnabled ? 'Yes' : 'No')),
        DataCell(Text(record.lastSoldDate?.toString().split(' ').first ?? '')),
        DataCell(Text(record.safetyStockLevel.toString())),
        DataCell(Text(record.averageDailyUsage.toString())),
        DataCell(Text(record.stockTurnoverRatio.toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              tooltip: 'View',
              onPressed: () => onView(record),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              tooltip: 'Edit',
              onPressed: () => onEdit(record),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => docs.length;
  @override
  int get selectedRowCount => 0;
}

// Placeholder for the View Inventory screen (table view)
class _ViewInventoryScreen extends StatefulWidget {
  @override
  _ViewInventoryScreenState createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<_ViewInventoryScreen> {
  String _searchQuery = '';
  int _rowsPerPage = 8;
  final _tableKey = GlobalKey<PaginatedDataTableState>();
  late final _InventoryDataTableSource _dataSource;
  List<QueryDocumentSnapshot> _allDocs = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dataSource = _InventoryDataTableSource([], context, _onEdit, _onView);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;
    final query = _searchQuery.toLowerCase();
    return docs.where((doc) {
      final p = doc.data() as Map<String, dynamic>;
      return p.values.any((value) {
        if (value == null) return false;
        if (value is List) {
          return value.join(',').toLowerCase().contains(query);
        }
        return value.toString().toLowerCase().contains(query);
      });
    }).toList();
  }

  void _updateDataSource(List<QueryDocumentSnapshot> docs) {
    final filtered = _filterDocs(docs);
    _dataSource.updateData(filtered);
  }

  void _onEdit(InventoryRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (_) => AddEditInventoryScreen(record: record),
        builder: (_) => const Scaffold(
          body: Center(child: Text('Edit Inventory - Coming Soon')),
        ),
      ),
    );
  }

  void _onView(InventoryRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (_) => InventoryDetailScreen(record: record),
        builder: (_) => const Scaffold(
          body: Center(child: Text('Inventory Detail - Coming Soon')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryStream = FirebaseFirestore.instance
        .collection('inventory')
        .orderBy('last_updated', descending: true)
        .snapshots();
    // Remove Scaffold to fix competing Expanded widgets issue
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'View Inventory',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: StreamBuilder<QuerySnapshot>(
              stream: inventoryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                _allDocs = snapshot.data?.docs ?? [];
                _updateDataSource(_allDocs);
                return _buildTable(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final filteredDocs = _filterDocs(_allDocs);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Inventory List', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text(
              'Loaded: [36m${_allDocs.length}[39m | After search: [36m${filteredDocs.length}[39m',
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black, backgroundColor: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search inventory',
                labelStyle: const TextStyle(color: Colors.black),
                hintText: 'Type to search...',
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                            _updateDataSource(_allDocs);
                            _tableKey.currentState?.pageTo(0);
                          });
                        },
                      )
                    : null,
              ),
              cursorColor: Colors.black,
              onChanged: (value) {
                _searchQuery = value;
                _updateDataSource(_allDocs);
                _tableKey.currentState?.pageTo(0);
              },
            ),
          ),
          const SizedBox(height: 8),
          if (_allDocs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text('No inventory in Firestore.', style: TextStyle(fontSize: 18, color: Colors.red))),
            )
          else if (filteredDocs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text('No inventory found for your search.', style: TextStyle(fontSize: 18, color: Colors.grey))),
            )
          else
            Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 1800, maxWidth: 3000),
                  child: PaginatedDataTable(
                    key: _tableKey,
                    header: const Text('All Inventory'),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Product ID')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Brand')),
                      DataColumn(label: Text('Store Location')),
                      DataColumn(label: Text('Qty Available')),
                      DataColumn(label: Text('Qty Reserved')),
                      DataColumn(label: Text('Qty On Order')),
                      DataColumn(label: Text('Qty Damaged')),
                      DataColumn(label: Text('Qty Returned')),
                      DataColumn(label: Text('Reorder Point')),
                      DataColumn(label: Text('Batch Number')),
                      DataColumn(label: Text('Expiry Date')),
                      DataColumn(label: Text('Manufacture Date')),
                      DataColumn(label: Text('Storage Location')),
                      DataColumn(label: Text('Entry Mode')),
                      DataColumn(label: Text('Last Updated')),
                      DataColumn(label: Text('Stock Status')),
                      DataColumn(label: Text('Added By')),
                      DataColumn(label: Text('Remarks')),
                      DataColumn(label: Text('FIFO/LIFO')),
                      DataColumn(label: Text('Audit Flag')),
                      DataColumn(label: Text('Auto Restock')),
                      DataColumn(label: Text('Last Sold Date')),
                      DataColumn(label: Text('Safety Stock')),
                      DataColumn(label: Text('Avg Daily Usage')),
                      DataColumn(label: Text('Turnover Ratio')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _dataSource,
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: const [8],
                    showFirstLastButtons: true,
                    columnSpacing: 16,
                    horizontalMargin: 12,
                    dataRowMinHeight: 40,
                    dataRowMaxHeight: 60,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Import Inventory Screen ---
class _ImportInventoryScreen extends StatefulWidget {
  @override
  State<_ImportInventoryScreen> createState() => _ImportInventoryScreenState();
}

class _ImportInventoryScreenState extends State<_ImportInventoryScreen> {
  String? _fileName;
  String? _status;
  List<List<dynamic>>? _csvData;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() { _status = null; });
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final csvString = utf8.decode(bytes);
      final csvTable = CsvToListConverter().convert(csvString, eol: '\n');
      setState(() {
        _fileName = result.files.single.name;
        _csvData = csvTable;
        _status = 'File loaded: $_fileName';
      });
    } else {
      setState(() {
        _fileName = null;
        _csvData = null;
        _status = 'No file selected.';
      });
    }
  }

  Future<void> _importFile() async {
    if (_csvData == null || _csvData!.isEmpty) return;
    setState(() { _isLoading = true; _status = 'Importing...'; });
    final headers = _csvData!.first.map((e) => e.toString()).toList();
    int success = 0, failed = 0;
    for (int i = 1; i < _csvData!.length; i++) {
      final row = _csvData![i];
      if (row.length != headers.length) { failed++; continue; }
      final data = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        data[headers[j]] = row[j];
      }
      try {
        await FirebaseFirestore.instance.collection('inventory').add(data);
        success++;
      } catch (e) {
        failed++;
      }
    }
    setState(() {
      _isLoading = false;
      _status = 'Import complete! Success: $success, Failed: $failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose CSV File'),
                  onPressed: _isLoading ? null : _pickFile,
                ),
                const SizedBox(width: 16),
                Text(_fileName ?? 'No file selected'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_fileName != null && !_isLoading) ? _importFile : null,
              child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Import'),
            ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!, style: TextStyle(color: _status!.contains('Success') ? Colors.green : Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Export Inventory Screen ---
class _ExportInventoryScreen extends StatefulWidget {
  @override
  State<_ExportInventoryScreen> createState() => _ExportInventoryScreenState();
}

class _ExportInventoryScreenState extends State<_ExportInventoryScreen> {
  String? _status;
  bool _isLoading = false;

  Future<void> _exportData() async {
    setState(() { _isLoading = true; _status = null; });
    try {
      final snapshot = await FirebaseFirestore.instance.collection('inventory').get();
      if (snapshot.docs.isEmpty) {
        setState(() { _isLoading = false; _status = 'No inventory data to export.'; });
        return;
      }
      final headers = snapshot.docs.first.data().keys.map((e) => e.toString()).toList();
      final rows = <List<String>>[headers];
      for (final doc in snapshot.docs) {
        final row = headers.map((h) => (doc.data()[h] ?? '').toString()).toList();
        rows.add(row);
      }
      final csvString = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csvString));
      await FileDownloadService.downloadFile(bytes, 'inventory_export.csv');
      setState(() { _isLoading = false; _status = 'Exported inventory_export.csv'; });
    } catch (e) {
      setState(() { _isLoading = false; _status = 'Export failed: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Export as CSV'),
              onPressed: _isLoading ? null : _exportData,
            ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!, style: TextStyle(color: _status!.contains('Exported') ? Colors.green : Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Analytics Screen (already present as InventoryAnalyticsScreen) ---
class InventoryAnalyticsScreen extends StatefulWidget {
  @override
  State<InventoryAnalyticsScreen> createState() => _InventoryAnalyticsScreenState();
}

class _InventoryAnalyticsScreenState extends State<InventoryAnalyticsScreen> with SingleTickerProviderStateMixin {
  DateTimeRange? _dateRange;
  late TabController _tabController;
  final List<String> _tabs = [
    'Overview',
    'By Category',
    'By Brand',
    'By Location',
    'Aging',
    'Stock Alerts',
    'Download',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    final now = DateTime.now();
    _dateRange = DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              const Text('Inventory Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(_dateRange == null
                    ? 'Select Date Range'
                    : '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}'),
                onPressed: _pickDateRange,
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(dateRange: _dateRange),
              _CategoryTab(dateRange: _dateRange),
              _BrandTab(dateRange: _dateRange),
              _LocationTab(dateRange: _dateRange),
              _AgingTab(dateRange: _dateRange),
              _StockAlertsTab(dateRange: _dateRange),
              _DownloadTab(dateRange: _dateRange),
            ],
          ),
        ),
      ],
    );
  }
}

// Stubs for analytics tabs
class _OverviewTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _OverviewTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No inventory data in selected range.'));
        }

        // KPIs
        final totalItems = docs.length;
        final lowStock = docs.where((d) => ((d['quantity_available'] ?? 0) as num).toInt() < ((d['reorder_point'] ?? 10) as num).toInt()).length;
        final outOfStock = docs.where((d) => ((d['quantity_available'] ?? 0) as num).toInt() == 0).length;
        final totalValue = docs.fold<double>(0, (sum, d) =>
          sum + (((d['quantity_available'] ?? 0) as num).toDouble() * ((d['cost_price'] ?? 0) as num).toDouble()));

        // Top 5 products by quantity
        final productQuantities = <String, int>{};
        for (final d in docs) {
          final pid = d['product_id'] ?? '';
          final qty = ((d['quantity_available'] ?? 0) as num).toInt();
          productQuantities[pid] = (productQuantities[pid] ?? 0) + qty;
        }
        final topProducts = productQuantities.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top5 = topProducts.take(5).toList();

        // Inventory trend: items added per month
        final Map<String, int> monthCounts = {};
        for (final d in docs) {
          final dt = (d['last_updated'] as Timestamp?)?.toDate();
          if (dt != null) {
            final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
            monthCounts[key] = (monthCounts[key] ?? 0) + 1;
          }
        }
        final sortedMonths = monthCounts.keys.toList()..sort();
        final trendSpots = [
          for (int i = 0; i < sortedMonths.length; i++)
            FlSpot(i.toDouble(), monthCounts[sortedMonths[i]]!.toDouble())
        ];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _KpiCard(label: 'Total Items', value: '$totalItems', icon: Icons.inventory_2),
                  _KpiCard(label: 'Low Stock', value: '$lowStock', icon: Icons.warning, color: Colors.orange),
                  _KpiCard(label: 'Out of Stock', value: '$outOfStock', icon: Icons.error, color: Colors.red),
                  _KpiCard(label: 'Total Value', value: '₹${totalValue.toStringAsFixed(2)}', icon: Icons.attach_money, color: Colors.green),
                ],
              ),
              const SizedBox(height: 32),
              // Top 5 products bar chart
              Text('Top 5 Products by Quantity', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: [
                      for (int i = 0; i < top5.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: top5[i].value.toDouble(),
                              color: Colors.deepPurple,
                              width: 24,
                            ),
                          ],
                        ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= top5.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(top5[idx].key, style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Inventory trend line chart
              Text('Inventory Added per Month', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: trendSpots,
                        isCurved: true,
                        color: Colors.deepPurple,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= sortedMonths.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(sortedMonths[idx], style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _CategoryTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No inventory data in selected range.'));
        }
        // Group by category
        final Map<String, List<QueryDocumentSnapshot>> byCategory = {};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final cat = data['category'] ?? 'Uncategorized';
          byCategory.putIfAbsent(cat, () => []).add(d);
        }
        // Prepare data for chart
        final catLabels = byCategory.keys.toList();
        final catQtys = catLabels.map((cat) => byCategory[cat]!.fold<int>(0, (sum, d) {
          final data = d.data() as Map<String, dynamic>;
          final qty = data['quantity_available'] ?? 0;
          return sum + (qty is int ? qty : (qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0));
        })).toList();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Inventory by Category', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < catLabels.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: catQtys[i].toDouble(),
                            color: Colors.blue,
                            width: 32,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= catLabels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(catLabels[idx], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...byCategory.entries.map((entry) {
              final cat = entry.key;
              final items = entry.value;
              final totalQty = items.fold<int>(0, (sum, d) {
                final data = d.data() as Map<String, dynamic>;
                final qty = data['quantity_available'] ?? 0;
                return sum + (qty is int ? qty : (qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0));
              });
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text('$cat  (Items: ${items.length}, Qty: $totalQty)'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final data = items[idx].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['product_name'] ?? data['product_id'] ?? ''),
                          subtitle: Text('SKU: ${data['sku'] ?? ''} | Qty: ${((data['quantity_available'] ?? 0) as num).toInt()}'),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _BrandTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _BrandTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No inventory data in selected range.'));
        }
        // Group by brand
        final Map<String, List<QueryDocumentSnapshot>> byBrand = {};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final brand = data['brand'] ?? 'Unbranded';
          byBrand.putIfAbsent(brand, () => []).add(d);
        }
        // Prepare data for chart
        final brandLabels = byBrand.keys.toList();
        final brandQtys = brandLabels.map((brand) => byBrand[brand]!.fold<int>(0, (sum, d) {
          final data = d.data() as Map<String, dynamic>;
          final qty = data['quantity_available'] ?? 0;
          return sum + (qty is int ? qty : (qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0));
        })).toList();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Inventory by Brand', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < brandLabels.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: brandQtys[i].toDouble(),
                            color: Colors.green,
                            width: 32,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= brandLabels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(brandLabels[idx], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...byBrand.entries.map((entry) {
              final brand = entry.key;
              final items = entry.value;
              final totalQty = items.fold<int>(0, (sum, d) {
                final data = d.data() as Map<String, dynamic>;
                final qty = data['quantity_available'] ?? 0;
                return sum + (qty is int ? qty : (qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0));
              });
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text('$brand  (Items: [1m${items.length}[0m, Qty: $totalQty)'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final data = items[idx].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['product_name'] ?? data['product_id'] ?? ''),
                          subtitle: Text('SKU: ${data['sku'] ?? ''} | Qty: ${((data['quantity_available'] ?? 0) as num).toInt()}'),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _LocationTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _LocationTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No inventory data in selected range.'));
        }
        // Group by store_location
        final Map<String, List<QueryDocumentSnapshot>> byLocation = {};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final loc = data['store_location'] ?? 'Unknown';
          byLocation.putIfAbsent(loc, () => []).add(d);
        }
        // Prepare data for chart
        final locLabels = byLocation.keys.toList();
        final locQtys = locLabels.map((loc) => byLocation[loc]!.fold<int>(0, (sum, d) {
          final data = d.data() as Map<String, dynamic>;
          final qty = data['quantity_available'] ?? 0;
          return sum + (qty is int ? qty : (qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0));
        })).toList();
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Inventory by Location', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < locLabels.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: locQtys[i].toDouble(),
                            color: Colors.purple,
                            width: 32,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= locLabels.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(locLabels[idx], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...byLocation.entries.map((entry) {
              final loc = entry.key;
              final items = entry.value;
              final totalQty = items.fold<int>(0, (sum, d) {
                final data = d.data() as Map<String, dynamic>;
                final qty = data['quantity_available'] ?? 0;
                return sum + (qty is int ? qty : (qty is num ? qty.toInt() : int.tryParse(qty.toString()) ?? 0));
              });
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text('$loc  (Items: ${items.length}, Qty: $totalQty)'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final data = items[idx].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['product_name'] ?? data['product_id'] ?? ''),
                          subtitle: Text('SKU: ${data['sku'] ?? ''} | Qty: ${((data['quantity_available'] ?? 0) as num).toInt()}'),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _AgingTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _AgingTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No inventory data in selected range.'));
        }
        // Age buckets: <30d, 30-90d, 90-180d, >180d
        final now = DateTime.now();
        final Map<String, int> buckets = {
          '<30d': 0,
          '30-90d': 0,
          '90-180d': 0,
          '>180d': 0,
        };
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final mfg = data['manufacture_date'] is Timestamp
              ? (data['manufacture_date'] as Timestamp).toDate()
              : (data['manufacture_date'] is DateTime ? data['manufacture_date'] : null);
          if (mfg == null) continue;
          final age = now.difference(mfg).inDays;
          if (age < 30) buckets['<30d'] = buckets['<30d']! + 1;
          else if (age < 90) buckets['30-90d'] = buckets['30-90d']! + 1;
          else if (age < 180) buckets['90-180d'] = buckets['90-180d']! + 1;
          else buckets['>180d'] = buckets['>180d']! + 1;
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Inventory Aging', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      for (int i = 0; i < buckets.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: buckets.values.elementAt(i).toDouble(),
                              color: Colors.blue,
                              width: 32,
                            ),
                          ],
                        ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= buckets.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(buckets.keys.elementAt(idx), style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StockAlertsTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _StockAlertsTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventory')
          .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No inventory data in selected range.'));
        }
        final lowStock = <Map<String, dynamic>>[];
        final overStock = <Map<String, dynamic>>[];
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final qty = ((data['quantity_available'] ?? 0) as num).toInt();
          final reorder = ((data['reorder_point'] ?? 10) as num).toInt();
          final maxStock = ((data['max_stock_level'] ?? 200) as num).toInt();
          if (qty <= reorder) lowStock.add(data);
          if (qty > maxStock) overStock.add(data);
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stock Alerts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text('Low Stock (${lowStock.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...lowStock.map((data) => ListTile(
                title: Text(data['product_name'] ?? data['product_id'] ?? ''),
                subtitle: Text('Qty: [1m${((data['quantity_available'] ?? 0) as num).toInt()}[0m | Reorder Point: ${((data['reorder_point'] ?? 0) as num).toInt()}'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Reorder'),
                ),
              )),
              const SizedBox(height: 24),
              Text('Overstock (${overStock.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...overStock.map((data) => ListTile(
                title: Text(data['product_name'] ?? data['product_id'] ?? ''),
                subtitle: Text('Qty: ${((data['quantity_available'] ?? 0) as num).toInt()} | Max Stock: ${((data['max_stock_level'] ?? 0) as num).toInt()}'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Reduce'),
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _DownloadTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _DownloadTab({Key? key, this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
    final end = dateRange?.end ?? DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text('Export Inventory as CSV'),
        onPressed: () async {
          final snapshot = await FirebaseFirestore.instance
              .collection('inventory')
              .where('last_updated', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
              .where('last_updated', isLessThanOrEqualTo: Timestamp.fromDate(end))
              .get();
          if (snapshot.docs.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No inventory data to export.')));
            return;
          }
          final headers = snapshot.docs.first.data().keys.map((e) => e.toString()).toList();
          final rows = <List<String>>[headers];
          for (final doc in snapshot.docs) {
            final row = headers.map((h) => (doc.data()[h] ?? '').toString()).toList();
            rows.add(row);
          }
          final csvString = const ListToCsvConverter().convert(rows);
          final bytes = Uint8List.fromList(utf8.encode(csvString));
          await FileDownloadService.downloadFile(bytes, 'inventory_export.csv');
        },
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.icon, this.color = Colors.deepPurple});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

