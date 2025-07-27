import 'package:flutter/material.dart';
import '../design_system/business_themes.dart';
import '../components/business_card.dart';
import '../templates/dashboard_template.dart';
import '../templates/list_template.dart';
import '../templates/form_template.dart';
import '../templates/analytics_template.dart';
import '../templates/detail_template.dart';
import '../migration/template_wrapper.dart';

/// 🔌 **Business Template Integration Examples**
/// 
/// Complete examples showing how to integrate the business template system
/// with your existing ERP modules. Copy and adapt these examples for your needs.

// ============================================================================
// 📊 DASHBOARD MODULE INTEGRATION
// ============================================================================

/// Example: Integrating business template with existing dashboard
class DashboardModuleExample extends StatelessWidget {
  const DashboardModuleExample({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      mode: MigrationMode.businessOnly,
      onMigrationAnalytics: () {
        MigrationProgressTracker.markModuleMigrated('dashboard_module');
      },
      child: DashboardTemplate(
        title: 'ERP Dashboard',
        kpiCards: [
          KPICardData(
            title: 'Total Revenue',
            value: '\$2.4M',
            trend: TrendDirection.up,
            trendValue: 12.5,
          ),
          KPICardData(
            title: 'Active Orders',
            value: '1,234',
            trend: TrendDirection.up,
            trendValue: 8.2,
          ),
          KPICardData(
            title: 'Inventory Value',
            value: '\$450K',
            trend: TrendDirection.down,
            trendValue: -2.1,
          ),
          KPICardData(
            title: 'Customer Satisfaction',
            value: '94%',
            trend: TrendDirection.up,
            trendValue: 5.3,
          ),
        ],
        quickActions: [
          DashboardAction(
            title: 'New Order',
            icon: Icons.add_shopping_cart,
            onTap: () => _navigateToNewOrder(context),
          ),
          DashboardAction(
            title: 'Inventory Check',
            icon: Icons.inventory,
            onTap: () => _navigateToInventory(context),
          ),
          DashboardAction(
            title: 'Customer Reports',
            icon: Icons.analytics,
            onTap: () => _navigateToReports(context),
          ),
          DashboardAction(
            title: 'Settings',
            icon: Icons.settings,
            onTap: () => _navigateToSettings(context),
          ),
        ],
        recentActivities: [
          'Order #1234 completed',
          'New customer registration: ABC Corp',
          'Inventory low alert: Product XYZ',
          'Payment received: Invoice #5678',
          'Monthly report generated',
        ],
      ),
    );
  }
  
  void _navigateToNewOrder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrderFormExample()),
    );
  }
  
  void _navigateToInventory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryListExample()),
    );
  }
  
  void _navigateToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsModuleExample()),
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsFormExample()),
    );
  }
}

// ============================================================================
// 📋 LIST MODULE INTEGRATION
// ============================================================================

/// Example: Product inventory list with business template
class InventoryListExample extends StatelessWidget {
  const InventoryListExample({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      child: ListTemplate<InventoryItem>(
        title: 'Inventory Management',
        items: _getSampleInventory(),
        itemBuilder: (context, item) => _buildInventoryCard(context, item),
        searchFields: ['name', 'sku', 'category'],
        searchPlaceholder: 'Search products...',
        onAdd: () => _showAddProduct(context),
        onRefresh: () => _refreshInventory(),
        filters: [
          FilterOption(
            key: 'category',
            title: 'Category',
            options: ['Electronics', 'Clothing', 'Books', 'Home & Garden'],
          ),
          FilterOption(
            key: 'status',
            title: 'Status',
            options: ['In Stock', 'Low Stock', 'Out of Stock'],
          ),
        ],
        sortOptions: [
          SortOption(key: 'name', title: 'Name'),
          SortOption(key: 'quantity', title: 'Quantity'),
          SortOption(key: 'price', title: 'Price'),
          SortOption(key: 'lastUpdated', title: 'Last Updated'),
        ],
        emptyMessage: 'No products found',
        emptyIcon: Icons.inventory_2_outlined,
      ),
    );
  }
  
  Widget _buildInventoryCard(BuildContext context, InventoryItem item) {
    return BusinessCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isLowStock 
              ? Colors.orange[100] 
              : Colors.green[100],
          child: Icon(
            Icons.inventory,
            color: item.isLowStock ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${item.sku}'),
            Text('Category: ${item.category}'),
            Text(
              'Quantity: ${item.quantity}',
              style: TextStyle(
                color: item.isLowStock ? Colors.orange : null,
                fontWeight: item.isLowStock ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (item.isLowStock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Low Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showProductDetails(context, item),
      ),
    );
  }
  
  List<InventoryItem> _getSampleInventory() {
    return [
      InventoryItem(
        id: '1',
        name: 'Wireless Headphones',
        sku: 'WH-001',
        category: 'Electronics',
        quantity: 45,
        price: 129.99,
        isLowStock: false,
      ),
      InventoryItem(
        id: '2',
        name: 'Cotton T-Shirt',
        sku: 'CT-002',
        category: 'Clothing',
        quantity: 5,
        price: 24.99,
        isLowStock: true,
      ),
      InventoryItem(
        id: '3',
        name: 'Programming Book',
        sku: 'PB-003',
        category: 'Books',
        quantity: 23,
        price: 49.99,
        isLowStock: false,
      ),
    ];
  }
  
  void _showAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductFormExample()),
    );
  }
  
  Future<void> _refreshInventory() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
  
  void _showProductDetails(BuildContext context, InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailExample(product: item),
      ),
    );
  }
}

// ============================================================================
// 📝 FORM MODULE INTEGRATION
// ============================================================================

/// Example: Order form with business template
class OrderFormExample extends StatelessWidget {
  const OrderFormExample({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      child: FormTemplate(
        title: 'New Order',
        sections: [
          FormSection(
            title: 'Customer Information',
            icon: Icons.person,
            fields: [
              FormField(
                key: 'customer_name',
                label: 'Customer Name',
                type: FormFieldType.text,
                isRequired: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Customer name is required';
                  }
                  return null;
                },
              ),
              FormField(
                key: 'customer_email',
                label: 'Email Address',
                type: FormFieldType.email,
                isRequired: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              FormField(
                key: 'customer_phone',
                label: 'Phone Number',
                type: FormFieldType.phone,
                isRequired: false,
              ),
            ],
          ),
          FormSection(
            title: 'Order Details',
            icon: Icons.shopping_cart,
            fields: [
              FormField(
                key: 'order_date',
                label: 'Order Date',
                type: FormFieldType.date,
                isRequired: true,
                defaultValue: DateTime.now(),
              ),
              FormField(
                key: 'priority',
                label: 'Priority',
                type: FormFieldType.dropdown,
                options: ['Low', 'Medium', 'High', 'Urgent'],
                defaultValue: 'Medium',
                isRequired: true,
              ),
              FormField(
                key: 'notes',
                label: 'Order Notes',
                type: FormFieldType.multiline,
                isRequired: false,
                maxLines: 3,
              ),
            ],
          ),
          FormSection(
            title: 'Products',
            icon: Icons.inventory,
            fields: [
              FormField(
                key: 'products',
                label: 'Select Products',
                type: FormFieldType.multiSelect,
                options: [
                  'Wireless Headphones - \$129.99',
                  'Cotton T-Shirt - \$24.99',
                  'Programming Book - \$49.99',
                ],
                isRequired: true,
                validator: (value) {
                  if (value == null || (value as List).isEmpty) {
                    return 'Please select at least one product';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
        onSave: (data) => _saveOrder(context, data),
        onCancel: () => Navigator.pop(context),
        saveButtonText: 'Create Order',
        showProgress: true,
      ),
    );
  }
  
  Future<void> _saveOrder(BuildContext context, Map<String, dynamic> data) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Example: Product form
class ProductFormExample extends StatelessWidget {
  const ProductFormExample({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      child: FormTemplate(
        title: 'Add Product',
        sections: [
          FormSection(
            title: 'Basic Information',
            icon: Icons.info,
            fields: [
              FormField(
                key: 'name',
                label: 'Product Name',
                type: FormFieldType.text,
                isRequired: true,
              ),
              FormField(
                key: 'sku',
                label: 'SKU',
                type: FormFieldType.text,
                isRequired: true,
              ),
              FormField(
                key: 'category',
                label: 'Category',
                type: FormFieldType.dropdown,
                options: ['Electronics', 'Clothing', 'Books', 'Home & Garden'],
                isRequired: true,
              ),
            ],
          ),
          FormSection(
            title: 'Pricing & Inventory',
            icon: Icons.attach_money,
            fields: [
              FormField(
                key: 'price',
                label: 'Price',
                type: FormFieldType.currency,
                isRequired: true,
              ),
              FormField(
                key: 'quantity',
                label: 'Initial Quantity',
                type: FormFieldType.number,
                isRequired: true,
              ),
              FormField(
                key: 'min_stock',
                label: 'Minimum Stock Level',
                type: FormFieldType.number,
                isRequired: true,
              ),
            ],
          ),
        ],
        onSave: (data) => _saveProduct(context, data),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
  
  Future<void> _saveProduct(BuildContext context, Map<String, dynamic> data) async {
    // Simulate save
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);
  }
}

/// Example: Settings form
class SettingsFormExample extends StatelessWidget {
  const SettingsFormExample({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      child: FormTemplate(
        title: 'System Settings',
        sections: [
          FormSection(
            title: 'General Settings',
            icon: Icons.settings,
            fields: [
              FormField(
                key: 'company_name',
                label: 'Company Name',
                type: FormFieldType.text,
                defaultValue: 'Ravali Software Solutions',
                isRequired: true,
              ),
              FormField(
                key: 'currency',
                label: 'Default Currency',
                type: FormFieldType.dropdown,
                options: ['USD', 'EUR', 'GBP', 'INR'],
                defaultValue: 'USD',
                isRequired: true,
              ),
              FormField(
                key: 'timezone',
                label: 'Timezone',
                type: FormFieldType.dropdown,
                options: ['UTC', 'EST', 'PST', 'IST'],
                defaultValue: 'UTC',
                isRequired: true,
              ),
            ],
          ),
          FormSection(
            title: 'Notifications',
            icon: Icons.notifications,
            fields: [
              FormField(
                key: 'email_notifications',
                label: 'Email Notifications',
                type: FormFieldType.toggle,
                defaultValue: true,
              ),
              FormField(
                key: 'low_stock_alerts',
                label: 'Low Stock Alerts',
                type: FormFieldType.toggle,
                defaultValue: true,
              ),
              FormField(
                key: 'order_notifications',
                label: 'Order Notifications',
                type: FormFieldType.toggle,
                defaultValue: true,
              ),
            ],
          ),
        ],
        onSave: (data) => _saveSettings(context, data),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
  
  Future<void> _saveSettings(BuildContext context, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
    Navigator.pop(context);
  }
}

// ============================================================================
// 📊 ANALYTICS MODULE INTEGRATION
// ============================================================================

/// Example: Sales analytics with business template
class AnalyticsModuleExample extends StatelessWidget {
  const AnalyticsModuleExample({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      child: AnalyticsTemplate(
        title: 'Sales Analytics',
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        ),
        kpiCards: [
          AnalyticsKPI(
            title: 'Total Sales',
            value: '\$145,250',
            trend: 15.3,
            subtitle: 'vs last month',
          ),
          AnalyticsKPI(
            title: 'Orders Count',
            value: '1,247',
            trend: 8.7,
            subtitle: 'vs last month',
          ),
          AnalyticsKPI(
            title: 'Avg Order Value',
            value: '\$116.50',
            trend: -2.1,
            subtitle: 'vs last month',
          ),
          AnalyticsKPI(
            title: 'Conversion Rate',
            value: '3.2%',
            trend: 5.4,
            subtitle: 'vs last month',
          ),
        ],
        charts: [
          AnalyticsChart(
            title: 'Sales Over Time',
            type: ChartType.line,
            data: _getSalesData(),
          ),
          AnalyticsChart(
            title: 'Sales by Category',
            type: ChartType.pie,
            data: _getCategoryData(),
          ),
          AnalyticsChart(
            title: 'Order Status Distribution',
            type: ChartType.bar,
            data: _getOrderStatusData(),
          ),
        ],
        filters: [
          AnalyticsFilter(
            key: 'period',
            title: 'Time Period',
            options: ['Last 7 days', 'Last 30 days', 'Last 90 days', 'Last year'],
            defaultValue: 'Last 30 days',
          ),
          AnalyticsFilter(
            key: 'category',
            title: 'Category',
            options: ['All', 'Electronics', 'Clothing', 'Books'],
            defaultValue: 'All',
          ),
        ],
        onExport: (format) => _exportData(context, format),
        onDateRangeChanged: (dateRange) => _updateDateRange(dateRange),
      ),
    );
  }
  
  List<ChartDataPoint> _getSalesData() {
    return [
      ChartDataPoint(label: 'Week 1', value: 12500),
      ChartDataPoint(label: 'Week 2', value: 15200),
      ChartDataPoint(label: 'Week 3', value: 18900),
      ChartDataPoint(label: 'Week 4', value: 16800),
    ];
  }
  
  List<ChartDataPoint> _getCategoryData() {
    return [
      ChartDataPoint(label: 'Electronics', value: 45),
      ChartDataPoint(label: 'Clothing', value: 30),
      ChartDataPoint(label: 'Books', value: 15),
      ChartDataPoint(label: 'Other', value: 10),
    ];
  }
  
  List<ChartDataPoint> _getOrderStatusData() {
    return [
      ChartDataPoint(label: 'Completed', value: 850),
      ChartDataPoint(label: 'Processing', value: 245),
      ChartDataPoint(label: 'Shipped', value: 152),
    ];
  }
  
  void _exportData(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting data as $format...')),
    );
  }
  
  void _updateDateRange(DateRange dateRange) {
    // Update analytics data based on new date range
  }
}

// ============================================================================
// 📄 DETAIL MODULE INTEGRATION
// ============================================================================

/// Example: Product detail view with business template
class ProductDetailExample extends StatelessWidget {
  final InventoryItem product;
  
  const ProductDetailExample({
    Key? key,
    required this.product,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      child: DetailTemplate(
        title: product.name,
        subtitle: 'SKU: ${product.sku}',
        headerActions: [
          DetailAction(
            icon: Icons.edit,
            label: 'Edit',
            onTap: () => _editProduct(context),
          ),
          DetailAction(
            icon: Icons.delete,
            label: 'Delete',
            onTap: () => _deleteProduct(context),
            isDestructive: true,
          ),
        ],
        sections: [
          DetailSection(
            title: 'Basic Information',
            items: [
              DetailItem(label: 'Name', value: product.name),
              DetailItem(label: 'SKU', value: product.sku),
              DetailItem(label: 'Category', value: product.category),
              DetailItem(
                label: 'Status',
                value: product.isLowStock ? 'Low Stock' : 'In Stock',
                valueColor: product.isLowStock ? Colors.orange : Colors.green,
              ),
            ],
          ),
          DetailSection(
            title: 'Pricing & Inventory',
            items: [
              DetailItem(
                label: 'Price',
                value: '\$${product.price.toStringAsFixed(2)}',
                isHighlighted: true,
              ),
              DetailItem(
                label: 'Current Stock',
                value: '${product.quantity} units',
                valueColor: product.isLowStock ? Colors.orange : null,
              ),
              DetailItem(label: 'Minimum Stock', value: '10 units'),
              DetailItem(label: 'Reorder Point', value: '15 units'),
            ],
          ),
          DetailSection(
            title: 'History',
            items: [
              DetailItem(label: 'Created', value: '2024-01-15'),
              DetailItem(label: 'Last Updated', value: '2024-01-20'),
              DetailItem(label: 'Last Sale', value: '2024-01-18'),
            ],
          ),
        ],
        relatedItems: [
          RelatedItem(
            title: 'Recent Orders',
            items: [
              'Order #1234 - 5 units',
              'Order #1235 - 2 units',
              'Order #1236 - 3 units',
            ],
            onViewAll: () => _viewOrders(context),
          ),
          RelatedItem(
            title: 'Similar Products',
            items: [
              'Bluetooth Headphones',
              'Gaming Headset',
              'Noise Cancelling Headphones',
            ],
            onViewAll: () => _viewSimilar(context),
          ),
        ],
        activityLog: [
          ActivityLogEntry(
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            action: 'Stock updated',
            details: 'Quantity changed from 50 to 45',
          ),
          ActivityLogEntry(
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            action: 'Price updated',
            details: 'Price changed from \$124.99 to \$129.99',
          ),
          ActivityLogEntry(
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            action: 'Product created',
            details: 'Initial inventory entry',
          ),
        ],
      ),
    );
  }
  
  void _editProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductFormExample()),
    );
  }
  
  void _deleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _viewOrders(BuildContext context) {
    // Navigate to orders related to this product
  }
  
  void _viewSimilar(BuildContext context) {
    // Navigate to similar products
  }
}

// ============================================================================
// 📊 DATA MODELS
// ============================================================================

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int quantity;
  final double price;
  final bool isLowStock;
  
  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.price,
    required this.isLowStock,
  });
}

// ============================================================================
// 🚀 MAIN INTEGRATION DEMO
// ============================================================================

/// Main demo app showing all integration examples
class BusinessTemplateIntegrationDemo extends StatelessWidget {
  const BusinessTemplateIntegrationDemo({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Template Integration Demo',
      theme: BusinessThemes.lightTheme,
      darkTheme: BusinessThemes.darkTheme,
      home: const IntegrationDemoHome(),
    );
  }
}

class IntegrationDemoHome extends StatelessWidget {
  const IntegrationDemoHome({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Template Integration'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDemoCard(
              context,
              'Dashboard Module',
              Icons.dashboard,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardModuleExample(),
                ),
              ),
            ),
            _buildDemoCard(
              context,
              'Inventory List',
              Icons.inventory,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryListExample(),
                ),
              ),
            ),
            _buildDemoCard(
              context,
              'Order Form',
              Icons.add_shopping_cart,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderFormExample(),
                ),
              ),
            ),
            _buildDemoCard(
              context,
              'Analytics',
              Icons.analytics,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsModuleExample(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDemoCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return BusinessCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
