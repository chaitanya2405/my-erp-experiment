import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';
import '../widgets/po_document_upload.dart';
import 'purchase_order_detail_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PurchaseOrderFormScreen extends StatefulWidget {
  final String? poId;
  final bool viewOnly;
  const PurchaseOrderFormScreen({Key? key, this.poId, this.viewOnly = false}) : super(key: key);

  @override
  State<PurchaseOrderFormScreen> createState() => _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState extends State<PurchaseOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _poNumberController = TextEditingController();
  String? _selectedSupplierId;
  final _storeIdController = TextEditingController();
  DateTime? _orderDate;
  DateTime? _expectedDelivery;
  String _status = 'Draft';
  final _totalItemsController = TextEditingController();
  final _totalValueController = TextEditingController();
  final _createdByController = TextEditingController();
  final _approvedByController = TextEditingController();
  final _remarksController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _deliveryTermsController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  DateTime? _receivedDate;
  String _deliveryStatus = 'Pending';

  // New: Billing/Shipping address controllers
  final _billingAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();

  List<POItem> _lineItems = [];
  bool _isSaving = false;
  String? _createdPoId;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _fetchSuppliers().then((s) => setState(() => _suppliers = s));
    _fetchProducts().then((p) => setState(() => _products = p));
    if (widget.poId != null) {
      _loadPurchaseOrder(widget.poId!);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'sku': data['sku'] ?? doc.id,
        'name': data['name'] ?? doc.id,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchSuppliers() async {
    final snapshot = await FirebaseFirestore.instance.collection('suppliers').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? doc.id,
      };
    }).toList();
  }

  Future<void> _loadPurchaseOrder(String poId) async {
    final doc = await FirebaseFirestore.instance.collection('purchase_orders').doc(poId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _poNumberController.text = data['poNumber'] ?? '';
        // Only set supplier if it exists in the list, else null
        _selectedSupplierId = _suppliers.any((s) => s['id'] == data['supplierId'])
          ? data['supplierId']
          : null;
        _storeIdController.text = data['storeId'] ?? '';
        _orderDate = (data['orderDate'] as Timestamp?)?.toDate();
        _expectedDelivery = (data['expectedDelivery'] as Timestamp?)?.toDate();
        _status = data['status'] ?? 'Draft';
        _totalItemsController.text = (data['totalItems'] ?? '').toString();
        _totalValueController.text = (data['totalValue'] ?? '').toString();
        _createdByController.text = data['createdBy'] ?? '';
        _approvedByController.text = data['approvedBy'] ?? '';
        _remarksController.text = data['remarks'] ?? '';
        _paymentTermsController.text = data['paymentTerms'] ?? '';
        _deliveryTermsController.text = data['deliveryTerms'] ?? '';
        _invoiceNumberController.text = data['invoiceNumber'] ?? '';
        _receivedDate = (data['receivedDate'] as Timestamp?)?.toDate();
        _deliveryStatus = data['deliveryStatus'] ?? 'Pending';
        _billingAddressController.text = data['billingAddress'] ?? '';
        _shippingAddressController.text = data['shippingAddress'] ?? '';
        _lineItems = (data['lineItems'] as List<dynamic>? ?? [])
            .map((item) => POItem.fromMap(item as Map<String, dynamic>))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _storeIdController.dispose();
    _totalItemsController.dispose();
    _totalValueController.dispose();
    _createdByController.dispose();
    _approvedByController.dispose();
    _remarksController.dispose();
    _paymentTermsController.dispose();
    _deliveryTermsController.dispose();
    _invoiceNumberController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, ValueChanged<DateTime> onSelected) async {
    if (widget.viewOnly) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _savePO() async {
    if (!_formKey.currentState!.validate()) return;
    // Validate supplier
    if (!_suppliers.any((s) => s['id'] == _selectedSupplierId)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid supplier selected!')));
      return;
    }
    // Validate products in line items
    for (final item in _lineItems) {
      if (!_products.any((p) => p['sku'] == item.sku)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid product SKU: ${item.sku}')));
        return;
      }
    }
    setState(() => _isSaving = true);

    // Approval history logic
    List<Map<String, dynamic>> approvalHistory = [];
    if (widget.poId != null) {
      final doc = await FirebaseFirestore.instance.collection('purchase_orders').doc(widget.poId).get();
      if (doc.exists) {
        approvalHistory = List<Map<String, dynamic>>.from(doc['approvalHistory'] ?? []);
        // If status changed, log it
        if (doc['status'] != _status) {
          approvalHistory.add({
            'status': _status,
            'user': _approvedByController.text.isNotEmpty ? _approvedByController.text : _createdByController.text,
            'timestamp': DateTime.now(),
          });
        }
      }
    } else {
      approvalHistory.add({
        'status': _status,
        'user': _createdByController.text,
        'timestamp': DateTime.now(),
      });
    }

    final po = PurchaseOrder(
      poId: widget.poId ?? '',
      poNumber: _poNumberController.text,
      supplierId: _selectedSupplierId ?? '',
      storeId: _storeIdController.text,
      orderDate: _orderDate ?? DateTime.now(),
      expectedDelivery: _expectedDelivery ?? DateTime.now(),
      status: _status,
      totalItems: int.tryParse(_totalItemsController.text) ?? 0,
      totalValue: double.tryParse(_totalValueController.text) ?? 0.0,
      createdBy: _createdByController.text,
      approvedBy: _approvedByController.text.isEmpty ? null : _approvedByController.text,
      remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      lineItems: _lineItems,
      paymentTerms: _paymentTermsController.text.isEmpty ? null : _paymentTermsController.text,
      deliveryTerms: _deliveryTermsController.text.isEmpty ? null : _deliveryTermsController.text,
      invoiceNumber: _invoiceNumberController.text.isEmpty ? null : _invoiceNumberController.text,
      receivedDate: _receivedDate,
      deliveryStatus: _deliveryStatus,
      documentsAttached: [],
      approvalHistory: approvalHistory,
      // New fields
      billingAddress: _billingAddressController.text,
      shippingAddress: _shippingAddressController.text,
    );

    if (widget.poId != null) {
      await FirebaseFirestore.instance
          .collection('purchase_orders')
          .doc(widget.poId)
          .set(po.toMap());
      // Inventory update if delivered
      if (_status == 'Delivered') await _updateInventoryOnDelivery();
      setState(() {
        _createdPoId = widget.poId;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Order Updated!')));
    } else {
      final docRef = await FirebaseFirestore.instance.collection('purchase_orders').add(po.toMap());
      if (_status == 'Delivered') await _updateInventoryOnDelivery();
      setState(() {
        _createdPoId = docRef.id;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Order Created!')));
    }
  }

  Future<void> _updateInventoryOnDelivery() async {
    for (final item in _lineItems) {
      final productDoc = FirebaseFirestore.instance.collection('products').where('sku', isEqualTo: item.sku);
      final snapshot = await productDoc.get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        final currentQty = (data['inventory'] ?? 0) as int;
        await doc.reference.update({'inventory': currentQty + (item.quantity ?? 0)});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.viewOnly;
    return Scaffold(
      appBar: AppBar(title: Text(isView ? 'View Purchase Order' : widget.poId != null ? 'Edit Purchase Order' : 'Create Purchase Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // PO Number
              TextFormField(
                controller: _poNumberController,
                decoration: const InputDecoration(labelText: 'PO Number'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                enabled: !isView,
              ),
              // Supplier Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSupplierId,
                items: _suppliers
                    .map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(
                          value: s['id'] as String,
                          child: Text(s['name'] as String),
                        ))
                    .toList(),
                onChanged: isView ? null : (v) => setState(() => _selectedSupplierId = v),
                decoration: const InputDecoration(labelText: 'Supplier'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              // Store ID
              TextFormField(
                controller: _storeIdController,
                decoration: const InputDecoration(labelText: 'Store ID'),
                enabled: !isView,
              ),
              // Order Date
              Row(
                children: [
                  Expanded(
                    child: Text(_orderDate == null
                        ? 'Order Date: Not set'
                        : 'Order Date: ${_orderDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: isView ? null : () => _selectDate(context, _orderDate, (d) => setState(() => _orderDate = d)),
                    child: const Text('Select'),
                  ),
                ],
              ),
              // Expected Delivery
              Row(
                children: [
                  Expanded(
                    child: Text(_expectedDelivery == null
                        ? 'Expected Delivery: Not set'
                        : 'Expected Delivery: ${_expectedDelivery!.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: isView ? null : () => _selectDate(context, _expectedDelivery, (d) => setState(() => _expectedDelivery = d)),
                    child: const Text('Select'),
                  ),
                ],
              ),
              // Status
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: isView ? null : (v) => setState(() => _status = v ?? 'Draft'),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              // Total Items
              TextFormField(
                controller: _totalItemsController,
                decoration: const InputDecoration(labelText: 'Total Items'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                enabled: !isView,
              ),
              // Total Value
              TextFormField(
                controller: _totalValueController,
                decoration: const InputDecoration(labelText: 'Total Value'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                enabled: !isView,
              ),
              // Created By
              TextFormField(
                controller: _createdByController,
                decoration: const InputDecoration(labelText: 'Created By'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                enabled: !isView,
              ),
              // Approved By (optional)
              TextFormField(
                controller: _approvedByController,
                decoration: const InputDecoration(labelText: 'Approved By (optional)'),
                enabled: !isView,
              ),
              // Remarks (optional)
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(labelText: 'Remarks (optional)'),
                enabled: !isView,
              ),
              // Payment Terms (optional)
              TextFormField(
                controller: _paymentTermsController,
                decoration: const InputDecoration(labelText: 'Payment Terms (optional)'),
                enabled: !isView,
              ),
              // Delivery Terms (optional)
              TextFormField(
                controller: _deliveryTermsController,
                decoration: const InputDecoration(labelText: 'Delivery Terms (optional)'),
                enabled: !isView,
              ),
              // Invoice Number (optional)
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(labelText: 'Invoice Number (optional)'),
                enabled: !isView,
              ),
              // Billing/Shipping Address fields
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _billingAddressController,
                      decoration: const InputDecoration(labelText: 'Billing Address'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      enabled: !isView,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _shippingAddressController,
                      decoration: const InputDecoration(labelText: 'Shipping Address'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      enabled: !isView,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              // Received Date (optional)
              Row(
                children: [
                  Expanded(
                    child: Text(_receivedDate == null
                        ? 'Received Date: Not set'
                        : 'Received Date: ${_receivedDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: isView ? null : () => _selectDate(context, _receivedDate, (d) => setState(() => _receivedDate = d)),
                    child: const Text('Select'),
                  ),
                ],
              ),
              // Delivery Status
              DropdownButtonFormField<String>(
                value: _deliveryStatus,
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                  DropdownMenuItem(value: 'Partially Delivered', child: Text('Partially Delivered')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: isView ? null : (v) => setState(() => _deliveryStatus = v ?? 'Pending'),
                decoration: const InputDecoration(labelText: 'Delivery Status'),
              ),
              const SizedBox(height: 24),
              // Line Items (simple add, can be expanded)
              Row(
                children: [
                  const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (!isView)
                    ElevatedButton(
                      onPressed: () async {
                        final item = await showDialog<POItem>(
                          context: context,
                          builder: (context) => _AddLineItemDialog(products: _products),
                        );
                        if (item != null) {
                          setState(() => _lineItems.add(item));
                        }
                      },
                      child: const Text('Add Item'),
                    ),
                ],
              ),
              ..._lineItems.map((item) => ListTile(
                title: Text('SKU: ${item.sku}'),
                subtitle: Text('Qty: ${item.quantity}, Price: ${item.price}, Discount: ${item.discount}, Tax: ${item.tax}'),
                trailing: !isView
                    ? IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => _lineItems.remove(item)),
                      )
                    : null,
              )),
              const SizedBox(height: 32),
              if (!isView)
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _savePO,
                        icon: const Icon(Icons.save),
                        label: Text(widget.poId != null ? 'Update Purchase Order' : 'Save Purchase Order'),
                      ),
              // Show document upload and "View This PO" after PO is created
              if (_createdPoId != null) ...[
                const SizedBox(height: 32),
                Text('Attach Documents', style: Theme.of(context).textTheme.titleLarge),
                PoDocumentUpload(poId: _createdPoId!),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('View This PO'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseOrderDetailScreen(poId: _createdPoId!),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // QR Code
                QrImageView(
                  data: _createdPoId!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog for adding a line item
class _AddLineItemDialog extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  const _AddLineItemDialog({this.products = const []});
  @override
  State<_AddLineItemDialog> createState() => _AddLineItemDialogState();
}

class _AddLineItemDialogState extends State<_AddLineItemDialog> {
  String? _selectedSku;
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Line Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedSku,
            items: widget.products.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(
              value: p['sku'] as String,
              child: Text('${p['sku']} - ${p['name']}'),
            )).toList(),
            onChanged: (v) => setState(() => _selectedSku = v),
            decoration: const InputDecoration(labelText: 'Product'),
          ),
          TextField(
            controller: _qtyController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _discountController,
            decoration: const InputDecoration(labelText: 'Discount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _taxController,
            decoration: const InputDecoration(labelText: 'Tax'),
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
          onPressed: () {
            if (_selectedSku == null) return;
            final item = POItem(
              sku: _selectedSku!,
              quantity: int.tryParse(_qtyController.text) ?? 0,
              price: double.tryParse(_priceController.text) ?? 0.0,
              discount: double.tryParse(_discountController.text) ?? 0.0,
              tax: double.tryParse(_taxController.text) ?? 0.0,
            );
            Navigator.pop(context, item);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
