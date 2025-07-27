import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/supplier.dart';
import '../models/supplier_service.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final Supplier? supplier;
  const AddEditSupplierScreen({this.supplier, Key? key}) : super(key: key);

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SupplierService();
  final _uuid = Uuid();

  // Controllers for all text fields
  final TextEditingController _supplierCodeController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonMobileController = TextEditingController();
  final TextEditingController _alternateContactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  String _supplierType = 'Manufacturer';
  final TextEditingController _businessRegistrationNoController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _bankAccountNumberController = TextEditingController();
  final TextEditingController _bankIfscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  String _preferredPaymentMode = 'UPI';
  final TextEditingController _creditLimitController = TextEditingController();
  String _defaultCurrency = 'INR';
  final TextEditingController _productsSuppliedController = TextEditingController();
  DateTime? _contractStartDate;
  DateTime? _contractEndDate;
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _onTimeDeliveryRateController = TextEditingController();
  final TextEditingController _averageLeadTimeDaysController = TextEditingController();
  DateTime? _lastSuppliedDate;
  final TextEditingController _totalOrdersSuppliedController = TextEditingController();
  final TextEditingController _totalOrderValueController = TextEditingController();
  final TextEditingController _complianceDocumentsController = TextEditingController();
  bool _isPreferredSupplier = false;
  final TextEditingController _notesController = TextEditingController();
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      final s = widget.supplier!;
      _supplierCodeController.text = s.supplierCode;
      _supplierNameController.text = s.supplierName;
      _contactPersonNameController.text = s.contactPersonName;
      _contactPersonMobileController.text = s.contactPersonMobile;
      _alternateContactNumberController.text = s.alternateContactNumber ?? '';
      _emailController.text = s.email;
      _addressLine1Controller.text = s.addressLine1;
      _addressLine2Controller.text = s.addressLine2 ?? '';
      _cityController.text = s.city;
      _stateController.text = s.state;
      _postalCodeController.text = s.postalCode;
      _countryController.text = s.country;
      _gstinController.text = s.gstin;
      _panNumberController.text = s.panNumber;
      _supplierType = s.supplierType;
      _businessRegistrationNoController.text = s.businessRegistrationNo ?? '';
      _websiteController.text = s.website ?? '';
      _bankAccountNumberController.text = s.bankAccountNumber;
      _bankIfscCodeController.text = s.bankIfscCode;
      _bankNameController.text = s.bankName;
      _upiIdController.text = s.upiId ?? '';
      _paymentTermsController.text = s.paymentTerms;
      _preferredPaymentMode = s.preferredPaymentMode;
      _creditLimitController.text = s.creditLimit.toString();
      _defaultCurrency = s.defaultCurrency;
      _productsSuppliedController.text = s.productsSupplied.join(', ');
      _contractStartDate = s.contractStartDate;
      _contractEndDate = s.contractEndDate;
      _ratingController.text = s.rating.toString();
      _onTimeDeliveryRateController.text = s.onTimeDeliveryRate.toString();
      _averageLeadTimeDaysController.text = s.averageLeadTimeDays.toString();
      _lastSuppliedDate = s.lastSuppliedDate;
      _totalOrdersSuppliedController.text = s.totalOrdersSupplied.toString();
      _totalOrderValueController.text = s.totalOrderValue.toString();
      _complianceDocumentsController.text = s.complianceDocuments.join(', ');
      _isPreferredSupplier = s.isPreferredSupplier;
      _notesController.text = s.notes ?? '';
      _status = s.status;
    }
  }

  @override
  void dispose() {
    _supplierCodeController.dispose();
    _supplierNameController.dispose();
    _contactPersonNameController.dispose();
    _contactPersonMobileController.dispose();
    _alternateContactNumberController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _gstinController.dispose();
    _panNumberController.dispose();
    _businessRegistrationNoController.dispose();
    _websiteController.dispose();
    _bankAccountNumberController.dispose();
    _bankIfscCodeController.dispose();
    _bankNameController.dispose();
    _upiIdController.dispose();
    _paymentTermsController.dispose();
    _creditLimitController.dispose();
    _productsSuppliedController.dispose();
    _ratingController.dispose();
    _onTimeDeliveryRateController.dispose();
    _averageLeadTimeDaysController.dispose();
    _totalOrdersSuppliedController.dispose();
    _totalOrderValueController.dispose();
    _complianceDocumentsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final supplier = Supplier(
      supplierId: widget.supplier?.supplierId ?? _uuid.v4(),
      supplierCode: _supplierCodeController.text,
      supplierName: _supplierNameController.text,
      contactPersonName: _contactPersonNameController.text,
      contactPersonMobile: _contactPersonMobileController.text,
      alternateContactNumber: _alternateContactNumberController.text.isNotEmpty ? _alternateContactNumberController.text : null,
      email: _emailController.text,
      addressLine1: _addressLine1Controller.text,
      addressLine2: _addressLine2Controller.text.isNotEmpty ? _addressLine2Controller.text : null,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: _postalCodeController.text,
      country: _countryController.text,
      gstin: _gstinController.text,
      panNumber: _panNumberController.text,
      supplierType: _supplierType,
      businessRegistrationNo: _businessRegistrationNoController.text.isNotEmpty ? _businessRegistrationNoController.text : null,
      website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
      bankAccountNumber: _bankAccountNumberController.text,
      bankIfscCode: _bankIfscCodeController.text,
      bankName: _bankNameController.text,
      upiId: _upiIdController.text.isNotEmpty ? _upiIdController.text : null,
      paymentTerms: _paymentTermsController.text,
      preferredPaymentMode: _preferredPaymentMode,
      creditLimit: num.tryParse(_creditLimitController.text) ?? 0,
      defaultCurrency: _defaultCurrency,
      productsSupplied: _productsSuppliedController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      contractStartDate: _contractStartDate,
      contractEndDate: _contractEndDate,
      rating: num.tryParse(_ratingController.text) ?? 0,
      onTimeDeliveryRate: num.tryParse(_onTimeDeliveryRateController.text) ?? 0,
      averageLeadTimeDays: num.tryParse(_averageLeadTimeDaysController.text) ?? 0,
      lastSuppliedDate: _lastSuppliedDate,
      totalOrdersSupplied: int.tryParse(_totalOrdersSuppliedController.text) ?? 0,
      totalOrderValue: num.tryParse(_totalOrderValueController.text) ?? 0,
      complianceDocuments: _complianceDocumentsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      isPreferredSupplier: _isPreferredSupplier,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
      createdAt: widget.supplier?.createdAt ?? Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    if (widget.supplier == null) {
      await _service.addSupplier(supplier);
    } else {
      await _service.updateSupplier(supplier);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null ? 'Add Supplier' : 'Edit Supplier'),
        backgroundColor: Colors.deepPurple.shade700,
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
              child: ListView(
                children: [
                  TextFormField(
                    controller: _supplierCodeController,
                    decoration: const InputDecoration(labelText: 'Supplier Code'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _supplierNameController,
                    decoration: const InputDecoration(labelText: 'Supplier Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _contactPersonNameController,
                    decoration: const InputDecoration(labelText: 'Contact Person Name'),
                  ),
                  TextFormField(
                    controller: _contactPersonMobileController,
                    decoration: const InputDecoration(labelText: 'Contact Person Mobile'),
                  ),
                  TextFormField(
                    controller: _alternateContactNumberController,
                    decoration: const InputDecoration(labelText: 'Alternate Contact Number'),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextFormField(
                    controller: _addressLine1Controller,
                    decoration: const InputDecoration(labelText: 'Address Line 1'),
                  ),
                  TextFormField(
                    controller: _addressLine2Controller,
                    decoration: const InputDecoration(labelText: 'Address Line 2'),
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                  TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(labelText: 'Postal Code'),
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  TextFormField(
                    controller: _gstinController,
                    decoration: const InputDecoration(labelText: 'GSTIN'),
                  ),
                  TextFormField(
                    controller: _panNumberController,
                    decoration: const InputDecoration(labelText: 'PAN Number'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _supplierType,
                    decoration: const InputDecoration(labelText: 'Supplier Type'),
                    items: const [
                      DropdownMenuItem(value: 'Manufacturer', child: Text('Manufacturer')),
                      DropdownMenuItem(value: 'Wholesaler', child: Text('Wholesaler')),
                      DropdownMenuItem(value: 'Distributor', child: Text('Distributor')),
                      DropdownMenuItem(value: 'Local Vendor', child: Text('Local Vendor')),
                    ],
                    onChanged: (v) => setState(() => _supplierType = v ?? 'Manufacturer'),
                  ),
                  TextFormField(
                    controller: _businessRegistrationNoController,
                    decoration: const InputDecoration(labelText: 'Business Registration No'),
                  ),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(labelText: 'Website'),
                  ),
                  TextFormField(
                    controller: _bankAccountNumberController,
                    decoration: const InputDecoration(labelText: 'Bank Account Number'),
                  ),
                  TextFormField(
                    controller: _bankIfscCodeController,
                    decoration: const InputDecoration(labelText: 'Bank IFSC Code'),
                  ),
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  TextFormField(
                    controller: _upiIdController,
                    decoration: const InputDecoration(labelText: 'UPI ID'),
                  ),
                  TextFormField(
                    controller: _paymentTermsController,
                    decoration: const InputDecoration(labelText: 'Payment Terms'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _preferredPaymentMode,
                    decoration: const InputDecoration(labelText: 'Preferred Payment Mode'),
                    items: const [
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    ],
                    onChanged: (v) => setState(() => _preferredPaymentMode = v ?? 'UPI'),
                  ),
                  TextFormField(
                    controller: _creditLimitController,
                    decoration: const InputDecoration(labelText: 'Credit Limit'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: _defaultCurrency,
                    decoration: const InputDecoration(labelText: 'Default Currency'),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: (v) => setState(() => _defaultCurrency = v ?? 'INR'),
                  ),
                  TextFormField(
                    controller: _productsSuppliedController,
                    decoration: const InputDecoration(labelText: 'Products Supplied (comma separated IDs)'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InputDatePickerFormField(
                          initialDate: _contractStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          fieldLabelText: 'Contract Start Date',
                          onDateSubmitted: (date) => setState(() => _contractStartDate = date),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InputDatePickerFormField(
                          initialDate: _contractEndDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          fieldLabelText: 'Contract End Date',
                          onDateSubmitted: (date) => setState(() => _contractEndDate = date),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _onTimeDeliveryRateController,
                    decoration: const InputDecoration(labelText: 'On Time Delivery Rate (%)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _averageLeadTimeDaysController,
                    decoration: const InputDecoration(labelText: 'Average Lead Time (days)'),
                    keyboardType: TextInputType.number,
                  ),
                  InputDatePickerFormField(
                    initialDate: _lastSuppliedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    fieldLabelText: 'Last Supplied Date',
                    onDateSubmitted: (date) => setState(() => _lastSuppliedDate = date),
                  ),
                  TextFormField(
                    controller: _totalOrdersSuppliedController,
                    decoration: const InputDecoration(labelText: 'Total Orders Supplied'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _totalOrderValueController,
                    decoration: const InputDecoration(labelText: 'Total Order Value'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _complianceDocumentsController,
                    decoration: const InputDecoration(labelText: 'Compliance Documents (comma separated URLs)'),
                  ),
                  SwitchListTile(
                    value: _isPreferredSupplier,
                    title: const Text('Preferred Supplier'),
                    onChanged: (v) => setState(() => _isPreferredSupplier = v),
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'Blacklisted', child: Text('Blacklisted')),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'Active'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
