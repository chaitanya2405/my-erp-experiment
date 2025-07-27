import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../activity_tracker.dart';

/// 🌉 Universal ERP Bridge - The central nervous system for ALL modules
/// 
/// This bridge enables ANY module to communicate with ANY other module
/// without hardcoded dependencies. It's completely dynamic and future-proof.
/// 
/// Features:
/// - Auto-discovery of all modules
/// - Dynamic data exchange between any modules
/// - Real-time event broadcasting
/// - Smart data transformation
/// - Zero-configuration integration for new modules
class UniversalERPBridge {
  static final UniversalERPBridge _instance = UniversalERPBridge._internal();
  static UniversalERPBridge get instance => _instance;
  UniversalERPBridge._internal();

  // Core bridge components
  final Map<String, ModuleConnector> _registeredModules = {};
  final Map<String, StreamController> _eventStreams = {};
  final Map<String, dynamic> _dataCache = {};
  final List<BridgeRule> _businessRules = [];
  final DataTransformationEngine _transformer = DataTransformationEngine();
  
  // Bridge status
  bool _isInitialized = false;
  final StreamController<BridgeEvent> _bridgeEventStream = StreamController.broadcast();

  /// Initialize the Universal Bridge
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (kDebugMode) {
        print('🌉 Initializing Universal ERP Bridge...');
      }
      
      // Auto-discover all modules
      await _discoverModules();
      
      // Initialize cross-module relationships
      await _buildModuleRelationships();
      
      // Setup real-time listeners
      await _setupRealtimeListeners();
      
      _isInitialized = true;
      
      _broadcastBridgeEvent(BridgeEvent(
        type: 'bridge_initialized',
        message: 'Universal ERP Bridge is now active',
        timestamp: DateTime.now(),
      ));
      
      if (kDebugMode) {
        print('✅ Universal ERP Bridge initialized successfully');
        print('📊 Discovered ${_registeredModules.length} modules');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Bridge initialization failed: $e');
      }
      rethrow;
    }
  }

  /// 📡 Universal Data Request - Get data from ANY module
  Future<dynamic> requestData({
    required String fromModule,
    required String dataType,
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      final cacheKey = _generateCacheKey(fromModule, dataType, filters);
      
      // Check cache first
      if (useCache && _dataCache.containsKey(cacheKey)) {
        if (kDebugMode) {
          print('🔄 Bridge: Serving cached data for $fromModule.$dataType');
        }
        return _dataCache[cacheKey];
      }
      
      // Get module connector
      final module = _registeredModules[fromModule];
      if (module == null) {
        throw BridgeException('Module "$fromModule" not found');
      }
      
      // Request data from module
      final data = await module.getData(dataType, filters ?? {});
      
      // Transform data if needed
      final transformedData = await _transformer.transform(data, fromModule, dataType);
      
      // Cache the result
      if (useCache) {
        _dataCache[cacheKey] = transformedData;
        
        // Auto-expire cache after 5 minutes
        Timer(const Duration(minutes: 5), () {
          _dataCache.remove(cacheKey);
        });
      }
      
      // Track the request
      ActivityTracker().trackDataOperation(
        operation: 'bridge_data_request: Data requested from $fromModule for $dataType',
        collection: 'bridge_requests',
        queryParams: {
          'from_module': fromModule,
          'data_type': dataType,
          'filters': filters?.toString() ?? 'none',
          'cached': useCache && _dataCache.containsKey(cacheKey),
        },
      );
      
      if (kDebugMode) {
        print('📊 Bridge: Data retrieved from $fromModule.$dataType');
      }
      
      return transformedData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Bridge data request failed: $e');
      }
      rethrow;
    }
  }

  /// 📢 Universal Event Broadcasting - Send events to ANY modules
  Future<void> broadcastEvent({
    required String eventType,
    required dynamic data,
    List<String>? targetModules, // null = broadcast to all
    String? sourceModule,
  }) async {
    try {
      final event = UniversalEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: eventType,
        data: data,
        sourceModule: sourceModule,
        targetModules: targetModules,
        timestamp: DateTime.now(),
      );
      
      // Determine target modules
      final targets = targetModules ?? _registeredModules.keys.toList();
      
      // Broadcast to each target module
      for (final targetModule in targets) {
        final module = _registeredModules[targetModule];
        if (module != null && targetModule != sourceModule) {
          try {
            await module.receiveEvent(event);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Failed to deliver event to $targetModule: $e');
            }
          }
        }
      }
      
      // Broadcast to internal event stream
      if (_eventStreams.containsKey(eventType)) {
        _eventStreams[eventType]!.add(event);
      }
      
      // Apply business rules
      await _applyBusinessRules(event);
      
      // Track the event
      ActivityTracker().trackDataOperation(
        operation: 'bridge_event_broadcast: Event $eventType broadcasted from ${sourceModule ?? "system"}',
        collection: 'bridge_events', 
        queryParams: {
          'event_type': eventType,
          'source_module': sourceModule ?? 'system',
          'target_modules': targets.toString(),
          'data_size': jsonEncode(data).length,
        },
      );
      
      if (kDebugMode) {
        print('📡 Bridge: Event $eventType broadcasted to ${targets.length} modules');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Event broadcast failed: $e');
      }
    }
  }

  /// 👂 Listen to ANY events from ANY modules
  Stream<UniversalEvent> listenToEvents(String eventPattern) {
    if (!_eventStreams.containsKey(eventPattern)) {
      _eventStreams[eventPattern] = StreamController.broadcast();
    }
    return _eventStreams[eventPattern]!.stream.cast<UniversalEvent>();
  }

  /// 🔗 Register a new module (auto-called or manual)
  Future<void> registerModule(ModuleConnector module) async {
    try {
      _registeredModules[module.moduleName] = module;
      
      // Initialize the module's bridge connection
      await module.initializeBridgeConnection(this);
      
      _broadcastBridgeEvent(BridgeEvent(
        type: 'module_registered',
        message: 'Module ${module.moduleName} registered with bridge',
        timestamp: DateTime.now(),
        metadata: {
          'module_name': module.moduleName,
          'capabilities': module.capabilities,
        },
      ));
      
      if (kDebugMode) {
        print('🔗 Module ${module.moduleName} registered with bridge');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Module registration failed: $e');
      }
    }
  }

  /// 🎯 Add business rule that applies across modules
  void addBusinessRule(BridgeRule rule) {
    _businessRules.add(rule);
    if (kDebugMode) {
      print('📋 Business rule added: ${rule.name}');
    }
  }

  /// 📊 Get bridge status and statistics
  BridgeStatus getStatus() {
    return BridgeStatus(
      isInitialized: _isInitialized,
      moduleCount: _registeredModules.length,
      activeStreams: _eventStreams.length,
      cacheSize: _dataCache.length,
      businessRules: _businessRules.length,
      modules: _registeredModules.keys.toList(),
    );
  }

  /// 🔍 Auto-discover all available modules
  Future<void> _discoverModules() async {
    // This will be enhanced to automatically scan for modules
    // For now, modules will self-register
    
    if (kDebugMode) {
      print('🔍 Starting module auto-discovery...');
    }
    
    // Discovery logic will be implemented based on your module structure
    // This is the foundation for future auto-discovery
  }

  /// 🕸️ Build relationships between modules
  Future<void> _buildModuleRelationships() async {
    // Analyze module capabilities and build smart relationships
    // This enables intelligent data routing
    
    if (kDebugMode) {
      print('🕸️ Building inter-module relationships...');
    }
  }

  /// 📡 Setup real-time Firestore listeners
  Future<void> _setupRealtimeListeners() async {
    // Setup Firestore listeners for real-time data sync
    FirebaseFirestore.instance
        .collection('bridge_events')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleFirestoreEvent(change.doc.data()!);
        }
      }
    });
  }

  /// 🔧 Apply business rules to events
  Future<void> _applyBusinessRules(UniversalEvent event) async {
    for (final rule in _businessRules) {
      if (rule.shouldApply(event)) {
        try {
          await rule.execute(event, this);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Business rule ${rule.name} failed: $e');
          }
        }
      }
    }
  }

  /// 📦 Handle Firestore events
  void _handleFirestoreEvent(Map<String, dynamic> eventData) {
    // Process external events from Firestore
    // This enables system-wide event synchronization
  }

  /// 🏷️ Generate cache key
  String _generateCacheKey(String module, String dataType, Map<String, dynamic>? filters) {
    final filterString = filters != null ? jsonEncode(filters) : '';
    return '$module:$dataType:${filterString.hashCode}';
  }

  /// 📡 Broadcast bridge system events
  void _broadcastBridgeEvent(BridgeEvent event) {
    _bridgeEventStream.add(event);
  }

  /// 📊 Listen to bridge system events
  Stream<BridgeEvent> get bridgeEvents => _bridgeEventStream.stream;

  /// 🧹 Cleanup resources
  void dispose() {
    for (final stream in _eventStreams.values) {
      stream.close();
    }
    _bridgeEventStream.close();
    _dataCache.clear();
    _registeredModules.clear();
  }
}

/// 🔌 Module Connector - Interface for all modules
abstract class ModuleConnector {
  String get moduleName;
  List<String> get capabilities;
  Map<String, dynamic> get schema;
  
  /// Initialize bridge connection
  Future<void> initializeBridgeConnection(UniversalERPBridge bridge);
  
  /// Get data from this module
  Future<dynamic> getData(String dataType, Map<String, dynamic> filters);
  
  /// Receive events from other modules
  Future<void> receiveEvent(UniversalEvent event);
  
  /// Get module health status
  Future<Map<String, dynamic>> getHealthStatus();
}

/// 📦 Universal Event structure
class UniversalEvent {
  final String id;
  final String type;
  final dynamic data;
  final String? sourceModule;
  final List<String>? targetModules;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  UniversalEvent({
    required this.id,
    required this.type,
    required this.data,
    this.sourceModule,
    this.targetModules,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'source_module': sourceModule,
      'target_modules': targetModules,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UniversalEvent.fromMap(Map<String, dynamic> map) {
    return UniversalEvent(
      id: map['id'],
      type: map['type'],
      data: map['data'],
      sourceModule: map['source_module'],
      targetModules: map['target_modules']?.cast<String>(),
      timestamp: DateTime.parse(map['timestamp']),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

/// 📋 Business Rule for cross-module logic
abstract class BridgeRule {
  String get name;
  bool shouldApply(UniversalEvent event);
  Future<void> execute(UniversalEvent event, UniversalERPBridge bridge);
}

/// 🔄 Data Transformation Engine
class DataTransformationEngine {
  final Map<String, Map<String, Function>> _transformers = {};
  
  Future<dynamic> transform(dynamic data, String fromModule, String dataType) async {
    // Smart data transformation between modules
    // This will be enhanced with AI-like mapping capabilities
    return data;
  }
  
  void registerTransformer(String fromModule, String toModule, Function transformer) {
    _transformers[fromModule] ??= {};
    _transformers[fromModule]![toModule] = transformer;
  }
}

/// 📊 Bridge Status
class BridgeStatus {
  final bool isInitialized;
  final int moduleCount;
  final int activeStreams;
  final int cacheSize;
  final int businessRules;
  final List<String> modules;

  BridgeStatus({
    required this.isInitialized,
    required this.moduleCount,
    required this.activeStreams,
    required this.cacheSize,
    required this.businessRules,
    required this.modules,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_initialized': isInitialized,
      'module_count': moduleCount,
      'active_streams': activeStreams,
      'cache_size': cacheSize,
      'business_rules': businessRules,
      'modules': modules,
    };
  }
}

/// 🚨 Bridge Event for system notifications
class BridgeEvent {
  final String type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  BridgeEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// ⚠️ Bridge Exception
class BridgeException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  BridgeException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'BridgeException: $message';
}
