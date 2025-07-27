import 'package:flutter/material.dart';
import '../design_system/business_colors.dart';
import '../design_system/business_spacing.dart';
import '../design_system/business_typography.dart';
import '../platform/platform_detector.dart';

/// 🎯 **Interactive Template Demo**
/// 
/// A comprehensive demo showcasing all business template components and features

class TemplateDemo extends StatefulWidget {
  const TemplateDemo({Key? key}) : super(key: key);

  @override
  State<TemplateDemo> createState() => _TemplateDemoState();
}

class _TemplateDemoState extends State<TemplateDemo> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Business Template Demo'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: PlatformResponsiveBuilder(
        builder: (context, platformInfo) {
          if (platformInfo.isDesktop) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          color: Colors.white,
          child: _buildSidebar(),
        ),
        // Main content
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Components'),
              Tab(text: 'Dashboard'),
              Tab(text: 'Forms'),
              Tab(text: 'Charts'),
              Tab(text: 'Colors'),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
        // Content
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final items = [
      SidebarItem('Components', Icons.widgets, 0),
      SidebarItem('Dashboard Demo', Icons.dashboard, 1),
      SidebarItem('Form Templates', Icons.description, 2),
      SidebarItem('Chart Gallery', Icons.analytics, 3),
      SidebarItem('Color System', Icons.palette, 4),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items.map((item) {
        final isSelected = _selectedIndex == item.index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? BusinessColors.primaryBlue.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              item.icon,
              color: isSelected ? BusinessColors.primaryBlue : Colors.grey[600],
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: isSelected ? BusinessColors.primaryBlue : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = item.index;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildComponentsDemo();
      case 1:
        return _buildDashboardDemo();
      case 2:
        return _buildFormsDemo();
      case 3:
        return _buildChartsDemo();
      case 4:
        return _buildColorsDemo();
      default:
        return _buildComponentsDemo();
    }
  }

  Widget _buildComponentsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Components',
            style: BusinessTypography.headingLarge(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Professional UI components designed for enterprise applications',
            style: BusinessTypography.bodyLarge(context).copyWith(
              color: BusinessColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 32),

          // Business Cards Section
          _buildSectionTitle('Business Cards'),
          const SizedBox(height: 16),
          _buildBusinessCardsDemo(),
          
          const SizedBox(height: 32),

          // KPI Cards Section
          _buildSectionTitle('KPI Cards'),
          const SizedBox(height: 16),
          _buildKPICardsDemo(),

          const SizedBox(height: 32),

          // Button Variations
          _buildSectionTitle('Professional Buttons'),
          const SizedBox(height: 16),
          _buildButtonsDemo(),

          const SizedBox(height: 32),

          // Input Fields
          _buildSectionTitle('Form Fields'),
          const SizedBox(height: 16),
          _buildInputDemo(),
        ],
      ),
    );
  }

  Widget _buildBusinessCardsDemo() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 280,
          child: _buildBusinessCard(
            'Elevated Card',
            'Professional card with subtle shadow and elevation',
            Icons.layers,
            BusinessColors.primaryBlue,
            true,
          ),
        ),
        SizedBox(
          width: 280,
          child: _buildBusinessCard(
            'Outlined Card',
            'Clean card with border styling for subtle emphasis',
            Icons.crop_free,
            BusinessColors.successGreen,
            false,
          ),
        ),
        SizedBox(
          width: 280,
          child: _buildBusinessCard(
            'Info Card',
            'Information display card with icon and actions',
            Icons.info,
            BusinessColors.warningOrange,
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(String title, String description, IconData icon, Color color, bool elevated) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: elevated ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
        border: !elevated ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: BusinessTypography.titleMedium(context),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: BusinessTypography.bodySmall(context),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title clicked!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try It'),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICardsDemo() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildKPICard('Total Revenue', '\$2.4M', '+12.5%', true, Icons.attach_money),
        _buildKPICard('Active Users', '24,500', '+8.2%', true, Icons.people),
        _buildKPICard('Conversion Rate', '3.2%', '-2.1%', false, Icons.trending_up),
        _buildKPICard('Support Tickets', '156', '+15.3%', false, Icons.support),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String trend, bool isPositive, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: BusinessColors.primaryBlue, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? BusinessColors.successGreen : BusinessColors.dangerRed).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: isPositive ? BusinessColors.successGreen : BusinessColors.dangerRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: BusinessTypography.headingLarge(context).copyWith(
              color: BusinessColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: BusinessTypography.bodySmall(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsDemo() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Primary Action'),
          style: ElevatedButton.styleFrom(
            backgroundColor: BusinessColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Secondary Action'),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text('Tertiary Action'),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text('Success'),
          style: ElevatedButton.styleFrom(
            backgroundColor: BusinessColors.successGreen,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.warning),
          label: const Text('Warning'),
          style: ElevatedButton.styleFrom(
            backgroundColor: BusinessColors.warningOrange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.error),
          label: const Text('Danger'),
          style: ElevatedButton.styleFrom(
            backgroundColor: BusinessColors.dangerRed,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInputDemo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Product Name',
              hintText: 'Enter product name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.inventory),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Price',
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'USD',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: ['Electronics', 'Clothing', 'Books', 'Home & Garden']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executive Dashboard',
            style: BusinessTypography.headingLarge(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time business insights and key performance indicators',
            style: BusinessTypography.bodyLarge(context).copyWith(
              color: BusinessColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 32),

          // KPI Overview
          _buildSectionTitle('Key Performance Indicators'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildKPICard('Revenue', '\$2.4M', '+12.5%', true, Icons.attach_money),
              _buildKPICard('Orders', '1,247', '+8.7%', true, Icons.shopping_cart),
              _buildKPICard('Customers', '5,892', '+15.3%', true, Icons.people),
              _buildKPICard('Conversion', '3.2%', '-2.1%', false, Icons.trending_up),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(),

          const SizedBox(height: 32),

          // Recent Activity
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildQuickActionButton('New Order', Icons.add_shopping_cart, BusinessColors.primaryBlue),
          _buildQuickActionButton('Add Product', Icons.inventory, BusinessColors.successGreen),
          _buildQuickActionButton('View Reports', Icons.analytics, BusinessColors.warningOrange),
          _buildQuickActionButton('Settings', Icons.settings, BusinessColors.gray500),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color) {
    return SizedBox(
      width: 140,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label clicked!')),
          );
        },
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      ActivityItem('Order #1234 completed', '2 minutes ago', Icons.check_circle, BusinessColors.successGreen),
      ActivityItem('New customer registered: ABC Corp', '15 minutes ago', Icons.person_add, BusinessColors.primaryBlue),
      ActivityItem('Inventory low alert: Product XYZ', '1 hour ago', Icons.warning, BusinessColors.warningOrange),
      ActivityItem('Payment received: Invoice #5678', '2 hours ago', Icons.payment, BusinessColors.successGreen),
      ActivityItem('Monthly report generated', '3 hours ago', Icons.description, BusinessColors.gray500),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(activity.icon, color: activity.color, size: 20),
            ),
            title: Text(activity.title),
            subtitle: Text(activity.time),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Activity: ${activity.title}')),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFormsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Templates',
            style: BusinessTypography.headingLarge(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Professional form layouts with validation and structure',
            style: BusinessTypography.bodyLarge(context).copyWith(
              color: BusinessColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 32),

          _buildSampleForm(),
        ],
      ),
    );
  }

  Widget _buildSampleForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Information',
            style: BusinessTypography.titleLarge(context),
          ),
          const SizedBox(height: 20),

          // Form fields
          TextField(
            decoration: InputDecoration(
              labelText: 'Product Name *',
              hintText: 'Enter product name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.inventory),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'SKU *',
                    hintText: 'Product SKU',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.qr_code),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Price *',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: ['Electronics', 'Clothing', 'Books', 'Home & Garden']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),

          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Product description...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form saved successfully!')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BusinessColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.preview),
                label: const Text('Preview'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Charts',
            style: BusinessTypography.headingLarge(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Data visualization components for business insights',
            style: BusinessTypography.bodyLarge(context).copyWith(
              color: BusinessColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 32),

          _buildChartPlaceholders(),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholders() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildChartPlaceholder('Sales Revenue', 'Line Chart', Icons.show_chart, BusinessColors.primaryBlue),
        _buildChartPlaceholder('Category Distribution', 'Pie Chart', Icons.pie_chart, BusinessColors.successGreen),
        _buildChartPlaceholder('Monthly Orders', 'Bar Chart', Icons.bar_chart, BusinessColors.warningOrange),
        _buildChartPlaceholder('Customer Growth', 'Area Chart', Icons.area_chart, BusinessColors.dangerRed),
      ],
    );
  }

  Widget _buildChartPlaceholder(String title, String type, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BusinessTypography.titleMedium(context)),
                  Text(type, style: BusinessTypography.bodySmall(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color.withOpacity(0.5), size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Interactive $type',
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color System',
            style: BusinessTypography.headingLarge(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Professional color palette designed for enterprise applications',
            style: BusinessTypography.bodyLarge(context).copyWith(
              color: BusinessColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 32),

          _buildColorSection('Primary Colors', [
            ColorInfo('Primary Blue', BusinessColors.primaryBlue, '#2563EB'),
            ColorInfo('Success Green', BusinessColors.successGreen, '#059669'),
            ColorInfo('Warning Orange', BusinessColors.warningOrange, '#F59E0B'),
            ColorInfo('Danger Red', BusinessColors.dangerRed, '#DC2626'),
          ]),

          const SizedBox(height: 32),

          _buildColorSection('Neutral Colors', [
            ColorInfo('Gray 100', BusinessColors.gray100, '#F3F4F6'),
            ColorInfo('Gray 300', BusinessColors.gray300, '#D1D5DB'),
            ColorInfo('Gray 500', BusinessColors.gray500, '#6B7280'),
            ColorInfo('Gray 900', BusinessColors.gray900, '#111827'),
          ]),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<ColorInfo> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: BusinessTypography.titleLarge(context)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((colorInfo) => _buildColorCard(colorInfo)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCard(ColorInfo colorInfo) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: colorInfo.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colorInfo.name,
                  style: BusinessTypography.titleMedium(context),
                ),
                const SizedBox(height: 4),
                Text(
                  colorInfo.hex,
                  style: BusinessTypography.bodySmall(context).copyWith(
                    fontFamily: 'monospace',
                    color: BusinessColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: BusinessTypography.titleLarge(context),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Template Demo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 This comprehensive demo showcases:'),
            SizedBox(height: 8),
            Text('• Professional UI components'),
            Text('• Executive dashboard templates'),
            Text('• Form templates with validation'),
            Text('• Chart and analytics components'),
            Text('• Complete color system'),
            SizedBox(height: 16),
            Text('✨ All components are production-ready and can be integrated into your ERP system.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Data classes
class SidebarItem {
  final String title;
  final IconData icon;
  final int index;

  SidebarItem(this.title, this.icon, this.index);
}

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  ActivityItem(this.title, this.time, this.icon, this.color);
}

class ColorInfo {
  final String name;
  final Color color;
  final String hex;

  ColorInfo(this.name, this.color, this.hex);
}
