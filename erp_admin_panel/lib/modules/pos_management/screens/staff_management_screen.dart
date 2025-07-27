import 'package:flutter/material.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  String _searchQuery = '';
  String _selectedRole = 'All';
  final List<String> _roles = ['All', 'Manager', 'Cashier', 'Assistant'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewStaff,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search staff...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Staff List
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Mock data
              itemBuilder: (context, index) {
                return _buildStaffCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(int index) {
    final List<Map<String, dynamic>> mockStaffData = [
      {
        'name': 'John Doe',
        'role': 'Manager',
        'email': 'john@example.com',
        'phone': '+91 9876543210',
        'status': 'Active',
        'shift': 'Morning',
      },
      {
        'name': 'Jane Smith',
        'role': 'Cashier',
        'email': 'jane@example.com',
        'phone': '+91 9876543211',
        'status': 'Active',
        'shift': 'Evening',
      },
      {
        'name': 'Mike Johnson',
        'role': 'Assistant',
        'email': 'mike@example.com',
        'phone': '+91 9876543212',
        'status': 'Inactive',
        'shift': 'Night',
      },
    ];

    final staff = mockStaffData[index % mockStaffData.length];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(staff['name'][0]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            staff['name'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          _buildStatusChip(staff['status']),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff['role'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
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
                      _buildInfoRow(Icons.email, staff['email']),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.phone, staff['phone']),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.access_time, '${staff['shift']} Shift'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editStaff(staff),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showStaffOptions(staff),
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

  Widget _buildStatusChip(String status) {
    Color color = status == 'Active' ? Colors.green : Colors.red;
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  void _addNewStaff() {
    // Navigate to add staff screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Staff'),
        content: const Text('Add new staff functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editStaff(Map<String, dynamic> staff) {
    // Navigate to edit staff screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${staff['name']}'),
        content: const Text('Edit staff functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStaffOptions(Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Manage Schedule'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Permissions'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.block, color: Colors.red[700]),
            title: Text('Deactivate', style: TextStyle(color: Colors.red[700])),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
