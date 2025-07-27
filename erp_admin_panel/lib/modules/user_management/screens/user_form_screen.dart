
import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// PDR-compliant role, access, and employment type lists
const List<String> kRoles = [
  'Owner / Super Admin',
  'General Manager',
  'Store Manager',
  'Finance Manager',
  'Marketing Manager',
  'POS Sales Staff',
  'Inventory Staff',
  'Delivery / Logistics Staff',
  'HR Manager',
  'Customer App User',
  'Supplier App User',
  'Auditor / External API User',
];
const List<String> kAccessLevels = [
  'All Stores',
  'Assigned Stores',
  'Own Data Only',
  'Store Only',
  'View Only',
  'Full',
  'Restricted',
  'Read-only',
];
const List<String> kEmploymentTypes = [
  'Full-time',
  'Part-time',
  'Contract',
  'Intern',
  'External',
];

class UserFormScreen extends StatefulWidget {
  final bool showAppBar;
  final UserProfile? user;
  const UserFormScreen({Key? key, this.showAppBar = true, this.user}) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _role;
  String? _accessLevel;
  String? _employmentType;
  bool _isActive = true;
  bool _isSaving = false;
  bool _apiAccessFlag = false;
  bool _twoFaEnabled = false;
  bool _biometricLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.displayName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phoneNumber ?? '');
    _role = widget.user?.role;
    _accessLevel = widget.user?.accessLevel;
    _employmentType = widget.user?.employmentType;
    _isActive = widget.user?.isActive ?? true;
    _apiAccessFlag = widget.user?.apiAccessFlag ?? false;
    _twoFaEnabled = widget.user?.twoFaEnabled ?? false;
    _biometricLoginEnabled = widget.user?.biometricLoginEnabled ?? false;
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
    setState(() => _isSaving = true);
    final data = {
      'displayName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'role': _role,
      'accessLevel': _accessLevel,
      'employmentType': _employmentType,
      'isActive': _isActive,
      'apiAccessFlag': _apiAccessFlag,
      'twoFaEnabled': _twoFaEnabled,
      'biometricLoginEnabled': _biometricLoginEnabled,
      'updatedAt': Timestamp.now(),
      // Add more fields as needed
    };
    final auditTrailRef = FirebaseFirestore.instance.collection('audit_trail');
    try {
      if (widget.user == null) {
        // Add new user
        data['createdAt'] = Timestamp.now();
        final docRef = await FirebaseFirestore.instance.collection('users').add(data);
        await auditTrailRef.add({
          'userId': docRef.id,
          'userDisplayName': data['displayName'],
          'action': 'Created User',
          'module': 'User Management',
          'timestamp': Timestamp.now(),
        });
      } else {
        // Update existing user
        await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).update(data);
        await auditTrailRef.add({
          'userId': widget.user!.uid,
          'userDisplayName': data['displayName'],
          'action': 'Updated User',
          'module': 'User Management',
          'timestamp': Timestamp.now(),
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _role,
            items: kRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _role = v),
            decoration: const InputDecoration(labelText: 'Role'),
            validator: (v) => v == null || v.isEmpty ? 'Select role' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _accessLevel,
            items: kAccessLevels.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _accessLevel = v),
            decoration: const InputDecoration(labelText: 'Access Level'),
            validator: (v) => v == null || v.isEmpty ? 'Select access level' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _employmentType,
            items: kEmploymentTypes.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _employmentType = v),
            decoration: const InputDecoration(labelText: 'Employment Type'),
            validator: (v) => v == null || v.isEmpty ? 'Select employment type' : null,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            title: const Text('Active'),
          ),
          SwitchListTile(
            value: _apiAccessFlag,
            onChanged: (v) => setState(() => _apiAccessFlag = v),
            title: const Text('API Access'),
          ),
          SwitchListTile(
            value: _twoFaEnabled,
            onChanged: (v) => setState(() => _twoFaEnabled = v),
            title: const Text('2FA Enabled'),
          ),
          SwitchListTile(
            value: _biometricLoginEnabled,
            onChanged: (v) => setState(() => _biometricLoginEnabled = v),
            title: const Text('Biometric Login'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveUser,
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(widget.user == null ? 'Add User' : 'Update User'),
          ),
        ],
      ),
    );
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.user == null ? 'Add User' : 'Edit User'),
        ),
        body: form,
      );
    } else {
      return form;
    }
  }
}
