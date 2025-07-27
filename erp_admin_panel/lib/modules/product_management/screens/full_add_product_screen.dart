import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/store_service.dart';
import '../models/store_models.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productSlugController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subcategoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _variantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _hsnCodeController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _taxPercentController = TextEditingController();
  final TextEditingController _defaultSupplierIdController = TextEditingController();
  final TextEditingController _minStockLevelController = TextEditingController();
  final TextEditingController _maxStockLevelController = TextEditingController();
  final TextEditingController _leadTimeDaysController = TextEditingController();
  final TextEditingController _shelfLifeDaysController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  // Dropdown values
  String? _unit;
  String? _taxCategory;
  String? _productStatus;
  String? _productType;
  
  // Store selection
  String? _selectedStoreId;
  List<Store> _stores = [];
  bool _isLoadingStores = true;

  // Auto-calculated
  double? _marginPercent;

  // Dropdown options
  final List<String> _unitOptions = ['kg', 'Litre', 'pcs'];
  final List<String> _taxCategoryOptions = ['0%', '5%', '12%', '18%'];
  final List<String> _productStatusOptions = ['Active', 'Inactive', 'Discontinued'];
  final List<String> _productTypeOptions = ['Simple', 'Composite'];

  // Image URLs and Tags
  final List<String> _imageUrls = [];
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }
  
  Future<void> _loadStores() async {
    try {
      final stores = await StoreService.searchStores(status: 'Active');
      setState(() {
        _stores = stores;
        _isLoadingStores = false;
        // Set default store if only one store available
        if (stores.length == 1) {
          _selectedStoreId = stores.first.storeId;
        }
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
    _productNameController.dispose();
    _productSlugController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _brandController.dispose();
    _variantController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _hsnCodeController.dispose();
    _mrpController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _taxPercentController.dispose();
    _defaultSupplierIdController.dispose();
    _minStockLevelController.dispose();
    _maxStockLevelController.dispose();
    _leadTimeDaysController.dispose();
    _shelfLifeDaysController.dispose();
    _imageUrlController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _calculateMargin() {
    final cost = double.tryParse(_costPriceController.text) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    if (cost > 0) {
      setState(() {
        _marginPercent = ((selling - cost) / cost) * 100;
      });
    } else {
      setState(() {
        _marginPercent = null;
      });
    }
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final productId = const Uuid().v4();
      try {
        // Create store availability data
        final Map<String, dynamic> storeAvailability = {};
        if (_selectedStoreId != null) {
          storeAvailability[_selectedStoreId!] = {
            'available': true,
            'stock_level': int.tryParse(_minStockLevelController.text) ?? 0,
            'last_updated': FieldValue.serverTimestamp(),
          };
        }

        await FirebaseFirestore.instance.collection('products').doc(productId).set({
          'product_id': productId,
          'product_name': _productNameController.text.trim(),
          'product_slug': _productSlugController.text.trim(),
          'category': _categoryController.text.trim(),
          'subcategory': _subcategoryController.text.trim(),
          'brand': _brandController.text.trim(),
          'variant': _variantController.text.trim(),
          'unit': _unit,
          'description': _descriptionController.text.trim(),
          'sku': _skuController.text.trim(),
          'barcode': _barcodeController.text.trim(),
          'hsn_code': _hsnCodeController.text.trim(),
          'mrp': double.tryParse(_mrpController.text) ?? 0,
          'cost_price': double.tryParse(_costPriceController.text) ?? 0,
          'selling_price': double.tryParse(_sellingPriceController.text) ?? 0,
          'margin_percent': _marginPercent ?? 0,
          'tax_percent': double.tryParse(_taxPercentController.text) ?? 0,
          'tax_category': _taxCategory,
          'default_supplier_id': _defaultSupplierIdController.text.trim(),
          'min_stock_level': int.tryParse(_minStockLevelController.text) ?? 0,
          'max_stock_level': int.tryParse(_maxStockLevelController.text) ?? 0,
          'lead_time_days': int.tryParse(_leadTimeDaysController.text) ?? 0,
          'shelf_life_days': int.tryParse(_shelfLifeDaysController.text) ?? 0,
          'product_status': _productStatus,
          'product_type': _productType,
          'product_image_urls': _imageUrls,
          'tags': _tags,
          // Store-related fields
          'target_store_id': _selectedStoreId,
          'store_availability': storeAvailability,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        final storeName = _stores.firstWhere(
          (store) => store.storeId == _selectedStoreId,
          orElse: () => Store(
            storeId: '', 
            storeCode: '', 
            storeName: 'Unknown Store', 
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
          )
        ).storeName;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product "${_productNameController.text}" added to $storeName successfully!')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageUrls.clear();
          _tags.clear();
          _unit = null;
          _taxCategory = null;
          _productStatus = null;
          _productType = null;
          _selectedStoreId = _stores.length == 1 ? _stores.first.storeId : null; // Reset to default if single store
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Product', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Basic Information', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Text('Product ID: ${Uuid().v4()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(labelText: 'Product Name *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onChanged: (v) {
                        _productSlugController.text = v.toLowerCase().replaceAll(' ', '-');
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _productSlugController,
                      decoration: const InputDecoration(labelText: 'Product Slug'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    // Store Selection
                    _isLoadingStores
                      ? Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Loading stores...', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedStoreId,
                          decoration: InputDecoration(
                            labelText: 'Target Store *',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            prefixIcon: Icon(Icons.store, color: Colors.deepPurple),
                            helperText: 'Select the store where this product will be available',
                          ),
                          isExpanded: true,
                          items: _stores.map((store) => DropdownMenuItem<String>(
                            value: store.storeId,
                            child: Row(
                              children: [
                                Icon(Icons.store_outlined, size: 18, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        store.storeName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${store.storeCode} • ${store.city}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                          validator: (value) => value == null ? 'Please select a target store' : null,
                          onChanged: (value) {
                            setState(() {
                              _selectedStoreId = value;
                            });
                          },
                        ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Category *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _subcategoryController,
                      decoration: const InputDecoration(labelText: 'Subcategory'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _variantController,
                      decoration: const InputDecoration(labelText: 'Variant'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _unit,
                      items: _unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setState(() => _unit = v),
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pricing', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mrpController,
                      decoration: const InputDecoration(labelText: 'MRP'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateMargin(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(labelText: 'Cost Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateMargin(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(labelText: 'Selling Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateMargin(),
                    ),
                    const SizedBox(height: 8),
                    Text('Margin %: ${_marginPercent?.toStringAsFixed(2) ?? "-"}', style: const TextStyle(color: Colors.blueGrey)),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock & Supplier', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(labelText: 'Barcode'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hsnCodeController,
                      decoration: const InputDecoration(labelText: 'HSN Code'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _defaultSupplierIdController,
                      decoration: const InputDecoration(labelText: 'Default Supplier ID'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _minStockLevelController,
                      decoration: const InputDecoration(labelText: 'Min Stock Level'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _maxStockLevelController,
                      decoration: const InputDecoration(labelText: 'Max Stock Level'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _leadTimeDaysController,
                      decoration: const InputDecoration(labelText: 'Lead Time (days)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _shelfLifeDaysController,
                      decoration: const InputDecoration(labelText: 'Shelf Life (days)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tax & Status', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxPercentController,
                      decoration: const InputDecoration(labelText: 'Tax Percent'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _taxCategory,
                      items: _taxCategoryOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _taxCategory = v),
                      decoration: const InputDecoration(labelText: 'Tax Category'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _productStatus,
                      items: _productStatusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _productStatus = v),
                      decoration: const InputDecoration(labelText: 'Product Status'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _productType,
                      items: _productTypeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _productType = v),
                      decoration: const InputDecoration(labelText: 'Product Type'),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Images & Tags', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Text('Product Images'),
                    Wrap(
                      spacing: 8,
                      children: _imageUrls.map((url) => Chip(
                        label: Text(url),
                        onDeleted: () {
                          setState(() => _imageUrls.remove(url));
                        },
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: const TextStyle(color: Colors.blue),
                      )).toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(labelText: 'Add Image URL'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () {
                            final url = _imageUrlController.text.trim();
                            if (url.isNotEmpty) {
                              setState(() {
                                _imageUrls.add(url);
                                _imageUrlController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Tags'),
                    Wrap(
                      spacing: 8,
                      children: _tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() => _tags.remove(tag));
                        },
                        backgroundColor: Colors.green.shade50,
                        labelStyle: const TextStyle(color: Colors.green),
                      )).toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: const InputDecoration(labelText: 'Add Tag'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            final tag = _tagController.text.trim();
                            if (tag.isNotEmpty) {
                              setState(() {
                                _tags.add(tag);
                                _tagController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Add Product', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}