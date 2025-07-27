import 'package:flutter/material.dart';
import '../design_system/business_colors.dart';
import '../design_system/business_spacing.dart';
import '../design_system/business_typography.dart';
import '../components/business_card.dart';
import '../platform/platform_detector.dart';

/// 📊 **Business Dashboard Template**
/// 
/// Professional executive dashboard template featuring:
/// - KPI overview cards
/// - Interactive charts and analytics
/// - Quick action panels
/// - Recent activity feeds
/// - Responsive layout across all platforms
/// - Role-based content adaptation
class BusinessDashboardTemplate extends StatefulWidget {
  /// Dashboard title
  final String title;
  
  /// KPI figures to display
  final List<KPIFigure>? kpiFigures;
  
  /// Chart widgets
  final List<ChartWidget>? charts;
  
  /// Quick action items
  final List<QuickAction>? quickActions;
  
  /// Recent activity items
  final List<ActivityItem>? recentActivity;
  
  /// Custom header widget
  final Widget? customHeader;
  
  /// Custom footer widget
  final Widget? customFooter;
  
  /// Whether to show search bar
  final bool showSearchBar;
  
  /// Search callback
  final ValueChanged<String>? onSearch;
  
  /// Refresh callback
  final VoidCallback? onRefresh;
  
  /// Settings callback
  final VoidCallback? onSettings;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Custom app bar actions
  final List<Widget>? appBarActions;
  
  const BusinessDashboardTemplate({
    Key? key,
    required this.title,
    this.kpiFigures,
    this.charts,
    this.quickActions,
    this.recentActivity,
    this.customHeader,
    this.customFooter,
    this.showSearchBar = true,
    this.onSearch,
    this.onRefresh,
    this.onSettings,
    this.backgroundColor,
    this.appBarActions,
  }) : super(key: key);
  
  @override
  State<BusinessDashboardTemplate> createState() => _BusinessDashboardTemplateState();
}

class _BusinessDashboardTemplateState extends State<BusinessDashboardTemplate> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchExpanded = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return PlatformResponsiveBuilder(
      builder: (context, platformInfo) {
        return Scaffold(
          backgroundColor: widget.backgroundColor ?? BusinessColors.surfaceColor(context),
          appBar: _buildAppBar(context, platformInfo),
          body: _buildBody(context, platformInfo),
          floatingActionButton: _buildFloatingActionButton(context, platformInfo),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, PlatformInfo platformInfo) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        // Search toggle
        if (widget.showSearchBar && !_isSearchExpanded)
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchExpanded = true;
              });
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        
        // Refresh button
        if (widget.onRefresh != null)
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        
        // Settings button
        if (widget.onSettings != null)
          IconButton(
            onPressed: widget.onSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        
        // Custom actions
        ...?widget.appBarActions,
        
        const SizedBox(width: BusinessSpacing.gapSM),
      ],
      bottom: _isSearchExpanded ? _buildSearchBar(context) : null,
    );
  }
  
  PreferredSizeWidget _buildSearchBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: BusinessSpacing.all(BusinessSpacing.paddingMD),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search dashboard...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            if (widget.onSearch != null) {
                              widget.onSearch!('');
                            }
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
                onChanged: widget.onSearch,
              ),
            ),
            const SizedBox(width: BusinessSpacing.gapSM),
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, PlatformInfo platformInfo) {
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: BusinessSpacing.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header
            if (widget.customHeader != null) ...[
              widget.customHeader!,
              const SizedBox(height: BusinessSpacing.gapLG),
            ],
            
            // Welcome section
            _buildWelcomeSection(context, platformInfo),
            
            const SizedBox(height: BusinessSpacing.gapXL),
            
            // KPI section
            if (widget.kpiFigures != null && widget.kpiFigures!.isNotEmpty) ...[
              _buildKPISection(context, platformInfo),
              const SizedBox(height: BusinessSpacing.gapXL),
            ],
            
            // Charts section
            if (widget.charts != null && widget.charts!.isNotEmpty) ...[
              _buildChartsSection(context, platformInfo),
              const SizedBox(height: BusinessSpacing.gapXL),
            ],
            
            // Quick actions and recent activity
            _buildActionAndActivitySection(context, platformInfo),
            
            // Custom footer
            if (widget.customFooter != null) ...[
              const SizedBox(height: BusinessSpacing.gapXL),
              widget.customFooter!,
            ],
            
            // Bottom padding
            const SizedBox(height: BusinessSpacing.gapXXL),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection(BuildContext context, PlatformInfo platformInfo) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }
    
    return BusinessCard(
      backgroundColor: BusinessColors.primaryBlue,
      content: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      greetingIcon,
                      color: Colors.white,
                      size: BusinessSpacing.iconMD,
                    ),
                    const SizedBox(width: BusinessSpacing.gapSM),
                    Text(
                      greeting,
                      style: BusinessTypography.titleMediumStyle(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BusinessSpacing.gapSM),
                Text(
                  'Welcome back to your dashboard',
                  style: BusinessTypography.headlineSmallStyle(context).copyWith(
                    color: Colors.white,
                    fontWeight: BusinessTypography.bold,
                  ),
                ),
                const SizedBox(height: BusinessSpacing.gapSM),
                Text(
                  'Here\'s what\'s happening with your business today.',
                  style: BusinessTypography.bodyMediumStyle(context).copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (!platformInfo.isMobile) ...[
            const SizedBox(width: BusinessSpacing.gapLG),
            Icon(
              Icons.dashboard,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildKPISection(BuildContext context, PlatformInfo platformInfo) {
    final columns = BusinessSpacing.getColumnCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 4,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Key Performance Indicators',
              style: BusinessTypography.titleLargeStyle(context),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // Navigate to detailed analytics
              },
              icon: const Icon(Icons.analytics),
              label: const Text('View Details'),
            ),
          ],
        ),
        
        const SizedBox(height: BusinessSpacing.gapMD),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: BusinessSpacing.gridGap(context),
            mainAxisSpacing: BusinessSpacing.gridGap(context),
            childAspectRatio: 1.4,
          ),
          itemCount: widget.kpiFigures!.length,
          itemBuilder: (context, index) {
            final kpi = widget.kpiFigures![index];
            return BusinessKPICard(
              title: kpi.title,
              value: kpi.value,
              subtitle: kpi.subtitle,
              icon: kpi.icon,
              iconColor: kpi.iconColor,
              trend: kpi.trend,
              trendValue: kpi.trendValue,
              onTap: kpi.onTap,
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildChartsSection(BuildContext context, PlatformInfo platformInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Analytics & Charts',
              style: BusinessTypography.titleLargeStyle(context),
            ),
            const Spacer(),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'day', label: Text('Day')),
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
              ],
              selected: {'week'},
              onSelectionChanged: (Set<String> selection) {
                // Handle time period change
              },
            ),
          ],
        ),
        
        const SizedBox(height: BusinessSpacing.gapMD),
        
        if (platformInfo.isDesktop) ...[
          // Desktop: side-by-side charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.charts!.length && i < 2; i++) ...[
                Expanded(child: widget.charts![i]),
                if (i == 0 && widget.charts!.length > 1)
                  const SizedBox(width: BusinessSpacing.gapMD),
              ],
            ],
          ),
          if (widget.charts!.length > 2) ...[
            const SizedBox(height: BusinessSpacing.gapMD),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 2; i < widget.charts!.length && i < 4; i++) ...[
                  Expanded(child: widget.charts![i]),
                  if (i == 2 && widget.charts!.length > 3)
                    const SizedBox(width: BusinessSpacing.gapMD),
                ],
              ],
            ),
          ],
        ] else ...[
          // Mobile/Tablet: stacked charts
          ...widget.charts!.map((chart) => Padding(
            padding: const EdgeInsets.only(bottom: BusinessSpacing.gapMD),
            child: chart,
          )),
        ],
      ],
    );
  }
  
  Widget _buildActionAndActivitySection(BuildContext context, PlatformInfo platformInfo) {
    if (platformInfo.isDesktop) {
      // Desktop: side-by-side layout
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          if (widget.quickActions != null && widget.quickActions!.isNotEmpty) ...[
            Expanded(
              flex: 1,
              child: _buildQuickActionsCard(context),
            ),
            const SizedBox(width: BusinessSpacing.gapMD),
          ],
          
          // Recent activity
          if (widget.recentActivity != null && widget.recentActivity!.isNotEmpty)
            Expanded(
              flex: 2,
              child: _buildRecentActivityCard(context),
            ),
        ],
      );
    } else {
      // Mobile/Tablet: stacked layout
      return Column(
        children: [
          // Quick actions
          if (widget.quickActions != null && widget.quickActions!.isNotEmpty) ...[
            _buildQuickActionsCard(context),
            const SizedBox(height: BusinessSpacing.gapMD),
          ],
          
          // Recent activity
          if (widget.recentActivity != null && widget.recentActivity!.isNotEmpty)
            _buildRecentActivityCard(context),
        ],
      );
    }
  }
  
  Widget _buildQuickActionsCard(BuildContext context) {
    return BusinessCard(
      title: 'Quick Actions',
      trailing: IconButton(
        onPressed: () {
          // Show all actions
        },
        icon: const Icon(Icons.more_horiz),
      ),
      content: Column(
        children: widget.quickActions!.map((action) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: BusinessSpacing.paddingXS),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: action.color?.withOpacity(0.1) ?? BusinessColors.primaryBlue.withOpacity(0.1),
                child: Icon(
                  action.icon,
                  color: action.color ?? BusinessColors.primaryBlue,
                ),
              ),
              title: Text(
                action.title,
                style: BusinessTypography.titleSmallStyle(context),
              ),
              subtitle: action.subtitle != null
                  ? Text(
                      action.subtitle!,
                      style: BusinessTypography.bodySmallStyle(context),
                    )
                  : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: action.onTap,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildRecentActivityCard(BuildContext context) {
    return BusinessCard(
      title: 'Recent Activity',
      trailing: TextButton(
        onPressed: () {
          // Show all activity
        },
        child: const Text('View All'),
      ),
      content: Column(
        children: widget.recentActivity!.take(5).map((activity) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: BusinessSpacing.paddingSM),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: activity.color?.withOpacity(0.1) ?? BusinessColors.info.withOpacity(0.1),
                  child: Icon(
                    activity.icon,
                    size: 16,
                    color: activity.color ?? BusinessColors.info,
                  ),
                ),
                const SizedBox(width: BusinessSpacing.gapMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: BusinessTypography.bodyMediumStyle(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (activity.subtitle != null) ...[
                        const SizedBox(height: BusinessSpacing.gapXS),
                        Text(
                          activity.subtitle!,
                          style: BusinessTypography.bodySmallStyle(context),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  activity.timestamp,
                  style: BusinessTypography.labelSmallStyle(context),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget? _buildFloatingActionButton(BuildContext context, PlatformInfo platformInfo) {
    if (platformInfo.isMobile) {
      return FloatingActionButton(
        onPressed: () {
          // Show quick add menu
          _showQuickAddMenu(context);
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
  
  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: BusinessSpacing.all(BusinessSpacing.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Add',
              style: BusinessTypography.titleLargeStyle(context),
            ),
            const SizedBox(height: BusinessSpacing.gapLG),
            ...?widget.quickActions?.map((action) => ListTile(
              leading: Icon(action.icon),
              title: Text(action.title),
              onTap: () {
                Navigator.pop(context);
                action.onTap?.call();
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 📊 DATA MODELS
// ============================================================================

/// KPI figure data model
class KPIFigure {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final double? trendValue;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  
  const KPIFigure({
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendValue,
    this.icon,
    this.iconColor,
    this.onTap,
  });
}

/// Chart widget wrapper
class ChartWidget extends StatelessWidget {
  final String title;
  final Widget chart;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  
  const ChartWidget({
    Key? key,
    required this.title,
    required this.chart,
    this.onTap,
    this.actions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BusinessCard(
      title: title,
      trailing: actions != null && actions!.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            )
          : null,
      onTap: onTap,
      content: SizedBox(
        height: 300,
        child: chart,
      ),
    );
  }
}

/// Quick action data model
class QuickAction {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  
  const QuickAction({
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  });
}

/// Activity item data model
class ActivityItem {
  final String title;
  final String? subtitle;
  final String timestamp;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  
  const ActivityItem({
    required this.title,
    this.subtitle,
    required this.timestamp,
    required this.icon,
    this.color,
    this.onTap,
  });
}
