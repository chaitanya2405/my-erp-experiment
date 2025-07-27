import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot productDoc;

  const ProductDetailScreen({Key? key, required this.productDoc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = productDoc.data() as Map<String, dynamic>;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(productDoc: productDoc),
                  ),
                );
              },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['product_name'] ?? 'No Name',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SKU: ${product['sku'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(product['product_status'] ?? 'Unknown'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Basic Information
            _buildInfoSection(
              context,
              'Basic Information',
              [
                _buildInfoRow('Product ID', product['product_id']),
                _buildInfoRow('Product Slug', product['product_slug']),
                _buildInfoRow('Category', product['category']),
                _buildInfoRow('Subcategory', product['subcategory']),
                _buildInfoRow('Brand', product['brand']),
                _buildInfoRow('Variant', product['variant']),
                _buildInfoRow('Unit', product['unit']),
                _buildInfoRow('Description', product['description']),
                _buildInfoRow('Barcode', product['barcode']),
                _buildInfoRow('HSN Code', product['hsn_code']),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pricing Information
            _buildInfoSection(
              context,
              'Pricing Information',
              [
                _buildInfoRow('MRP', '₹${product['mrp']?.toString() ?? '0'}'),
                _buildInfoRow('Cost Price', '₹${product['cost_price']?.toString() ?? '0'}'),
                _buildInfoRow('Selling Price', '₹${product['selling_price']?.toString() ?? '0'}'),
                _buildInfoRow('Margin %', '${product['margin_percent']?.toString() ?? '0'}%'),
                _buildInfoRow('Tax %', '${product['tax_percent']?.toString() ?? '0'}%'),
                _buildInfoRow('Tax Category', product['tax_category']),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Inventory Information
            _buildInfoSection(
              context,
              'Inventory Information',
              [
                _buildInfoRow('Min Stock Level', product['min_stock_level']?.toString()),
                _buildInfoRow('Max Stock Level', product['max_stock_level']?.toString()),
                _buildInfoRow('Lead Time (Days)', product['lead_time_days']?.toString()),
                _buildInfoRow('Shelf Life (Days)', product['shelf_life_days']?.toString()),
                _buildInfoRow('Product Status', product['product_status']),
                _buildInfoRow('Product Type', product['product_type']),
                _buildInfoRow('Default Supplier ID', product['default_supplier_id']),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Additional Information
            _buildInfoSection(
              context,
              'Additional Information',
              [
                _buildInfoRow('Tags', (product['tags'] is List) ? (product['tags'] as List).join(', ') : 'None'),
                _buildInfoRow('Created At', _formatDate(product['created_at'])),
                _buildInfoRow('Updated At', _formatDate(product['updated_at'])),
                _buildInfoRow('Created By', product['created_by']),
                _buildInfoRow('Updated By', product['updated_by']),
              ],
            ),
            
            // Product Images
            if (product['product_image_urls'] is List && (product['product_image_urls'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Product Images',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (product['product_image_urls'] as List).length,
                      itemBuilder: (context, index) {
                        final imageUrl = (product['product_image_urls'] as List)[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image_not_supported, size: 50);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'inactive':
        chipColor = Colors.red;
        break;
      case 'draft':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }
    
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      if (timestamp is Timestamp) {
        return DateFormat('MMM dd, yyyy hh:mm a').format(timestamp.toDate());
      }
      return timestamp.toString();
    } catch (e) {
      return 'Invalid Date';
    }
  }
}

// Edit Product Screen with functional form
class EditProductScreen extends StatefulWidget {
  final QueryDocumentSnapshot productDoc;

  const EditProductScreen({Key? key, required this.productDoc}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _productData;
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _categoryController;
  late TextEditingController _subcategoryController;
  late TextEditingController _brandController;
  late TextEditingController _variantController;
  late TextEditingController _unitController;
  late TextEditingController _descriptionController;
  late TextEditingController _barcodeController;
  late TextEditingController _hsnCodeController;
  late TextEditingController _mrpController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _marginPercentController;
  late TextEditingController _taxPercentController;
  late TextEditingController _taxCategoryController;
  late TextEditingController _minStockController;
  late TextEditingController _maxStockController;
  late TextEditingController _leadTimeController;
  late TextEditingController _shelfLifeController;
  String _selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    _productData = widget.productDoc.data() as Map<String, dynamic>;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _productData['product_name'] ?? '');
    _skuController = TextEditingController(text: _productData['sku'] ?? '');
    _categoryController = TextEditingController(text: _productData['category'] ?? '');
    _subcategoryController = TextEditingController(text: _productData['subcategory'] ?? '');
    _brandController = TextEditingController(text: _productData['brand'] ?? '');
    _variantController = TextEditingController(text: _productData['variant'] ?? '');
    _unitController = TextEditingController(text: _productData['unit'] ?? '');
    _descriptionController = TextEditingController(text: _productData['description'] ?? '');
    _barcodeController = TextEditingController(text: _productData['barcode'] ?? '');
    _hsnCodeController = TextEditingController(text: _productData['hsn_code'] ?? '');
    _mrpController = TextEditingController(text: _productData['mrp']?.toString() ?? '');
    _costPriceController = TextEditingController(text: _productData['cost_price']?.toString() ?? '');
    _sellingPriceController = TextEditingController(text: _productData['selling_price']?.toString() ?? '');
    _marginPercentController = TextEditingController(text: _productData['margin_percent']?.toString() ?? '');
    _taxPercentController = TextEditingController(text: _productData['tax_percent']?.toString() ?? '');
    _taxCategoryController = TextEditingController(text: _productData['tax_category'] ?? '');
    _minStockController = TextEditingController(text: _productData['min_stock_level']?.toString() ?? '');
    _maxStockController = TextEditingController(text: _productData['max_stock_level']?.toString() ?? '');
    _leadTimeController = TextEditingController(text: _productData['lead_time_days']?.toString() ?? '');
    _shelfLifeController = TextEditingController(text: _productData['shelf_life_days']?.toString() ?? '');
    _selectedStatus = (_productData['product_status'] ?? 'active').toString().toLowerCase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _brandController.dispose();
    _variantController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _hsnCodeController.dispose();
    _mrpController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _marginPercentController.dispose();
    _taxPercentController.dispose();
    _taxCategoryController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _leadTimeController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'product_name': _nameController.text.trim(),
        'sku': _skuController.text.trim(),
        'category': _categoryController.text.trim(),
        'subcategory': _subcategoryController.text.trim(),
        'brand': _brandController.text.trim(),
        'variant': _variantController.text.trim(),
        'unit': _unitController.text.trim(),
        'description': _descriptionController.text.trim(),
        'barcode': _barcodeController.text.trim(),
        'hsn_code': _hsnCodeController.text.trim(),
        'mrp': double.tryParse(_mrpController.text) ?? 0.0,
        'cost_price': double.tryParse(_costPriceController.text) ?? 0.0,
        'selling_price': double.tryParse(_sellingPriceController.text) ?? 0.0,
        'margin_percent': double.tryParse(_marginPercentController.text) ?? 0.0,
        'tax_percent': double.tryParse(_taxPercentController.text) ?? 0.0,
        'tax_category': _taxCategoryController.text.trim(),
        'min_stock_level': int.tryParse(_minStockController.text) ?? 0,
        'max_stock_level': int.tryParse(_maxStockController.text) ?? 0,
        'lead_time_days': int.tryParse(_leadTimeController.text) ?? 0,
        'shelf_life_days': int.tryParse(_shelfLifeController.text) ?? 0,
        'product_status': _selectedStatus,
        'updated_at': FieldValue.serverTimestamp(),
        'updated_by': 'current_user', // You can replace this with actual user info
      };

      await widget.productDoc.reference.update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              _showStoreAvailabilityDialog();
            },
            tooltip: 'Store Availability',
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionCard(
                'Basic Information',
                [
                  _buildTextFormField('Product Name', _nameController, required: true),
                  _buildTextFormField('SKU', _skuController, required: true),
                  _buildTextFormField('Category', _categoryController),
                  _buildTextFormField('Subcategory', _subcategoryController),
                  _buildTextFormField('Brand', _brandController),
                  _buildTextFormField('Variant', _variantController),
                  _buildTextFormField('Unit', _unitController),
                  _buildTextFormField('Description', _descriptionController, maxLines: 3),
                  _buildTextFormField('Barcode', _barcodeController),
                  _buildTextFormField('HSN Code', _hsnCodeController),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Pricing Information Section
              _buildSectionCard(
                'Pricing Information',
                [
                  _buildTextFormField('MRP', _mrpController, keyboardType: TextInputType.number),
                  _buildTextFormField('Cost Price', _costPriceController, keyboardType: TextInputType.number),
                  _buildTextFormField('Selling Price', _sellingPriceController, keyboardType: TextInputType.number),
                  _buildTextFormField('Margin %', _marginPercentController, keyboardType: TextInputType.number),
                  _buildTextFormField('Tax %', _taxPercentController, keyboardType: TextInputType.number),
                  _buildTextFormField('Tax Category', _taxCategoryController),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Inventory Information Section
              _buildSectionCard(
                'Inventory Information',
                [
                  _buildTextFormField('Min Stock Level', _minStockController, keyboardType: TextInputType.number),
                  _buildTextFormField('Max Stock Level', _maxStockController, keyboardType: TextInputType.number),
                  _buildTextFormField('Lead Time (Days)', _leadTimeController, keyboardType: TextInputType.number),
                  _buildTextFormField('Shelf Life (Days)', _shelfLifeController, keyboardType: TextInputType.number),
                  _buildStatusDropdown(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Product', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required ? (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        } : null,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    // Ensure the selected status is valid
    final validStatuses = ['active', 'inactive', 'draft'];
    if (!validStatuses.contains(_selectedStatus)) {
      _selectedStatus = 'active';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedStatus,
        decoration: InputDecoration(
          labelText: 'Product Status',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: validStatuses.map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status.substring(0, 1).toUpperCase() + status.substring(1)),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              _selectedStatus = value;
            });
          }
        },
      ),
    );
  }

  void _showStoreAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.store, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Store Availability'),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView(
            children: [
              _buildStoreAvailabilityCard('Ravali Distribution Center - Gurgaon', 45, 20, Colors.green),
              _buildStoreAvailabilityCard('Ravali Express - Bangalore MG Road', 12, 5, Colors.orange),
              _buildStoreAvailabilityCard('Ravali Quick - Pune Kothrud', 8, 15, Colors.red),
              _buildStoreAvailabilityCard('Ravali SuperMart - Hyderabad Central', 25, 10, Colors.green),
              _buildStoreAvailabilityCard('Ravali Local - Vijayawada', 0, 5, Colors.red),
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
              _showBulkTransferDialog();
            },
            child: const Text('Transfer Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreAvailabilityCard(String storeName, int currentStock, int minStock, Color statusColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(storeName, style: const TextStyle(fontWeight: FontWeight.w500)),
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

  void _showBulkTransferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Stock Transfer'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Transfer ${_productData['product_name']} between stores'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'From Store'),
                items: ['Ravali Distribution Center - Gurgaon', 'Ravali SuperMart - Hyderabad Central']
                    .map((store) => DropdownMenuItem(value: store, child: Text(store))).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'To Store'),
                items: ['Ravali Quick - Pune Kothrud', 'Ravali Local - Vijayawada']
                    .map((store) => DropdownMenuItem(value: store, child: Text(store))).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock transfer initiated successfully')),
              );
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}
