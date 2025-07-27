// 🌐 CROSS-PLATFORM UNIFIED UI DESIGN SHOWCASE
// Sample showing how modern ERP design adapts across Web, macOS, Android, Windows
// NOT FOR IMPLEMENTATION - Design reference and inspiration only

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ============================================================================
// 🎨 UNIFIED DESIGN SYSTEM - CROSS-PLATFORM 2025
// ============================================================================

class UnifiedERPDesignSystem {
  // 🎨 Core Brand Colors (consistent across all platforms)
  static const Color primaryBlue = Color(0xFF2B5CE6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  
  // 🌍 Platform-Adaptive Backgrounds
  static Color get platformBackground {
    if (kIsWeb) return const Color(0xFFF8FAFC); // Web: Light gray
    if (defaultTargetPlatform == TargetPlatform.macOS) return const Color(0xFFF5F5F7); // macOS: System gray
    if (defaultTargetPlatform == TargetPlatform.windows) return const Color(0xFFF3F3F3); // Windows: Fluent gray
    return const Color(0xFFFFFFFF); // Android: Pure white
  }
  
  static Color get platformCard {
    if (kIsWeb) return Colors.white;
    if (defaultTargetPlatform == TargetPlatform.macOS) return const Color(0xFFFFFFFF);
    if (defaultTargetPlatform == TargetPlatform.windows) return const Color(0xFFFAFAFA);
    return const Color(0xFFFFFFFF);
  }
  
  // 📱 Platform-Specific Gradients
  static LinearGradient get platformGradient {
    if (kIsWeb) {
      return const LinearGradient(
        colors: [primaryBlue, primaryPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return LinearGradient(
        colors: [primaryBlue.withOpacity(0.9), primaryPurple.withOpacity(0.9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return const LinearGradient(
        colors: [Color(0xFF0078D4), Color(0xFF106EBE)], // Windows Blue
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    // Android Material You inspired
    return const LinearGradient(
      colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  // 🎯 Platform-Adaptive Shadows
  static List<BoxShadow> get platformShadow {
    if (kIsWeb) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }
    // Android elevation
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  // 📐 Platform-Adaptive Border Radius
  static BorderRadius get platformRadius {
    if (kIsWeb) return BorderRadius.circular(16);
    if (defaultTargetPlatform == TargetPlatform.macOS) return BorderRadius.circular(12);
    if (defaultTargetPlatform == TargetPlatform.windows) return BorderRadius.circular(8);
    return BorderRadius.circular(20); // Android: More rounded
  }
  
  // 📱 Responsive Breakpoints
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 1024;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width > 768 && MediaQuery.of(context).size.width <= 1024;
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width <= 768;
  
  // 🎨 Platform-Specific Typography
  static TextStyle get platformHeaderStyle {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        fontFamily: 'SF Pro Display',
      );
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamily: 'Segoe UI',
      );
    }
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      fontFamily: 'Roboto',
    );
  }
}

// ============================================================================
// 🌍 CROSS-PLATFORM ADAPTIVE DASHBOARD
// ============================================================================

class UnifiedCrossPlatformDashboard extends StatefulWidget {
  const UnifiedCrossPlatformDashboard({Key? key}) : super(key: key);

  @override
  State<UnifiedCrossPlatformDashboard> createState() => _UnifiedCrossPlatformDashboardState();
}

class _UnifiedCrossPlatformDashboardState extends State<UnifiedCrossPlatformDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedERPDesignSystem.platformBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (UnifiedERPDesignSystem.isDesktop(context)) {
            return _buildDesktopLayout();
          } else if (UnifiedERPDesignSystem.isTablet(context)) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // 🖥️ DESKTOP LAYOUT (Web & Desktop Apps)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar for desktop
        Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: UnifiedERPDesignSystem.platformGradient,
          ),
          child: _buildNavigationSidebar(),
        ),
        // Main content
        Expanded(
          child: Column(
            children: [
              _buildPlatformHeader(),
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ],
    );
  }

  // 📱 TABLET LAYOUT
  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildPlatformHeader(),
        Expanded(
          child: Row(
            children: [
              // Compact sidebar for tablet
              Container(
                width: 200,
                decoration: BoxDecoration(
                  gradient: UnifiedERPDesignSystem.platformGradient,
                ),
                child: _buildCompactSidebar(),
              ),
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ],
    );
  }

  // 📱 MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(child: _buildMobileContent()),
      ],
    );
  }

  // 🎯 Platform-Adaptive Header
  Widget _buildPlatformHeader() {
    String platformName = _getPlatformName();
    IconData platformIcon = _getPlatformIcon();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UnifiedERPDesignSystem.platformCard,
        boxShadow: UnifiedERPDesignSystem.platformShadow,
      ),
      child: Row(
        children: [
          // Platform indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UnifiedERPDesignSystem.primaryBlue.withOpacity(0.1),
              borderRadius: UnifiedERPDesignSystem.platformRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(platformIcon, size: 16, color: UnifiedERPDesignSystem.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  platformName,
                  style: TextStyle(
                    color: UnifiedERPDesignSystem.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Main title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ERP Pro - $platformName Edition',
                  style: UnifiedERPDesignSystem.platformHeaderStyle.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Unified experience across all platforms',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Platform-specific actions
          _buildPlatformActions(),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return AppBar(
      backgroundColor: UnifiedERPDesignSystem.platformCard,
      elevation: 2,
      title: Text(
        'ERP Pro Mobile',
        style: UnifiedERPDesignSystem.platformHeaderStyle.copyWith(fontSize: 20),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _showMobileMenu(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  // 🎨 Platform-Specific Actions
  Widget _buildPlatformActions() {
    if (kIsWeb) {
      return Row(
        children: [
          _buildWebAction(Icons.fullscreen, 'Fullscreen'),
          _buildWebAction(Icons.download, 'Export'),
          _buildWebAction(Icons.share, 'Share'),
        ],
      );
    }
    
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return Row(
        children: [
          _buildMacAction(Icons.search, 'Spotlight'),
          _buildMacAction(Icons.notifications, 'Notifications'),
          _buildMacAction(Icons.person, 'Profile'),
        ],
      );
    }
    
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return Row(
        children: [
          _buildWindowsAction(Icons.search, 'Search'),
          _buildWindowsAction(Icons.settings, 'Settings'),
          _buildWindowsAction(Icons.account_circle, 'Account'),
        ],
      );
    }
    
    // Android
    return Row(
      children: [
        _buildAndroidAction(Icons.search, 'Search'),
        _buildAndroidAction(Icons.more_vert, 'More'),
      ],
    );
  }

  Widget _buildWebAction(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildMacAction(IconData icon, String tooltip) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 18, color: Colors.grey.shade700),
    );
  }

  Widget _buildWindowsAction(IconData icon, String tooltip) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: Colors.grey.shade600),
    );
  }

  Widget _buildAndroidAction(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {},
      color: Colors.grey.shade600,
    );
  }

  // 📱 Navigation Components
  Widget _buildNavigationSidebar() {
    return Column(
      children: [
        // Brand section
        Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: UnifiedERPDesignSystem.platformRadius,
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ERP Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _getPlatformName(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Navigation items
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildNavItem(Icons.dashboard_rounded, 'Dashboard', true),
                _buildNavItem(Icons.inventory_2_rounded, 'Inventory', false),
                _buildNavItem(Icons.shopping_cart_rounded, 'POS System', false),
                _buildNavItem(Icons.people_rounded, 'Customers', false),
                _buildNavItem(Icons.local_shipping_rounded, 'Suppliers', false),
                _buildNavItem(Icons.analytics_rounded, 'Analytics', false),
                
                const Spacer(),
                
                // Platform info
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: UnifiedERPDesignSystem.platformRadius,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getPlatformIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Optimized for\n${_getPlatformName()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSidebar() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.business_center, color: Colors.white, size: 32),
        const SizedBox(height: 20),
        
        Expanded(
          child: Column(
            children: [
              _buildCompactNavItem(Icons.dashboard_rounded, 'Dashboard', true),
              _buildCompactNavItem(Icons.inventory_2_rounded, 'Inventory', false),
              _buildCompactNavItem(Icons.shopping_cart_rounded, 'POS', false),
              _buildCompactNavItem(Icons.people_rounded, 'Customers', false),
              _buildCompactNavItem(Icons.analytics_rounded, 'Analytics', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: UnifiedERPDesignSystem.platformRadius,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: UnifiedERPDesignSystem.platformRadius,
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactNavItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // 📊 Main Content Areas
  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlatformSpecificStats(),
          const SizedBox(height: 24),
          _buildAdaptiveChartsGrid(),
          const SizedBox(height: 24),
          _buildResponsiveDataTable(),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMobileStats(),
          const SizedBox(height: 16),
          _buildMobileCharts(),
          const SizedBox(height: 16),
          _buildMobileTable(),
        ],
      ),
    );
  }

  // 📊 Platform-Specific Stats
  Widget _buildPlatformSpecificStats() {
    return GridView.count(
      crossAxisCount: UnifiedERPDesignSystem.isDesktop(context) ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Revenue', '₹2,45,890', '+12.5%', UnifiedERPDesignSystem.accentGreen, Icons.trending_up),
        _buildStatCard('Orders', '1,234', '+8.2%', UnifiedERPDesignSystem.accentCyan, Icons.shopping_bag),
        _buildStatCard('Customers', '856', '+15.3%', UnifiedERPDesignSystem.accentOrange, Icons.people),
        _buildStatCard('Products', '342', '+5.1%', UnifiedERPDesignSystem.primaryPurple, Icons.inventory_2),
      ],
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Revenue', '₹2.45L', '+12.5%', UnifiedERPDesignSystem.accentGreen, Icons.trending_up)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Orders', '1,234', '+8.2%', UnifiedERPDesignSystem.accentCyan, Icons.shopping_bag)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Customers', '856', '+15.3%', UnifiedERPDesignSystem.accentOrange, Icons.people)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Products', '342', '+5.1%', UnifiedERPDesignSystem.primaryPurple, Icons.inventory_2)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UnifiedERPDesignSystem.platformCard,
        borderRadius: UnifiedERPDesignSystem.platformRadius,
        boxShadow: UnifiedERPDesignSystem.platformShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📈 Adaptive Charts
  Widget _buildAdaptiveChartsGrid() {
    if (UnifiedERPDesignSystem.isMobile(context)) {
      return _buildMobileCharts();
    }
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildChartContainer(
            'Sales Analytics - ${_getPlatformName()}',
            'Platform-optimized revenue visualization',
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildChartContainer(
            'Top Categories',
            'Cross-platform data',
            Icons.pie_chart,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCharts() {
    return Column(
      children: [
        _buildChartContainer(
          'Sales Analytics',
          'Mobile-optimized view',
          Icons.trending_up,
        ),
        const SizedBox(height: 16),
        _buildChartContainer(
          'Categories',
          'Touch-friendly charts',
          Icons.pie_chart,
        ),
      ],
    );
  }

  Widget _buildChartContainer(String title, String subtitle, IconData icon) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UnifiedERPDesignSystem.platformCard,
        borderRadius: UnifiedERPDesignSystem.platformRadius,
        boxShadow: UnifiedERPDesignSystem.platformShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: UnifiedERPDesignSystem.primaryBlue),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UnifiedERPDesignSystem.primaryBlue.withOpacity(0.1),
                    UnifiedERPDesignSystem.accentCyan.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getPlatformIcon(),
                      size: 48,
                      color: UnifiedERPDesignSystem.primaryBlue.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📊 ${_getPlatformName()} Optimized Chart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: UnifiedERPDesignSystem.primaryBlue,
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

  // 📋 Responsive Data Table
  Widget _buildResponsiveDataTable() {
    if (UnifiedERPDesignSystem.isMobile(context)) {
      return _buildMobileTable();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: UnifiedERPDesignSystem.platformCard,
        borderRadius: UnifiedERPDesignSystem.platformRadius,
        boxShadow: UnifiedERPDesignSystem.platformShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Orders - ${_getPlatformName()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Platform-optimized data display',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Icon(_getPlatformIcon(), color: UnifiedERPDesignSystem.primaryBlue),
              ],
            ),
          ),
          
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.w600))),
                const Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.w600))),
                const Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                const Expanded(child: Text('Platform', style: TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Table rows
          ...List.generate(5, (index) => _buildTableRow(
            'Customer ${index + 1}',
            '₹${(1250 * (index + 1)).toString()}',
            index % 3 == 0 ? 'Completed' : index % 3 == 1 ? 'Pending' : 'Processing',
            _getPlatformName(),
          )),
        ],
      ),
    );
  }

  Widget _buildMobileTable() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: UnifiedERPDesignSystem.platformCard,
          borderRadius: UnifiedERPDesignSystem.platformRadius,
          boxShadow: UnifiedERPDesignSystem.platformShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Icon(_getPlatformIcon(), size: 16, color: UnifiedERPDesignSystem.primaryBlue),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${(1250 * (index + 1)).toString()}'),
                _buildStatusChip(index % 3 == 0 ? 'Completed' : 'Pending'),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildTableRow(String customer, String amount, String status, String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: UnifiedERPDesignSystem.primaryBlue.withOpacity(0.1),
                  child: Text(
                    customer[0],
                    style: TextStyle(
                      color: UnifiedERPDesignSystem.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(customer),
              ],
            ),
          ),
          Expanded(child: Text(amount, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: _buildStatusChip(status)),
          Expanded(child: Row(
            children: [
              Icon(_getPlatformIcon(), size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(platform, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          )),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = UnifiedERPDesignSystem.accentGreen;
        break;
      case 'Pending':
        color = UnifiedERPDesignSystem.accentOrange;
        break;
      default:
        color = UnifiedERPDesignSystem.accentCyan;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 🔧 Platform Detection Helpers
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      default:
        return 'Desktop';
    }
  }

  IconData _getPlatformIcon() {
    if (kIsWeb) return Icons.language;
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return Icons.laptop_mac;
      case TargetPlatform.windows:
        return Icons.computer;
      case TargetPlatform.android:
        return Icons.phone_android;
      case TargetPlatform.iOS:
        return Icons.phone_iphone;
      default:
        return Icons.devices;
    }
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_rounded),
              title: const Text('Inventory'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_rounded),
              title: const Text('POS System'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people_rounded),
              title: const Text('Customers'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_rounded),
              title: const Text('Analytics'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ============================================================================
// 📱 PLATFORM-SPECIFIC DESIGN DOCUMENTATION
// ============================================================================

class CrossPlatformDesignGuide {
  static const String designPhilosophy = '''
  🌍 CROSS-PLATFORM UNIFIED DESIGN PHILOSOPHY:
  
  1. CONSISTENT BRAND IDENTITY
     - Same color palette across all platforms
     - Unified typography hierarchy  
     - Consistent iconography and messaging
     - Brand recognition regardless of platform
  
  2. PLATFORM-NATIVE FEEL
     - Web: Glassmorphism, large clickable areas
     - macOS: Subtle shadows, SF Pro fonts, native spacing
     - Windows: Fluent Design, sharp corners, Segoe UI
     - Android: Material You, elevated surfaces, Roboto
  
  3. ADAPTIVE LAYOUTS
     - Desktop: Sidebar + main content (1024px+)
     - Tablet: Compact sidebar + content (768-1024px)
     - Mobile: Bottom nav + stacked content (<768px)
     - Touch-optimized for mobile platforms
  
  4. PLATFORM-SPECIFIC OPTIMIZATIONS
     - Web: Keyboard shortcuts, context menus
     - macOS: Spotlight integration, trackpad gestures
     - Windows: Live tiles, cortana integration
     - Android: Back button, swipe gestures, notifications
  
  5. UNIFIED DATA VISUALIZATION
     - Same chart types across platforms
     - Platform-optimized interactions (hover vs touch)
     - Consistent color coding and legends
     - Responsive chart scaling
  ''';
  
  static const String implementationStrategy = '''
  🚀 IMPLEMENTATION STRATEGY:
  
  PHASE 1: DESIGN SYSTEM (Week 1-2)
  - Define unified color palette and typography
  - Create platform-adaptive components
  - Establish responsive breakpoints
  - Design platform-specific variations
  
  PHASE 2: LAYOUT ADAPTATION (Week 3-4)
  - Desktop: Full sidebar navigation
  - Tablet: Compact sidebar with icons
  - Mobile: Bottom navigation bar
  - Platform-specific headers and actions
  
  PHASE 3: COMPONENT OPTIMIZATION (Week 5-6)
  - Platform-native shadows and borders
  - Adaptive spacing and sizing
  - Touch vs mouse interactions
  - Platform-specific animations
  
  PHASE 4: DATA INTEGRATION (Week 7-8)
  - Unified data models across platforms
  - Platform-optimized data visualization
  - Responsive table designs
  - Cross-platform synchronization
  
  PHASE 5: PLATFORM FEATURES (Week 9-10)
  - Web: PWA capabilities, keyboard shortcuts
  - macOS: Menu bar integration, native dialogs
  - Windows: System notifications, taskbar
  - Android: Widgets, share intents, deep links
  
  PHASE 6: TESTING & OPTIMIZATION (Week 11-12)
  - Cross-platform testing
  - Performance optimization per platform
  - Accessibility compliance
  - User experience validation
  ''';
  
  static const String platformSpecificFeatures = '''
  🎯 PLATFORM-SPECIFIC FEATURES:
  
  📱 WEB EDITION:
  - Progressive Web App (PWA) capabilities
  - Offline data synchronization
  - Browser notifications
  - Keyboard shortcuts (Ctrl+K for search)
  - Right-click context menus
  - Drag & drop file uploads
  - Full-screen mode support
  
  🖥️ macOS EDITION:
  - Native macOS menu bar
  - Spotlight search integration
  - Touch Bar support (if available)
  - Dark mode automatic switching
  - Trackpad gesture support
  - iCloud sync integration
  - Retina display optimization
  
  💻 WINDOWS EDITION:
  - Fluent Design System elements
  - Windows notifications
  - Taskbar jump lists
  - Cortana integration potential
  - Windows Hello authentication
  - Live tiles (if applicable)
  - Snap assist compatibility
  
  📱 ANDROID EDITION:
  - Material You dynamic theming
  - Home screen widgets
  - Android share intents
  - Biometric authentication
  - Adaptive icon support
  - Android Auto integration
  - Google Assistant shortcuts
  
  📱 iOS EDITION (Future):
  - iOS Design Language
  - Siri shortcuts integration
  - Widget support
  - Face ID / Touch ID
  - Handoff continuation
  - Apple Watch companion
  - AirDrop sharing
  ''';
}
