import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business_template/safe_integration.dart';

/// 🎯 **Enhanced Product Management Module**
/// 
/// This shows how to safely integrate business template components
/// with your existing product management module.
/// 
/// Key Benefits:
/// ✅ No breaking changes to existing code
/// ✅ Feature flag controlled
/// ✅ Easy rollback
/// ✅ Maintains all existing functionality

class EnhancedProductManagementDashboard extends ConsumerStatefulWidget {
  const EnhancedProductManagementDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<EnhancedProductManagementDashboard> createState() =>
      _EnhancedProductManagementDashboardState();
}

class _EnhancedProductManagementDashboardState
    extends ConsumerState<EnhancedProductManagementDashboard> {
  
  // Keep all your existing state variables
  String searchQuery = '';
  String selectedCategory = 'All';
  List<String> categories = ['All', 'Electronics', 'Clothing', 'Food', 'Books'];
  
  // Mock data - replace with your actual product data
  List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'iPhone 15 Pro',
      'category': 'Electronics',
      'price': 999.99,
      'stock': 50,
      'status': 'Active',
      'sales': 125,
    },
    {
      'id': '2', 
      'name': 'Samsung Galaxy S24',
      'category': 'Electronics',
      'price': 899.99,
      'stock': 30,
      'status': 'Active',
      'sales': 89,
    },
    {
      'id': '3',
      'name': 'Nike Air Max',
      'category': 'Clothing',
      'price': 129.99,
      'stock': 0,
      'status': 'Out of Stock',
      'sales': 67,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isBusinessEnabled = ref.watch(businessTemplateEnabledProvider);
    
    return SafeBusinessModuleWrapper(
      moduleName: 'Product Management',
      enableBusinessStyling: true,
      child: Scaffold(
        backgroundColor: isBusinessEnabled 
          ? SafeBusinessColors.backgroundColor(context)
          : null,
        appBar: _buildAppBar(context, isBusinessEnabled),
        body: isBusinessEnabled 
          ? _buildEnhancedBody(context)
          : _buildLegacyBody(context),
        floatingActionButton: _buildFloatingActionButton(context, isBusinessEnabled),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isBusinessEnabled) {
    return AppBar(
      title: Text(
        'Product Management',
        style: isBusinessEnabled 
          ? SafeBusinessTypography.headingMedium(context)
          : null,
      ),
      backgroundColor: isBusinessEnabled 
        ? SafeBusinessColors.primaryBlue
        : null,
      foregroundColor: isBusinessEnabled ? Colors.white : null,
      elevation: isBusinessEnabled ? 0 : null,
      actions: [
        // Feature toggle for testing
        IconButton(
          icon: Icon(isBusinessEnabled ? Icons.toggle_on : Icons.toggle_off),
          onPressed: () {
            ref.read(businessTemplateEnabledProvider.notifier).state = 
              !isBusinessEnabled;
          },
          tooltip: 'Toggle Business Template',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Your existing settings functionality
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced KPI Section
          _buildKPISection(context),
          const SizedBox(height: 32),
          
          // Enhanced Search and Filters
          _buildEnhancedSearchSection(context),
          const SizedBox(height: 24),
          
          // Enhanced Product List
          _buildEnhancedProductList(context),
        ],
      ),
    );
  }

  Widget _buildKPISection(BuildContext context) {
    final totalProducts = products.length;
    final totalStock = products.fold<int>(0, (sum, product) => sum + (product['stock'] as int));
    final outOfStock = products.where((p) => p['stock'] == 0).length;
    final totalSales = products.fold<int>(0, (sum, product) => sum + (product['sales'] as int));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Overview',
          style: SafeBusinessTypography.headingLarge(context),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            SafeBusinessKPICard(
              title: 'Total Products',
              value: totalProducts.toString(),
              trend: '+12%',
              isPositive: true,
              icon: Icons.inventory_2,
            ),
            SafeBusinessKPICard(
              title: 'Total Stock',
              value: totalStock.toString(),
              trend: '-5%',
              isPositive: false,
              icon: Icons.warehouse,
            ),
            SafeBusinessKPICard(
              title: 'Out of Stock',
              value: outOfStock.toString(),
              icon: Icons.warning,
              customColor: SafeBusinessColors.warningYellow,
            ),
            SafeBusinessKPICard(
              title: 'Total Sales',
              value: totalSales.toString(),
              trend: '+28%',
              isPositive: true,
              icon: Icons.trending_up,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedSearchSection(BuildContext context) {
    return SafeBusinessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: SafeBusinessColors.neutralGray100),
                    ),
                    filled: true,
                    fillColor: SafeBusinessColors.neutralGray50,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: SafeBusinessColors.neutralGray50,
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              SafeBusinessButton(
                text: 'Add Product',
                icon: Icons.add,
                onPressed: () {
                  _showAddProductDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProductList(BuildContext context) {
    final filteredProducts = products.where((product) {
      final matchesSearch = product['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || 
          product['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products (${filteredProducts.length})',
          style: SafeBusinessTypography.headingMedium(context),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return _buildEnhancedProductCard(context, product);
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedProductCard(BuildContext context, Map<String, dynamic> product) {
    final isOutOfStock = product['stock'] == 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SafeBusinessCard(
        onTap: () {
          _editProduct(product);
        },
        child: Row(
          children: [
            // Product Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SafeBusinessColors.neutralGray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 32,
                color: SafeBusinessColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: SafeBusinessTypography.headingMedium(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'],
                    style: SafeBusinessTypography.bodyMedium(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product['price']}',
                        style: SafeBusinessTypography.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: SafeBusinessColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutOfStock 
                            ? SafeBusinessColors.errorRed.withValues(alpha: 0.1)
                            : SafeBusinessColors.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['status'],
                          style: TextStyle(
                            color: isOutOfStock 
                              ? SafeBusinessColors.errorRed
                              : SafeBusinessColors.successGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Stock and Sales Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock: ${product['stock']}',
                  style: SafeBusinessTypography.bodyMedium(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sales: ${product['sales']}',
                  style: SafeBusinessTypography.bodyMedium(context).copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Actions
            const SizedBox(width: 16),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editProduct(product);
                    break;
                  case 'delete':
                    _deleteProduct(product);
                    break;
                  case 'duplicate':
                    _duplicateProduct(product);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyBody(BuildContext context) {
    // Return your existing product management UI
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Your existing search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Your existing product list
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Text(product['category']),
                    trailing: Text('\$${product['price']}'),
                    onTap: () => _editProduct(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isBusinessEnabled) {
    if (isBusinessEnabled) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: SafeBusinessColors.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      );
    }
    
    return FloatingActionButton(
      onPressed: () => _showAddProductDialog(context),
      child: const Icon(Icons.add),
    );
  }

  // Keep all your existing methods
  void _editProduct(Map<String, dynamic> product) {
    // Your existing edit product logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${product['name']}')),
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    // Your existing delete product logic
    setState(() {
      products.removeWhere((p) => p['id'] == product['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${product['name']}')),
    );
  }

  void _duplicateProduct(Map<String, dynamic> product) {
    // Your existing duplicate product logic
    final newProduct = Map<String, dynamic>.from(product);
    newProduct['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    newProduct['name'] = '${product['name']} (Copy)';
    
    setState(() {
      products.add(newProduct);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated ${product['name']}')),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Your existing add product dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: const Text('Add product form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
