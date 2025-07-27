import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/original_models.dart';
import '../services/enhanced_services.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name, SKU, or barcode...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Products list
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: EnhancedProductService.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading products: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                final allProducts = snapshot.data ?? [];
                
                // Filter products based on search query
                final filteredProducts = _searchQuery.isEmpty
                    ? allProducts
                    : allProducts.where((product) {
                        final query = _searchQuery.toLowerCase();
                        return product.productName.toLowerCase().contains(query) ||
                               product.sku.toLowerCase().contains(query) ||
                               (product.barcode?.toLowerCase().contains(query) ?? false) ||
                               product.category.toLowerCase().contains(query);
                      }).toList();
                
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No products found. Add some products to get started!'
                              : 'No products match your search.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showAddProductDialog(context),
                            child: const Text('Add First Product'),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductCard(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (product.barcode != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Barcode: ${product.barcode}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.productStatus == 'active' ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.productStatus.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleProductAction(value, product),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: ${product.category}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (product.brand != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Brand: ${product.brand}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'MRP: ₹${product.mrp.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Selling: ₹${product.sellingPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Cost: ₹${product.costPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Stock: Min ${product.minStockLevel} | Max ${product.maxStockLevel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  product.unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleProductAction(String action, Product product) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(context, product);
        break;
      case 'view':
        _showProductDetails(context, product);
        break;
      case 'delete':
        _showDeleteConfirmation(context, product);
        break;
    }
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ProductFormDialog(),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: product),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.productName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('SKU', product.sku),
              if (product.barcode != null) _buildDetailRow('Barcode', product.barcode!),
              _buildDetailRow('Category', product.category),
              if (product.subcategory != null) _buildDetailRow('Subcategory', product.subcategory!),
              if (product.brand != null) _buildDetailRow('Brand', product.brand!),
              _buildDetailRow('Unit', product.unit),
              _buildDetailRow('Status', product.productStatus),
              _buildDetailRow('Type', product.productType),
              const Divider(),
              _buildDetailRow('MRP', '₹${product.mrp.toStringAsFixed(2)}'),
              _buildDetailRow('Selling Price', '₹${product.sellingPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Cost Price', '₹${product.costPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Margin', '${product.marginPercent.toStringAsFixed(1)}%'),
              _buildDetailRow('Tax', '${product.taxPercent.toStringAsFixed(1)}%'),
              const Divider(),
              _buildDetailRow('Min Stock', product.minStockLevel.toString()),
              _buildDetailRow('Max Stock', product.maxStockLevel.toString()),
              if (product.leadTimeDays != null) _buildDetailRow('Lead Time', '${product.leadTimeDays} days'),
              if (product.description != null) ...[
                const Divider(),
                _buildDetailRow('Description', product.description!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await EnhancedProductService.deleteProduct(product.productId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete product')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final Product? product;

  const _ProductFormDialog({this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mrpController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _taxController = TextEditingController();

  String _status = 'active';
  String _type = 'simple';

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.productName;
      _skuController.text = widget.product!.sku;
      _barcodeController.text = widget.product!.barcode ?? '';
      _categoryController.text = widget.product!.category;
      _brandController.text = widget.product!.brand ?? '';
      _unitController.text = widget.product!.unit;
      _descriptionController.text = widget.product!.description ?? '';
      _mrpController.text = widget.product!.mrp.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _costPriceController.text = widget.product!.costPrice.toString();
      _minStockController.text = widget.product!.minStockLevel.toString();
      _maxStockController.text = widget.product!.maxStockLevel.toString();
      _taxController.text = widget.product!.taxPercent.toString();
      _status = widget.product!.productStatus;
      _type = widget.product!.productType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name *'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(labelText: 'SKU *'),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category *'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(labelText: 'Brand'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(labelText: 'Unit *'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['active', 'inactive', 'discontinued']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mrpController,
                        decoration: const InputDecoration(labelText: 'MRP *'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(labelText: 'Selling Price *'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        decoration: const InputDecoration(labelText: 'Cost Price *'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        decoration: const InputDecoration(labelText: 'Min Stock *'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maxStockController,
                        decoration: const InputDecoration(labelText: 'Max Stock *'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxController,
                  decoration: const InputDecoration(labelText: 'Tax % *'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: Text(widget.product == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final now = Timestamp.now();
    final mrp = double.parse(_mrpController.text);
    final sellingPrice = double.parse(_sellingPriceController.text);
    final costPrice = double.parse(_costPriceController.text);
    final margin = ((sellingPrice - costPrice) / costPrice * 100);

    final product = Product(
      productId: widget.product?.productId ?? '',
      productName: _nameController.text,
      productSlug: _nameController.text.toLowerCase().replaceAll(' ', '-'),
      category: _categoryController.text,
      brand: _brandController.text.isEmpty ? null : _brandController.text,
      variant: null,
      unit: _unitController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      sku: _skuController.text,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
      hsnCode: null,
      mrp: mrp,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      marginPercent: margin,
      taxPercent: double.parse(_taxController.text),
      taxCategory: 'Standard',
      minStockLevel: int.parse(_minStockController.text),
      maxStockLevel: int.parse(_maxStockController.text),
      productStatus: _status,
      productType: _type,
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (widget.product == null) {
      final id = await EnhancedProductService.addProduct(product);
      success = id != null;
    } else {
      success = await EnhancedProductService.updateProduct(widget.product!.productId, product);
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product ${widget.product == null ? 'added' : 'updated'} successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${widget.product == null ? 'add' : 'update'} product')),
      );
    }
  }
}
