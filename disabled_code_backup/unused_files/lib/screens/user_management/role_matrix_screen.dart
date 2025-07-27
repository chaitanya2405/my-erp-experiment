import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kModules = [
  'Product', 'Inventory', 'Supplier', 'Purchase', 'Store', 'CRM', 'COM', 'POS', 'Finance', 'Analytics', 'Logistics', 'User Management', 'HR', 'Asset', 'WMS', 'Quality', 'Expense', 'Audit', 'Notification', 'Loyalty', 'Marketing', 'API', 'DMS', 'Feedback', 'Franchise', 'Sustainability', 'Wiki'
];
const List<String> kPermissions = ['View', 'Create', 'Edit', 'Delete'];

/// Role Matrix Screen: Visualize and edit role/module/field-level permissions
class RoleMatrixScreen extends StatefulWidget {
  final bool showAppBar;
  const RoleMatrixScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<RoleMatrixScreen> createState() => _RoleMatrixScreenState();
}

class _RoleMatrixScreenState extends State<RoleMatrixScreen> {
  String? _selectedRole;
  Map<String, Map<String, bool>> _matrix = {};
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = null;
  }

  Future<void> _loadMatrix() async {
    if (_selectedRole == null) return;
    setState(() => _loading = true);
    final doc = await FirebaseFirestore.instance.collection('roles').doc(_selectedRole).get();
    final data = doc.data() as Map<String, dynamic>?;
    _matrix = {};
    for (final module in kModules) {
      final perms = data != null && data.containsKey(module) ? Map<String, bool>.from(data[module]) : {};
      _matrix[module] = {for (var p in kPermissions) p: perms[p] ?? false};
    }
    setState(() => _loading = false);
  }

  Future<void> _saveMatrix() async {
    if (_selectedRole == null) return;
    setState(() => _saving = true);
    final data = {for (var m in kModules) m: _matrix[m]};
    await FirebaseFirestore.instance.collection('roles').doc(_selectedRole).set(data);
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissions updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: DropdownButton<String>(
            value: _selectedRole,
            hint: const Text('Select Role'),
            items: [
              ...['Owner', 'GM', 'Store Manager', 'Staff', 'Customer', 'Supplier', 'Admin']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            ],
            onChanged: (v) async {
              setState(() => _selectedRole = v);
              await _loadMatrix();
            },
          ),
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
        if (!_loading && _selectedRole != null)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Module')),
                  ...kPermissions.map((p) => DataColumn(label: Text(p))),
                ],
                rows: kModules.map((module) {
                  return DataRow(
                    cells: [
                      DataCell(Text(module)),
                      ...kPermissions.map((perm) => DataCell(Checkbox(
                        value: _matrix[module]?[perm] ?? false,
                        onChanged: (v) {
                          setState(() {
                            _matrix[module]?[perm] = v ?? false;
                          });
                        },
                      ))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        if (_selectedRole != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
              label: const Text('Save Permissions'),
              onPressed: _saving ? null : _saveMatrix,
            ),
          ),
      ],
    );
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Role Matrix')),
        body: content,
      );
    } else {
      return content;
    }
  }
}
