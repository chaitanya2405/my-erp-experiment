import 'package:flutter/material.dart';

/// 🚀 **Comprehensive Business Template Demo**
/// 
/// This demo showcases the complete business template system with all features:
/// - Professional design system
/// - Interactive components
/// - Dashboard templates
/// - Form templates
/// - Chart components
/// - Color system
/// - Typography system
/// - Responsive layouts

void main() {
  runApp(const BusinessTemplateDemoApp());
}

class BusinessTemplateDemoApp extends StatelessWidget {
  const BusinessTemplateDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Template Demo - Complete Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Business Template System',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Professional Enterprise UI Components\nfor Modern Business Applications',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Features Grid
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What\'s Included',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Explore our comprehensive business template system',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Features Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900 ? 3 : 
                                                  constraints.maxWidth > 600 ? 2 : 1;
                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.1,
                              children: [
                                _buildFeatureCard(
                                  'UI Components',
                                  'Professional business cards, buttons, inputs, and more',
                                  Icons.widgets,
                                  const Color(0xFF2563EB),
                                ),
                                _buildFeatureCard(
                                  'Dashboard Templates',
                                  'Executive dashboards with KPIs and analytics',
                                  Icons.dashboard,
                                  const Color(0xFF059669),
                                ),
                                _buildFeatureCard(
                                  'Form Templates',
                                  'Professional forms with validation and structure',
                                  Icons.description,
                                  const Color(0xFFF59E0B),
                                ),
                                _buildFeatureCard(
                                  'Chart Components',
                                  'Data visualization for business insights',
                                  Icons.analytics,
                                  const Color(0xFFDC2626),
                                ),
                                _buildFeatureCard(
                                  'Color System',
                                  'Professional color palette with accessibility',
                                  Icons.palette,
                                  const Color(0xFF7C3AED),
                                ),
                                _buildFeatureCard(
                                  'Responsive Design',
                                  'Cross-platform layouts for all devices',
                                  Icons.devices,
                                  const Color(0xFF0891B2),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // CTA Button
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: () {                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FullTemplateDemoPage(),
                                ),
                              );
                              },
                              icon: const Icon(Icons.play_arrow, size: 24),
                              label: const Text(
                                'Launch Interactive Demo',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Technical Details
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚡ Technical Highlights',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTechItem('✅ Material 3 Design System'),
                              _buildTechItem('✅ Cross-platform Compatibility'),
                              _buildTechItem('✅ Professional Color Palette'),
                              _buildTechItem('✅ Responsive Grid Layouts'),
                              _buildTechItem('✅ Accessibility Compliant'),
                              _buildTechItem('✅ Enterprise-grade Components'),
                              _buildTechItem('✅ Dark & Light Theme Support'),
                              _buildTechItem('✅ Production-ready Code'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF374151),
          height: 1.4,
        ),
      ),
    );
  }
}

/// 📱 **Full Template Demo Page**
/// 
/// Complete showcase of all business template features

class FullTemplateDemoPage extends StatefulWidget {
  const FullTemplateDemoPage({Key? key}) : super(key: key);

  @override
  State<FullTemplateDemoPage> createState() => _FullTemplateDemoPageState();
}

class _FullTemplateDemoPageState extends State<FullTemplateDemoPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // Business color constants
  static const primaryBlue = Color(0xFF2563EB);
  static const successGreen = Color(0xFF059669);
  static const warningOrange = Color(0xFFF59E0B);
  static const dangerRed = Color(0xFFDC2626);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray100 = Color(0xFFF3F4F6);

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
      backgroundColor: gray100,
      appBar: AppBar(
        title: const Text('Business Template Demo'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: _buildResponsiveLayout(context),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1200) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
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
            labelColor: primaryBlue,
            unselectedLabelColor: gray600,
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
            color: isSelected ? primaryBlue.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(
              item.icon,
              color: isSelected ? primaryBlue : gray600,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: isSelected ? primaryBlue : gray600,
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
          const Text(
            'Business Components',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Professional UI components designed for enterprise applications',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // Business Cards Section
          _buildSectionTitle('Business Feature Cards'),
          const SizedBox(height: 16),
          _buildBusinessCardsDemo(),
          
          const SizedBox(height: 32),

          // KPI Cards Section
          _buildSectionTitle('KPI Dashboard Cards'),
          const SizedBox(height: 16),
          _buildKPICardsDemo(),

          const SizedBox(height: 32),

          // Button Variations
          _buildSectionTitle('Professional Button Suite'),
          const SizedBox(height: 16),
          _buildButtonsDemo(),

          const SizedBox(height: 32),

          // Input Fields
          _buildSectionTitle('Enterprise Form Fields'),
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
          width: 300,
          child: _buildBusinessCard(
            'Revenue Analytics',
            'Track your business performance with advanced analytics and real-time insights for better decision making',
            Icons.analytics,
            primaryBlue,
            true,
          ),
        ),
        SizedBox(
          width: 300,
          child: _buildBusinessCard(
            'Customer Management',
            'Comprehensive CRM features for managing customer relationships, tracking interactions, and improving satisfaction',
            Icons.people,
            successGreen,
            false,
          ),
        ),
        SizedBox(
          width: 300,
          child: _buildBusinessCard(
            'Inventory Control',
            'Monitor stock levels, track inventory movement, manage supplies, and optimize warehouse operations',
            Icons.inventory,
            warningOrange,
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(String title, String description, IconData icon, Color color, bool elevated) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: elevated ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
        border: !elevated ? Border.all(color: color.withOpacity(0.2), width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title feature clicked!'),
                    backgroundColor: color,
                  ),
                );
              },
              icon: const Icon(Icons.launch, size: 18),
              label: const Text('Explore Feature'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
        _buildKPICard('Support Tickets', '156', '+15.3%', false, Icons.support_agent),
        _buildKPICard('Monthly Orders', '1,847', '+22.7%', true, Icons.shopping_cart),
        _buildKPICard('Avg Order Value', '\$186', '+5.4%', true, Icons.monetization_on),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String trend, bool isPositive, IconData icon) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryBlue, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? successGreen : dangerRed).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? successGreen : dangerRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: isPositive ? successGreen : dangerRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsDemo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Button Styles & States',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showButtonAction('Primary Action'),
                icon: const Icon(Icons.add),
                label: const Text('Primary Action'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showButtonAction('Success Action'),
                icon: const Icon(Icons.check),
                label: const Text('Success'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showButtonAction('Warning Action'),
                icon: const Icon(Icons.warning),
                label: const Text('Warning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warningOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showButtonAction('Danger Action'),
                icon: const Icon(Icons.error),
                label: const Text('Danger'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showButtonAction('Secondary Action'),
                icon: const Icon(Icons.edit),
                label: const Text('Secondary'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: BorderSide(color: primaryBlue),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showButtonAction('Tertiary Action'),
                icon: const Icon(Icons.download),
                label: const Text('Tertiary'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputDemo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Form Components',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.inventory),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
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
              ),
            ],
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
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: $value')),
              );
            },
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
          const Text(
            'Executive Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time business insights and key performance indicators',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // Quick Stats Overview
          _buildSectionTitle('Performance Overview'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 
                          MediaQuery.of(context).size.width > 800 ? 3 : 
                          MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildKPICard('Revenue', '\$2.4M', '+12.5%', true, Icons.attach_money),
              _buildKPICard('Orders', '1,247', '+8.7%', true, Icons.shopping_cart),
              _buildKPICard('Customers', '5,892', '+15.3%', true, Icons.people),
              _buildKPICard('Conversion', '3.2%', '-2.1%', false, Icons.trending_up),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions Panel
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActionsPanel(),

          const SizedBox(height: 32),

          // Recent Activity Feed
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: 16),
          _buildActivityFeed(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management Tools',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickActionButton('New Order', Icons.add_shopping_cart, primaryBlue),
              _buildQuickActionButton('Add Product', Icons.inventory, successGreen),
              _buildQuickActionButton('View Reports', Icons.analytics, warningOrange),
              _buildQuickActionButton('Customer Support', Icons.support_agent, gray500),
              _buildQuickActionButton('Finance', Icons.account_balance, primaryBlue),
              _buildQuickActionButton('Settings', Icons.settings, gray500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label action triggered!'),
              backgroundColor: color,
            ),
          );
        },
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFeed() {
    final activities = [
      ActivityItem('New order #ORD-1234 received', '2 minutes ago', Icons.shopping_cart, successGreen),
      ActivityItem('Customer registration: TechCorp Industries', '15 minutes ago', Icons.person_add, primaryBlue),
      ActivityItem('Low inventory alert: MacBook Pro', '1 hour ago', Icons.warning, warningOrange),
      ActivityItem('Payment processed: Invoice #INV-5678', '2 hours ago', Icons.payment, successGreen),
      ActivityItem('Monthly sales report generated', '3 hours ago', Icons.description, gray500),
      ActivityItem('System backup completed successfully', '4 hours ago', Icons.backup, successGreen),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(activity.icon, color: activity.color, size: 20),
            ),
            title: Text(
              activity.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              activity.time,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
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
          const Text(
            'Enterprise Form Templates',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Professional form layouts with validation and business logic',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          _buildBusinessForm(),
        ],
      ),
    );
  }

  Widget _buildBusinessForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Product Registration Form',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Product Basic Info
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Product Name *',
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.inventory),
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
            ],
          ),
          const SizedBox(height: 16),

          // Price and Category
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Price *',
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText: 'USD',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: ['Electronics', 'Clothing', 'Books', 'Home & Garden', 'Sports', 'Automotive']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.inventory_2),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Product Description',
              hintText: 'Detailed product description...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),

          // Tags and Specifications
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    hintText: 'comma, separated, tags',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.tag),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: '0.0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.scale),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Product saved successfully!'),
                        backgroundColor: successGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('👁️ Preview mode activated')),
                    );
                  },
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🗑️ Form cleared')),
                  );
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gray500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
          const Text(
            'Analytics & Data Visualization',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Interactive charts and graphs for business intelligence',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          _buildChartsGallery(),
        ],
      ),
    );
  }

  Widget _buildChartsGallery() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildChartCard('Revenue Analytics', 'Line Chart', Icons.show_chart, primaryBlue, 'Track revenue trends over time'),
        _buildChartCard('Market Share', 'Pie Chart', Icons.pie_chart, successGreen, 'Product category distribution'),
        _buildChartCard('Monthly Performance', 'Bar Chart', Icons.bar_chart, warningOrange, 'Compare monthly metrics'),
        _buildChartCard('Growth Metrics', 'Area Chart', Icons.area_chart, dangerRed, 'Customer acquisition trends'),
      ],
    );
  }

  Widget _buildChartCard(String title, String type, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color.withOpacity(0.6), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Interactive $type',
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📊 $title chart interaction'),
                          backgroundColor: color,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
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
          const Text(
            'Professional Color System',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enterprise-grade color palette with accessibility standards',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          _buildColorPalettes(),
        ],
      ),
    );
  }

  Widget _buildColorPalettes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorSection('Primary Brand Colors', [
          ColorInfo('Primary Blue', primaryBlue, '#2563EB', 'Main brand color for primary actions'),
          ColorInfo('Success Green', successGreen, '#059669', 'Positive feedback and confirmations'),
          ColorInfo('Warning Orange', warningOrange, '#F59E0B', 'Cautions and attention required'),
          ColorInfo('Danger Red', dangerRed, '#DC2626', 'Errors and critical actions'),
        ]),

        const SizedBox(height: 32),

        _buildColorSection('Neutral Grays', [
          ColorInfo('Gray 100', gray100, '#F3F4F6', 'Background and subtle elements'),
          ColorInfo('Gray 500', gray500, '#6B7280', 'Secondary text and icons'),
          ColorInfo('Gray 600', gray600, '#4B5563', 'Primary text and emphasis'),
          ColorInfo('Pure White', Colors.white, '#FFFFFF', 'Cards and content backgrounds'),
        ]),

        const SizedBox(height: 32),

        _buildUsageExamples(),
      ],
    );
  }

  Widget _buildColorSection(String title, List<ColorInfo> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: colors.map((colorInfo) => _buildColorCard(colorInfo)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCard(ColorInfo colorInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorInfo.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: colorInfo.color == Colors.white
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: gray100),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colorInfo.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorInfo.hex,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorInfo.usage,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageExamples() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Usage Examples',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorExample('Primary Action', primaryBlue),
              _buildColorExample('Success State', successGreen),
              _buildColorExample('Warning Alert', warningOrange),
              _buildColorExample('Error State', dangerRed),
              _buildColorExample('Neutral', gray500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorExample(String label, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎨 $label color example'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  void _showButtonAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔘 $action triggered!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, color: primaryBlue),
            ),
            const SizedBox(width: 12),
            const Text('Business Template System'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Comprehensive Enterprise Demo Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('✅ Professional UI Components'),
            Text('✅ Executive Dashboard Templates'),
            Text('✅ Advanced Form Layouts'),
            Text('✅ Interactive Chart Placeholders'),
            Text('✅ Complete Color System'),
            Text('✅ Responsive Design'),
            Text('✅ Cross-platform Support'),
            SizedBox(height: 16),
            Text(
              '🚀 All components are production-ready and can be integrated into your ERP ecosystem.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color(0xFF6B7280),
              ),
            ),
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

// Helper classes
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
  final String usage;

  ColorInfo(this.name, this.color, this.hex, this.usage);
}
