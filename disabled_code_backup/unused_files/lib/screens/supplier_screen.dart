import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/index.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({Key? key}) : super(key: key);

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _selectedSupplierType = 'all';
  String _selectedRating = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => _showAddSupplierDialog(context),
            tooltip: 'Add New Supplier',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showSupplierAnalytics(context),
            tooltip: 'Supplier Analytics',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSupplierMetrics(),
          _buildFiltersAndSearch(),
          Expanded(child: _buildSupplierList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSupplierDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildSupplierMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.indigo.shade50,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('suppliers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final suppliers = snapshot.data!.docs;
          final totalSuppliers = suppliers.length;
          final activeSuppliers = suppliers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'active';
          }).length;
          final preferredSuppliers = suppliers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['is_preferred'] == true;
          }).length;
          final avgRating = suppliers.isEmpty ? 0.0 : suppliers.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['rating'] as num?)?.toDouble() ?? 0.0;
          }).reduce((a, b) => a + b) / suppliers.length;

          return Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Suppliers',
                  totalSuppliers.toString(),
                  Icons.business,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Active Suppliers',
                  activeSuppliers.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Preferred',
                  preferredSuppliers.toString(),
                  Icons.star,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Avg Rating',
                  avgRating.toStringAsFixed(1),
                  Icons.rate_review,
                  Colors.purple,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search suppliers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSupplierType,
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'manufacturer', child: Text('Manufacturer')),
                DropdownMenuItem(value: 'distributor', child: Text('Distributor')),
                DropdownMenuItem(value: 'wholesaler', child: Text('Wholesaler')),
                DropdownMenuItem(value: 'retailer', child: Text('Retailer')),
              ],
              onChanged: (value) => setState(() => _selectedSupplierType = value!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRating,
              decoration: InputDecoration(
                labelText: 'Rating',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Ratings')),
                DropdownMenuItem(value: '5', child: Text('5 Stars')),
                DropdownMenuItem(value: '4', child: Text('4+ Stars')),
                DropdownMenuItem(value: '3', child: Text('3+ Stars')),
                DropdownMenuItem(value: '2', child: Text('2+ Stars')),
              ],
              onChanged: (value) => setState(() => _selectedRating = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Error loading suppliers', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No suppliers found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddSupplierDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Supplier'),
                ),
              ],
            ),
          );
        }

        var suppliers = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['supplier_name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final type = data['supplier_type'] ?? '';
          final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;

          // Apply search filter
          final matchesSearch = _searchQuery.isEmpty || 
              name.contains(_searchQuery.toLowerCase()) ||
              email.contains(_searchQuery.toLowerCase());

          // Apply type filter
          final matchesType = _selectedSupplierType == 'all' || type == _selectedSupplierType;

          // Apply rating filter
          bool matchesRating = true;
          if (_selectedRating != 'all') {
            final minRating = double.parse(_selectedRating);
            matchesRating = rating >= minRating;
          }

          return matchesSearch && matchesType && matchesRating;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            final data = supplier.data() as Map<String, dynamic>;
            return _buildSupplierCard(supplier.id, data);
          },
        );
      },
    );
  }

  Widget _buildSupplierCard(String supplierId, Map<String, dynamic> data) {
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final isPreferred = data['is_preferred'] == true;
    final status = data['status'] ?? 'active';

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
                      Row(
                        children: [
                          Text(
                            data['supplier_name'] ?? 'Unknown Supplier',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPreferred) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.orange.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Preferred',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['supplier_code'] ?? 'No Code',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'active' ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: status == 'active' ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      _buildDetailRow(Icons.person, 'Contact', data['contact_person_name'] ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.phone, 'Phone', data['contact_person_mobile'] ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.email, 'Email', data['email'] ?? 'N/A'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.category, 'Type', data['supplier_type'] ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.location_on, 'City', data['city'] ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.payment, 'Payment Terms', data['payment_terms'] ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Total Orders: ${data['total_orders_supplied'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Total Value: ₹${_formatCurrency(data['total_order_value'] ?? 0)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () => _showSupplierDetails(context, supplierId, data),
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditSupplierDialog(context, supplierId, data),
                      tooltip: 'Edit Supplier',
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.green),
                      onPressed: () => _createPurchaseOrder(context, supplierId, data),
                      tooltip: 'Create Purchase Order',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteSupplier(context, supplierId, data['supplier_name']),
                      tooltip: 'Delete Supplier',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0.00';
    final numValue = value is num ? value : 0;
    return numValue.toStringAsFixed(2);
  }

  void _showAddSupplierDialog(BuildContext context) {
    _showSupplierFormDialog(context, 'Add New Supplier');
  }

  void _showEditSupplierDialog(BuildContext context, String supplierId, Map<String, dynamic> data) {
    _showSupplierFormDialog(context, 'Edit Supplier', supplierId: supplierId, existingData: data);
  }

  void _showSupplierFormDialog(BuildContext context, String title, {String? supplierId, Map<String, dynamic>? existingData}) {
    final formKey = GlobalKey<FormState>();
    final supplierNameController = TextEditingController(text: existingData?['supplier_name'] ?? '');
    final supplierCodeController = TextEditingController(text: existingData?['supplier_code'] ?? '');
    final contactPersonController = TextEditingController(text: existingData?['contact_person_name'] ?? '');
    final contactMobileController = TextEditingController(text: existingData?['contact_person_mobile'] ?? '');
    final emailController = TextEditingController(text: existingData?['email'] ?? '');
    final addressController = TextEditingController(text: existingData?['address_line1'] ?? '');
    final cityController = TextEditingController(text: existingData?['city'] ?? '');
    final stateController = TextEditingController(text: existingData?['state'] ?? '');
    final postalCodeController = TextEditingController(text: existingData?['postal_code'] ?? '');
    final gstinController = TextEditingController(text: existingData?['gstin'] ?? '');
    final panController = TextEditingController(text: existingData?['pan_number'] ?? '');
    String selectedType = existingData?['supplier_type'] ?? 'manufacturer';
    String selectedPaymentTerms = existingData?['payment_terms'] ?? '30 days';
    bool isPreferred = existingData?['is_preferred'] ?? false;
    double rating = (existingData?['rating'] as num?)?.toDouble() ?? 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 600,
            height: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: supplierNameController,
                            decoration: const InputDecoration(
                              labelText: 'Supplier Name *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: supplierCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Supplier Code *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: contactPersonController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Person *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: contactMobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Required';
                        if (!value!.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: 'City *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: stateController,
                            decoration: const InputDecoration(
                              labelText: 'State *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: postalCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Postal Code *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: gstinController,
                            decoration: const InputDecoration(
                              labelText: 'GSTIN',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: panController,
                            decoration: const InputDecoration(
                              labelText: 'PAN Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Supplier Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'manufacturer', child: Text('Manufacturer')),
                              DropdownMenuItem(value: 'distributor', child: Text('Distributor')),
                              DropdownMenuItem(value: 'wholesaler', child: Text('Wholesaler')),
                              DropdownMenuItem(value: 'retailer', child: Text('Retailer')),
                            ],
                            onChanged: (value) => setDialogState(() => selectedType = value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedPaymentTerms,
                            decoration: const InputDecoration(
                              labelText: 'Payment Terms',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'immediate', child: Text('Immediate')),
                              DropdownMenuItem(value: '15 days', child: Text('15 Days')),
                              DropdownMenuItem(value: '30 days', child: Text('30 Days')),
                              DropdownMenuItem(value: '45 days', child: Text('45 Days')),
                              DropdownMenuItem(value: '60 days', child: Text('60 Days')),
                            ],
                            onChanged: (value) => setDialogState(() => selectedPaymentTerms = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rating: ${rating.toStringAsFixed(1)}'),
                              Slider(
                                value: rating,
                                min: 1.0,
                                max: 5.0,
                                divisions: 8,
                                onChanged: (value) => setDialogState(() => rating = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            const Text('Preferred Supplier'),
                            Switch(
                              value: isPreferred,
                              onChanged: (value) => setDialogState(() => isPreferred = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final supplierData = {
                      'supplier_name': supplierNameController.text.trim(),
                      'supplier_code': supplierCodeController.text.trim(),
                      'contact_person_name': contactPersonController.text.trim(),
                      'contact_person_mobile': contactMobileController.text.trim(),
                      'email': emailController.text.trim(),
                      'address_line1': addressController.text.trim(),
                      'city': cityController.text.trim(),
                      'state': stateController.text.trim(),
                      'postal_code': postalCodeController.text.trim(),
                      'gstin': gstinController.text.trim(),
                      'pan_number': panController.text.trim(),
                      'supplier_type': selectedType,
                      'payment_terms': selectedPaymentTerms,
                      'is_preferred': isPreferred,
                      'rating': rating,
                      'status': 'active',
                      'total_orders_supplied': existingData?['total_orders_supplied'] ?? 0,
                      'total_order_value': existingData?['total_order_value'] ?? 0.0,
                      'updated_at': FieldValue.serverTimestamp(),
                    };

                    if (supplierId != null) {
                      // Update existing supplier
                      await _firestore.collection('suppliers').doc(supplierId).update(supplierData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Supplier updated successfully!')),
                      );
                    } else {
                      // Add new supplier
                      supplierData['created_at'] = FieldValue.serverTimestamp();
                      await _firestore.collection('suppliers').add(supplierData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Supplier added successfully!')),
                      );
                    }

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(supplierId != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierDetails(BuildContext context, String supplierId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${data['supplier_name']} - Details'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Basic Information', [
                  ['Supplier Code', data['supplier_code'] ?? 'N/A'],
                  ['Contact Person', data['contact_person_name'] ?? 'N/A'],
                  ['Mobile', data['contact_person_mobile'] ?? 'N/A'],
                  ['Email', data['email'] ?? 'N/A'],
                  ['Type', data['supplier_type'] ?? 'N/A'],
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Address', [
                  ['Address', data['address_line1'] ?? 'N/A'],
                  ['City', data['city'] ?? 'N/A'],
                  ['State', data['state'] ?? 'N/A'],
                  ['Postal Code', data['postal_code'] ?? 'N/A'],
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Business Information', [
                  ['GSTIN', data['gstin'] ?? 'N/A'],
                  ['PAN Number', data['pan_number'] ?? 'N/A'],
                  ['Payment Terms', data['payment_terms'] ?? 'N/A'],
                  ['Rating', '${data['rating'] ?? 0}/5'],
                  ['Preferred', data['is_preferred'] == true ? 'Yes' : 'No'],
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Order Statistics', [
                  ['Total Orders', '${data['total_orders_supplied'] ?? 0}'],
                  ['Total Value', '₹${_formatCurrency(data['total_order_value'])}'],
                  ['Status', data['status'] ?? 'active'],
                ]),
              ],
            ),
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
              _showEditSupplierDialog(context, supplierId, data);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<List<String>> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...details.map((detail) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '${detail[0]}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(child: Text(detail[1])),
            ],
          ),
        )),
      ],
    );
  }

  void _createPurchaseOrder(BuildContext context, String supplierId, Map<String, dynamic> supplierData) {
    // Navigate to Purchase Order screen with supplier pre-selected
    Navigator.pushNamed(context, '/purchase-orders', arguments: {
      'supplier_id': supplierId,
      'supplier_name': supplierData['supplier_name'],
    });
  }

  void _confirmDeleteSupplier(BuildContext context, String supplierId, String? supplierName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${supplierName ?? 'this supplier'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('suppliers').doc(supplierId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supplier deleted successfully!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting supplier: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupplierAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supplier Analytics'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('suppliers').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final suppliers = snapshot.data!.docs;
              final typeDistribution = <String, int>{};
              final ratingDistribution = <String, int>{};
              double totalOrderValue = 0;
              int totalOrders = 0;

              for (final doc in suppliers) {
                final data = doc.data() as Map<String, dynamic>;
                final type = data['supplier_type'] ?? 'unknown';
                final rating = ((data['rating'] as num?)?.toDouble() ?? 0.0).round();
                final orderValue = (data['total_order_value'] as num?)?.toDouble() ?? 0.0;
                final orderCount = (data['total_orders_supplied'] as num?)?.toInt() ?? 0;

                typeDistribution[type] = (typeDistribution[type] ?? 0) + 1;
                ratingDistribution['$rating stars'] = (ratingDistribution['$rating stars'] ?? 0) + 1;
                totalOrderValue += orderValue;
                totalOrders += orderCount;
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Supplier Type Distribution:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...typeDistribution.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key.toUpperCase()),
                          Text('${entry.value} suppliers'),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    const Text('Rating Distribution:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...ratingDistribution.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text('${entry.value} suppliers'),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    const Text('Order Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Total Orders: $totalOrders'),
                    Text('Total Order Value: ₹${totalOrderValue.toStringAsFixed(2)}'),
                    Text('Average Order Value: ₹${totalOrders > 0 ? (totalOrderValue / totalOrders).toStringAsFixed(2) : '0.00'}'),
                  ],
                ),
              );
            },
          ),
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
}
