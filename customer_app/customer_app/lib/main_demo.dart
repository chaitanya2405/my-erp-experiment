// 👤 CUSTOMER APP - MAIN ENTRY POINT (DEMO VERSION)
// Dedicated customer shopping experience
// All customer-specific functionality preserved from original system

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers for customer state management
        ChangeNotifierProvider(create: (_) => CustomerAppState()),
      ],
      child: MaterialApp(
        title: 'Ravali Software - Customer App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.1),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const CustomerDashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Simple state management for demo
class CustomerAppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _customerName = 'Demo Customer';
  
  bool get isAuthenticated => _isAuthenticated;
  String get customerName => _customerName;
  
  void signIn(String name) {
    _customerName = name;
    _isAuthenticated = true;
    notifyListeners();
  }
  
  void signOut() {
    _isAuthenticated = false;
    notifyListeners();
  }
}

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerAppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ravali Software - Customer Portal'),
            actions: [
              if (appState.isAuthenticated)
                TextButton.icon(
                  onPressed: () => appState.signOut(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Sign Out (${appState.customerName})',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: appState.isAuthenticated
              ? _buildDashboard(context, appState)
              : _buildSignInForm(context, appState),
        );
      },
    );
  }

  Widget _buildSignInForm(BuildContext context, CustomerAppState appState) {
    final nameController = TextEditingController();
    
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront,
                size: 64,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Ravali Software',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customer Portal - Modular ERP Demo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    appState.signIn(nameController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Sign In to Customer Portal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CustomerAppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.waving_hand,
                    size: 32,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${appState.customerName}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Your modular ERP customer portal is ready',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Restructuring Success Banner
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ERP Restructuring Complete!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your ERP system has been successfully modularized into separate Customer, Supplier, and Admin apps with shared components.',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Feature Grid
          const Text(
            'Customer Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildFeatureCard(
                'Browse Products',
                Icons.shopping_bag,
                'View our complete product catalog',
                Colors.blue,
              ),
              _buildFeatureCard(
                'Place Orders',
                Icons.shopping_cart,
                'Quick and easy order placement',
                Colors.green,
              ),
              _buildFeatureCard(
                'Track Orders',
                Icons.track_changes,
                'Real-time order status updates',
                Colors.orange,
              ),
              _buildFeatureCard(
                'View Invoices',
                Icons.receipt,
                'Access your billing history',
                Colors.purple,
              ),
              _buildFeatureCard(
                'Customer Support',
                Icons.support_agent,
                'Get help when you need it',
                Colors.red,
              ),
              _buildFeatureCard(
                'Account Settings',
                Icons.settings,
                'Manage your profile and preferences',
                Colors.grey,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Modular Architecture Info
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.architecture,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Modular Architecture Benefits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem('✅ Separate, focused apps for different user types'),
                  _buildBenefitItem('✅ Shared codebase for models and services'),
                  _buildBenefitItem('✅ Independent deployment and scaling'),
                  _buildBenefitItem('✅ Better security and access control'),
                  _buildBenefitItem('✅ Easier maintenance and updates'),
                  _buildBenefitItem('✅ Cross-platform support (Web, Mobile, Desktop)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String description, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          // Feature navigation would go here
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 14,
        ),
      ),
    );
  }
}
