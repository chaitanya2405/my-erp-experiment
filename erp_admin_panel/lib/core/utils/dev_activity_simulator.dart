import '../services/web_code_tracker.dart';

/// Simulates realistic development activities for demonstration
class DevActivitySimulator {
  static final DevActivitySimulator _instance = DevActivitySimulator._internal();
  factory DevActivitySimulator() => _instance;
  DevActivitySimulator._internal();

  final List<Map<String, dynamic>> _simulatedActivities = [
    {
      'type': ActivityType.create,
      'file': 'pos_analytics_screen.dart',
      'description': 'Created POS Analytics screen with chart visualization',
      'details': {'lines_added': 625, 'module': 'POS Management'},
      'tags': ['pos', 'analytics', 'charts'],
    },
    {
      'type': ActivityType.edit,
      'file': 'web_code_tracker.dart',
      'description': 'Implemented web-compatible code tracking system',
      'details': {'lines_added': 450, 'features': ['memory_storage', 'activity_tracking']},
      'tags': ['core', 'tracking', 'web'],
    },
    {
      'type': ActivityType.refactor,
      'file': 'main.dart',
      'description': 'Refactored app initialization with tracker integration',
      'details': {'lines_modified': 15, 'improvements': ['initialization', 'web_compatibility']},
      'tags': ['main', 'initialization', 'refactor'],
    },
    {
      'type': ActivityType.edit,
      'file': 'pos_providers.dart',
      'description': 'Enhanced POS state management with analytics support',
      'details': {'methods_added': 3, 'analytics_integration': true},
      'tags': ['providers', 'state_management', 'pos'],
    },
    {
      'type': ActivityType.debug,
      'file': 'web_code_tracker.dart',
      'description': 'Fixed Map.take() error for web compatibility',
      'details': {'bug_type': 'method_not_found', 'solution': 'entries.take()'},
      'tags': ['debug', 'web_compatibility', 'fix'],
    },
    {
      'type': ActivityType.build,
      'file': 'pubspec.yaml',
      'description': 'Updated dependencies for chart visualization',
      'details': {'dependencies_added': ['fl_chart'], 'version_updates': 2},
      'tags': ['dependencies', 'build', 'charts'],
    },
  ];

  /// Simulate realistic development activities over time
  Future<void> simulateRealisticDevSession() async {
    final tracker = WebCodeTracker();
    
    print('🎭 Simulating realistic development session...');
    
    // Simulate activities with realistic timing
    for (int i = 0; i < _simulatedActivities.length; i++) {
      final activity = _simulatedActivities[i];
      
      // Add some time variation to make it realistic
      final minutesAgo = (i * 15) + (i * 5); // Spread over time
      final timestamp = DateTime.now().subtract(Duration(minutes: minutesAgo));
      
      await tracker.trackActivity(
        activity['type'] as ActivityType,
        activity['file'] as String,
        activity['description'] as String,
        details: activity['details'] as Map<String, dynamic>,
        tags: List<String>.from(activity['tags']),
      );
      
      // Modify the timestamp to make it look realistic
      if (tracker.getRecentActivities().isNotEmpty) {
        final lastActivity = tracker.getRecentActivities().first;
        // In a real implementation, you'd modify the internal timestamp
      }
      
      print('📝 Simulated: ${activity['description']}');
      
      // Small delay to make it feel more realistic
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Add some recent real-time activities
    await _simulateRecentActivities(tracker);
    
    print('✅ Development session simulation complete!');
  }

  Future<void> _simulateRecentActivities(WebCodeTracker tracker) async {
    // Recent activities (last 30 minutes)
    final recentActivities = [
      {
        'type': ActivityType.navigation,
        'file': 'pos_analytics_screen.dart',
        'description': 'Navigated to POS Analytics dashboard',
        'details': {'route': '/pos/analytics', 'session_time': '5m'},
        'tags': ['navigation', 'pos'],
        'minutesAgo': 2,
      },
      {
        'type': ActivityType.edit,
        'file': 'pos_analytics_screen.dart',
        'description': 'Added comprehensive activity tracking to analytics screen',
        'details': {'lines_added': 45, 'tracking_points': 5},
        'tags': ['edit', 'tracking', 'analytics'],
        'minutesAgo': 5,
      },
    ];

    for (final activity in recentActivities) {
      await tracker.trackActivity(
        activity['type'] as ActivityType,
        activity['file'] as String,
        activity['description'] as String,
        details: activity['details'] as Map<String, dynamic>,
        tags: List<String>.from((activity['tags'] as List?) ?? []),
      );
    }
  }

  /// Generate random development activity for ongoing simulation
  Future<void> generateRandomActivity() async {
    final tracker = WebCodeTracker();
    
    final randomActivities = [
      {
        'type': ActivityType.edit,
        'file': 'customer_order_screen.dart',
        'description': 'Improved order validation logic',
        'details': {'validation_rules': 3, 'error_handling': true},
        'tags': ['edit', 'validation', 'orders'],
      },
      {
        'type': ActivityType.refactor,
        'file': 'inventory_service.dart',
        'description': 'Optimized inventory level calculations',
        'details': {'performance_gain': '25%', 'methods_optimized': 4},
        'tags': ['refactor', 'performance', 'inventory'],
      },
      {
        'type': ActivityType.debug,
        'file': 'payment_processor.dart',
        'description': 'Fixed payment gateway timeout issue',
        'details': {'timeout_ms': 5000, 'retry_logic': true},
        'tags': ['debug', 'payment', 'timeout'],
      },
      {
        'type': ActivityType.create,
        'file': 'notification_service.dart',
        'description': 'Added real-time notification system',
        'details': {'notification_types': 5, 'real_time': true},
        'tags': ['create', 'notifications', 'real_time'],
      },
    ];

    final random = DateTime.now().millisecond % randomActivities.length;
    final activity = randomActivities[random];

    await tracker.trackActivity(
      activity['type'] as ActivityType,
      activity['file'] as String,
      activity['description'] as String,
      details: activity['details'] as Map<String, dynamic>,
      tags: List<String>.from((activity['tags'] as List?) ?? []),
    );

    print('🔄 Generated random activity: ${activity['description']}');
  }

  /// Simulate a bug fix workflow
  Future<void> simulateBugFixWorkflow() async {
    final tracker = WebCodeTracker();
    
    print('🐛 Simulating bug fix workflow...');
    
    // Bug discovery
    await tracker.trackActivity(
      ActivityType.debug,
      'payment_screen.dart',
      'Discovered payment calculation bug',
      details: {'severity': 'high', 'affected_users': 'all'},
      tags: ['bug', 'payment', 'critical'],
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Investigation
    await tracker.trackActivity(
      ActivityType.debug,
      'payment_service.dart',
      'Investigated payment calculation logic',
      details: {'files_reviewed': 3, 'root_cause': 'rounding_error'},
      tags: ['investigation', 'debug', 'payment'],
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Fix implementation
    await tracker.trackActivity(
      ActivityType.edit,
      'payment_service.dart',
      'Fixed decimal precision in payment calculations',
      details: {'lines_changed': 8, 'precision_digits': 2},
      tags: ['fix', 'payment', 'precision'],
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Testing
    await tracker.trackActivity(
      ActivityType.test,
      'payment_service_test.dart',
      'Added unit tests for payment calculation fix',
      details: {'test_cases': 5, 'edge_cases': 3},
      tags: ['test', 'payment', 'validation'],
    );

    print('✅ Bug fix workflow simulation complete!');
  }

  /// Simulate feature development workflow
  Future<void> simulateFeatureWorkflow() async {
    final tracker = WebCodeTracker();
    
    print('🚀 Simulating feature development workflow...');
    
    // Planning
    await tracker.trackActivity(
      ActivityType.system,
      'feature_spec.md',
      'Planned loyalty points feature implementation',
      details: {'story_points': 8, 'estimated_days': 3},
      tags: ['planning', 'feature', 'loyalty'],
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Model creation
    await tracker.trackActivity(
      ActivityType.create,
      'loyalty_point.dart',
      'Created loyalty points data model',
      details: {'properties': 6, 'validation': true},
      tags: ['create', 'model', 'loyalty'],
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Service implementation
    await tracker.trackActivity(
      ActivityType.create,
      'loyalty_service.dart',
      'Implemented loyalty points calculation service',
      details: {'methods': 4, 'business_rules': 3},
      tags: ['create', 'service', 'loyalty'],
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // UI implementation
    await tracker.trackActivity(
      ActivityType.create,
      'loyalty_screen.dart',
      'Built loyalty points management UI',
      details: {'widgets': 8, 'animations': 2},
      tags: ['create', 'ui', 'loyalty'],
    );

    print('✅ Feature development workflow simulation complete!');
  }
}
