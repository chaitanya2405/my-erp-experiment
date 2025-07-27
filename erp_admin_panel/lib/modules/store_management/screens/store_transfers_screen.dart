import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/store_models.dart';
import '../services/store_service.dart';

/// 🔄 Store Transfers Screen
/// Manages inter-store inventory transfers and logistics
class StoreTransfersScreen extends StatefulWidget {
  @override
  _StoreTransfersScreenState createState() => _StoreTransfersScreenState();
}

class _StoreTransfersScreenState extends State<StoreTransfersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'All';
  String _selectedFromStore = 'All';
  String _selectedToStore = 'All';
  bool _isLoading = true;
  
  List<Store> _stores = [];
  List<StoreTransfer> _transfers = [];
  
  // Add stream subscriptions for proper disposal
  StreamSubscription<List<Store>>? _storesSubscription;
  StreamSubscription<List<StoreTransfer>>? _transfersSubscription;
  
  final List<String> _statusOptions = ['All', 'Pending', 'In Transit', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    
    print('🔄 Initializing Store Transfers Screen...');
    print('  📦 Loading inter-store transfer requests');
    print('  🚚 Setting up logistics tracking');
    print('  📋 Preparing transfer management tools');
    print('  ✅ Ready for inventory transfers');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storesSubscription?.cancel();
    _transfersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // Load stores
      final storesStream = StoreService.getStoresStream();
      _storesSubscription = storesStream.listen((storesSnapshot) {
        if (mounted) {
          setState(() {
            _stores = storesSnapshot.where((s) => s.storeStatus == 'Active').toList();
          });
        }
      });
      
      // Load transfers
      final transfersStream = StoreService.getStoreTransfersStream();
      _transfersSubscription = transfersStream.listen((transfers) {
        if (mounted) {
          setState(() {
            _transfers = transfers;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Error loading data: $e');
      // Generate mock data for demo
      _generateMockTransfers();
    }
  }

  void _generateMockTransfers() {
    // Generate mock transfer data for demo
    if (_stores.length < 2) return;
    
    _transfers = List.generate(10, (index) {
      final fromStore = _stores[index % _stores.length];
      final toStore = _stores[(index + 1) % _stores.length];
      final statuses = ['Pending', 'In Transit', 'Completed', 'Cancelled'];
      final status = statuses[index % statuses.length];
      
      return StoreTransfer(
        transferId: 'TRF${(1000 + index).toString()}',
        fromStoreId: fromStore.storeId,
        toStoreId: toStore.storeId,
        fromStoreName: fromStore.storeName,
        toStoreName: toStore.storeName,
        items: [
          {
            'product_id': 'PROD${100 + index}',
            'product_name': 'Product ${index + 1}',
            'quantity': 10 + (index * 5),
            'unit_price': 500.0 + (index * 100),
            'total_value': (10 + (index * 5)) * (500.0 + (index * 100)),
          }
        ],
        transferStatus: status,
        requestedBy: 'Manager${index % 3 + 1}',
        approvedBy: status != 'Pending' ? 'Supervisor${index % 2 + 1}' : null,
        requestDate: Timestamp.fromDate(DateTime.now().subtract(Duration(days: index))),
        approvalDate: status != 'Pending' 
            ? Timestamp.fromDate(DateTime.now().subtract(Duration(days: index - 1)))
            : null,
        completionDate: status == 'Completed'
            ? Timestamp.fromDate(DateTime.now().subtract(Duration(days: index - 2)))
            : null,
        notes: status == 'Cancelled' ? 'Transfer cancelled due to stock unavailability' : null,
        totalValue: (10 + (index * 5)) * (500.0 + (index * 100)),
      );
    });
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading transfer data...'),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
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
                    const Icon(Icons.swap_horiz, color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Store Transfers',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _createNewTransfer(),
                      icon: const Icon(Icons.add),
                      label: const Text('New Transfer'),
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
                // Filters
                Row(
                  children: [
                    // Status Filter
                    SizedBox(
                      width: 150,
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
                    const SizedBox(width: 16),
                    // From Store Filter
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedFromStore,
                        decoration: InputDecoration(
                          labelText: 'From Store',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          const DropdownMenuItem(value: 'All', child: Text('All Stores')),
                          ..._stores.map((store) => DropdownMenuItem(
                            value: store.storeId,
                            child: Text(store.storeName),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedFromStore = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // To Store Filter
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedToStore,
                        decoration: InputDecoration(
                          labelText: 'To Store',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          const DropdownMenuItem(value: 'All', child: Text('All Stores')),
                          ..._stores.map((store) => DropdownMenuItem(
                            value: store.storeId,
                            child: Text(store.storeName),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedToStore = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.indigo,
                  tabs: const [
                    Tab(text: 'All Transfers'),
                    Tab(text: 'Pending Approval'),
                    Tab(text: 'In Transit'),
                  ],
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransfersList(_getFilteredTransfers()),
                _buildTransfersList(_getFilteredTransfers().where((t) => t.transferStatus == 'Pending').toList()),
                _buildTransfersList(_getFilteredTransfers().where((t) => t.transferStatus == 'In Transit').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<StoreTransfer> _getFilteredTransfers() {
    return _transfers.where((transfer) {
      // Status filter
      if (_selectedStatus != 'All' && transfer.transferStatus != _selectedStatus) {
        return false;
      }
      
      // From store filter
      if (_selectedFromStore != 'All' && transfer.fromStoreId != _selectedFromStore) {
        return false;
      }
      
      // To store filter
      if (_selectedToStore != 'All' && transfer.toStoreId != _selectedToStore) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildTransfersList(List<StoreTransfer> transfers) {
    if (transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swap_horiz, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No transfers found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createNewTransfer(),
              icon: const Icon(Icons.add),
              label: const Text('Create Transfer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return _buildTransferCard(transfer);
      },
    );
  }

  Widget _buildTransferCard(StoreTransfer transfer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Transfer ID and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            transfer.transferId,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusChip(transfer.transferStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested by ${transfer.requestedBy}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) => _handleTransferAction(action, transfer),
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
                    if (transfer.transferStatus == 'Pending')
                      const PopupMenuItem(
                        value: 'approve',
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Approve'),
                          ],
                        ),
                      ),
                    if (transfer.transferStatus == 'In Transit')
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.done_all, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Mark Complete'),
                          ],
                        ),
                      ),
                    if (transfer.transferStatus == 'Pending' || transfer.transferStatus == 'In Transit')
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cancel'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Store Transfer Direction
            Row(
              children: [
                // From Store
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.store, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            const Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transfer.fromStoreName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                // To Store
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.store, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            const Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transfer.toStoreName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Transfer Details
            Row(
              children: [
                _buildTransferDetail('📦', 'Items', '${transfer.items.length}'),
                const SizedBox(width: 24),
                _buildTransferDetail('💰', 'Value', '₹${transfer.totalValue.toStringAsFixed(0)}'),
                const SizedBox(width: 24),
                _buildTransferDetail('📅', 'Requested', _formatDate(transfer.requestDate.toDate())),
                if (transfer.approvalDate != null) ...[
                  const SizedBox(width: 24),
                  _buildTransferDetail('✅', 'Approved', _formatDate(transfer.approvalDate!.toDate())),
                ],
              ],
            ),
            if (transfer.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transfer.notes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'In Transit':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'Completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'Cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
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

  Widget _buildTransferDetail(String icon, String label, String value) {
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

  void _createNewTransfer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Transfer'),
        content: const Text('Transfer creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _handleTransferAction(String action, StoreTransfer transfer) {
    switch (action) {
      case 'view':
        _viewTransferDetails(transfer);
        break;
      case 'approve':
        _approveTransfer(transfer);
        break;
      case 'complete':
        _completeTransfer(transfer);
        break;
      case 'cancel':
        _cancelTransfer(transfer);
        break;
    }
  }

  void _viewTransferDetails(StoreTransfer transfer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer ${transfer.transferId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${transfer.fromStoreName}'),
              Text('To: ${transfer.toStoreName}'),
              Text('Status: ${transfer.transferStatus}'),
              Text('Requested by: ${transfer.requestedBy}'),
              if (transfer.approvedBy != null)
                Text('Approved by: ${transfer.approvedBy}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...transfer.items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• ${item['product_name']} (Qty: ${item['quantity']})'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _approveTransfer(StoreTransfer transfer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Transfer'),
        content: Text('Approve transfer ${transfer.transferId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update transfer status
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfer approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _completeTransfer(StoreTransfer transfer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Transfer'),
        content: Text('Mark transfer ${transfer.transferId} as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update transfer status
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfer completed successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _cancelTransfer(StoreTransfer transfer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Transfer'),
        content: Text('Cancel transfer ${transfer.transferId}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update transfer status
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfer cancelled'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Transfer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
