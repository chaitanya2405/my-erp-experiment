import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/pos_provider.dart';
import '../models/pos_transaction.dart';
import '../models/product.dart';
import '../models/customer_profile.dart';
import '../core/models/unified_models.dart' hide PosTransaction, Product, CustomerProfile;
import '../models/original_models.dart' as legacy_models;
import '../services/discount_engine.dart';
import '../services/gst_calculator.dart';
import '../services/barcode_scanner_service.dart';
import '../services/role_based_access_service.dart';
import '../services/pos_audit_service.dart';
import '../services/pos_service.dart';

class AddEditPosTransactionScreen extends StatefulWidget {
  final legacy_models.PosTransaction? transaction;

  const AddEditPosTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddEditPosTransactionScreen> createState() => _AddEditPosTransactionScreenState();
}

class _AddEditPosTransactionScreenState extends State<AddEditPosTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers for form fields
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _couponCodeController = TextEditingController();
  final _remarksController = TextEditingController();
  
  // Product item controllers
  final List<Map<String, TextEditingController>> _itemControllers = [];
  
  // Form data
  String _selectedPaymentMode = 'Cash';
  String _selectedCustomerTier = 'Regular';
  String _selectedChannel = 'In-Store';
  bool _isLoyaltyMember = false;
  bool _isFirstTimeCustomer = false;
  bool _expressMode = false;
  
  // Product items
  List<Map<String, dynamic>> _productItems = [];
  
  // Dropdown data
  List<Product> _availableProducts = [];
  List<CustomerProfile> _availableCustomers = [];
  CustomerProfile? _selectedCustomer;
  String _customerSearchQuery = '';
  String _productSearchQuery = '';
  bool _showCustomerDropdown = false;
  bool _showProductDropdown = false;
  
  // Calculation results
  double _subtotal = 0;
  double _totalDiscount = 0;
  double _totalGst = 0;
  double _finalAmount = 0;
  Map<String, dynamic> _discountDetails = {};
  Map<String, dynamic> _gstDetails = {};
  
  // Loading states
  bool _isLoading = false;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _couponCodeController.dispose();
    _remarksController.dispose();
    _scrollController.dispose();
    _disposeItemControllers();
    super.dispose();
  }

  // Helper functions for dropdown validation
  String _getValidPaymentMode(String value) {
    const validModes = ['Cash', 'Card', 'UPI', 'Wallet', 'Credit'];
    return validModes.contains(value) ? value : 'Cash';
  }

  String _getValidCustomerTier(String value) {
    const validTiers = ['VIP', 'Premium', 'Gold', 'Silver', 'Regular'];
    return validTiers.contains(value) ? value : 'Regular';
  }

  String _getValidChannel(String value) {
    const validChannels = ['In-Store', 'Online', 'Phone', 'WhatsApp'];
    // Handle common mismatches
    if (value.toLowerCase() == 'online') return 'Online';
    if (value.toLowerCase() == 'offline' || value.toLowerCase() == 'in-store') return 'In-Store';
    return validChannels.contains(value) ? value : 'In-Store';
  }

  String _getValidCategoryValue(String value) {
    const validCategories = [
      'electronics',
      'clothing', 
      'food_grains',
      'dairy',
      'fruits',
      'vegetables',
      'medicines',
      'cosmetics',
      'books',
      'furniture',
    ];
    return validCategories.contains(value) ? value : 'electronics';
  }

  void _initializeForm() {
    if (widget.transaction != null) {
      // Edit mode - populate existing data
      final transaction = widget.transaction!;
      _customerNameController.text = transaction.customerInfo?['customerName'] ?? '';
      _customerPhoneController.text = transaction.customerInfo?['customerPhone'] ?? '';
      _customerEmailController.text = transaction.customerInfo?['customerEmail'] ?? '';
      _selectedPaymentMode = _getValidPaymentMode(transaction.paymentMethod);
      _selectedCustomerTier = _getValidCustomerTier(transaction.customerInfo?['customerTier'] ?? 'Regular');
      _selectedChannel = _getValidChannel(transaction.customerInfo?['channel'] ?? 'POS');
      _remarksController.text = transaction.notes ?? '';
      
      // Populate product items - convert item objects to Map format
      _productItems = transaction.items.map((item) => {
        'productId': item['product_id'] ?? '',
        'productName': item['product_name'] ?? '',
        'sku': item['sku'] ?? '',
        'quantity': item['quantity'] ?? 1,
        'mrp': item['mrp'] ?? 0.0,
        'sellingPrice': item['unit_price'] ?? 0.0,
        'finalPrice': item['final_price'] ?? item['unit_price'] ?? 0.0,
        'batchNumber': item['batch_number'] ?? '',
        'discountAmount': item['discount'] ?? 0.0,
        'taxAmount': item['tax_amount'] ?? 0.0,
        'taxSlab': item['tax_slab'] ?? '18%',
        // Additional fields used in the UI
        'unit_price': item['unit_price'] ?? 0.0,
        'total_price': item['total_price'] ?? 0.0,
      }).toList();
      _createItemControllers();
      _calculateTotals();
    } else {
      // New transaction - add first item
      _addNewItem();
    }
    
    // Load dropdown data
    _loadAvailableData();
  }

  // Load available customers and products for dropdowns
  Future<void> _loadAvailableData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load customers and products in parallel
      final results = await Future.wait([
        PosService.searchCustomers(''), // Load all customers
        PosService.getAvailableProducts(), // Load all products
      ]);
      
      setState(() {
        _availableCustomers = results[0] as List<CustomerProfile>;
        _availableProducts = results[1] as List<Product>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  // Search customers
  Future<void> _searchCustomers(String query) async {
    if (query.isEmpty) {
      await _loadAvailableData();
      return;
    }
    
    try {
      final customers = await PosService.searchCustomers(query);
      setState(() {
        _availableCustomers = customers;
        _customerSearchQuery = query;
      });
    } catch (e) {
      debugPrint('Error searching customers: $e');
    }
  }

  // Search products
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      await _loadAvailableData();
      return;
    }
    
    try {
      final products = await PosService.searchProducts(query);
      setState(() {
        _availableProducts = products;
        _productSearchQuery = query;
      });
    } catch (e) {
      debugPrint('Error searching products: $e');
    }
  }

  void _createItemControllers() {
    _disposeItemControllers();
    _itemControllers.clear();
    
    for (int i = 0; i < _productItems.length; i++) {
      final item = _productItems[i];
      _itemControllers.add({
        'name': TextEditingController(text: item['product_name'] ?? ''),
        'code': TextEditingController(text: item['product_code'] ?? ''),
        'quantity': TextEditingController(text: (item['quantity'] ?? 1).toString()),
        'price': TextEditingController(text: (item['unit_price'] ?? 0.0).toString()),
        'category': TextEditingController(text: item['category'] ?? 'electronics'),
      });
    }
  }

  void _disposeItemControllers() {
    for (final controllers in _itemControllers) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'New Sale' : 'Edit Sale'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_expressMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'EXPRESS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanBarcode(0),
            tooltip: 'Scan Barcode',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'express_mode',
                child: Row(
                  children: [
                    Icon(_expressMode ? Icons.flash_off : Icons.flash_on),
                    const SizedBox(width: 8),
                    Text(_expressMode ? 'Disable Express' : 'Enable Express'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'apply_coupon',
                child: Row(
                  children: [
                    Icon(Icons.local_offer),
                    SizedBox(width: 8),
                    Text('Apply Coupon'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'customer_lookup',
                child: Row(
                  children: [
                    Icon(Icons.person_search),
                    SizedBox(width: 8),
                    Text('Customer Lookup'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerSection(),
                    const SizedBox(height: 24),
                    _buildProductItemsSection(),
                    const SizedBox(height: 24),
                    _buildCalculationSection(),
                    const SizedBox(height: 24),
                    _buildPaymentSection(),
                    if (!_expressMode) ...[
                      const SizedBox(height: 24),
                      _buildAdvancedOptionsSection(),
                    ],
                    const SizedBox(height: 100), // Space for bottom sheet
                  ],
                ),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Customer Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_selectedCustomer != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCustomer = null;
                        _customerNameController.clear();
                        _customerPhoneController.clear();
                        _customerEmailController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_expressMode) ...[
              // Customer Search/Select Dropdown
              _buildCustomerSearchDropdown(),
              const SizedBox(height: 16),
              
              // Customer details (auto-filled if selected, manual if new)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        hintText: _selectedCustomer != null 
                          ? 'Auto-filled from selected customer'
                          : 'Enter customer name (optional)',
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                        enabled: _selectedCustomer == null,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _customerPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: _selectedCustomer != null
                          ? 'Auto-filled'
                          : 'Enter phone number',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        enabled: _selectedCustomer == null,
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCustomerTier,
                      decoration: const InputDecoration(
                        labelText: 'Customer Tier',
                        border: OutlineInputBorder(),
                      ),
                      items: ['VIP', 'Premium', 'Gold', 'Silver', 'Regular']
                          .map((tier) => DropdownMenuItem(
                                value: tier,
                                child: Text(tier),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerTier = value!;
                        });
                        _calculateTotals();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Loyalty Member'),
                      value: _isLoyaltyMember,
                      onChanged: (value) {
                        setState(() {
                          _isLoyaltyMember = value!;
                        });
                        _calculateTotals();
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('First Time Customer'),
                      value: _isFirstTimeCustomer,
                      onChanged: (value) {
                        setState(() {
                          _isFirstTimeCustomer = value!;
                        });
                        _calculateTotals();
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Express Mode - Customer: ${_customerNameController.text.isEmpty ? 'Walk-in Customer' : _customerNameController.text}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build customer search dropdown
  Widget _buildCustomerSearchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Existing Customer (Optional)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        
        // Search field with selected customer display
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Search/Display field
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _selectedCustomer != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    child: Text(_selectedCustomer!.customerName.isNotEmpty 
                                      ? _selectedCustomer!.customerName[0].toUpperCase() 
                                      : 'C'),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCustomer!.customerName,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        if (_selectedCustomer!.mobileNumber.isNotEmpty)
                                          Text(
                                            _selectedCustomer!.mobileNumber,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _selectedCustomer = null;
                                        _customerNameController.clear();
                                        _customerPhoneController.clear();
                                        _customerEmailController.clear();
                                        _customerIdController.clear();
                                        _showCustomerDropdown = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                          : TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search by name or phone number...',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _showCustomerDropdown = value.isNotEmpty;
                                });
                                _searchCustomers(value);
                              },
                              onTap: () {
                                setState(() {
                                  _showCustomerDropdown = true;
                                });
                              },
                            ),
                    ),
                  ],
                ),
              ),
              
              // Customer list (only show when searching and no customer selected)
              if (_showCustomerDropdown && _selectedCustomer == null) ...[
                const Divider(height: 1),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (_availableCustomers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No customers found'),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _availableCustomers[index];
                        
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(customer.customerName.isNotEmpty 
                              ? customer.customerName[0].toUpperCase() 
                              : 'C'),
                          ),
                          title: Text(customer.customerName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer.mobileNumber.isNotEmpty)
                                Text('📞 ${customer.mobileNumber}'),
                              if (customer.email.isNotEmpty)
                                Text('📧 ${customer.email}'),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCustomer = customer;
                              _customerNameController.text = customer.customerName;
                              _customerPhoneController.text = customer.mobileNumber;
                              _customerEmailController.text = customer.email;
                              _customerIdController.text = customer.customerId;
                              _showCustomerDropdown = false; // Hide dropdown after selection
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildProductItemsList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductItemsList() {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _productItems.length; i++) {
      widgets.add(_buildProductItemCard(i));
      if (i < _productItems.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    return widgets;
  }

  Widget _buildProductItemCard(int index) {
    final controllers = _itemControllers[index];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_productItems.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_expressMode) ...[
            // Product selection dropdown
            _buildProductSelectionDropdown(index),
            const SizedBox(height: 12),
            
            // Product details (auto-filled if selected, manual if new)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controllers['name'],
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      border: OutlineInputBorder(),
                      hintText: 'Select from dropdown or enter manually',
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Product name is required' : null,
                    onChanged: (value) => _updateItem(index, 'product_name', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controllers['code'],
                    decoration: const InputDecoration(
                      labelText: 'Product Code',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _updateItem(index, 'product_code', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers['quantity'],
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Quantity is required';
                    final qty = int.tryParse(value!);
                    if (qty == null || qty <= 0) return 'Invalid quantity';
                    return null;
                  },
                  onChanged: (value) {
                    final qty = int.tryParse(value) ?? 0;
                    _updateItem(index, 'quantity', qty);
                    _calculateTotals();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controllers['price'],
                  decoration: const InputDecoration(
                    labelText: 'Unit Price *',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Price is required';
                    final price = double.tryParse(value!);
                    if (price == null || price <= 0) return 'Invalid price';
                    return null;
                  },
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    _updateItem(index, 'unit_price', price);
                    _calculateTotals();
                  },
                ),
              ),
              if (!_expressMode) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _getValidCategoryValue(controllers['category']!.text),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'electronics',
                      'clothing',
                      'food_grains',
                      'dairy',
                      'fruits',
                      'vegetables',
                      'medicines',
                      'cosmetics',
                      'books',
                      'furniture',
                    ].map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.replaceAll('_', ' ').toUpperCase()),
                        ))
                        .toList(),
                    onChanged: (value) {
                      controllers['category']!.text = value!;
                      _updateItem(index, 'category', value);
                      _calculateTotals();
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹${(_productItems[index]['total_price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (!_expressMode)
                TextButton.icon(
                  onPressed: () => _scanBarcode(index),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Build product selection dropdown for a specific item
  Widget _buildProductSelectionDropdown(int index) {
    final selectedProductId = _productItems[index]['product_id'];
    final selectedProduct = selectedProductId != null 
        ? _availableProducts.firstWhere((p) => p.productId == selectedProductId, orElse: () => _availableProducts.first)
        : null;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Product ${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Search/Display field
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: selectedProduct != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue[100],
                                    child: Text(
                                      selectedProduct.productName.isNotEmpty 
                                        ? selectedProduct.productName[0].toUpperCase() 
                                        : 'P',
                                      style: TextStyle(color: Colors.blue[800]),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedProduct.productName,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          'SKU: ${selectedProduct.sku} • ₹${selectedProduct.sellingPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _productItems[index].remove('product_id');
                                        if (index < _itemControllers.length) {
                                          _itemControllers[index]['name']?.clear();
                                          _itemControllers[index]['code']?.clear();
                                          _itemControllers[index]['price']?.clear();
                                        }
                                      });
                                      _calculateTotals();
                                    },
                                  ),
                                ],
                              ),
                            )
                          : TextField(
                              decoration: InputDecoration(
                                hintText: 'Search products by name, SKU, or barcode...',
                                prefixIcon: const Icon(Icons.search),
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  onPressed: () => _scanBarcode(index),
                                  tooltip: 'Scan Barcode',
                                ),
                              ),
                              onChanged: (value) {
                                _searchProducts(value);
                              },
                            ),
                    ),
                  ],
                ),
              ),
              
              // Product list (only show when no product is selected and there are products)
              if (selectedProduct == null && _availableProducts.isNotEmpty) ...[
                const Divider(height: 1),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableProducts.length,
                      itemBuilder: (context, productIndex) {
                        final product = _availableProducts[productIndex];
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              product.productName.isNotEmpty 
                                ? product.productName[0].toUpperCase() 
                                : 'P',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                          title: Text(product.productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SKU: ${product.sku}'),
                              Text('Price: ₹${product.sellingPrice.toStringAsFixed(2)}'),
                              if (product.description?.isNotEmpty == true)
                                Text('${product.description}'),
                            ],
                          ),
                          onTap: () {
                            _selectProductForItem(index, product);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Select a product for a specific item
  void _selectProductForItem(int index, Product product) {
    setState(() {
      _productItems[index] = {
        'product_id': product.productId,
        'product_name': product.productName,
        'product_code': product.sku,
        'unit_price': product.sellingPrice,
        'quantity': _productItems[index]['quantity'] ?? 1,
        'category': _getValidCategoryValue(product.category),
        'gst_rate': product.taxPercent,
        'description': product.description,
      };
      
      // Calculate total price for the item
      final quantity = _productItems[index]['quantity'] ?? 1;
      final unitPrice = product.sellingPrice;
      _productItems[index]['total_price'] = quantity * unitPrice;
      
      // Update controllers
      if (index < _itemControllers.length) {
        _itemControllers[index]['name']?.text = product.productName;
        _itemControllers[index]['code']?.text = product.sku;
        _itemControllers[index]['price']?.text = product.sellingPrice.toString();
        _itemControllers[index]['category']?.text = _getValidCategoryValue(product.category);
      }
    });
    
    _calculateTotals();
  }

  // Scan barcode for product selection
  Future<void> _scanBarcode(int index) async {
    try {
      final barcode = await BarcodeScannerService.scanBarcode();
      if (barcode != null && barcode.isNotEmpty) {
        final product = await PosService.getProductByBarcode(barcode);
        if (product != null) {
          _selectProductForItem(index, product);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product found: ${product.productName}')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product not found for this barcode')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barcode scan failed: $e')),
        );
      }
    }
  }

  Widget _buildCalculationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculation Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isCalculating)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildCalculationRow('Subtotal', _subtotal),
              if (_totalDiscount > 0) ...[
                _buildCalculationRow('Discount', -_totalDiscount, color: Colors.orange),
                if (_discountDetails['applied_discounts'] != null) ...[
                  const SizedBox(height: 8),
                  ...(_discountDetails['applied_discounts'] as List<String>)
                      .map((discount) => Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '• $discount',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                              ),
                            ),
                          )),
                ],
              ],
              if (_totalGst > 0)
                _buildCalculationRow('GST', _totalGst, color: Colors.blue),
              const Divider(),
              _buildCalculationRow(
                'Final Amount',
                _finalAmount,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, double amount, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: color ?? (isTotal ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMode,
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                border: OutlineInputBorder(),
              ),
              items: ['Cash', 'Card', 'UPI', 'Wallet', 'Credit']
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMode = value!;
                });
              },
            ),
            if (!_expressMode) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedChannel,
                decoration: const InputDecoration(
                  labelText: 'Sales Channel',
                  border: OutlineInputBorder(),
                ),
                items: ['In-Store', 'Online', 'Phone', 'WhatsApp']
                    .map((channel) => DropdownMenuItem(
                          value: channel,
                          child: Text(channel),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChannel = value!;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _couponCodeController,
              decoration: InputDecoration(
                labelText: 'Coupon Code',
                hintText: 'Enter coupon code',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _applyCoupon,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                hintText: 'Additional notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₹${_finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      widget.transaction == null ? 'Create Sale' : 'Update Sale',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _productItems.add({
        'product_name': '',
        'product_code': '',
        'quantity': 1,
        'unit_price': 0.0,
        'total_price': 0.0,
        'category': 'electronics',
      });
      
      _itemControllers.add({
        'name': TextEditingController(),
        'code': TextEditingController(),
        'quantity': TextEditingController(text: '1'),
        'price': TextEditingController(text: '0'),
        'category': TextEditingController(text: 'electronics'),
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _productItems.removeAt(index);
      
      // Dispose controllers
      for (final controller in _itemControllers[index].values) {
        controller.dispose();
      }
      _itemControllers.removeAt(index);
    });
    _calculateTotals();
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      _productItems[index][field] = value;
      
      // Calculate total price for the item
      final quantity = _productItems[index]['quantity'] ?? 0;
      final unitPrice = _productItems[index]['unit_price'] ?? 0.0;
      _productItems[index]['total_price'] = quantity * unitPrice;
    });
  }

  void _calculateTotals() {
    setState(() {
      _isCalculating = true;
    });

    // Calculate subtotal
    _subtotal = _productItems.fold(0.0, (sum, item) {
      return sum + (item['total_price'] ?? 0.0);
    });

    // Calculate discount
    _discountDetails = DiscountEngine.calculateDiscount(
      items: _productItems,
      customerTier: _selectedCustomerTier,
      totalAmount: _subtotal,
      isFirstTimeCustomer: _isFirstTimeCustomer,
      isLoyaltyMember: _isLoyaltyMember,
      couponCode: _couponCodeController.text.trim(),
      transactionTime: DateTime.now(),
    );

    _totalDiscount = _discountDetails['total_discount'] ?? 0.0;
    final amountAfterDiscount = _subtotal - _totalDiscount;

    // Calculate GST
    _gstDetails = GstCalculator.calculateTransactionGst(
      items: _productItems,
      stateFrom: 'Karnataka', // Store state
      stateTo: 'Karnataka',   // Customer state (assume same for now)
      inclusive: false,
    );

    _totalGst = _gstDetails['total_gst_amount'] ?? 0.0;
    _finalAmount = amountAfterDiscount + _totalGst;

    setState(() {
      _isCalculating = false;
    });
  }

  void _applyCoupon() {
    final couponCode = _couponCodeController.text.trim();
    
    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    if (!DiscountEngine.isValidCouponCode(couponCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid coupon code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _calculateTotals();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon applied successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'express_mode':
        setState(() {
          _expressMode = !_expressMode;
        });
        break;
      case 'apply_coupon':
        _showCouponDialog();
        break;
      case 'customer_lookup':
        _showCustomerLookupDialog();
        break;
    }
  }

  void _showCouponDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Coupons'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DiscountEngine.getAvailableCoupons().map((coupon) {
            return ListTile(
              title: Text(coupon['code']),
              subtitle: Text(coupon['description']),
              onTap: () {
                _couponCodeController.text = coupon['code'];
                Navigator.pop(context);
                _applyCoupon();
              },
            );
          }).toList(),
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

  void _showCustomerLookupDialog() {
    // TODO: Implement customer lookup
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Lookup'),
        content: const Text('Customer lookup feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    // Check RBAC permissions
    final rbac = RoleBasedAccessService.instance;
    
    if (widget.transaction == null) {
      // Creating new transaction
      rbac.requirePermission(PosPermission.createTransaction, 'create transactions');
    } else {
      // Editing existing transaction
      rbac.requirePermission(PosPermission.editTransaction, 'edit transactions');
    }
    
    // Check payment mode permissions
    if (!_canProcessPaymentMode(_selectedPaymentMode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You do not have permission to process $_selectedPaymentMode payments'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check discount approval if needed
    if (_totalDiscount > 0 && _totalDiscount > _subtotal * 0.1) {
      // High discount requires approval
      if (!rbac.hasPermission(PosPermission.approveDiscount)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('High discounts require manager approval'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // TODO: Implement approval workflow
        final approved = await _requestDiscountApproval();
        if (!approved) return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_productItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final posProvider = Provider.of<PosProvider>(context, listen: false);
      
      // Generate invoice number if creating new transaction
      String invoiceNumber = widget.transaction?.receiptNumber ?? '';
      if (invoiceNumber.isEmpty) {
        invoiceNumber = await posProvider.generateInvoiceNumber();
      }

      final transaction = legacy_models.PosTransaction(
        transactionId: widget.transaction?.transactionId ?? '',
        storeId: posProvider.selectedStore,
        customerId: _customerIdController.text.trim().isEmpty ? null : _customerIdController.text.trim(),
        cashierId: rbac.currentUser?.id ?? 'UNKNOWN',
        transactionDate: Timestamp.fromDate(widget.transaction?.transactionDate.toDate() ?? DateTime.now()),
        items: _productItems.map((item) => {
          'product_id': item['productId'] ?? '',
          'product_name': item['productName'] ?? '',
          'product_code': item['sku'] ?? '',
          'quantity': item['quantity'] ?? 1,
          'unit_price': (item['sellingPrice'] ?? 0).toDouble(),
          'total_price': (item['finalPrice'] ?? 0).toDouble() * (item['quantity'] ?? 1),
          'discount': (item['discountAmount'] ?? 0).toDouble(),
          'tax_amount': (item['taxAmount'] ?? 0).toDouble(),
          'mrp': (item['mrp'] ?? 0).toDouble(),
          'batch_number': item['batchNumber'] ?? '',
          'tax_slab': item['taxSlab'] ?? '18%',
          'category': item['category'] ?? '',
          'variant': item['variant'] ?? '',
        }).toList(),
        subtotal: _subtotal,
        discountAmount: _totalDiscount,
        taxAmount: _gstDetails.values.fold(0.0, (sum, value) => sum + (value as num).toDouble()),
        totalAmount: _finalAmount,
        paymentMethod: _selectedPaymentMode,
        transactionStatus: 'completed',
        receiptNumber: invoiceNumber,
        customerInfo: {
          'customerName': _customerNameController.text.trim(),
          'customerPhone': _customerPhoneController.text.trim(),
          'customerEmail': _customerEmailController.text.trim(),
          'customerTier': _selectedCustomerTier,
          'channel': _selectedChannel,
        },
        notes: _remarksController.text.trim(),
        createdAt: Timestamp.fromDate(widget.transaction?.createdAt.toDate() ?? DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()),
      );

      String? result;
      if (widget.transaction == null) {
        result = await posProvider.createTransaction(_convertToUnified(transaction));
      } else {
        final success = await posProvider.updateTransaction(
          widget.transaction!.transactionId,
          _convertToUnified(transaction),
        );
        result = success ? 'updated' : null;
      }

      if (result != null) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.transaction == null
                    ? 'Transaction created successfully'
                    : 'Transaction updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(posProvider.error ?? 'Failed to save transaction');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Look up product by barcode (mock implementation)
  Future<Map<String, dynamic>?> _lookupProductByBarcode(String barcode) async {
    // In a real app, this would query your product database
    // For demo purposes, we'll return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock product database
    final mockProducts = {
      'PROD123456': {
        'id': 'prod_001',
        'name': 'Sample Product 1',
        'price': 299.99,
        'category': 'electronics',
        'hsn_code': '85171200',
        'gst_rate': 18.0,
        'description': 'Sample electronic product',
      },
      'SKU789012': {
        'id': 'prod_002',
        'name': 'Sample Product 2',
        'price': 149.99,
        'category': 'clothing',
        'hsn_code': '61091000',
        'gst_rate': 12.0,
        'description': 'Sample clothing item',
      },
      '1234567890123': {
        'id': 'prod_003',
        'name': 'Grocery Item',
        'price': 89.99,
        'category': 'food',
        'hsn_code': '19019000',
        'gst_rate': 5.0,
        'description': 'Sample food item',
      },
    };
    
    return mockProducts[barcode];
  }

  /// Add item from barcode scan
  void _addItemFromBarcode(Map<String, dynamic> product) {
    setState(() {
      _productItems.add({
        'product_id': product['id'],
        'product_name': product['name'],
        'product_code': product['barcode'] ?? '',
        'quantity': 1,
        'unit_price': product['price'] ?? 0.0,
        'category': product['category'] ?? 'electronics',
        'hsn_code': product['hsn_code'] ?? '',
        'gst_rate': product['gst_rate'] ?? 18.0,
      });
    });
    
    // Add controllers for the new item
    _itemControllers.add({
      'name': TextEditingController(text: product['name']),
      'code': TextEditingController(text: product['barcode'] ?? ''),
      'quantity': TextEditingController(text: '1'),
      'price': TextEditingController(text: (product['price'] ?? 0.0).toString()),
      'category': TextEditingController(text: product['category'] ?? 'electronics'),
    });
    
    _calculateTotals();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product['name']} to cart'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show dialog when product is not found
  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: $barcode'),
            const SizedBox(height: 8),
            const Text('This product is not in our database. Would you like to:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addManualItem(barcode);
              Navigator.of(context).pop();
            },
            child: const Text('Add Manually'),
          ),
          TextButton(
            onPressed: () {
              _createNewProduct(barcode);
              Navigator.of(context).pop();
            },
            child: const Text('Create New Product'),
          ),
        ],
      ),
    );
  }

  /// Add manual item with scanned barcode
  void _addManualItem(String barcode) {
    setState(() {
      _productItems.add({
        'product_id': 'manual_${DateTime.now().millisecondsSinceEpoch}',
        'product_name': '',
        'product_code': barcode,
        'quantity': 1,
        'unit_price': 0.0,
        'category': 'electronics',
        'hsn_code': '',
        'gst_rate': 18.0,
      });
    });
    
    _itemControllers.add({
      'name': TextEditingController(),
      'code': TextEditingController(text: barcode),
      'quantity': TextEditingController(text: '1'),
      'price': TextEditingController(text: '0.0'),
      'category': TextEditingController(text: 'electronics'),
    });
    
    // Scroll to the new item for user to fill details
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in product details manually'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Create new product (placeholder)
  void _createNewProduct(String barcode) {
    // TODO: Implement new product creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product creation feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Batch scan multiple items
  Future<void> _batchScan() async {
    final rbac = RoleBasedAccessService.instance;
    if (!rbac.hasPermission(PosPermission.scanBarcode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to scan barcodes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final List<String> barcodes = await BarcodeScannerService.batchScan(maxItems: 10);
      
      if (barcodes.isNotEmpty) {
        int addedCount = 0;
        int notFoundCount = 0;
        
        for (final barcode in barcodes) {
          final product = await _lookupProductByBarcode(barcode);
          if (product != null) {
            _addItemFromBarcode(product);
            addedCount++;
          } else {
            notFoundCount++;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $addedCount items. $notFoundCount not found.'),
            backgroundColor: addedCount > 0 ? Colors.green : Colors.orange,
          ),
        );
        
        // Log batch scan
        await PosAuditService.logEvent(
          'BATCH_SCAN_COMPLETED',
          'Batch scan completed: $addedCount added, $notFoundCount not found',
          userId: rbac.currentUser?.id ?? 'unknown',
          entityId: 'batch_${DateTime.now().millisecondsSinceEpoch}',
          metadata: {
            'barcodes': barcodes,
            'addedCount': addedCount,
            'notFoundCount': notFoundCount,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Batch scan failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Check if user can process specific payment mode
  bool _canProcessPaymentMode(String paymentMode) {
    final rbac = RoleBasedAccessService.instance;
    
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return rbac.hasPermission(PosPermission.processCash);
      case 'card':
        return rbac.hasPermission(PosPermission.processCard);
      case 'upi':
        return rbac.hasPermission(PosPermission.processUPI);
      case 'wallet':
        return rbac.hasPermission(PosPermission.processWallet);
      default:
        return rbac.hasPermission(PosPermission.processCash);
    }
  }

  /// Request discount approval from manager
  Future<bool> _requestDiscountApproval() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Manager Approval Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discount: ₹${_totalDiscount.toStringAsFixed(2)}'),
            Text('Subtotal: ₹${_subtotal.toStringAsFixed(2)}'),
            Text('Discount %: ${((_totalDiscount / _subtotal) * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('This discount requires manager approval. Please ask your manager to approve this transaction.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual approval workflow
              Navigator.of(context).pop(true);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Check express mode permission
  void _checkExpressModePermission() {
    if (_expressMode) {
      final rbac = RoleBasedAccessService.instance;
      if (!rbac.hasPermission(PosPermission.expressMode)) {
        setState(() {
          _expressMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to use express mode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Apply bulk discount with permission check
  Future<void> _applyBulkDiscount() async {
    final rbac = RoleBasedAccessService.instance;
    if (!rbac.hasPermission(PosPermission.bulkOperations)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission for bulk operations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement bulk discount logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk discount feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Convert PosTransaction to UnifiedPOSTransaction
  UnifiedPOSTransaction _convertToUnified(legacy_models.PosTransaction transaction) {
    return UnifiedPOSTransaction(
      id: transaction.transactionId,
      posTransactionId: transaction.transactionId,
      transactionId: transaction.transactionId,
      customerId: transaction.customerId,
      storeId: transaction.storeId,
      terminalId: 'terminal_01', // Default terminal ID
      cashierId: transaction.cashierId,
      productItems: (transaction.items).map((item) => UnifiedPOSTransactionItem(
        productId: item['product_id'] ?? '',
        productName: item['product_name'] ?? '',
        quantity: item['quantity'] ?? 1,
        unitPrice: (item['unit_price'] ?? 0).toDouble(),
        totalPrice: (item['total_price'] ?? 0).toDouble(),
        discount: (item['discount'] ?? 0).toDouble(),
        metadata: {
          'category': item['category'] ?? '',
          'variant': item['variant'] ?? '',
          'originalItemId': item['product_id'] ?? '',
          'productCode': item['product_code'] ?? '',
          'taxAmount': item['tax_amount'] ?? 0.0,
          'mrp': item['mrp'] ?? 0.0,
          'batchNumber': item['batch_number'] ?? '',
          'taxSlab': item['tax_slab'] ?? '',
        },
      )).toList(),
      subTotal: transaction.subtotal,
      taxAmount: transaction.taxAmount,
      discountApplied: transaction.discountAmount,
      roundOffAmount: 0.0, // Default value
      totalAmount: transaction.totalAmount,
      paymentMode: transaction.paymentMethod,
      walletUsed: 0.0, // Default value
      changeReturned: 0.0, // Default value
      loyaltyPointsEarned: 0, // Default value
      loyaltyPointsUsed: 0, // Default value
      invoiceNumber: transaction.receiptNumber ?? '',
      invoiceType: 'regular', // Default value
      refundStatus: 'none', // Default value
      syncedToServer: true, // Default value
      syncedToInventory: false, // Default value
      syncedToFinance: false, // Default value
      isOfflineMode: false, // Default value
      pricingEngineSnapshot: {}, // Default value
      taxBreakup: {}, // Default value
      createdAt: transaction.createdAt.toDate(),
      updatedAt: transaction.updatedAt.toDate(),
      metadata: {
        'invoiceNumber': transaction.receiptNumber ?? '',
        'transactionStatus': transaction.transactionStatus,
        'customerInfo': transaction.customerInfo ?? {},
        'notes': transaction.notes ?? '',
      },
    );
  }
}
