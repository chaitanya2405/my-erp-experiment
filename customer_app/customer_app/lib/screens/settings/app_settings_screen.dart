// ⚙️ APP SETTINGS SCREEN
// Application settings and preferences

import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _language = 'English';
  String _currency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive notifications from the app'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive order updates via email'),
                  value: _emailNotifications,
                  onChanged: _notificationsEnabled ? (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  } : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive order updates via SMS'),
                  value: _smsNotifications,
                  onChanged: _notificationsEnabled ? (value) {
                    setState(() {
                      _smsNotifications = value;
                    });
                  } : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: _pushNotifications,
                  onChanged: _notificationsEnabled ? (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  } : null,
                ),
              ],
            ),
          ),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    // TODO: Implement theme switching
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme switching coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
              ],
            ),
          ),

          // Regional Section
          _buildSectionHeader('Regional'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Currency'),
                  subtitle: Text(_currency),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showCurrencyDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Time Zone'),
                  subtitle: const Text('Asia/Kolkata (IST)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Time zone settings coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          // Privacy Section
          _buildSectionHeader('Privacy & Security'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('View our privacy policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy policy coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  subtitle: const Text('View terms and conditions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to terms of service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Terms of service coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Clear App Data'),
                  subtitle: const Text('Clear all cached data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showClearDataDialog();
                  },
                ),
              ],
            ),
          ),

          // Support Section
          _buildSectionHeader('Support'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help Center'),
                  subtitle: const Text('Get help and support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/support');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report a Bug'),
                  subtitle: const Text('Report issues with the app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showBugReportDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_rate),
                  title: const Text('Rate the App'),
                  subtitle: const Text('Rate us on the app store'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for considering to rate us!')),
                    );
                  },
                ),
              ],
            ),
          ),

          // About Section
          _buildSectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0 (Build 1)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('Check for Updates'),
                  subtitle: const Text('Update to the latest version'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You are using the latest version')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) => RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: _language,
            onChanged: (value) {
              setState(() {
                _language = value!;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language changed to $value')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) => RadioListTile<String>(
            title: Text(currency),
            value: currency,
            groupValue: _currency,
            onChanged: (value) {
              setState(() {
                _currency = value!;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Currency changed to $value')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'This will clear all cached data including offline content. Your account data will remain safe. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App data cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe the bug...',
              ),
              maxLines: 4,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Customer ERP App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.business, size: 64),
      children: [
        const Text(
          'A comprehensive ERP solution for customers to manage orders, track deliveries, and get support.',
        ),
        const SizedBox(height: 16),
        const Text('© 2024 Your Company Name'),
      ],
    );
  }
}
