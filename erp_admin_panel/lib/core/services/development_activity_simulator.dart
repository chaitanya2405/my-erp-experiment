import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'web_code_tracker.dart';

/// Simulates realistic development activities across the entire ERP ecosystem
class DevelopmentActivitySimulator {
  static final DevelopmentActivitySimulator _instance = DevelopmentActivitySimulator._internal();
  factory DevelopmentActivitySimulator() => _instance;
  DevelopmentActivitySimulator._internal();

  Timer? _simulationTimer;
  final Random _random = Random();
  final WebCodeTracker _tracker = WebCodeTracker();

  /// All ERP modules and their related files
  static const Map<String, List<String>> _moduleFiles = {
    // Core Infrastructure
    'Core System': [
      'main.dart',
      'app_router.dart',
      'app_theme.dart',
      'auth_service.dart',
      'firebase_service.dart',
      'rbac_service.dart',
      'web_code_tracker.dart',
      'auto_code_tracker.dart',
      'code_activity_tracker.dart',
    ],
    
    // Business Modules
    'POS Management': [
      'pos_analytics_screen.dart',
      'pos_transaction_screen.dart',
      'pos_dashboard.dart',
      'pos_providers.dart',
      'pos_service.dart',
      'cash_register_screen.dart',
      'receipt_printer.dart',
    ],
    
    'Inventory Management': [
      'inventory_dashboard.dart',
      'stock_management_screen.dart',
      'low_stock_alerts.dart',
      'inventory_providers.dart',
      'warehouse_management.dart',
      'barcode_scanner.dart',
      'stock_adjustment_screen.dart',
    ],
    
    'Product Management': [
      'product_catalog_screen.dart',
      'product_details_screen.dart',
      'category_management.dart',
      'pricing_engine.dart',
      'product_providers.dart',
      'bulk_import_screen.dart',
      'product_images_manager.dart',
    ],
    
    'Customer Management': [
      'customer_dashboard.dart',
      'customer_profile_screen.dart',
      'loyalty_program.dart',
      'customer_providers.dart',
      'crm_analytics.dart',
      'customer_orders_screen.dart',
      'feedback_system.dart',
    ],
    
    'Supplier Management': [
      'supplier_dashboard.dart',
      'supplier_profile_screen.dart',
      'supplier_orders.dart',
      'supplier_providers.dart',
      'procurement_workflow.dart',
      'vendor_evaluation.dart',
      'payment_terms_manager.dart',
    ],
    
    'Store Management': [
      'store_dashboard.dart',
      'multi_store_manager.dart',
      'store_settings_screen.dart',
      'store_providers.dart',
      'branch_management.dart',
      'staff_scheduling.dart',
      'store_analytics.dart',
    ],
    
    'User Management': [
      'user_dashboard.dart',
      'role_management_screen.dart',
      'permissions_screen.dart',
      'user_providers.dart',
      'staff_management.dart',
      'access_control.dart',
      'audit_logs.dart',
    ],
    
    'Purchase Orders': [
      'purchase_order_screen.dart',
      'po_workflow.dart',
      'po_approval_system.dart',
      'po_providers.dart',
      'automated_reordering.dart',
      'supplier_integration.dart',
      'cost_analysis.dart',
    ],
    
    'Reports & Analytics': [
      'business_intelligence.dart',
      'sales_reports.dart',
      'inventory_reports.dart',
      'financial_dashboard.dart',
      'custom_reports.dart',
      'data_export_service.dart',
      'kpi_tracking.dart',
    ],
    
    // Future Modules (planned)
    'Accounting & Finance': [
      'ledger_management.dart',
      'invoice_generator.dart',
      'tax_calculation.dart',
      'payment_processing.dart',
      'financial_reports.dart',
      'budget_planning.dart',
    ],
    
    'E-commerce Integration': [
      'online_store_sync.dart',
      'marketplace_connector.dart',
      'shipping_integration.dart',
      'payment_gateway.dart',
      'seo_optimization.dart',
    ],
    
    'Mobile Apps': [
      'customer_mobile_app.dart',
      'supplier_mobile_app.dart',
      'staff_mobile_app.dart',
      'delivery_tracking.dart',
    ],
    
    'API & Integrations': [
      'rest_api_service.dart',
      'webhook_manager.dart',
      'third_party_integrations.dart',
      'sync_service.dart',
    ],
  };

  /// Development activity templates for realistic simulation
  static const List<Map<String, dynamic>> _activityTemplates = [
    // Feature Development
    {
      'type': ActivityType.create,
      'descriptions': [
        'Created new {feature} component',
        'Added {feature} functionality',
        'Implemented {feature} screen',
        'Built {feature} service',
        'Created {feature} provider',
      ],
      'features': [
        'dashboard widget', 'data visualization', 'user interface', 'API endpoint',
        'form validation', 'search functionality', 'filtering system', 'export feature',
        'notification system', 'real-time updates', 'batch processing', 'report generator'
      ]
    },
    
    // Bug Fixes
    {
      'type': ActivityType.edit,
      'descriptions': [
        'Fixed {bug} in {module}',
        'Resolved {issue} bug',
        'Corrected {problem} issue',
        'Updated {component} to fix {bug}',
      ],
      'bugs': [
        'data loading issue', 'UI rendering problem', 'validation error', 'sync issue',
        'performance bottleneck', 'memory leak', 'null pointer exception', 'race condition'
      ],
      'issues': [
        'authentication', 'data persistence', 'API response', 'form submission',
        'navigation', 'state management', 'error handling', 'data validation'
      ],
      'problems': [
        'infinite loading', 'blank screen', 'incorrect calculations', 'missing data',
        'slow performance', 'crash on startup', 'network timeout', 'cache invalidation'
      ]
    },
    
    // Refactoring
    {
      'type': ActivityType.refactor,
      'descriptions': [
        'Refactored {component} for better {improvement}',
        'Optimized {module} {aspect}',
        'Restructured {component} architecture',
        'Improved {feature} implementation',
      ],
      'improvements': [
        'performance', 'maintainability', 'readability', 'scalability',
        'testability', 'reusability', 'modularity', 'extensibility'
      ],
      'aspects': [
        'data handling', 'state management', 'error handling', 'user experience',
        'code structure', 'API integration', 'caching strategy', 'validation logic'
      ]
    },
    
    // Testing
    {
      'type': ActivityType.test,
      'descriptions': [
        'Added unit tests for {component}',
        'Created integration tests for {feature}',
        'Updated test coverage for {module}',
        'Fixed failing tests in {component}',
      ]
    },
    
    // Documentation
    {
      'type': ActivityType.edit,
      'descriptions': [
        'Updated documentation for {module}',
        'Added API documentation for {service}',
        'Created user guide for {feature}',
        'Updated README for {component}',
      ]
    },
  ];

  /// Start automatic activity simulation
  void startSimulation({Duration interval = const Duration(minutes: 2)}) {
    if (_simulationTimer?.isActive == true) return;
    
    print('🤖 Starting development activity simulation...');
    
    _simulationTimer = Timer.periodic(interval, (_) async {
      await _generateRandomActivity();
    });
    
    // Generate some initial activities
    _generateInitialActivities();
  }

  /// Stop activity simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    print('⏹️ Development activity simulation stopped');
  }

  /// Toggle simulation on/off
  void toggleSimulation() {
    if (_simulationTimer?.isActive ?? false) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  /// Generate initial set of activities to populate the dashboard
  void _generateInitialActivities() async {
    print('📝 Generating initial development activities...');
    
    // Generate activities for the last few hours
    final now = DateTime.now();
    
    for (int i = 0; i < 25; i++) {
      final activityTime = now.subtract(Duration(
        minutes: _random.nextInt(480), // Last 8 hours
        seconds: _random.nextInt(60),
      ));
      
      await _generateActivityAtTime(activityTime);
      
      // Small delay to avoid overwhelming the system
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    print('✅ Initial activities generated');
  }

  /// Generate a random development activity
  Future<void> _generateRandomActivity() async {
    await _generateActivityAtTime(DateTime.now());
  }

  /// Generate an activity at a specific time
  Future<void> _generateActivityAtTime(DateTime timestamp) async {
    // Select random module and file
    final moduleNames = _moduleFiles.keys.toList();
    final selectedModule = moduleNames[_random.nextInt(moduleNames.length)];
    final moduleFiles = _moduleFiles[selectedModule]!;
    final selectedFile = moduleFiles[_random.nextInt(moduleFiles.length)];
    
    // Select random activity template
    final template = _activityTemplates[_random.nextInt(_activityTemplates.length)];
    final activityType = template['type'] as ActivityType;
    
    // Generate description
    final descriptions = template['descriptions'] as List<String>;
    String description = descriptions[_random.nextInt(descriptions.length)];
    
    // Replace placeholders with random values
    description = _replacePlaceholders(description, template, selectedModule);
    
    // Generate additional context
    final details = _generateActivityDetails(activityType, selectedModule, selectedFile);
    
    // Create custom activity with timestamp
    final activity = CodeActivity(
      id: '${timestamp.millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      type: activityType,
      filePath: 'lib/modules/${_getModulePath(selectedModule)}/$selectedFile',
      description: description,
      timestamp: timestamp,
      details: details,
      tags: _generateTags(selectedModule, activityType),
    );
    
    // Add directly to tracker's activity list
    _tracker.activities.add(activity);
    _tracker.updateFileTracking(activity.filePath, activity);
    
    if (kDebugMode) {
      print('📝 ${activityType.name}: ${_getFileName(activity.filePath)} - $description');
    }
  }

  /// Replace placeholders in description templates
  String _replacePlaceholders(String description, Map<String, dynamic> template, String module) {
    String result = description;
    
    // Replace {module} placeholder
    result = result.replaceAll('{module}', module);
    result = result.replaceAll('{component}', _generateComponentName());
    result = result.replaceAll('{feature}', _getRandomFromList(template['features'] ?? ['feature']));
    result = result.replaceAll('{bug}', _getRandomFromList(template['bugs'] ?? ['issue']));
    result = result.replaceAll('{issue}', _getRandomFromList(template['issues'] ?? ['problem']));
    result = result.replaceAll('{problem}', _getRandomFromList(template['problems'] ?? ['issue']));
    result = result.replaceAll('{improvement}', _getRandomFromList(template['improvements'] ?? ['quality']));
    result = result.replaceAll('{aspect}', _getRandomFromList(template['aspects'] ?? ['functionality']));
    result = result.replaceAll('{service}', '${module.toLowerCase().replaceAll(' ', '_')}_service');
    
    return result;
  }

  /// Generate realistic activity details
  Map<String, dynamic> _generateActivityDetails(ActivityType type, String module, String file) {
    final details = <String, dynamic>{
      'module': module,
      'file': file,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    switch (type) {
      case ActivityType.create:
        details.addAll({
          'lines_added': _random.nextInt(100) + 10,
          'complexity': ['low', 'medium', 'high'][_random.nextInt(3)],
        });
        break;
        
      case ActivityType.edit:
        details.addAll({
          'lines_changed': _random.nextInt(50) + 5,
          'lines_added': _random.nextInt(20),
          'lines_removed': _random.nextInt(15),
        });
        break;
        
      case ActivityType.refactor:
        details.addAll({
          'lines_moved': _random.nextInt(200) + 50,
          'files_affected': _random.nextInt(5) + 1,
          'improvement_type': ['performance', 'maintainability', 'readability'][_random.nextInt(3)],
        });
        break;
        
      case ActivityType.test:
        details.addAll({
          'test_cases_added': _random.nextInt(10) + 1,
          'coverage_increase': '${_random.nextInt(15) + 5}%',
        });
        break;
        
      default:
        break;
    }
    
    return details;
  }

  /// Generate relevant tags for the activity
  List<String> _generateTags(String module, ActivityType type) {
    final tags = <String>[
      module.toLowerCase().replaceAll(' ', '_'),
      type.name,
    ];
    
    // Add contextual tags
    final contextTags = [
      'frontend', 'backend', 'database', 'api', 'ui', 'ux', 
      'performance', 'security', 'testing', 'documentation'
    ];
    
    // Add 1-3 random context tags
    final numTags = _random.nextInt(3) + 1;
    for (int i = 0; i < numTags; i++) {
      final tag = contextTags[_random.nextInt(contextTags.length)];
      if (!tags.contains(tag)) {
        tags.add(tag);
      }
    }
    
    return tags;
  }

  /// Generate realistic component names
  String _generateComponentName() {
    final components = [
      'widget', 'screen', 'service', 'provider', 'controller',
      'repository', 'model', 'view', 'component', 'utility'
    ];
    return components[_random.nextInt(components.length)];
  }

  /// Get random item from list
  String _getRandomFromList(List<String> list) {
    return list[_random.nextInt(list.length)];
  }

  /// Convert module name to file path
  String _getModulePath(String moduleName) {
    return moduleName.toLowerCase()
        .replaceAll(' & ', '_')
        .replaceAll(' ', '_')
        .replaceAll('management', 'mgmt');
  }

  /// Get filename from path
  String _getFileName(String filePath) {
    if (filePath.contains('/')) {
      return filePath.split('/').last;
    }
    return filePath;
  }

  /// Manually trigger activity generation for testing
  void generateTestActivities({int count = 10}) async {
    print('🧪 Generating $count test activities...');
    
    for (int i = 0; i < count; i++) {
      _generateRandomActivity();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    print('✅ Test activities generated');
  }

  /// Generate activities for a specific module
  void generateModuleActivities(String moduleName, {int count = 5}) async {
    if (!_moduleFiles.containsKey(moduleName)) {
      print('❌ Module "$moduleName" not found');
      return;
    }
    
    print('📝 Generating activities for $moduleName...');
    
    final moduleFiles = _moduleFiles[moduleName]!;
    
    for (int i = 0; i < count; i++) {
      final selectedFile = moduleFiles[_random.nextInt(moduleFiles.length)];
      final template = _activityTemplates[_random.nextInt(_activityTemplates.length)];
      final activityType = template['type'] as ActivityType;
      
      final descriptions = template['descriptions'] as List<String>;
      String description = descriptions[_random.nextInt(descriptions.length)];
      description = _replacePlaceholders(description, template, moduleName);
      
      await _tracker.trackActivity(
        activityType,
        'lib/modules/${_getModulePath(moduleName)}/$selectedFile',
        description,
        details: _generateActivityDetails(activityType, moduleName, selectedFile),
        tags: _generateTags(moduleName, activityType),
      );
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    print('✅ Activities generated for $moduleName');
  }

  /// Get all available modules
  List<String> getAvailableModules() {
    return _moduleFiles.keys.toList();
  }

  /// Get statistics about simulated activities
  Map<String, dynamic> getSimulationStats() {
    final activities = _tracker.getRecentActivities(limit: 1000);
    
    final moduleStats = <String, int>{};
    final typeStats = <String, int>{};
    
    for (final activity in activities) {
      // Count by module (extract from file path)
      for (final module in _moduleFiles.keys) {
        final modulePath = _getModulePath(module);
        if (activity.filePath.contains(modulePath)) {
          moduleStats[module] = (moduleStats[module] ?? 0) + 1;
          break;
        }
      }
      
      // Count by type
      typeStats[activity.type.name] = (typeStats[activity.type.name] ?? 0) + 1;
    }
    
    return {
      'total_activities': activities.length,
      'modules_active': moduleStats.length,
      'module_breakdown': moduleStats,
      'activity_type_breakdown': typeStats,
      'simulation_running': _simulationTimer?.isActive ?? false,
    };
  }
}
