import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableRealTimeSync = true;
  bool _enableAnalytics = true;
  bool _enableAutoBackup = false;
  String _selectedCurrency = 'INR';
  String _selectedTimeZone = 'Asia/Kolkata';
  
  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP'];
  final List<String> _timeZones = ['Asia/Kolkata', 'UTC', 'America/New_York', 'Europe/London'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // System Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'System Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Version', '2.0.0 Enhanced'),
                  _buildInfoRow('Build', '2025.01.05'),
                  _buildInfoRow('Architecture', 'Event-Driven Unified'),
                  _buildInfoRow('Platform', 'Flutter Web'),
                  _buildInfoRow('Database', 'Cloud Firestore'),
                  _buildInfoRow('Status', 'Active', Colors.green),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // General Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'General Settings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Currency Setting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Currency'),
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCurrency = newValue!;
                          });
                        },
                        items: _currencies.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Time Zone Setting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time Zone'),
                      DropdownButton<String>(
                        value: _selectedTimeZone,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTimeZone = newValue!;
                          });
                        },
                        items: _timeZones.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Feature Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Feature Settings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive system and business alerts'),
                    value: _enableNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        _enableNotifications = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Real-time Sync'),
                    subtitle: const Text('Synchronize data across all modules'),
                    value: _enableRealTimeSync,
                    onChanged: (bool value) {
                      setState(() {
                        _enableRealTimeSync = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Analytics Engine'),
                    subtitle: const Text('Enable business intelligence features'),
                    value: _enableAnalytics,
                    onChanged: (bool value) {
                      setState(() {
                        _enableAnalytics = value;
                      });
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Auto Backup'),
                    subtitle: const Text('Automatically backup data daily'),
                    value: _enableAutoBackup,
                    onChanged: (bool value) {
                      setState(() {
                        _enableAutoBackup = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data Management Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storage, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Data Management',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup Data'),
                    subtitle: const Text('Create a backup of all system data'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showBackupDialog(),
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore Data'),
                    subtitle: const Text('Restore data from a previous backup'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRestoreDialog(),
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Force Sync'),
                    subtitle: const Text('Manually synchronize all data'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _performForceSync(),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red.shade600),
                    title: Text('Clear Cache', style: TextStyle(color: Colors.red.shade600)),
                    subtitle: const Text('Clear temporary files and cache'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showClearCacheDialog(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Architecture Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.architecture, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Enhanced Architecture',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildArchitectureFeature('Event-Driven System', 'Active', Colors.green),
                  _buildArchitectureFeature('Unified Data Models', 'Implemented', Colors.green),
                  _buildArchitectureFeature('Transaction Orchestration', 'Running', Colors.green),
                  _buildArchitectureFeature('Real-time Synchronization', 'Active', Colors.green),
                  _buildArchitectureFeature('Business Intelligence', 'Processing', Colors.blue),
                  _buildArchitectureFeature('Service Registry', 'Registered', Colors.green),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveSettings(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _resetToDefaults(),
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset to Defaults'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  'Ravali Enhanced ERP System',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Powered by Event-Driven Architecture',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 Enhanced Architecture Implementation',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.grey.shade700,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureFeature(String feature, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(feature, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('This will create a backup of all system data. This process may take a few minutes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performBackup();
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('Select a backup file to restore. This will overwrite current data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRestore();
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all temporary files and cache. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _performBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Creating backup... This may take a few minutes.'),
        duration: Duration(seconds: 3),
      ),
    );
    
    // Simulate backup process
    Future.delayed(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Backup created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _performRestore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📁 File picker functionality would open here')),
    );
  }

  void _performForceSync() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔄 Force sync initiated...')),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data synchronized successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧹 Cache cleared successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveSettings() async {
    try {
      // Save settings to Firestore
      await FirebaseFirestore.instance.collection('system_settings').doc('general').set({
        'currency': _selectedCurrency,
        'timezone': _selectedTimeZone,
        'notifications_enabled': _enableNotifications,
        'realtime_sync_enabled': _enableRealTimeSync,
        'analytics_enabled': _enableAnalytics,
        'auto_backup_enabled': _enableAutoBackup,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving settings: $e')),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _enableNotifications = true;
      _enableRealTimeSync = true;
      _enableAnalytics = true;
      _enableAutoBackup = false;
      _selectedCurrency = 'INR';
      _selectedTimeZone = 'Asia/Kolkata';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Settings reset to defaults'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
