import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/inventory_models.dart';
import '../models/inventory_service.dart';
import '../../../core/activity_tracker.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryRecord? record;
  const AddEditInventoryScreen({this.record, Key? key}) : super(key: key);

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = InventoryService();
  final _uuid = Uuid();

  // Controllers for all fields
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _storeLocationController = TextEditingController();
  final TextEditingController _quantityAvailableController = TextEditingController();
  final TextEditingController _quantityReservedController = TextEditingController();
  final TextEditingController _quantityOnOrderController = TextEditingController();
  final TextEditingController _quantityDamagedController = TextEditingController();
  final TextEditingController _quantityReturnedController = TextEditingController();
  final TextEditingController _reorderPointController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  DateTime? _expiryDate;
  DateTime? _manufactureDate;
  final TextEditingController _storageLocationController = TextEditingController();
  String _entryMode = 'Manual';
  String _stockStatus = 'In Stock';
  final TextEditingController _addedByController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  String _fifoLifoFlag = 'FIFO';
  bool _auditFlag = false;
  bool _autoRestockEnabled = false;
  DateTime? _lastSoldDate;
  final TextEditingController _safetyStockLevelController = TextEditingController();
  final TextEditingController _averageDailyUsageController = TextEditingController();
  final TextEditingController _stockTurnoverRatioController = TextEditingController();

  // Fetch all products from Firestore
  List<Map<String, dynamic>> _productList = [];
  List<Map<String, dynamic>> _storeList = [];
  List<Map<String, dynamic>> _supplierList = [];
  List<Map<String, dynamic>> _purchaseOrderList = [];
  
  // New controllers for supplier and purchase order
  final TextEditingController _supplierIdController = TextEditingController();
  final TextEditingController _purchaseOrderIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchStores();
    _fetchSuppliers();
    _fetchPurchaseOrders();
    if (widget.record != null) {
      final r = widget.record!;
      _productIdController.text = r.productId;
      _storeLocationController.text = r.storeLocation;
      // Initialize new supplier and purchase order fields if they exist
      _supplierIdController.text = r.supplierId ?? '';
      _purchaseOrderIdController.text = r.purchaseOrderId ?? '';
      _quantityAvailableController.text = r.quantityAvailable.toString();
      _quantityReservedController.text = r.quantityReserved.toString();
      _quantityOnOrderController.text = r.quantityOnOrder.toString();
      _quantityDamagedController.text = r.quantityDamaged.toString();
      _quantityReturnedController.text = r.quantityReturned.toString();
      _reorderPointController.text = r.reorderPoint.toString();
      _batchNumberController.text = r.batchNumber;
      _expiryDate = r.expiryDate;
      _manufactureDate = r.manufactureDate;
      _storageLocationController.text = r.storageLocation;
      _entryMode = r.entryMode;
      _stockStatus = r.stockStatus;
      _addedByController.text = r.addedBy;
      _remarksController.text = r.remarks;
      _fifoLifoFlag = r.fifoLifoFlag;
      _auditFlag = r.auditFlag;
      _autoRestockEnabled = r.autoRestockEnabled;
      _lastSoldDate = r.lastSoldDate;
      _safetyStockLevelController.text = r.safetyStockLevel.toString();
      _averageDailyUsageController.text = r.averageDailyUsage.toString();
      _stockTurnoverRatioController.text = r.stockTurnoverRatio.toString();
    }
  }

  Future<void> _fetchProducts() async {
    final snap = await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      _productList = snap.docs.map((d) => {'product_id': d.id, ...?d.data() as Map<String, dynamic>?}).toList();
    });
  }

  Future<void> _fetchStores() async {
    final snap = await FirebaseFirestore.instance.collection('stores').get();
    setState(() {
      _storeList = snap.docs.map((d) => {'store_id': d.id, ...?d.data() as Map<String, dynamic>?}).toList();
    });
  }

  Future<void> _fetchSuppliers() async {
    final snap = await FirebaseFirestore.instance.collection('suppliers').get();
    setState(() {
      _supplierList = snap.docs.map((d) => {'supplier_id': d.id, ...?d.data() as Map<String, dynamic>?}).toList();
    });
  }

  Future<void> _fetchPurchaseOrders() async {
    final snap = await FirebaseFirestore.instance.collection('purchase_orders').get();
    setState(() {
      _purchaseOrderList = snap.docs.map((d) => {'purchase_order_id': d.id, ...?d.data() as Map<String, dynamic>?}).toList();
    });
  }

  Future<void> _fetchPurchaseOrdersForSupplier(String? supplierId) async {
    if (supplierId == null || supplierId.isEmpty) {
      // If no supplier selected, show all purchase orders
      _fetchPurchaseOrders();
      return;
    }
    
    final snap = await FirebaseFirestore.instance
        .collection('purchase_orders')
        .where('supplier_id', isEqualTo: supplierId)
        .get();
    setState(() {
      _purchaseOrderList = snap.docs.map((d) => {'purchase_order_id': d.id, ...?d.data() as Map<String, dynamic>?}).toList();
      // Clear purchase order selection when supplier changes
      _purchaseOrderIdController.text = '';
    });
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _storeLocationController.dispose();
    _supplierIdController.dispose();
    _purchaseOrderIdController.dispose();
    _quantityAvailableController.dispose();
    _quantityReservedController.dispose();
    _quantityOnOrderController.dispose();
    _quantityDamagedController.dispose();
    _quantityReturnedController.dispose();
    _reorderPointController.dispose();
    _batchNumberController.dispose();
    _storageLocationController.dispose();
    _addedByController.dispose();
    _remarksController.dispose();
    _safetyStockLevelController.dispose();
    _averageDailyUsageController.dispose();
    _stockTurnoverRatioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    
    final isNewRecord = widget.record == null;
    final supplierId = _supplierIdController.text.isNotEmpty ? _supplierIdController.text : null;
    final purchaseOrderId = _purchaseOrderIdController.text.isNotEmpty ? _purchaseOrderIdController.text : null;
    
    final record = InventoryRecord(
      inventoryId: widget.record?.inventoryId ?? _uuid.v4(),
      productId: _productIdController.text,
      storeLocation: _storeLocationController.text,
      quantityAvailable: num.tryParse(_quantityAvailableController.text) ?? 0,
      quantityReserved: num.tryParse(_quantityReservedController.text) ?? 0,
      quantityOnOrder: num.tryParse(_quantityOnOrderController.text) ?? 0,
      quantityDamaged: num.tryParse(_quantityDamagedController.text) ?? 0,
      quantityReturned: num.tryParse(_quantityReturnedController.text) ?? 0,
      reorderPoint: num.tryParse(_reorderPointController.text) ?? 0,
      batchNumber: _batchNumberController.text,
      expiryDate: _expiryDate,
      manufactureDate: _manufactureDate,
      storageLocation: _storageLocationController.text,
      entryMode: _entryMode,
      lastUpdated: Timestamp.now(),
      stockStatus: _stockStatus,
      addedBy: _addedByController.text,
      remarks: _remarksController.text,
      fifoLifoFlag: _fifoLifoFlag,
      auditFlag: _auditFlag,
      autoRestockEnabled: _autoRestockEnabled,
      lastSoldDate: _lastSoldDate,
      safetyStockLevel: num.tryParse(_safetyStockLevelController.text) ?? 0,
      averageDailyUsage: num.tryParse(_averageDailyUsageController.text) ?? 0,
      stockTurnoverRatio: num.tryParse(_stockTurnoverRatioController.text) ?? 0,
      supplierId: supplierId,
      purchaseOrderId: purchaseOrderId,
    );
    
    try {
      if (isNewRecord) {
        await _service.addInventory(record);
      } else {
        await _service.updateInventory(record);
      }
      
      // Track inventory save activity with supplier/PO details
      ActivityTracker().trackInteraction(
        action: isNewRecord ? 'inventory_created' : 'inventory_updated',
        element: 'save_button',
        data: {
          'inventory_id': record.inventoryId,
          'product_id': record.productId,
          'supplier_id': supplierId,
          'purchase_order_id': purchaseOrderId,
          'has_supplier': supplierId != null,
          'has_purchase_order': purchaseOrderId != null,
          'stock_level': record.quantityAvailable,
          'store_location': record.storeLocation,
          'entry_mode': record.entryMode,
        },
      );
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Track save failure
      ActivityTracker().trackInteraction(
        action: 'inventory_save_failed',
        element: 'save_button',
        data: {
          'error': e.toString(),
          'is_new_record': isNewRecord,
          'has_supplier': supplierId != null,
          'has_purchase_order': purchaseOrderId != null,
        },
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.record == null ? 'Add Inventory' : 'Edit Inventory'),
          backgroundColor: Colors.deepPurple.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2),
                text: 'Basic Info',
              ),
              Tab(
                icon: Icon(Icons.date_range),
                text: 'Dates & Tracking',
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: 'Advanced',
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildBasicInfoTab(),
                          _buildDatesTrackingTab(),
                          _buildAdvancedTab(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Product & Location', Icons.inventory_2),
          const SizedBox(height: 16),
          _buildSectionHeader('Product & Location', Icons.inventory_2),
          const SizedBox(height: 16),
          // Product Dropdown
          DropdownButtonFormField<String>(
            value: _productIdController.text.isNotEmpty ? _productIdController.text : null,
            decoration: InputDecoration(
              labelText: 'Product *',
              hintText: 'Select a product',
              prefixIcon: const Icon(Icons.inventory),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select Product')),
              ..._productList.map((product) => DropdownMenuItem(
                    value: product['product_id'],
                    child: Text(
                      '${product['product_name'] ?? product['name'] ?? 'Unknown Product'} - SKU: ${product['sku'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _productIdController.text = value ?? '';
              });
            },
            validator: (v) => v == null || v.isEmpty ? 'Please select a product' : null,
          ),
          // Product Details Card
          Builder(
            builder: (context) {
              final selected = _productList.firstWhere(
                (p) => p['product_id'] == _productIdController.text,
                orElse: () => {},
              );
              if (selected.isEmpty) return const SizedBox.shrink();
              
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Name', selected['product_name'] ?? selected['name'] ?? 'N/A'),
                    _buildDetailRow('SKU', selected['sku'] ?? 'N/A'),
                    _buildDetailRow('Category', selected['category'] ?? 'N/A'),
                    _buildDetailRow('Brand', selected['brand'] ?? 'N/A'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Store Location
          DropdownButtonFormField<String>(
            value: _storeLocationController.text.isNotEmpty ? _storeLocationController.text : null,
            decoration: InputDecoration(
              labelText: 'Store Location *',
              hintText: 'Select a store location',
              prefixIcon: const Icon(Icons.store),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select Store Location')),
              ..._storeList.map((store) => DropdownMenuItem(
                    value: store['store_code'] ?? store['store_id'],
                    child: Text(
                      '${store['store_name'] ?? 'Unknown Store'} (${store['store_code'] ?? store['store_id']})',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _storeLocationController.text = value ?? '';
              });
            },
            validator: (v) => v == null || v.isEmpty ? 'Please select a store location' : null,
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Supplier & Purchase Order', Icons.business),
          const SizedBox(height: 16),
          // Supplier Dropdown
          DropdownButtonFormField<String>(
            value: _supplierIdController.text.isNotEmpty ? _supplierIdController.text : null,
            decoration: InputDecoration(
              labelText: 'Supplier',
              hintText: 'Select a supplier',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select Supplier')),
              ..._supplierList.map((supplier) => DropdownMenuItem(
                    value: supplier['supplier_id'],
                    child: Text(
                      '${supplier['supplier_name'] ?? supplier['name'] ?? 'Unknown Supplier'} (${supplier['supplier_code'] ?? supplier['supplier_id']})',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _supplierIdController.text = value ?? '';
                _fetchPurchaseOrdersForSupplier(value);
              });
              
              // Track supplier selection activity
              ActivityTracker().trackInteraction(
                action: 'supplier_selected',
                element: 'supplier_dropdown',
                data: {
                  'supplier_id': value,
                  'screen': 'add_edit_inventory',
                  'has_existing_record': widget.record != null,
                },
              );
            },
          ),
          const SizedBox(height: 16),
          // Purchase Order Dropdown
          DropdownButtonFormField<String>(
            value: _purchaseOrderIdController.text.isNotEmpty ? _purchaseOrderIdController.text : null,
            decoration: InputDecoration(
              labelText: 'Purchase Order',
              hintText: 'Select a purchase order',
              prefixIcon: const Icon(Icons.receipt_long),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select Purchase Order')),
              ..._purchaseOrderList.map((po) => DropdownMenuItem(
                    value: po['purchase_order_id'],
                    child: Text(
                      'PO-${po['po_number'] ?? po['purchase_order_id']} - ${po['supplier_name'] ?? 'Unknown Supplier'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _purchaseOrderIdController.text = value ?? '';
              });
              
              // Track purchase order selection activity
              ActivityTracker().trackInteraction(
                action: 'purchase_order_selected',
                element: 'purchase_order_dropdown',
                data: {
                  'purchase_order_id': value,
                  'supplier_id': _supplierIdController.text,
                  'screen': 'add_edit_inventory',
                  'has_existing_record': widget.record != null,
                },
              );
            },
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Stock Quantities', Icons.numbers),
          const SizedBox(height: 16),
          // Quantity Fields in Grid
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _quantityAvailableController,
                  label: 'Available *',
                  icon: Icons.inventory,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _quantityReservedController,
                  label: 'Reserved',
                  icon: Icons.lock,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _quantityOnOrderController,
                  label: 'On Order',
                  icon: Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _reorderPointController,
                  label: 'Reorder Point',
                  icon: Icons.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _quantityDamagedController,
                  label: 'Damaged',
                  icon: Icons.broken_image,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _quantityReturnedController,
                  label: 'Returned',
                  icon: Icons.keyboard_return,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Storage & Status', Icons.location_on),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _storageLocationController,
            label: 'Storage Location',
            icon: Icons.location_on,
            hint: 'e.g., Aisle 5, Shelf B',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _stockStatus,
                  decoration: InputDecoration(
                    labelText: 'Stock Status',
                    prefixIcon: const Icon(Icons.info),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Out', child: Text('Out')),
                    DropdownMenuItem(value: 'Reserved', child: Text('Reserved')),
                  ],
                  onChanged: (v) => setState(() => _stockStatus = v ?? 'In Stock'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _entryMode,
                  decoration: InputDecoration(
                    labelText: 'Entry Mode',
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                    DropdownMenuItem(value: 'Purchase', child: Text('Purchase')),
                    DropdownMenuItem(value: 'Return', child: Text('Return')),
                    DropdownMenuItem(value: 'Adjustment', child: Text('Adjustment')),
                  ],
                  onChanged: (v) => setState(() => _entryMode = v ?? 'Manual'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatesTrackingTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Product Dates', Icons.calendar_today),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Manufacture Date',
                  icon: Icons.build,
                  selectedDate: _manufactureDate,
                  onDateSelected: (date) => setState(() => _manufactureDate = date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Expiry Date',
                  icon: Icons.event_busy,
                  selectedDate: _expiryDate,
                  onDateSelected: (date) => setState(() => _expiryDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Last Sold Date',
            icon: Icons.sell,
            selectedDate: _lastSoldDate,
            onDateSelected: (date) => setState(() => _lastSoldDate = date),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Batch Information', Icons.qr_code),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _batchNumberController,
            label: 'Batch Number',
            icon: Icons.qr_code,
            hint: 'Enter batch/lot number',
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Tracking & Analytics', Icons.analytics),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _safetyStockLevelController,
                  label: 'Safety Stock Level',
                  icon: Icons.security,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _averageDailyUsageController,
                  label: 'Avg Daily Usage',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            controller: _stockTurnoverRatioController,
            label: 'Stock Turnover Ratio',
            icon: Icons.rotate_right,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addedByController,
            label: 'Added By',
            icon: Icons.person,
            hint: 'User who added this record',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _remarksController,
            label: 'Remarks',
            icon: Icons.note,
            hint: 'Additional notes or comments',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Inventory Management', Icons.settings),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _fifoLifoFlag,
            decoration: InputDecoration(
              labelText: 'Inventory Method',
              prefixIcon: const Icon(Icons.sort),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
              helperText: 'First In First Out or Last In First Out',
            ),
            items: const [
              DropdownMenuItem(value: 'FIFO', child: Text('FIFO (First In, First Out)')),
              DropdownMenuItem(value: 'LIFO', child: Text('LIFO (Last In, First Out)')),
              DropdownMenuItem(value: 'Manual', child: Text('Manual Selection')),
            ],
            onChanged: (v) => setState(() => _fifoLifoFlag = v ?? 'FIFO'),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Automation Settings', Icons.auto_awesome),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _autoRestockEnabled,
                    title: const Text('Auto Restock Enabled'),
                    subtitle: const Text('Automatically reorder when stock is low'),
                    secondary: const Icon(Icons.autorenew),
                    onChanged: (v) => setState(() => _autoRestockEnabled = v),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  const Divider(),
                  SwitchListTile(
                    value: _auditFlag,
                    title: const Text('Audit Flag'),
                    subtitle: const Text('Mark this item for audit tracking'),
                    secondary: const Icon(Icons.flag),
                    onChanged: (v) => setState(() => _auditFlag = v),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Help & Information', Icons.help_outline),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for better inventory management:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('Set reorder points to avoid stockouts'),
                  _buildTipItem('Use batch numbers for better tracking'),
                  _buildTipItem('Enable auto-restock for fast-moving items'),
                  _buildTipItem('Regular audits help maintain accuracy'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepPurple.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'This field is required' : null : null,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'This field is required' : null : null,
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null 
                        ? DateFormat('MMM dd, yyyy').format(selectedDate)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(widget.record == null ? 'Add Inventory' : 'Update Inventory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
