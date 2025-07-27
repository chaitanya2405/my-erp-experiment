import 'dart:async';
import 'package:flutter/foundation.dart';
import '../bridge_helper.dart';
import '../../../services/farmer_service.dart';

/// 🌾 Farmer Management Bridge Connector - Following Product Management Pattern
class FarmerManagementConnector {
  static const String moduleName = 'farmer_management';
  
  /// Connect the Farmer Management module to Universal ERP Bridge
  static Future<void> connect() async {
    try {
      await BridgeHelper.connectModule(
        moduleName: moduleName,
        capabilities: [
          'farmer_administration',
          'farmer_registration',
          'farmer_profile_management',
          'farm_data_management',
          'crop_management',
          'farmer_analytics',
          'farmer_search',
          'farmer_create',
          'farmer_update',
          'farmer_delete',
          'farmer_view',
          'location_tracking',
          'organic_certification',
          'financial_tracking',
        ],
        schema: {
          'farmers': {
            'type': 'collection',
            'fields': {
              'id': 'string',
              'farmer_code': 'string',
              'full_name': 'string',
              'mobile_number': 'string',
              'email': 'string',
              'village': 'string',
              'district': 'string',
              'state': 'string',
              'pincode': 'string',
              'total_land_area': 'number',
              'soil_type': 'string',
              'primary_crops': 'array',
              'secondary_crops': 'array',
              'is_organic_certified': 'boolean',
              'status': 'string',
              'created_at': 'timestamp',
              'updated_at': 'timestamp',
            },
            'indexes': ['farmer_code', 'village', 'district', 'state'],
          },
        },
        dataProvider: _handleDataRequest,
        eventHandler: _handleEvent,
      );
      
      if (kDebugMode) {
        print('✅ Farmer Management module connected to Universal Bridge');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to connect Farmer Management module: $e');
      }
      rethrow;
    }
  }

  /// Handle data requests from other modules
  static Future<dynamic> _handleDataRequest(String dataType, Map<String, dynamic> filters) async {
    try {
      switch (dataType) {
        case 'farmers':
          final storeId = filters['store_id'] as String?;
          final searchTerm = filters['search_term'] as String?;
          final limit = filters['limit'] as int? ?? 50;
          
          if (searchTerm != null && searchTerm.isNotEmpty) {
            return await FarmerService.instance.findFarmers(
              searchTerm: searchTerm,
              limit: limit,
            );
          } else {
            return await FarmerService.getAllFarmers(limit: limit, storeId: storeId);
          }
          
        case 'farmer_by_id':
          final farmerId = filters['farmer_id'] as String?;
          if (farmerId == null) throw Exception('Farmer ID required');
          return await FarmerService.getFarmerById(farmerId);
          
        case 'farmers_by_crop':
          final crop = filters['crop'] as String?;
          if (crop == null) throw Exception('Crop required');
          return await FarmerService.instance.getFarmersByCrop(crop);
          
        case 'farmers_by_location':
          final state = filters['state'] as String?;
          final district = filters['district'] as String?;
          final village = filters['village'] as String?;
          return await FarmerService.instance.getFarmersByLocation(
            state: state,
            district: district,
            village: village,
          );
          
        case 'farmer_analytics':
          return await FarmerService.instance.getFarmerAnalytics();
          
        case 'farmer_performance':
          final farmerId = filters['farmer_id'] as String?;
          if (farmerId == null) throw Exception('Farmer ID required');
          return await FarmerService.instance.getFarmerPerformance(farmerId);
          
        case 'crop_calendar':
          final farmerId = filters['farmer_id'] as String?;
          if (farmerId == null) throw Exception('Farmer ID required');
          return await FarmerService.instance.getCropCalendar(farmerId);
          
        default:
          throw Exception('Unknown data type: $dataType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Farmer Management data request failed: $e');
      }
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Handle events from other modules
  static Future<void> _handleEvent(dynamic event) async {
    try {
      final eventType = event.type as String;
      final eventData = event.data as Map<String, dynamic>;
      
      switch (eventType) {
        case 'inventory_low_stock':
          await _handleLowStockEvent(eventData);
          break;
          
        case 'order_created':
          await _handleOrderCreated(eventData);
          break;
          
        case 'payment_processed':
          await _handlePaymentProcessed(eventData);
          break;
          
        case 'harvest_season_started':
          await _handleHarvestSeasonStarted(eventData);
          break;
          
        default:
          if (kDebugMode) {
            print('🌾 Farmer Management: Received unknown event $eventType');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Farmer Management event handling failed: $e');
      }
    }
  }

  // Event handlers
  static Future<void> _handleLowStockEvent(Map<String, dynamic> data) async {
    // Notify farmers who supply the low stock product
    final productName = data['product_name'] as String?;
    
    if (productName != null) {
      final farmers = await FarmerService.instance.getFarmersByCrop(productName);
      
      for (final farmer in farmers) {
        if (kDebugMode) {
          print('📱 Notifying farmer ${farmer.fullName} about procurement opportunity for $productName');
        }
      }
    }
  }
  
  static Future<void> _handleOrderCreated(Map<String, dynamic> data) async {
    // Track orders that involve farmer products
    final orderId = data['order_id'] as String?;
    final products = data['products'] as List?;
    
    if (products != null) {
      for (final product in products) {
        final productName = product['name'] as String?;
        if (productName != null) {
          final farmers = await FarmerService.instance.getFarmersByCrop(productName);
          for (final farmer in farmers) {
            // Update delivery tracking
            if (kDebugMode) {
              print('📦 Tracking order $orderId for farmer ${farmer.fullName}');
            }
          }
        }
      }
    }
  }
  
  static Future<void> _handlePaymentProcessed(Map<String, dynamic> data) async {
    // Update farmer payment records
    final farmerId = data['farmer_id'] as String?;
    final amount = data['amount'] as double?;
    
    if (farmerId != null && amount != null) {
      final farmer = await FarmerService.getFarmerById(farmerId);
      if (farmer != null) {
        // Update payment tracking
        if (kDebugMode) {
          print('💰 Payment of ₹$amount processed for farmer ${farmer.fullName}');
        }
      }
    }
  }
  
  static Future<void> _handleHarvestSeasonStarted(Map<String, dynamic> data) async {
    // Send harvest reminders and preparations
    final season = data['season'] as String?;
    final crop = data['crop'] as String?;
    
    if (crop != null) {
      final farmers = await FarmerService.instance.getFarmersByCrop(crop);
      
      for (final farmer in farmers) {
        if (kDebugMode) {
          print('🌾 Notifying farmer ${farmer.fullName} about $crop harvest season');
        }
      }
    }
  }
}
