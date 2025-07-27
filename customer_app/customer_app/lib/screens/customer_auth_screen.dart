// 🔐 CUSTOMER AUTHENTICATION SCREEN
// Customer login and registration - exact same functionality as original

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_erp_package/shared_erp_package.dart';
import '../providers/customer_state_provider.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({Key? key}) : super(key: key);

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Customer Sign In
        final result = await CustomerAuthService.signInCustomer(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result != null && result['success'] == true) {
          final customerProfile = result['customer'] as CustomerProfile;
          final customer = customerProfile.toCustomer();
          
          if (mounted) {
            // Set customer in app state
            context.read<CustomerStateProvider>().setCustomer(customer);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${customer.name}!'),
                backgroundColor: SharedERPDesignSystem.successColor,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result?['error'] ?? 'Login failed'),
                backgroundColor: SharedERPDesignSystem.errorColor,
              ),
            );
          }
        }
      } else {
        // Customer Registration
        final result = await CustomerAuthService.registerCustomer(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          customerName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (result != null && result['success'] == true) {
          final customer = result['customer'] as Customer;
          
          if (mounted) {
            // Set customer in app state
            context.read<CustomerStateProvider>().setCustomer(customer);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome to ERP, ${customer.name}!'),
                backgroundColor: SharedERPDesignSystem.successColor,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result?['error'] ?? 'Registration failed'),
                backgroundColor: SharedERPDesignSystem.errorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: SharedERPDesignSystem.errorColor,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SharedERPDesignSystem.platformBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo and Title
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SharedERPDesignSystem.primaryBlue,
                          SharedERPDesignSystem.primaryPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Customer Portal',
                    style: SharedERPDesignSystem.h2.copyWith(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    _isLogin 
                        ? 'Sign in to your account'
                        : 'Create your customer account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Auth Form
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: SharedERPDesignSystem.platformCard,
                      borderRadius: SharedERPDesignSystem.platformRadius,
                      boxShadow: SharedERPDesignSystem.platformShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name field (registration only)
                          if (!_isLogin) ...[
                            SharedFormField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // Email field
                          SharedFormField(
                            label: 'Email Address',
                            hint: 'Enter your email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Phone field (registration only)
                          if (!_isLogin) ...[
                            SharedFormField(
                              label: 'Phone Number',
                              hint: 'Enter your phone number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // Password field
                          SharedFormField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (!_isLogin && value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          
                          // Auth Button
                          SizedBox(
                            width: double.infinity,
                            child: SharedActionButton(
                              text: _isLogin ? 'Sign In' : 'Create Account',
                              onPressed: _handleAuth,
                              isLoading: _isLoading,
                              icon: _isLogin ? Icons.login : Icons.person_add,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Toggle between login and registration
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Clear form when switching
                        _formKey.currentState?.reset();
                        _emailController.clear();
                        _passwordController.clear();
                        _nameController.clear();
                        _phoneController.clear();
                      });
                    },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : "Already have an account? Sign in",
                      style: TextStyle(
                        color: SharedERPDesignSystem.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
