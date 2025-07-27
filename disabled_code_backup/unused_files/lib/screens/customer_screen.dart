import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _searchController = TextEditingController();
  String _selectedSegment = 'All';
  
  final List<String> _segmentOptions = ['All', 'Regular', 'Premium', 'VIP', 'New'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddCustomerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
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
                  value: _selectedSegment,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSegment = newValue!;
                    });
                  },
                  items: _segmentOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Customer Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total Customers', '1,234', Icons.people, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('New This Month', '45', Icons.person_add, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Active', '987', Icons.trending_up, Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('VIP Customers', '156', Icons.star, Colors.orange)),
              ],
            ),
          ),
          
          // Customers List
          Expanded(
            child: _buildCustomersList(),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildCustomersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customer_profiles')
          .orderBy('full_name')
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
                Icon(Icons.people, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Customers Found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first customer to get started',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddCustomerDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Customer'),
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
                  backgroundColor: _getSegmentColor(data['customer_segment'] ?? 'Regular'),
                  child: Text(
                    (data['full_name'] ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  data['full_name'] ?? 'Unknown Customer',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile: ${data['mobile_number'] ?? 'N/A'}'),
                    Text('Segment: ${data['customer_segment'] ?? 'Regular'}'),
                    Text('Total Spent: ₹${data['total_spent']?.toStringAsFixed(0) ?? '0'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data['customer_segment'] == 'VIP')
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: ListTile(
                            leading: Icon(Icons.visibility),
                            title: Text('View Profile'),
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
                          value: 'history',
                          child: ListTile(
                            leading: Icon(Icons.history),
                            title: Text('Order History'),
                          ),
                        ),
                      ],
                      onSelected: (value) => _handleCustomerAction(value.toString(), doc.id, data),
                    ),
                  ],
                ),
                onTap: () => _showCustomerDetails(doc.id, data),
              ),
            );
          },
        );
      },
    );
  }

  Color _getSegmentColor(String segment) {
    switch (segment.toLowerCase()) {
      case 'vip': return Colors.orange;
      case 'premium': return Colors.purple;
      case 'regular': return Colors.blue;
      case 'new': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addCustomer(nameController.text, mobileController.text, emailController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCustomer(String name, String mobile, String email) async {
    if (name.trim().isEmpty || mobile.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and mobile number are required')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('customer_profiles').add({
        'full_name': name.trim(),
        'mobile_number': mobile.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'customer_segment': 'New',
        'total_spent': 0.0,
        'total_orders': 0,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding customer: $e')),
      );
    }
  }

  void _handleCustomerAction(String action, String docId, Map<String, dynamic> data) {
    switch (action) {
      case 'view':
        _showCustomerDetails(docId, data);
        break;
      case 'edit':
        _showEditCustomerDialog(docId, data);
        break;
      case 'history':
        _showOrderHistory(docId, data);
        break;
    }
  }

  void _showCustomerDetails(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['full_name'] ?? 'Customer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Mobile', data['mobile_number'] ?? 'N/A'),
            _buildDetailRow('Email', data['email'] ?? 'N/A'),
            _buildDetailRow('Segment', data['customer_segment'] ?? 'Regular'),
            _buildDetailRow('Total Spent', '₹${data['total_spent']?.toStringAsFixed(0) ?? '0'}'),
            _buildDetailRow('Total Orders', '${data['total_orders'] ?? 0}'),
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
              _showEditCustomerDialog(docId, data);
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

  void _showEditCustomerDialog(String docId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['full_name']);
    final mobileController = TextEditingController(text: data['mobile_number']);
    final emailController = TextEditingController(text: data['email'] ?? '');
    String selectedSegment = data['customer_segment'] ?? 'Regular';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSegment,
                decoration: const InputDecoration(
                  labelText: 'Customer Segment',
                  border: OutlineInputBorder(),
                ),
                items: ['Regular', 'Premium', 'VIP', 'New'].map((segment) {
                  return DropdownMenuItem(value: segment, child: Text(segment));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSegment = value!;
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
              onPressed: () => _updateCustomer(
                docId, 
                nameController.text, 
                mobileController.text, 
                emailController.text,
                selectedSegment,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCustomer(String docId, String name, String mobile, String email, String segment) async {
    try {
      await FirebaseFirestore.instance.collection('customer_profiles').doc(docId).update({
        'full_name': name.trim(),
        'mobile_number': mobile.trim(),
        'email': email.trim().isEmpty ? null : email.trim(),
        'customer_segment': segment,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating customer: $e')),
      );
    }
  }

  void _showOrderHistory(String customerId, Map<String, dynamic> customerData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${customerData['full_name']} - Order History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pos_transactions')
                .where('customer_id', isEqualTo: customerId)
                .orderBy('transaction_time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final orders = snapshot.data?.docs ?? [];
              
              if (orders.isEmpty) {
                return const Center(
                  child: Text('No orders found for this customer'),
                );
              }
              
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text('Order #${orders[index].id.substring(0, 6)}'),
                    subtitle: Text('Amount: ₹${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
                    trailing: Text(_formatTimestamp(order['transaction_time'])),
                  );
                },
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return timestamp.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
