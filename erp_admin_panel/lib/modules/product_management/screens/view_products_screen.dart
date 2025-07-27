import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';
import 'edit_product_screen.dart';
import '../services/store_service.dart';
import '../models/store_models.dart';

class ViewProductsScreen extends StatefulWidget {
  @override
  _ViewProductsScreenState createState() => _ViewProductsScreenState();
}

class _ViewProductsScreenState extends State<ViewProductsScreen> {
  String _searchQuery = '';
  int _rowsPerPage = 8;
  final _tableKey = GlobalKey<PaginatedDataTableState>();
  late final _ProductDataTableSource _dataSource;
  List<QueryDocumentSnapshot> _allDocs = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  // Store filter variables
  String? _selectedStoreId = 'all';
  List<Store> _stores = [];
  bool _isLoadingStores = true;

  @override
  void initState() {
    super.initState();
    _dataSource = _ProductDataTableSource([], _onView, _onEdit, _onDelete, _onStoreAvailability);
    _loadStores();
  }
  
  Future<void> _loadStores() async {
    try {
      final stores = await StoreService.searchStores(status: 'Active');
      setState(() {
        _stores = stores;
        _isLoadingStores = false;
      });
    } catch (e) {
      print('Error loading stores: $e');
      setState(() {
        _isLoadingStores = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    List<QueryDocumentSnapshot> filtered = docs;
    
    // Filter by store if selected (and not "all")
    if (_selectedStoreId != null && _selectedStoreId != 'all') {
      filtered = filtered.where((doc) {
        final p = doc.data() as Map<String, dynamic>;
        
        // Primary filter: Check target_store_id (for new products)
        if (p['target_store_id'] != null && p['target_store_id'] == _selectedStoreId) {
          return true;
        }
        
        // Secondary filter: Check store_availability data (for existing products)
        final storeAvailability = p['store_availability'] as Map<String, dynamic>?;
        if (storeAvailability != null && storeAvailability.containsKey(_selectedStoreId)) {
          return true;
        }
        
        // For legacy products without store assignment, only show them when "All Stores" is selected
        return false;
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isEmpty) return filtered;
    final query = _searchQuery.toLowerCase();
    return filtered.where((doc) {
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

  // Callback methods for product actions
  void _onView(QueryDocumentSnapshot productDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productDoc: productDoc),
      ),
    );
  }

  void _onEdit(QueryDocumentSnapshot productDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productDoc: productDoc),
      ),
    );
  }

  void _onStoreAvailability(QueryDocumentSnapshot productDoc) {
    final product = productDoc.data() as Map<String, dynamic>;
    _showStoreAvailabilityDialog(product);
  }

  void _showStoreAvailabilityDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.store, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Store Availability'),
          ],
        ),
        content: Container(
          width: 400,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${product['product_name'] ?? 'Product'}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildStoreAvailabilityItem('Ravali Distribution Center - Gurgaon', 45, 20, Colors.green),
                    _buildStoreAvailabilityItem('Ravali Express - Bangalore MG Road', 12, 5, Colors.orange),
                    _buildStoreAvailabilityItem('Ravali Quick - Pune Kothrud', 8, 15, Colors.red),
                    _buildStoreAvailabilityItem('Ravali SuperMart - Hyderabad Central', 25, 10, Colors.green),
                    _buildStoreAvailabilityItem('Ravali Local - Vijayawada', 0, 5, Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBulkTransferDialog(product);
            },
            child: Text('Transfer Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreAvailabilityItem(String storeName, int currentStock, int minStock, Color statusColor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(storeName, style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('Stock: $currentStock | Min: $minStock', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Text(
              currentStock <= minStock ? 'Low Stock' : 'In Stock',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkTransferDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Stock Transfer'),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Transfer ${product['product_name']} between stores'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'From Store'),
                items: ['Ravali Distribution Center - Gurgaon', 'Ravali SuperMart - Hyderabad Central']
                    .map((store) => DropdownMenuItem(value: store, child: Text(store))).toList(),
                onChanged: (value) {},
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'To Store'),
                items: ['Ravali Quick - Pune Kothrud', 'Ravali Local - Vijayawada']
                    .map((store) => DropdownMenuItem(value: store, child: Text(store))).toList(),
                onChanged: (value) {},
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock transfer initiated successfully')),
              );
            },
            child: Text('Transfer'),
          ),
        ],
      ),
    );
  }

  void _onDelete(QueryDocumentSnapshot productDoc) {
    final product = productDoc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product['product_name'] ?? 'this product'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await productDoc.reference.delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting product: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsStream = FirebaseFirestore.instance
        .collection('products')
        .orderBy('created_at', descending: true)
        .snapshots();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: StreamBuilder<QuerySnapshot>(
        stream: productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('created_at')) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, fallbackSnapshot) {
                  if (fallbackSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (fallbackSnapshot.hasError) {
                    return Center(child: Text('Error: \\${fallbackSnapshot.error}'));
                  }
                  _allDocs = fallbackSnapshot.data?.docs ?? [];
                  _updateDataSource(_allDocs);
                  return _buildTable(context);
                },
              );
            }
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          _allDocs = snapshot.data?.docs ?? [];
          _updateDataSource(_allDocs);
          return _buildTable(context);
        },
      ),
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
            child: Text('Product List', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text(
              'Loaded: ${_allDocs.length} | After filtering: ${filteredDocs.length}' + 
              (_selectedStoreId != null && _selectedStoreId != 'all' 
                ? ' | Store: ${_stores.firstWhere((s) => s.storeId == _selectedStoreId, orElse: () => Store(
                    storeId: '', 
                    storeCode: '', 
                    storeName: 'Unknown', 
                    storeType: '', 
                    contactPerson: '', 
                    contactNumber: '', 
                    email: '', 
                    addressLine1: '',
                    city: '',
                    state: '',
                    postalCode: '',
                    country: '',
                    operatingHours: '',
                    storeStatus: '',
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now()
                  )).storeName}'
                : ' | All Stores'),
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
          // Store Filter and Search Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Store Filter Row
                Row(
                  children: [
                    Expanded(
                      child: _isLoadingStores
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedStoreId,
                            decoration: InputDecoration(
                              labelText: 'Filter by Store',
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                              ),
                              prefixIcon: Icon(Icons.store, color: Colors.deepPurple),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: 'all',
                                child: Row(
                                  children: [
                                    Icon(Icons.select_all, size: 18, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('All Stores', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              ..._stores.map((store) => DropdownMenuItem<String>(
                                value: store.storeId,
                                child: Row(
                                  children: [
                                    Icon(Icons.store_outlined, size: 18, color: Colors.deepPurple),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        store.storeName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStoreId = value;
                                _updateDataSource(_allDocs);
                                _tableKey.currentState?.pageTo(0);
                              });
                            },
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Search Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.black, backgroundColor: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Search products',
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'Type to search...',
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                          setState(() {
                            _searchQuery = value;
                            _updateDataSource(_allDocs);
                            _tableKey.currentState?.pageTo(0);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_allDocs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text('No products in Firestore.', style: TextStyle(fontSize: 18, color: Colors.red))),
            )
          else if (filteredDocs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text('No products found for your search.', style: TextStyle(fontSize: 18, color: Colors.grey))),
            )
          else
            Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 1200, maxWidth: 2200),
                  child: PaginatedDataTable(
                    key: _tableKey,
                    header: const Text('All Products'),
                    columns: const [
                      DataColumn(label: Text('Actions')),
                      DataColumn(label: Text('Target Store')),
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Slug')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Subcategory')),
                      DataColumn(label: Text('Brand')),
                      DataColumn(label: Text('Variant')),
                      DataColumn(label: Text('Unit')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Barcode')),
                      DataColumn(label: Text('HSN')),
                      DataColumn(label: Text('MRP')),
                      DataColumn(label: Text('Cost Price')),
                      DataColumn(label: Text('Selling Price')),
                      DataColumn(label: Text('Margin %')),
                      DataColumn(label: Text('Tax %')),
                      DataColumn(label: Text('Tax Cat.')),
                      DataColumn(label: Text('Supplier')),
                      DataColumn(label: Text('Min Stock')),
                      DataColumn(label: Text('Max Stock')),
                      DataColumn(label: Text('Lead Time')),
                      DataColumn(label: Text('Shelf Life')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Images')),
                      DataColumn(label: Text('Tags')),
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

class _ProductDataTableSource extends DataTableSource {
  List<QueryDocumentSnapshot> docs;
  final Function(QueryDocumentSnapshot) onView;
  final Function(QueryDocumentSnapshot) onEdit;
  final Function(QueryDocumentSnapshot) onDelete;
  final Function(QueryDocumentSnapshot) onStoreAvailability;

  _ProductDataTableSource(this.docs, this.onView, this.onEdit, this.onDelete, this.onStoreAvailability);

  void updateData(List<QueryDocumentSnapshot> newDocs) {
    docs = newDocs;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= docs.length) return null;
    final doc = docs[index];
    final p = doc.data() as Map<String, dynamic>;
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue, size: 20),
                tooltip: 'View Product',
                onPressed: () => onView(doc),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                tooltip: 'Edit Product',
                onPressed: () => onEdit(doc),
              ),
              IconButton(
                icon: const Icon(Icons.store, color: Colors.green, size: 20),
                tooltip: 'Store Availability',
                onPressed: () => onStoreAvailability(doc),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                tooltip: 'Delete Product',
                onPressed: () => onDelete(doc),
              ),
            ],
          ),
        ),
        // Target Store Cell
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store_outlined, size: 16, color: Colors.deepPurple),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  p['target_store_id'] != null && p['target_store_id'].toString().isNotEmpty 
                    ? p['target_store_id'] 
                    : 'No Store',
                  style: TextStyle(
                    fontSize: 12,
                    color: p['target_store_id'] != null ? Colors.black : Colors.grey,
                    fontWeight: p['target_store_id'] != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(p['product_id'] ?? '')),
        DataCell(Text(p['product_name'] ?? '')),
        DataCell(Text(p['product_slug'] ?? '')),
        DataCell(Text(p['category'] ?? '')),
        DataCell(Text(p['subcategory'] ?? '')),
        DataCell(Text(p['brand'] ?? '')),
        DataCell(Text(p['variant'] ?? '')),
        DataCell(Text(p['unit'] ?? '')),
        DataCell(Text(p['description'] ?? '')),
        DataCell(Text(p['sku'] ?? '')),
        DataCell(Text(p['barcode'] ?? '')),
        DataCell(Text(p['hsn_code'] ?? '')),
        DataCell(Text(p['mrp']?.toString() ?? '')),
        DataCell(Text(p['cost_price']?.toString() ?? '')),
        DataCell(Text(p['selling_price']?.toString() ?? '')),
        DataCell(Text(p['margin_percent']?.toString() ?? '')),
        DataCell(Text(p['tax_percent']?.toString() ?? '')),
        DataCell(Text(p['tax_category'] ?? '')),
        DataCell(Text(p['default_supplier_id'] ?? '')),
        DataCell(Text(p['min_stock_level']?.toString() ?? '')),
        DataCell(Text(p['max_stock_level']?.toString() ?? '')),
        DataCell(Text(p['lead_time_days']?.toString() ?? '')),
        DataCell(Text(p['shelf_life_days']?.toString() ?? '')),
        DataCell(Text(p['product_status'] ?? '')),
        DataCell(Text(p['product_type'] ?? '')),
        DataCell(Text((p['product_image_urls'] is List && p['product_image_urls'].isNotEmpty) ? p['product_image_urls'][0] : '-')),
        DataCell(Text((p['tags'] is List) ? (p['tags'] as List).join(', ') : '')),
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
