import 'package:flutter/material.dart';
import '../services/role_based_access_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  List<StaffUser> _staffUsers = [];
  List<StaffUser> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedRoleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadStaffUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _checkPermissions() {
    final rbac = RoleBasedAccessService.instance;
    if (!rbac.hasPermission(PosPermission.manageUsers)) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to manage staff'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadStaffUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final users = await RoleBasedAccessService.instance.getAllStaffUsers();
      setState(() {
        _staffUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading staff users: $e')),
      );
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _staffUsers.where((user) {
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            user.name.toLowerCase().contains(searchText) ||
            user.email.toLowerCase().contains(searchText) ||
            user.phone.toLowerCase().contains(searchText);

        final matchesRole = _selectedRoleFilter == 'All' ||
            user.role.toString().split('.').last == _selectedRoleFilter.toLowerCase();

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _addNewUser() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditStaffUserScreen(),
      ),
    );
    
    if (result == true) {
      _loadStaffUsers();
    }
  }

  Future<void> _editUser(StaffUser user) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditStaffUserScreen(user: user),
      ),
    );
    
    if (result == true) {
      _loadStaffUsers();
    }
  }

  Future<void> _toggleUserStatus(StaffUser user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Deactivate' : 'Activate'} User'),
        content: Text(
          'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.name}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement user status toggle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been ${user.isActive ? 'deactivated' : 'activated'}'),
                ),
              );
            },
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addNewUser,
            tooltip: 'Add New User',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaffUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search staff',
                hintText: 'Name, email, phone...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRoleFilter,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: ['All', 'Admin', 'Manager', 'Cashier', 'Salesperson', 'Auditor', 'Viewer']
                  .map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoleFilter = value!;
                });
                _filterUsers();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No staff users found'),
            Text('Try adjusting your filters or add new users'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(StaffUser user) {
    final roleColor = _getRoleColor(user.role);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Chip(
              label: Text(
                user.role.toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: roleColor.withOpacity(0.2),
              side: BorderSide(color: roleColor),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(user.email)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(user.phone),
                const Spacer(),
                if (user.lastLoginAt != null)
                  Text(
                    'Last login: ${_formatDate(user.lastLoginAt!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Permissions: ${_getUserPermissionCount(user)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  'Created: ${_formatDate(user.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editUser(user);
                break;
              case 'permissions':
                _showPermissions(user);
                break;
              case 'toggle_status':
                _toggleUserStatus(user);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'permissions',
              child: ListTile(
                leading: Icon(Icons.security),
                title: Text('View Permissions'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: ListTile(
                leading: Icon(user.isActive ? Icons.block : Icons.check_circle),
                title: Text(user.isActive ? 'Deactivate' : 'Activate'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showPermissions(StaffUser user) {
    final rbac = RoleBasedAccessService.instance;
    // For demo purposes, we'll create a temporary instance with this user
    final userPermissions = rbac.getUserPermissions();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.name} - Permissions'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            children: PosPermission.values.map((permission) {
              final hasPermission = userPermissions.contains(permission);
              return ListTile(
                leading: Icon(
                  hasPermission ? Icons.check_circle : Icons.cancel,
                  color: hasPermission ? Colors.green : Colors.red,
                ),
                title: Text(
                  permission.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: hasPermission ? Colors.black : Colors.grey,
                  ),
                ),
                dense: true,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (rbac.hasPermission(PosPermission.manageUsers))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editUser(user);
              },
              child: const Text('Edit Permissions'),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return Colors.red;
      case StaffRole.manager:
        return Colors.blue;
      case StaffRole.cashier:
        return Colors.green;
      case StaffRole.salesperson:
        return Colors.orange;
      case StaffRole.auditor:
        return Colors.purple;
      case StaffRole.viewer:
        return Colors.grey;
    }
  }

  int _getUserPermissionCount(StaffUser user) {
    // This is a simplified count - in a real app, you'd calculate actual permissions
    final basePermissions = {
      StaffRole.admin: PosPermission.values.length,
      StaffRole.manager: 20,
      StaffRole.cashier: 10,
      StaffRole.salesperson: 8,
      StaffRole.auditor: 6,
      StaffRole.viewer: 3,
    };
    
    return (basePermissions[user.role] ?? 0) + user.customPermissions.length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Recently';
    }
  }
}

class AddEditStaffUserScreen extends StatefulWidget {
  final StaffUser? user;

  const AddEditStaffUserScreen({Key? key, this.user}) : super(key: key);

  @override
  State<AddEditStaffUserScreen> createState() => _AddEditStaffUserScreenState();
}

class _AddEditStaffUserScreenState extends State<AddEditStaffUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  StaffRole _selectedRole = StaffRole.viewer;
  bool _isActive = true;
  final Set<PosPermission> _customPermissions = {};

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone;
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
      _customPermissions.addAll(widget.user!.customPermissions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = StaffUser(
        id: widget.user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        customPermissions: _customPermissions.toList(),
        isActive: _isActive,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        metadata: widget.user?.metadata ?? {},
      );

      final success = await RoleBasedAccessService.instance.createStaffUser(user);
      
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.user == null ? 'Created' : 'Updated'} user successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add Staff User' : 'Edit Staff User'),
        actions: [
          TextButton.icon(
            onPressed: _saveUser,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StaffRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                border: OutlineInputBorder(),
              ),
              items: StaffRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('User can access the system'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Additional Permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant additional permissions beyond the default role permissions',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...PosPermission.values.map((permission) {
              return CheckboxListTile(
                title: Text(
                  permission.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                ),
                value: _customPermissions.contains(permission),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _customPermissions.add(permission);
                    } else {
                      _customPermissions.remove(permission);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
