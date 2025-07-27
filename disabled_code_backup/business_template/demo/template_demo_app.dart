import 'package:flutter/material.dart';
import '../design_system/business_colors.dart';
import '../design_system/business_spacing.dart';
import '../design_system/business_typography.dart';
import '../design_system/business_themes.dart';
import '../components/business_card.dart';
import '../platform/platform_detector.dart';

/// 🎨 **Business Template Demo Application**
/// 
/// Interactive showcase of the complete business template system featuring:
/// - All design system components
/// - Cross-platform adaptations
/// - Professional layouts
/// - Real-time responsiveness
/// - Template examples
void main() {
  runApp(const BusinessTemplateDemoApp());
}

class BusinessTemplateDemoApp extends StatelessWidget {
  const BusinessTemplateDemoApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Template Demo',
      debugShowCheckedModeBanner: false,
      theme: BusinessThemes.lightTheme,
      darkTheme: BusinessThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const BusinessTemplateDemoScreen(),
    );
  }
}

class BusinessTemplateDemoScreen extends StatefulWidget {
  const BusinessTemplateDemoScreen({Key? key}) : super(key: key);
  
  @override
  State<BusinessTemplateDemoScreen> createState() => _BusinessTemplateDemoScreenState();
}

class _BusinessTemplateDemoScreenState extends State<BusinessTemplateDemoScreen> {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  
  final List<DemoSection> _sections = [
    DemoSection('Overview', Icons.dashboard, 'Template system overview'),
    DemoSection('Colors', Icons.palette, 'Color system showcase'),
    DemoSection('Typography', Icons.text_fields, 'Typography hierarchy'),
    DemoSection('Components', Icons.widgets, 'Component library'),
    DemoSection('Layouts', Icons.view_quilt, 'Layout templates'),
    DemoSection('Platform', Icons.devices, 'Platform adaptations'),
  ];
  
  @override
  Widget build(BuildContext context) {
    return PlatformResponsiveBuilder(
      builder: (context, platformInfo) {
        return Scaffold(
          appBar: _buildAppBar(context, platformInfo),
          body: _buildBody(context, platformInfo),
          bottomNavigationBar: platformInfo.isMobile ? _buildBottomNav() : null,
          drawer: platformInfo.isMobile ? _buildDrawer(context) : null,
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, PlatformInfo platformInfo) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.business,
            color: BusinessColors.primaryBlue,
            size: platformInfo.iconSize,
          ),
          const SizedBox(width: BusinessSpacing.gapSM),
          Text(
            'Business Template Demo',
            style: BusinessTypography.titleLargeStyle(context),
          ),
        ],
      ),
      actions: [
        // Theme toggle
        IconButton(
          onPressed: () {
            setState(() {
              _isDarkMode = !_isDarkMode;
            });
          },
          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
          tooltip: 'Toggle theme',
        ),
        
        // Platform info
        IconButton(
          onPressed: () => _showPlatformInfo(context, platformInfo),
          icon: const Icon(Icons.info_outline),
          tooltip: 'Platform info',
        ),
        
        const SizedBox(width: BusinessSpacing.gapSM),
      ],
    );
  }
  
  Widget _buildBody(BuildContext context, PlatformInfo platformInfo) {
    if (platformInfo.isDesktop) {
      return Row(
        children: [
          // Sidebar navigation
          Container(
            width: BusinessSpacing.sidebarWidth,
            decoration: BoxDecoration(
              color: BusinessColors.surfaceColor(context),
              border: Border(
                right: BorderSide(
                  color: BusinessColors.borderColor(context),
                  width: 1,
                ),
              ),
            ),
            child: _buildSidebar(context),
          ),
          
          // Main content
          Expanded(
            child: _buildMainContent(context, platformInfo),
          ),
        ],
      );
    }
    
    return _buildMainContent(context, platformInfo);
  }
  
  Widget _buildSidebar(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: BusinessSpacing.all(BusinessSpacing.paddingLG),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: BusinessColors.primaryBlue,
                child: Icon(
                  Icons.business,
                  color: Colors.white,
                  size: BusinessSpacing.iconLG,
                ),
              ),
              const SizedBox(height: BusinessSpacing.gapMD),
              Text(
                'Template Demo',
                style: BusinessTypography.titleMediumStyle(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Navigation items
        Expanded(
          child: ListView.builder(
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              final section = _sections[index];
              final isSelected = index == _currentIndex;
              
              return ListTile(
                leading: Icon(
                  section.icon,
                  color: isSelected 
                      ? BusinessColors.primaryBlue 
                      : BusinessColors.textSecondary(context),
                ),
                title: Text(
                  section.title,
                  style: BusinessTypography.titleSmallStyle(context).copyWith(
                    color: isSelected 
                        ? BusinessColors.primaryBlue 
                        : BusinessColors.textPrimary(context),
                    fontWeight: isSelected 
                        ? BusinessTypography.semiBold 
                        : BusinessTypography.medium,
                  ),
                ),
                subtitle: Text(
                  section.description,
                  style: BusinessTypography.bodySmallStyle(context),
                ),
                selected: isSelected,
                selectedTileColor: BusinessColors.primaryBlue.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex.clamp(0, 4), // Limit to first 5 items
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: _sections.take(5).map((section) {
        return BottomNavigationBarItem(
          icon: Icon(section.icon),
          label: section.title,
        );
      }).toList(),
    );
  }
  
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: BusinessColors.primaryBlue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: BusinessSpacing.gapMD),
                Text(
                  'Template Demo',
                  style: BusinessTypography.titleLargeStyle(context).copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isSelected = index == _currentIndex;
                
                return ListTile(
                  leading: Icon(section.icon),
                  title: Text(section.title),
                  subtitle: Text(section.description),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent(BuildContext context, PlatformInfo platformInfo) {
    return Container(
      padding: BusinessSpacing.responsivePadding(context),
      child: _getCurrentSection(context, platformInfo),
    );
  }
  
  Widget _getCurrentSection(BuildContext context, PlatformInfo platformInfo) {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewSection(context, platformInfo);
      case 1:
        return _buildColorsSection(context);
      case 2:
        return _buildTypographySection(context);
      case 3:
        return _buildComponentsSection(context, platformInfo);
      case 4:
        return _buildLayoutsSection(context, platformInfo);
      case 5:
        return _buildPlatformSection(context, platformInfo);
      default:
        return _buildOverviewSection(context, platformInfo);
    }
  }
  
  Widget _buildOverviewSection(BuildContext context, PlatformInfo platformInfo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: BusinessSpacing.all(BusinessSpacing.paddingXL),
            decoration: BoxDecoration(
              gradient: BusinessColors.primaryGradient,
              borderRadius: BorderRadius.circular(BusinessSpacing.radiusLG),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.business,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: BusinessSpacing.gapLG),
                Text(
                  'Business Template System',
                  style: BusinessTypography.displayMediumStyle(context).copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: BusinessSpacing.gapMD),
                Text(
                  'World-class, cross-platform design system for enterprise applications',
                  style: BusinessTypography.bodyLargeStyle(context).copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Features grid
          _buildFeatureGrid(context, platformInfo),
          
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Stats section
          _buildStatsSection(context, platformInfo),
        ],
      ),
    );
  }
  
  Widget _buildFeatureGrid(BuildContext context, PlatformInfo platformInfo) {
    final features = [
      _FeatureData('Cross-Platform', Icons.devices, 'Works on Web, iOS, macOS, Android, Windows'),
      _FeatureData('Professional', Icons.business_center, 'Enterprise-grade design and components'),
      _FeatureData('Responsive', Icons.responsive_layout, 'Adapts to all screen sizes automatically'),
      _FeatureData('Accessible', Icons.accessibility, 'WCAG 2.1 compliant design'),
      _FeatureData('Performance', Icons.speed, 'Optimized for smooth operation'),
      _FeatureData('Consistent', Icons.check_circle, 'Unified design language'),
    ];
    
    final columns = BusinessSpacing.getColumnCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: BusinessSpacing.gridGap(context),
        mainAxisSpacing: BusinessSpacing.gridGap(context),
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return BusinessCard(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature.icon,
                size: 48,
                color: BusinessColors.primaryBlue,
              ),
              const SizedBox(height: BusinessSpacing.gapMD),
              Text(
                feature.title,
                style: BusinessTypography.titleMediumStyle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BusinessSpacing.gapSM),
              Text(
                feature.description,
                style: BusinessTypography.bodySmallStyle(context),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatsSection(BuildContext context, PlatformInfo platformInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Template Statistics',
          style: BusinessTypography.headlineSmallStyle(context),
        ),
        const SizedBox(height: BusinessSpacing.gapLG),
        
        // KPI cards
        Wrap(
          spacing: BusinessSpacing.gapMD,
          runSpacing: BusinessSpacing.gapMD,
          children: [
            BusinessKPICard(
              title: 'Components',
              value: '50+',
              subtitle: 'Ready-to-use',
              icon: Icons.widgets,
              trend: '+25%',
            ),
            BusinessKPICard(
              title: 'Colors',
              value: '100+',
              subtitle: 'Professional palette',
              icon: Icons.palette,
              trend: '+15%',
            ),
            BusinessKPICard(
              title: 'Platforms',
              value: '5',
              subtitle: 'Fully supported',
              icon: Icons.devices,
              trend: '+100%',
            ),
            BusinessKPICard(
              title: 'Consistency',
              value: '98%',
              subtitle: 'Design alignment',
              icon: Icons.check_circle,
              trend: '+45%',
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildColorsSection(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color System',
            style: BusinessTypography.headlineSmallStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapMD),
          Text(
            'Professional, accessible color palette designed for enterprise applications',
            style: BusinessTypography.bodyLargeStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Primary colors
          _buildColorSection('Primary Colors', [
            _ColorData('Primary Blue', BusinessColors.primaryBlue),
            _ColorData('Primary Light', BusinessColors.primaryBlueLight),
            _ColorData('Primary Dark', BusinessColors.primaryBlueDark),
            _ColorData('Secondary Indigo', BusinessColors.secondaryIndigo),
            _ColorData('Secondary Purple', BusinessColors.secondaryPurple),
            _ColorData('Secondary Teal', BusinessColors.secondaryTeal),
          ]),
          
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Semantic colors
          _buildColorSection('Semantic Colors', [
            _ColorData('Success', BusinessColors.success),
            _ColorData('Warning', BusinessColors.warning),
            _ColorData('Error', BusinessColors.error),
            _ColorData('Info', BusinessColors.info),
          ]),
          
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Accent colors
          _buildColorSection('Accent Colors', [
            _ColorData('Cyan', BusinessColors.accentCyan),
            _ColorData('Emerald', BusinessColors.accentEmerald),
            _ColorData('Yellow', BusinessColors.accentYellow),
            _ColorData('Rose', BusinessColors.accentRose),
            _ColorData('Violet', BusinessColors.accentViolet),
            _ColorData('Orange', BusinessColors.accentOrange),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildColorSection(String title, List<_ColorData> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: BusinessTypography.titleLargeStyle(context),
        ),
        const SizedBox(height: BusinessSpacing.gapMD),
        
        Wrap(
          spacing: BusinessSpacing.gapMD,
          runSpacing: BusinessSpacing.gapMD,
          children: colors.map((colorData) {
            return BusinessCard(
              width: 200,
              content: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorData.color,
                      borderRadius: BorderRadius.circular(BusinessSpacing.radiusMD),
                    ),
                  ),
                  const SizedBox(height: BusinessSpacing.gapMD),
                  Text(
                    colorData.name,
                    style: BusinessTypography.titleSmallStyle(context),
                  ),
                  const SizedBox(height: BusinessSpacing.gapXS),
                  Text(
                    '#${colorData.color.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: BusinessTypography.bodySmallStyle(context),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildTypographySection(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typography System',
            style: BusinessTypography.headlineSmallStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapMD),
          Text(
            'Professional typography hierarchy for excellent readability and visual hierarchy',
            style: BusinessTypography.bodyLargeStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Typography examples
          _buildTypographyExample('Display Large', BusinessTypography.displayLargeStyle(context)),
          _buildTypographyExample('Display Medium', BusinessTypography.displayMediumStyle(context)),
          _buildTypographyExample('Display Small', BusinessTypography.displaySmallStyle(context)),
          _buildTypographyExample('Headline Large', BusinessTypography.headlineLargeStyle(context)),
          _buildTypographyExample('Headline Medium', BusinessTypography.headlineMediumStyle(context)),
          _buildTypographyExample('Headline Small', BusinessTypography.headlineSmallStyle(context)),
          _buildTypographyExample('Title Large', BusinessTypography.titleLargeStyle(context)),
          _buildTypographyExample('Title Medium', BusinessTypography.titleMediumStyle(context)),
          _buildTypographyExample('Title Small', BusinessTypography.titleSmallStyle(context)),
          _buildTypographyExample('Body Large', BusinessTypography.bodyLargeStyle(context)),
          _buildTypographyExample('Body Medium', BusinessTypography.bodyMediumStyle(context)),
          _buildTypographyExample('Body Small', BusinessTypography.bodySmallStyle(context)),
          _buildTypographyExample('Label Large', BusinessTypography.labelLargeStyle(context)),
          _buildTypographyExample('Label Medium', BusinessTypography.labelMediumStyle(context)),
          _buildTypographyExample('Label Small', BusinessTypography.labelSmallStyle(context)),
        ],
      ),
    );
  }
  
  Widget _buildTypographyExample(String name, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BusinessSpacing.gapSM),
      child: BusinessCard(
        content: Row(
          children: [
            SizedBox(
              width: 150,
              child: Text(
                name,
                style: BusinessTypography.labelMediumStyle(context),
              ),
            ),
            Expanded(
              child: Text(
                'The quick brown fox jumps over the lazy dog',
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComponentsSection(BuildContext context, PlatformInfo platformInfo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Component Library',
            style: BusinessTypography.headlineSmallStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapMD),
          Text(
            'Professional components ready for enterprise applications',
            style: BusinessTypography.bodyLargeStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Component examples
          _buildComponentExample('Business Cards', _buildCardExamples()),
          const SizedBox(height: BusinessSpacing.gapXL),
          _buildComponentExample('KPI Cards', _buildKPIExamples()),
          const SizedBox(height: BusinessSpacing.gapXL),
          _buildComponentExample('Info Cards', _buildInfoCardExamples()),
        ],
      ),
    );
  }
  
  Widget _buildComponentExample(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: BusinessTypography.titleLargeStyle(context),
        ),
        const SizedBox(height: BusinessSpacing.gapMD),
        content,
      ],
    );
  }
  
  Widget _buildCardExamples() {
    return Wrap(
      spacing: BusinessSpacing.gapMD,
      runSpacing: BusinessSpacing.gapMD,
      children: [
        BusinessCard(
          title: 'Simple Card',
          subtitle: 'Basic card with title and subtitle',
          content: Text(
            'This is a simple business card with title, subtitle, and content.',
            style: BusinessTypography.bodyMediumStyle(context),
          ),
        ),
        BusinessCard(
          title: 'Card with Icon',
          subtitle: 'Card featuring leading icon',
          leading: Icon(
            Icons.star,
            color: BusinessColors.warning,
          ),
          content: Text(
            'This card includes a leading icon for visual emphasis.',
            style: BusinessTypography.bodyMediumStyle(context),
          ),
        ),
        BusinessCard(
          title: 'Interactive Card',
          subtitle: 'Tap to see interaction',
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card tapped!')),
            );
          },
          content: Text(
            'This card is interactive and responds to taps.',
            style: BusinessTypography.bodyMediumStyle(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildKPIExamples() {
    return Wrap(
      spacing: BusinessSpacing.gapMD,
      runSpacing: BusinessSpacing.gapMD,
      children: [
        BusinessKPICard(
          title: 'Revenue',
          value: '\$1.2M',
          subtitle: 'This month',
          icon: Icons.monetization_on,
          trend: '+12.5%',
          trendValue: 12.5,
        ),
        BusinessKPICard(
          title: 'Orders',
          value: '2,456',
          subtitle: 'Total orders',
          icon: Icons.shopping_cart,
          trend: '+8.2%',
          trendValue: 8.2,
        ),
        BusinessKPICard(
          title: 'Customers',
          value: '1,849',
          subtitle: 'Active users',
          icon: Icons.people,
          trend: '-2.1%',
          trendValue: -2.1,
        ),
      ],
    );
  }
  
  Widget _buildInfoCardExamples() {
    return Wrap(
      spacing: BusinessSpacing.gapMD,
      runSpacing: BusinessSpacing.gapMD,
      children: [
        BusinessInfoCard(
          title: 'Product Information',
          leading: Icon(
            Icons.inventory,
            color: BusinessColors.primaryBlue,
          ),
          information: {
            'SKU': 'PROD-001',
            'Category': 'Electronics',
            'Stock': '150 units',
            'Price': '\$299.99',
          },
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('View'),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLayoutsSection(BuildContext context, PlatformInfo platformInfo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layout Templates',
            style: BusinessTypography.headlineSmallStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapMD),
          Text(
            'Ready-to-use layout templates for common enterprise screens',
            style: BusinessTypography.bodyLargeStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Layout preview cards
          _buildLayoutPreview('Dashboard Layout', 'Executive dashboard with KPIs and charts', Icons.dashboard),
          const SizedBox(height: BusinessSpacing.gapMD),
          _buildLayoutPreview('List Screen Layout', 'Data tables with filtering and actions', Icons.list),
          const SizedBox(height: BusinessSpacing.gapMD),
          _buildLayoutPreview('Form Layout', 'Professional forms with validation', Icons.edit),
          const SizedBox(height: BusinessSpacing.gapMD),
          _buildLayoutPreview('Analytics Layout', 'Charts and data visualization', Icons.analytics),
          const SizedBox(height: BusinessSpacing.gapMD),
          _buildLayoutPreview('Detail Layout', 'Item detail views with actions', Icons.description),
        ],
      ),
    );
  }
  
  Widget _buildLayoutPreview(String title, String description, IconData icon) {
    return BusinessCard(
      title: title,
      subtitle: description,
      leading: Icon(
        icon,
        color: BusinessColors.primaryBlue,
        size: BusinessSpacing.iconLG,
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title selected')),
        );
      },
    );
  }
  
  Widget _buildPlatformSection(BuildContext context, PlatformInfo platformInfo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Adaptations',
            style: BusinessTypography.headlineSmallStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapMD),
          Text(
            'How the template adapts to different platforms and screen sizes',
            style: BusinessTypography.bodyLargeStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Current platform info
          BusinessInfoCard(
            title: 'Current Platform',
            leading: Icon(
              _getPlatformIcon(platformInfo),
              color: BusinessColors.primaryBlue,
            ),
            information: {
              'Device': platformInfo.category.name.toUpperCase(),
              'Screen Size': platformInfo.screenSize.name.toUpperCase(),
              'Navigation': platformInfo.navigationType.name.toUpperCase(),
              'Touch Input': platformInfo.hasTouchInput ? 'Yes' : 'No',
              'Hover Support': platformInfo.supportsHover ? 'Yes' : 'No',
              'Keyboard': platformInfo.hasKeyboardInput ? 'Yes' : 'No',
            },
          ),
          
          const SizedBox(height: BusinessSpacing.gapXL),
          
          // Platform features
          Text(
            'Platform Features',
            style: BusinessTypography.titleLargeStyle(context),
          ),
          const SizedBox(height: BusinessSpacing.gapMD),
          
          _buildPlatformFeature(
            'Mobile',
            'Touch-optimized with bottom navigation',
            Icons.phone_android,
            platformInfo.isMobile,
          ),
          _buildPlatformFeature(
            'Tablet',
            'Hybrid navigation with larger touch targets',
            Icons.tablet,
            platformInfo.isTablet,
          ),
          _buildPlatformFeature(
            'Desktop',
            'Sidebar navigation with hover effects',
            Icons.desktop_windows,
            platformInfo.isDesktop,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlatformFeature(String name, String description, IconData icon, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BusinessSpacing.gapSM),
      child: BusinessCard(
        backgroundColor: isActive 
            ? BusinessColors.primaryBlue.withOpacity(0.1)
            : null,
        border: isActive
            ? Border.all(color: BusinessColors.primaryBlue, width: 2)
            : null,
        content: Row(
          children: [
            Icon(
              icon,
              color: isActive 
                  ? BusinessColors.primaryBlue 
                  : BusinessColors.textSecondary(context),
              size: BusinessSpacing.iconLG,
            ),
            const SizedBox(width: BusinessSpacing.gapMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: BusinessTypography.titleMediumStyle(context).copyWith(
                      color: isActive ? BusinessColors.primaryBlue : null,
                    ),
                  ),
                  Text(
                    description,
                    style: BusinessTypography.bodySmallStyle(context),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: BusinessColors.success,
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPlatformIcon(PlatformInfo platformInfo) {
    switch (platformInfo.category) {
      case DeviceCategory.mobile:
        return Icons.phone_android;
      case DeviceCategory.tablet:
        return Icons.tablet;
      case DeviceCategory.desktop:
        return Icons.desktop_windows;
    }
  }
  
  void _showPlatformInfo(BuildContext context, PlatformInfo platformInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platform Information'),
        content: Text(platformInfo.toString()),
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
class DemoSection {
  final String title;
  final IconData icon;
  final String description;
  
  DemoSection(this.title, this.icon, this.description);
}

class _FeatureData {
  final String title;
  final IconData icon;
  final String description;
  
  _FeatureData(this.title, this.icon, this.description);
}

class _ColorData {
  final String name;
  final Color color;
  
  _ColorData(this.name, this.color);
}
