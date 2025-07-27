import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_models.dart';
import '../services/store_service.dart';

/// 🏪 Add/Edit Store Screen
/// Form for creating new stores or editing existing store information
class AddEditStoreScreen extends StatefulWidget {
  final Store? store;
  final bool isEditing;

  const AddEditStoreScreen({
    Key? key,
    this.store,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddEditStoreScreen> createState() => _AddEditStoreScreenState();
}

class _AddEditStoreScreenState extends State<AddEditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form Controllers
  final _storeCodeController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  final _storeAreaController = TextEditingController();
  final _gstController = TextEditingController();
  final _fssaiController = TextEditingController();
  final _parentCompanyController = TextEditingController();

  // Dropdown Values
  String _selectedStoreType = 'Retail';
  String _selectedStatus = 'Active';
  String _selectedCountry = 'India';

  // Form State
  bool _isLoading = false;
  bool _showAdvancedFields = false;

  // Dropdown Options
  final List<String> _storeTypes = ['Retail', 'Warehouse', 'Distribution Center'];
  final List<String> _statusOptions = ['Active', 'Inactive', 'Under Renovation'];
  final List<String> _countries = ['India', 'USA', 'UK', 'Canada', 'Australia'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.isEditing && widget.store != null) {
      final store = widget.store!;
      _storeCodeController.text = store.storeCode;
      _storeNameController.text = store.storeName;
      _contactPersonController.text = store.contactPerson;
      _contactNumberController.text = store.contactNumber;
      _emailController.text = store.email;
      _addressLine1Controller.text = store.addressLine1;
      _addressLine2Controller.text = store.addressLine2 ?? '';
      _cityController.text = store.city;
      _stateController.text = store.state;
      _postalCodeController.text = store.postalCode;
      _countryController.text = store.country;
      _latitudeController.text = store.latitude?.toString() ?? '';
      _longitudeController.text = store.longitude?.toString() ?? '';
      _operatingHoursController.text = store.operatingHours;
      _storeAreaController.text = store.storeAreaSqft?.toString() ?? '';
      _gstController.text = store.gstRegistrationNumber ?? '';
      _fssaiController.text = store.fssaiLicense ?? '';
      _parentCompanyController.text = store.parentCompany ?? '';
      
      _selectedStoreType = store.storeType;
      _selectedStatus = store.storeStatus;
      _selectedCountry = store.country;
    } else {
      // Set default values for new store
      _operatingHoursController.text = '9:00 AM - 9:00 PM';
      _countryController.text = 'India';
    }
  }

  @override
  void dispose() {
    _storeCodeController.dispose();
    _storeNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _operatingHoursController.dispose();
    _storeAreaController.dispose();
    _gstController.dispose();
    _fssaiController.dispose();
    _parentCompanyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.isEditing ? Icons.edit_location : Icons.add_business,
                  size: 28,
                  color: Colors.indigo[700],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEditing ? 'Edit Store' : 'Add New Store',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      widget.isEditing
                          ? 'Update store information and settings'
                          : 'Create a new store location for your business',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Advanced Fields Toggle
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAdvancedFields = !_showAdvancedFields;
                    });
                  },
                  icon: Icon(_showAdvancedFields ? Icons.expand_less : Icons.expand_more),
                  label: Text(_showAdvancedFields ? 'Hide Advanced' : 'Show Advanced'),
                ),
                
                const SizedBox(width: 12),
                
                // Save Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveStore,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(widget.isEditing ? 'Update Store' : 'Create Store'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionCard(
                      title: '📋 Basic Information',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _storeCodeController,
                                label: 'Store Code',
                                hint: 'e.g., HYD001',
                                required: true,
                                validator: _validateStoreCode,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _storeNameController,
                                label: 'Store Name',
                                hint: 'e.g., Hyderabad Main Branch',
                                required: true,
                              ),
                            ),
                          ],
                        ),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                value: _selectedStoreType,
                                label: 'Store Type',
                                items: _storeTypes,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStoreType = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                value: _selectedStatus,
                                label: 'Status',
                                items: _statusOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Contact Information Section
                    _buildSectionCard(
                      title: '📞 Contact Information',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _contactPersonController,
                                label: 'Contact Person',
                                hint: 'Store Manager Name',
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _contactNumberController,
                                label: 'Contact Number',
                                hint: '+91 9876543210',
                                required: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'store@company.com',
                          required: true,
                          validator: _validateEmail,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Address Information Section
                    _buildSectionCard(
                      title: '📍 Address Information',
                      children: [
                        _buildTextField(
                          controller: _addressLine1Controller,
                          label: 'Address Line 1',
                          hint: 'Street Address',
                          required: true,
                        ),
                        
                        _buildTextField(
                          controller: _addressLine2Controller,
                          label: 'Address Line 2',
                          hint: 'Apartment, suite, etc. (optional)',
                        ),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'e.g., Hyderabad',
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'e.g., Telangana',
                                required: true,
                              ),
                            ),
                          ],
                        ),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _postalCodeController,
                                label: 'Postal Code',
                                hint: '500001',
                                required: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                value: _selectedCountry,
                                label: 'Country',
                                items: _countries,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value!;
                                    _countryController.text = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Advanced Fields (Conditionally Shown)
                    if (_showAdvancedFields) ...[
                      const SizedBox(height: 24),
                      
                      // Location & Operations Section
                      _buildSectionCard(
                        title: '🗺️ Location & Operations',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _latitudeController,
                                  label: 'Latitude',
                                  hint: '17.3850',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                                  ],
                                  validator: _validateLatitude,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _longitudeController,
                                  label: 'Longitude',
                                  hint: '78.4867',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                                  ],
                                  validator: _validateLongitude,
                                ),
                              ),
                            ],
                          ),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _operatingHoursController,
                                  label: 'Operating Hours',
                                  hint: '9:00 AM - 9:00 PM',
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _storeAreaController,
                                  label: 'Store Area (sq ft)',
                                  hint: '2500',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Compliance Information Section
                      _buildSectionCard(
                        title: '📄 Compliance Information',
                        children: [
                          _buildTextField(
                            controller: _gstController,
                            label: 'GST Registration Number',
                            hint: '29ABCDE1234F1Z5',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                              LengthLimitingTextInputFormatter(15),
                            ],
                          ),
                          
                          _buildTextField(
                            controller: _fssaiController,
                            label: 'FSSAI License',
                            hint: '12345678901234',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              LengthLimitingTextInputFormatter(14),
                            ],
                          ),
                          
                          _buildTextField(
                            controller: _parentCompanyController,
                            label: 'Parent Company',
                            hint: 'If managed under franchise',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: child,
              )),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo[700]!),
        ),
      ),
      validator: validator ??
          (required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null),
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo[700]!),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  String? _validateStoreCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Store code is required';
    }
    if (value.length < 3) {
      return 'Store code must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final lng = double.tryParse(value);
    if (lng == null || lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final store = Store(
        storeId: widget.store?.storeId ?? '',
        storeCode: _storeCodeController.text.trim(),
        storeName: _storeNameController.text.trim(),
        storeType: _selectedStoreType,
        contactPerson: _contactPersonController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        email: _emailController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty
            ? null
            : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _selectedCountry,
        latitude: _latitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_latitudeController.text.trim()),
        longitude: _longitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_longitudeController.text.trim()),
        operatingHours: _operatingHoursController.text.trim(),
        storeAreaSqft: _storeAreaController.text.trim().isEmpty
            ? null
            : double.tryParse(_storeAreaController.text.trim()),
        gstRegistrationNumber: _gstController.text.trim().isEmpty
            ? null
            : _gstController.text.trim(),
        fssaiLicense: _fssaiController.text.trim().isEmpty
            ? null
            : _fssaiController.text.trim(),
        storeStatus: _selectedStatus,
        parentCompany: _parentCompanyController.text.trim().isEmpty
            ? null
            : _parentCompanyController.text.trim(),
        createdAt: widget.store?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      if (widget.isEditing) {
        await StoreService.updateStore(widget.store!.storeId, store);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Store updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final storeId = await StoreService.addStore(store);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Store created successfully! ID: $storeId'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _storeCodeController.clear();
    _storeNameController.clear();
    _contactPersonController.clear();
    _contactNumberController.clear();
    _emailController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _stateController.clear();
    _postalCodeController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _storeAreaController.clear();
    _gstController.clear();
    _fssaiController.clear();
    _parentCompanyController.clear();
    
    setState(() {
      _selectedStoreType = 'Retail';
      _selectedStatus = 'Active';
      _selectedCountry = 'India';
    });
    
    _operatingHoursController.text = '9:00 AM - 9:00 PM';
    _countryController.text = 'India';
  }
}
