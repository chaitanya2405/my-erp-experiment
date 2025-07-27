import 'package:flutter/material.dart';
import '../design_system/business_themes.dart';
import '../design_system/business_colors.dart';
import '../platform/platform_detector.dart';

/// 🔄 **Template Migration Wrapper**
/// 
/// Safe migration wrapper that allows gradual adoption of the business template system:
/// - Wraps existing widgets with business template styling
/// - Provides backward compatibility
/// - Enables A/B testing during migration
/// - Preserves existing functionality while adding professional styling
class TemplateMigrationWrapper extends StatelessWidget {
  /// The existing widget to wrap
  final Widget child;
  
  /// Whether to apply business template styling
  final bool useBusinessTemplate;
  
  /// Template migration mode
  final MigrationMode mode;
  
  /// Custom business theme
  final ThemeData? businessTheme;
  
  /// Migration analytics callback
  final VoidCallback? onMigrationAnalytics;
  
  /// Error fallback widget
  final Widget? errorFallback;
  
  const TemplateMigrationWrapper({
    Key? key,
    required this.child,
    this.useBusinessTemplate = true,
    this.mode = MigrationMode.gradual,
    this.businessTheme,
    this.onMigrationAnalytics,
    this.errorFallback,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Track migration analytics
    if (onMigrationAnalytics != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMigrationAnalytics!();
      });
    }
    
    // Handle different migration modes
    switch (mode) {
      case MigrationMode.legacy:
        return child;
        
      case MigrationMode.businessOnly:
        return _buildBusinessWrapper(context);
        
      case MigrationMode.gradual:
        return useBusinessTemplate 
            ? _buildBusinessWrapper(context)
            : child;
            
      case MigrationMode.comparison:
        return _buildComparisonView(context);
    }
  }
  
  Widget _buildBusinessWrapper(BuildContext context) {
    try {
      return Theme(
        data: businessTheme ?? BusinessThemes.lightTheme,
        child: Container(
          color: BusinessColors.backgroundColor(context),
          child: child,
        ),
      );
    } catch (e) {
      debugPrint('Business template error: $e');
      return errorFallback ?? child;
    }
  }
  
  Widget _buildComparisonView(BuildContext context) {
    return PlatformResponsiveBuilder(
      builder: (context, platformInfo) {
        if (platformInfo.isDesktop) {
          // Side-by-side comparison on desktop
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.grey[200],
                      child: const Text('Legacy Design'),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: BusinessColors.primaryBlue.withOpacity(0.1),
                      child: const Text('Business Template'),
                    ),
                    Expanded(child: _buildBusinessWrapper(context)),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Toggle view on mobile/tablet
          return _buildToggleComparisonView(context);
        }
      },
    );
  }
  
  Widget _buildToggleComparisonView(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool showBusiness = false;
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showBusiness ? 'Business Template' : 'Legacy Design',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Switch(
                    value: showBusiness,
                    onChanged: (value) {
                      setState(() {
                        showBusiness = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: showBusiness 
                  ? _buildBusinessWrapper(context)
                  : child,
            ),
          ],
        );
      },
    );
  }
}

/// 🔧 **Legacy Component Adapter**
/// 
/// Adapts existing components to use business template styling
class LegacyComponentAdapter {
  /// Adapt existing AppBar to business style
  static PreferredSizeWidget adaptAppBar(
    PreferredSizeWidget appBar, {
    bool useBusiness = true,
  }) {
    if (!useBusiness || appBar is! AppBar) return appBar;
    
    final originalAppBar = appBar as AppBar;
    
    return AppBar(
      title: originalAppBar.title,
      actions: originalAppBar.actions,
      leading: originalAppBar.leading,
      backgroundColor: BusinessColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: false,
    );
  }
  
  /// Adapt existing Card to business style
  static Widget adaptCard(
    Widget card, {
    bool useBusiness = true,
    EdgeInsets? padding,
  }) {
    if (!useBusiness) return card;
    
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: card,
      ),
    );
  }
  
  /// Adapt existing Button to business style
  static Widget adaptButton(
    Widget button, {
    bool useBusiness = true,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    if (!useBusiness || button is! ElevatedButton) return button;
    
    final originalButton = button as ElevatedButton;
    
    return ElevatedButton(
      onPressed: originalButton.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? BusinessColors.primaryBlue,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: originalButton.child,
    );
  }
  
  /// Adapt existing TextField to business style
  static Widget adaptTextField(
    Widget textField, {
    bool useBusiness = true,
  }) {
    if (!useBusiness || textField is! TextField) return textField;
    
    final originalField = textField as TextField;
    
    return TextField(
      controller: originalField.controller,
      decoration: originalField.decoration?.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ) ?? InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: originalField.onChanged,
      onSubmitted: originalField.onSubmitted,
    );
  }
  
  /// Adapt existing ListTile to business style
  static Widget adaptListTile(
    ListTile listTile, {
    bool useBusiness = true,
  }) {
    if (!useBusiness) return listTile;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: listTile.leading,
        title: listTile.title,
        subtitle: listTile.subtitle,
        trailing: listTile.trailing,
        onTap: listTile.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// 📋 **Migration Progress Tracker**
/// 
/// Tracks and reports on migration progress
class MigrationProgressTracker {
  static final Map<String, MigrationStatus> _moduleStatus = {};
  static final List<MigrationEvent> _events = [];
  
  /// Mark a module as migrated
  static void markModuleMigrated(String moduleName) {
    _moduleStatus[moduleName] = MigrationStatus.completed;
    _events.add(MigrationEvent(
      moduleName: moduleName,
      status: MigrationStatus.completed,
      timestamp: DateTime.now(),
    ));
  }
  
  /// Mark a module as in progress
  static void markModuleInProgress(String moduleName) {
    _moduleStatus[moduleName] = MigrationStatus.inProgress;
    _events.add(MigrationEvent(
      moduleName: moduleName,
      status: MigrationStatus.inProgress,
      timestamp: DateTime.now(),
    ));
  }
  
  /// Mark a module as having issues
  static void markModuleIssues(String moduleName, String issue) {
    _moduleStatus[moduleName] = MigrationStatus.issues;
    _events.add(MigrationEvent(
      moduleName: moduleName,
      status: MigrationStatus.issues,
      timestamp: DateTime.now(),
      details: issue,
    ));
  }
  
  /// Get migration progress
  static MigrationProgress getProgress() {
    final total = _moduleStatus.length;
    final completed = _moduleStatus.values
        .where((status) => status == MigrationStatus.completed)
        .length;
    final inProgress = _moduleStatus.values
        .where((status) => status == MigrationStatus.inProgress)
        .length;
    final issues = _moduleStatus.values
        .where((status) => status == MigrationStatus.issues)
        .length;
    
    return MigrationProgress(
      totalModules: total,
      completedModules: completed,
      inProgressModules: inProgress,
      issuesModules: issues,
      progressPercentage: total > 0 ? (completed / total) * 100 : 0,
      events: List.from(_events),
    );
  }
  
  /// Get migration report
  static String getReport() {
    final progress = getProgress();
    final buffer = StringBuffer();
    
    buffer.writeln('=== BUSINESS TEMPLATE MIGRATION REPORT ===');
    buffer.writeln('Total Modules: ${progress.totalModules}');
    buffer.writeln('Completed: ${progress.completedModules}');
    buffer.writeln('In Progress: ${progress.inProgressModules}');
    buffer.writeln('Issues: ${progress.issuesModules}');
    buffer.writeln('Progress: ${progress.progressPercentage.toStringAsFixed(1)}%');
    buffer.writeln();
    
    buffer.writeln('Module Status:');
    _moduleStatus.forEach((module, status) {
      buffer.writeln('  $module: ${status.name}');
    });
    
    if (_events.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Recent Events:');
      for (final event in _events.take(10)) {
        buffer.writeln('  ${event.timestamp}: ${event.moduleName} - ${event.status.name}');
        if (event.details != null) {
          buffer.writeln('    Details: ${event.details}');
        }
      }
    }
    
    return buffer.toString();
  }
  
  /// Clear all tracking data
  static void reset() {
    _moduleStatus.clear();
    _events.clear();
  }
}

/// 🎯 **Module Migration Helper**
/// 
/// Utilities to help migrate specific module types
class ModuleMigrationHelper {
  /// Get migration checklist for a module type
  static List<String> getMigrationChecklist(ModuleType moduleType) {
    final baseChecklist = [
      'Update theme to BusinessThemes.lightTheme',
      'Replace colors with BusinessColors palette',
      'Update spacing to BusinessSpacing system',
      'Apply BusinessTypography styles',
      'Test on all target platforms',
      'Verify accessibility compliance',
    ];
    
    switch (moduleType) {
      case ModuleType.dashboard:
        return [
          ...baseChecklist,
          'Implement KPI cards with BusinessKPICard',
          'Add responsive chart layouts',
          'Include quick actions panel',
          'Add recent activity feed',
        ];
        
      case ModuleType.dataList:
        return [
          ...baseChecklist,
          'Implement search functionality',
          'Add filtering and sorting',
          'Include bulk operations',
          'Add pagination or virtual scrolling',
          'Implement export capabilities',
        ];
        
      case ModuleType.form:
        return [
          ...baseChecklist,
          'Add form validation',
          'Implement auto-save',
          'Include file upload support',
          'Add progressive disclosure',
          'Implement multi-step wizard if needed',
        ];
        
      case ModuleType.analytics:
        return [
          ...baseChecklist,
          'Implement interactive charts',
          'Add drill-down capabilities',
          'Include export and sharing',
          'Add real-time data updates',
          'Implement responsive chart adaptation',
        ];
        
      case ModuleType.detail:
        return [
          ...baseChecklist,
          'Add related information panels',
          'Include action buttons and workflows',
          'Add history and activity tracking',
          'Implement print and export options',
        ];
    }
  }
  
  /// Get estimated migration time
  static Duration getEstimatedMigrationTime(ModuleType moduleType, ModuleComplexity complexity) {
    final baseHours = switch (complexity) {
      ModuleComplexity.simple => 4,
      ModuleComplexity.medium => 8,
      ModuleComplexity.complex => 16,
    };
    
    final multiplier = switch (moduleType) {
      ModuleType.dashboard => 1.5,
      ModuleType.dataList => 1.2,
      ModuleType.form => 1.0,
      ModuleType.analytics => 2.0,
      ModuleType.detail => 0.8,
    };
    
    return Duration(hours: (baseHours * multiplier).round());
  }
}

// ============================================================================
// 📊 ENUMS AND DATA CLASSES
// ============================================================================

enum MigrationMode {
  legacy,        // Use original styling only
  businessOnly,  // Use business template only
  gradual,       // Conditional migration based on flag
  comparison,    // Show both versions for comparison
}

enum MigrationStatus {
  notStarted,
  inProgress,
  completed,
  issues,
}

enum ModuleType {
  dashboard,
  dataList,
  form,
  analytics,
  detail,
}

enum ModuleComplexity {
  simple,
  medium,
  complex,
}

class MigrationEvent {
  final String moduleName;
  final MigrationStatus status;
  final DateTime timestamp;
  final String? details;
  
  MigrationEvent({
    required this.moduleName,
    required this.status,
    required this.timestamp,
    this.details,
  });
}

class MigrationProgress {
  final int totalModules;
  final int completedModules;
  final int inProgressModules;
  final int issuesModules;
  final double progressPercentage;
  final List<MigrationEvent> events;
  
  MigrationProgress({
    required this.totalModules,
    required this.completedModules,
    required this.inProgressModules,
    required this.issuesModules,
    required this.progressPercentage,
    required this.events,
  });
}
