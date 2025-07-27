import 'package:flutter/material.dart';
import '../design_system/business_colors.dart';
import '../design_system/business_spacing.dart';
import '../design_system/business_typography.dart';
import '../platform/platform_detector.dart';

/// 🏢 **Business Card Component**
/// 
/// Professional, cross-platform card component featuring:
/// - Consistent design across all platforms
/// - Hover effects and interactions
/// - Flexible content layouts
/// - Professional styling
/// - Accessibility support
class BusinessCard extends StatefulWidget {
  /// Card title (optional)
  final String? title;
  
  /// Card subtitle (optional)
  final String? subtitle;
  
  /// Main content widget
  final Widget? content;
  
  /// Leading widget (icon, avatar, etc.)
  final Widget? leading;
  
  /// Trailing widget (actions, arrow, etc.)
  final Widget? trailing;
  
  /// Footer widget (optional)
  final Widget? footer;
  
  /// Card padding
  final EdgeInsets? padding;
  
  /// Card margin
  final EdgeInsets? margin;
  
  /// Card background color
  final Color? backgroundColor;
  
  /// Card elevation
  final double? elevation;
  
  /// Border radius
  final double? borderRadius;
  
  /// On tap callback
  final VoidCallback? onTap;
  
  /// On long press callback
  final VoidCallback? onLongPress;
  
  /// Whether card is selectable
  final bool selectable;
  
  /// Whether card is selected
  final bool selected;
  
  /// Card width
  final double? width;
  
  /// Card height
  final double? height;
  
  /// Whether to show hover effects
  final bool showHoverEffects;
  
  /// Whether to show shadow
  final bool showShadow;
  
  /// Card border
  final Border? border;
  
  /// Gradient background
  final Gradient? gradient;
  
  /// Hero tag for navigation animations
  final String? heroTag;
  
  const BusinessCard({
    Key? key,
    this.title,
    this.subtitle,
    this.content,
    this.leading,
    this.trailing,
    this.footer,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.selectable = false,
    this.selected = false,
    this.width,
    this.height,
    this.showHoverEffects = true,
    this.showShadow = true,
    this.border,
    this.gradient,
    this.heroTag,
  }) : super(key: key);
  
  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> 
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? BusinessSpacing.cardElevation,
      end: (widget.elevation ?? BusinessSpacing.cardElevation) + 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleHoverChange(bool hovering) {
    if (!widget.showHoverEffects) return;
    
    setState(() {
      _isHovered = hovering;
    });
    
    if (hovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }
  
  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }
  
  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformInfo = PlatformDetector.getPlatformInfo(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine card styling based on state
    final cardColor = widget.backgroundColor ?? 
        BusinessColors.cardColor(context);
    
    final effectiveElevation = widget.showShadow 
        ? (widget.elevation ?? BusinessSpacing.cardElevation)
        : 0.0;
    
    final effectivePadding = widget.padding ?? 
        BusinessSpacing.cardPadding(context);
    
    final effectiveMargin = widget.margin ?? 
        BusinessSpacing.all(BusinessSpacing.marginSM);
    
    final effectiveBorderRadius = widget.borderRadius ?? 
        BusinessSpacing.cardRadius;
    
    // Build card content
    Widget cardContent = _buildCardContent(context);
    
    // Wrap with interactive elements if needed
    if (widget.onTap != null || widget.onLongPress != null) {
      cardContent = InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: cardContent,
      );
    }
    
    // Build the card
    Widget card = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = _isPressed ? 0.96 : 
            (_isHovered ? _scaleAnimation.value : 1.0);
        
        final elevation = _isHovered ? _elevationAnimation.value : effectiveElevation;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.gradient == null ? cardColor : null,
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: widget.border ?? (widget.selected 
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    )
                  : null),
              boxShadow: elevation > 0 ? [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                  blurRadius: elevation * 2,
                  spreadRadius: elevation / 2,
                  offset: Offset(0, elevation),
                ),
              ] : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: effectivePadding,
                  child: cardContent,
                ),
              ),
            ),
          ),
        );
      },
    );
    
    // Add hover detection for desktop
    if (platformInfo.isDesktop && widget.showHoverEffects) {
      card = MouseRegion(
        onEnter: (_) => _handleHoverChange(true),
        onExit: (_) => _handleHoverChange(false),
        child: card,
      );
    }
    
    // Add hero animation if tag provided
    if (widget.heroTag != null) {
      card = Hero(
        tag: widget.heroTag!,
        child: card,
      );
    }
    
    // Add margin
    return Padding(
      padding: effectiveMargin,
      child: card,
    );
  }
  
  Widget _buildCardContent(BuildContext context) {
    final children = <Widget>[];
    
    // Header section (title, subtitle, leading, trailing)
    if (widget.title != null || widget.subtitle != null || 
        widget.leading != null || widget.trailing != null) {
      children.add(_buildHeader(context));
    }
    
    // Main content
    if (widget.content != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: BusinessSpacing.gapMD));
      }
      children.add(widget.content!);
    }
    
    // Footer
    if (widget.footer != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: BusinessSpacing.gapMD));
      }
      children.add(widget.footer!);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    final hasTitle = widget.title != null || widget.subtitle != null;
    final hasLeading = widget.leading != null;
    final hasTrailing = widget.trailing != null;
    
    if (!hasTitle && !hasLeading && !hasTrailing) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        // Leading widget
        if (hasLeading) ...[
          widget.leading!,
          const SizedBox(width: BusinessSpacing.gapMD),
        ],
        
        // Title and subtitle
        if (hasTitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: BusinessTypography.titleMediumStyle(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.subtitle != null) ...[
                  if (widget.title != null)
                    const SizedBox(height: BusinessSpacing.gapXS),
                  Text(
                    widget.subtitle!,
                    style: BusinessTypography.bodySmallStyle(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        
        // Trailing widget
        if (hasTrailing) ...[
          const SizedBox(width: BusinessSpacing.gapMD),
          widget.trailing!,
        ],
      ],
    );
  }
}

/// 📊 **KPI Card Component**
/// 
/// Specialized card for displaying key performance indicators
class BusinessKPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  
  const BusinessKPICard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.showTrend = true,
    this.trendValue,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final trendColor = _getTrendColor();
    final trendIcon = _getTrendIcon();
    
    return BusinessCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      width: BusinessSpacing.kpiCardMinWidth,
      height: BusinessSpacing.kpiCardHeight,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with icon and title
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? BusinessColors.primaryBlue,
                  size: BusinessSpacing.iconLG,
                ),
                const SizedBox(width: BusinessSpacing.gapSM),
              ],
              Expanded(
                child: Text(
                  title,
                  style: BusinessTypography.labelMediumStyle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Value
          Text(
            value,
            style: BusinessTypography.displaySmallStyle(context).copyWith(
              fontWeight: BusinessTypography.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Subtitle and trend
          Row(
            children: [
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    style: BusinessTypography.bodySmallStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              if (showTrend && (trend != null || trendValue != null)) ...[
                Icon(
                  trendIcon,
                  color: trendColor,
                  size: BusinessSpacing.iconSM,
                ),
                const SizedBox(width: BusinessSpacing.gapXS),
                Text(
                  trend ?? '${trendValue!.toStringAsFixed(1)}%',
                  style: BusinessTypography.labelSmallStyle(context).copyWith(
                    color: trendColor,
                    fontWeight: BusinessTypography.semiBold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getTrendColor() {
    if (trendValue != null) {
      return trendValue! >= 0 
          ? BusinessColors.success 
          : BusinessColors.error;
    }
    
    if (trend != null) {
      final lowerTrend = trend!.toLowerCase();
      if (lowerTrend.contains('up') || lowerTrend.contains('+')) {
        return BusinessColors.success;
      } else if (lowerTrend.contains('down') || lowerTrend.contains('-')) {
        return BusinessColors.error;
      }
    }
    
    return BusinessColors.info;
  }
  
  IconData _getTrendIcon() {
    if (trendValue != null) {
      return trendValue! >= 0 
          ? Icons.trending_up 
          : Icons.trending_down;
    }
    
    if (trend != null) {
      final lowerTrend = trend!.toLowerCase();
      if (lowerTrend.contains('up') || lowerTrend.contains('+')) {
        return Icons.trending_up;
      } else if (lowerTrend.contains('down') || lowerTrend.contains('-')) {
        return Icons.trending_down;
      }
    }
    
    return Icons.trending_flat;
  }
}

/// 📋 **Info Card Component**
/// 
/// Card for displaying structured information
class BusinessInfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> information;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  
  const BusinessInfoCard({
    Key? key,
    required this.title,
    required this.information,
    this.leading,
    this.actions,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BusinessCard(
      title: title,
      leading: leading,
      onTap: onTap,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...information.entries.map((entry) =>
            Padding(
              padding: const EdgeInsets.symmetric(vertical: BusinessSpacing.paddingXS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      entry.key,
                      style: BusinessTypography.labelMediumStyle(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: BusinessTypography.bodyMediumStyle(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      footer: actions != null && actions!.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            )
          : null,
    );
  }
}
