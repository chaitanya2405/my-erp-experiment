import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_models.dart';
import '../services/store_service.dart';
import 'add_edit_store_screen.dart';

/// 🏪 View Stores Screen
/// Displays list of all stores with search, filter, and management capabilities
class ViewStoresScreen extends StatefulWidget {
  @override
  _ViewStoresScreenState createState() => _ViewStoresScreenState();
}

class _ViewStoresScreenState extends State<ViewStoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _selectedCity = 'All';
  bool _isLoading = false;

  final List<String> _storeTypes = ['All', 'Retail', 'Warehouse', 'Distribution Center'];
  final List<String> _statusOptions = ['All', 'Active', 'Inactive', 'Under Renovation'];

  @override
  void initState() {
    super.initState();
    print('👀 Initializing View Stores Screen...');
    print('  📊 Loading store data with real-time updates');
    print('  🔍 Setting up search and filter capabilities');
    print('  🎯 Ready for store management operations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with Search and Filters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.store, color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Store Locations',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _addNewStore(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search and Filter Row
                Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search stores by name, code, location...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.indigo),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Type Filter
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _storeTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedType = value!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Filter
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
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
                          onChanged: (value) => setState(() => _selectedStatus = value!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Store List
          Expanded(
            child: StreamBuilder<List<Store>>(
              stream: StoreService.getStoresStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading stores...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allStores = snapshot.data ?? [];
                final filteredStores = _filterStores(allStores);

                if (filteredStores.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store_mall_directory, color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          allStores.isEmpty ? 'No stores found' : 'No stores match your filters',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        if (allStores.isEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _addNewStore(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Store'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];
                    return _buildStoreCard(store);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Store> _filterStores(List<Store> stores) {
    return stores.where((store) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!store.storeName.toLowerCase().contains(query) &&
            !store.storeCode.toLowerCase().contains(query) &&
            !store.city.toLowerCase().contains(query) &&
            !store.state.toLowerCase().contains(query) &&
            !store.contactPerson.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != 'All' && store.storeType != _selectedType) {
        return false;
      }

      // Status filter
      if (_selectedStatus != 'All' && store.storeStatus != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildStoreCard(Store store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _viewStoreDetails(store),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Store Icon and Type
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: store.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      store.storeTypeIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Store Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store.storeName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ),
                            _buildStatusChip(store.storeStatus),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${store.storeCode} • ${store.storeType}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${store.city}, ${store.state}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              store.contactPerson,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) => _handleStoreAction(action, store),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Store'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'performance',
                        child: Row(
                          children: [
                            Icon(Icons.analytics, size: 18),
                            SizedBox(width: 8),
                            Text('Performance'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'transfers',
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, size: 18),
                            SizedBox(width: 8),
                            Text('Transfers'),
                          ],
                        ),
                      ),
                      if (store.storeStatus == 'Active')
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: Row(
                            children: [
                              Icon(Icons.block, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Deactivate', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quick Stats
              Row(
                children: [
                  _buildQuickStat('📱', 'Contact', store.contactNumber),
                  const SizedBox(width: 24),
                  _buildQuickStat('📧', 'Email', store.email),
                  const SizedBox(width: 24),
                  _buildQuickStat('🕒', 'Hours', store.operatingHours),
                ],
              ),
              if (store.todaysSales != null || store.todaysTransactions != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (store.todaysSales != null)
                      _buildQuickStat('💰', 'Today\'s Sales', '₹${store.todaysSales!.toStringAsFixed(0)}'),
                    if (store.todaysSales != null && store.todaysTransactions != null)
                      const SizedBox(width: 24),
                    if (store.todaysTransactions != null)
                      _buildQuickStat('🛒', 'Transactions', '${store.todaysTransactions}'),
                    if (store.averageTransactionValue != null) ...[
                      const SizedBox(width: 24),
                      _buildQuickStat('📊', 'Avg Value', '₹${store.averageTransactionValue!.toStringAsFixed(0)}'),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuickStat(String icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewStore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditStoreScreen(),
      ),
    );
  }

  void _viewStoreDetails(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(store.storeTypeIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(store.storeName)),
            _buildStatusChip(store.storeStatus),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Store Code', store.storeCode),
              _buildDetailRow('Type', store.storeType),
              _buildDetailRow('Contact Person', store.contactPerson),
              _buildDetailRow('Phone', store.contactNumber),
              _buildDetailRow('Email', store.email),
              const SizedBox(height: 16),
              Text('Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text(store.fullAddress),
              const SizedBox(height: 16),
              _buildDetailRow('Operating Hours', store.operatingHours),
              if (store.storeAreaSqft != null)
                _buildDetailRow('Area', '${store.storeAreaSqft!.toStringAsFixed(0)} sq ft'),
              if (store.managerName != null)
                _buildDetailRow('Manager', store.managerName!),
              if (store.gstRegistrationNumber != null)
                _buildDetailRow('GST Number', store.gstRegistrationNumber!),
              if (store.parentCompany != null)
                _buildDetailRow('Parent Company', store.parentCompany!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editStore(store);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _editStore(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditStoreScreen(
          store: store,
          isEditing: true,
        ),
      ),
    );
  }

  void _handleStoreAction(String action, Store store) {
    switch (action) {
      case 'view':
        _viewStoreDetails(store);
        break;
      case 'edit':
        _editStore(store);
        break;
      case 'performance':
        _showPerformanceDialog(store);
        break;
      case 'transfers':
        _showTransfersDialog(store);
        break;
      case 'deactivate':
        _confirmDeactivation(store);
        break;
    }
  }

  void _showPerformanceDialog(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${store.storeName} Performance'),
        content: const Text('Performance analytics will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTransfersDialog(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${store.storeName} Transfers'),
        content: const Text('Store transfer history will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivation(Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: Text('Are you sure you want to deactivate ${store.storeName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deactivateStore(store);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateStore(Store store) async {
    try {
      await StoreService.deleteStore(store.storeId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${store.storeName} has been deactivated'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deactivating store: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
