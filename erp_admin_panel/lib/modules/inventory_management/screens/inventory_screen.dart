import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  
  final List<String> _categoryOptions = ['All', 'Electronics', 'Clothing', 'Food', 'Books', 'Others'];
  final List<String> _statusOptions = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () => _showBulkUploadDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
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
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: _categoryOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
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
              ],
            ),
          ),
          
          // Inventory Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                
                final products = snapshot.data?.docs ?? [];
                int totalProducts = products.length;
                int lowStock = 0;
                int outOfStock = 0;
                double totalValue = 0;
                
                for (var product in products) {
                  final data = product.data() as Map<String, dynamic>;
                  final stock = data['current_stock'] ?? 0;
                  final reorderPoint = data['reorder_point'] ?? 10;
                  final price = (data['cost_price'] ?? 0).toDouble();
                  
                  totalValue += price * stock;
                  
                  if (stock == 0) {
                    outOfStock++;
                  } else if (stock <= reorderPoint) {
                    lowStock++;
                  }
                }
                
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Products', totalProducts.toString(), Icons.inventory, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Low Stock', lowStock.toString(), Icons.warning, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Out of Stock', outOfStock.toString(), Icons.error, Colors.red)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Total Value', '₹${totalValue.toStringAsFixed(0)}', Icons.currency_rupee, Colors.green)),
                  ],
                );
              },
            ),
          ),
          
          // Products List
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
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
                Icon(Icons.inventory, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Products Found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first product to get started',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddProductDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
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
                  backgroundColor: _getStockStatusColor(data),
                  child: Icon(
                    _getStockStatusIcon(data),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  data['name'] ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SKU: ${data['code'] ?? 'N/A'}'),
                    Text('Category: ${data['category'] ?? 'Uncategorized'}'),
                    Text('Stock: ${data['current_stock'] ?? 0} | Reorder: ${data['reorder_point'] ?? 0}'),
                    Text('Price: ₹${data['sale_price']?.toStringAsFixed(2) ?? '0.00'}'),
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
                      value: 'adjust',
                      child: ListTile(
                        leading: Icon(Icons.tune),
                        title: Text('Adjust Stock'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleProductAction(value.toString(), doc.id, data),
                ),
                onTap: () => _showProductDetails(doc.id, data),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStockStatusColor(Map<String, dynamic> data) {
    final stock = data['current_stock'] ?? 0;
    final reorderPoint = data['reorder_point'] ?? 10;
    
    if (stock == 0) return Colors.red;
    if (stock <= reorderPoint) return Colors.orange;
    return Colors.green;
  }

  IconData _getStockStatusIcon(Map<String, dynamic> data) {
    final stock = data['current_stock'] ?? 0;
    final reorderPoint = data['reorder_point'] ?? 10;
    
    if (stock == 0) return Icons.error;
    if (stock <= reorderPoint) return Icons.warning;
    return Icons.check;
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final categoryController = TextEditingController();
    final costPriceController = TextEditingController();
    final salePriceController = TextEditingController();
    final stockController = TextEditingController();
    final reorderController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Product Code/SKU',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: reorderController,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Point',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addProduct(
              nameController.text,
              codeController.text,
              categoryController.text,
              costPriceController.text,
              salePriceController.text,
              stockController.text,
              reorderController.text,
            ),
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _addProduct(String name, String code, String category, String costPrice, String salePrice, String stock, String reorderPoint) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name.trim(),
        'code': code.trim().isEmpty ? null : code.trim(),
        'category': category.trim().isEmpty ? 'Uncategorized' : category.trim(),
        'cost_price': double.tryParse(costPrice) ?? 0.0,
        'sale_price': double.tryParse(salePrice) ?? 0.0,
        'current_stock': int.tryParse(stock) ?? 0,
        'reorder_point': int.tryParse(reorderPoint) ?? 10,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  void _handleProductAction(String action, String docId, Map<String, dynamic> data) {
    switch (action) {
      case 'view':
        _showProductDetails(docId, data);
        break;
      case 'edit':
        _showEditProductDialog(docId, data);
        break;
      case 'adjust':
        _showStockAdjustmentDialog(docId, data);
        break;
      case 'delete':
        _showDeleteConfirmation(docId, data);
        break;
    }
  }

  void _showProductDetails(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name'] ?? 'Product Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Code', data['code'] ?? 'N/A'),
            _buildDetailRow('Category', data['category'] ?? 'Uncategorized'),
            _buildDetailRow('Cost Price', '₹${data['cost_price']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildDetailRow('Sale Price', '₹${data['sale_price']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildDetailRow('Current Stock', '${data['current_stock'] ?? 0}'),
            _buildDetailRow('Reorder Point', '${data['reorder_point'] ?? 0}'),
            _buildDetailRow('Status', data['is_active'] == true ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditProductDialog(docId, data);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditProductDialog(String docId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final codeController = TextEditingController(text: data['code'] ?? '');
    final categoryController = TextEditingController(text: data['category'] ?? '');
    final costPriceController = TextEditingController(text: data['cost_price']?.toString() ?? '');
    final salePriceController = TextEditingController(text: data['sale_price']?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Product Code/SKU',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateProduct(
              docId,
              nameController.text,
              codeController.text,
              categoryController.text,
              costPriceController.text,
              salePriceController.text,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateProduct(String docId, String name, String code, String category, String costPrice, String salePrice) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'name': name.trim(),
        'code': code.trim().isEmpty ? null : code.trim(),
        'category': category.trim().isEmpty ? 'Uncategorized' : category.trim(),
        'cost_price': double.tryParse(costPrice) ?? 0.0,
        'sale_price': double.tryParse(salePrice) ?? 0.0,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  void _showStockAdjustmentDialog(String docId, Map<String, dynamic> data) {
    final adjustmentController = TextEditingController();
    String adjustmentType = 'Add';
    String reason = 'Manual Adjustment';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Adjust Stock - ${data['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Stock: ${data['current_stock'] ?? 0}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: adjustmentType,
                decoration: const InputDecoration(
                  labelText: 'Adjustment Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Add', 'Remove'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    adjustmentType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adjustmentController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: reason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                items: ['Manual Adjustment', 'Damage', 'Return', 'Found', 'Sale'].map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    reason = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _adjustStock(docId, data, adjustmentType, adjustmentController.text, reason),
              child: const Text('Adjust'),
            ),
          ],
        ),
      ),
    );
  }

  void _adjustStock(String docId, Map<String, dynamic> data, String type, String quantity, String reason) async {
    final adjustment = int.tryParse(quantity) ?? 0;
    if (adjustment <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final currentStock = data['current_stock'] ?? 0;
    int newStock;
    
    if (type == 'Add') {
      newStock = currentStock + adjustment;
    } else {
      newStock = currentStock - adjustment;
      if (newStock < 0) newStock = 0;
    }

    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).update({
        'current_stock': newStock,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Log the stock movement
      await FirebaseFirestore.instance.collection('stock_movements').add({
        'product_id': docId,
        'product_name': data['name'],
        'movement_type': type.toLowerCase(),
        'quantity': adjustment,
        'previous_stock': currentStock,
        'new_stock': newStock,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock adjusted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adjusting stock: $e')),
      );
    }
  }

  void _showDeleteConfirmation(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${data['name']}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteProduct(docId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(docId).delete();
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  void _showBulkUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Upload'),
        content: const Text('Bulk upload functionality allows you to upload multiple products at once using a CSV file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV file picker would open here')),
              );
            },
            child: const Text('Select CSV File'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
