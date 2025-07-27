import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';
  
  final List<String> _statusOptions = ['All', 'Draft', 'Sent', 'Received', 'Completed'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePODialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search purchase orders...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                  items: _statusOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Purchase Orders List
          Expanded(
            child: _buildPurchaseOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('purchase_orders')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Purchase Orders Found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first purchase order to get started',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreatePODialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Purchase Order'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(data['status'] ?? 'Draft'),
                  child: Icon(
                    _getStatusIcon(data['status'] ?? 'Draft'),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'PO-${doc.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supplier: ${data['supplier_name'] ?? 'Unknown'}'),
                    Text('Total: ₹${data['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Status: ${data['status'] ?? 'Draft'}'),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('View Details'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'receive',
                      child: ListTile(
                        leading: Icon(Icons.check),
                        title: Text('Mark Received'),
                      ),
                    ),
                  ],
                  onSelected: (value) => _handlePOAction(value.toString(), doc.id, data),
                ),
                onTap: () => _showPODetails(doc.id, data),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft': return Colors.grey;
      case 'sent': return Colors.blue;
      case 'received': return Colors.orange;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'draft': return Icons.edit;
      case 'sent': return Icons.send;
      case 'received': return Icons.local_shipping;
      case 'completed': return Icons.check_circle;
      default: return Icons.shopping_bag;
    }
  }

  void _showCreatePODialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Purchase Order'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Supplier Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Total Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createPurchaseOrder(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createPurchaseOrder() async {
    try {
      await FirebaseFirestore.instance.collection('purchase_orders').add({
        'supplier_name': 'Sample Supplier',
        'total_amount': 10000.0,
        'status': 'Draft',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'items': [],
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating purchase order: $e')),
      );
    }
  }

  void _handlePOAction(String action, String docId, Map<String, dynamic> data) {
    switch (action) {
      case 'view':
        _showPODetails(docId, data);
        break;
      case 'edit':
        _showEditPODialog(docId, data);
        break;
      case 'receive':
        _markAsReceived(docId);
        break;
    }
  }

  void _showPODetails(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PO-${docId.substring(0, 6).toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplier: ${data['supplier_name'] ?? 'Unknown'}'),
            Text('Total Amount: ₹${data['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
            Text('Status: ${data['status'] ?? 'Draft'}'),
            Text('Created: ${_formatTimestamp(data['created_at'])}'),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${(data['items'] as List?)?.length ?? 0} items'),
          ],
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

  void _showEditPODialog(String docId, Map<String, dynamic> data) {
    final supplierController = TextEditingController(text: data['supplier_name']);
    final amountController = TextEditingController(text: data['total_amount']?.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Purchase Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updatePurchaseOrder(docId, supplierController.text, amountController.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updatePurchaseOrder(String docId, String supplier, String amount) async {
    try {
      await FirebaseFirestore.instance.collection('purchase_orders').doc(docId).update({
        'supplier_name': supplier,
        'total_amount': double.tryParse(amount) ?? 0.0,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating purchase order: $e')),
      );
    }
  }

  void _markAsReceived(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('purchase_orders').doc(docId).update({
        'status': 'Received',
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order marked as received!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return timestamp.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
