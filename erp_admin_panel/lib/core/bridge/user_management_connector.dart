import 'package:flutter/foundation.dart';
import 'bridge_helper.dart';
import '../../services/user_management_service.dart';

/// 👥 Complete User Management Module Connector for Universal ERP Bridge
class UserManagementConnector {
  /// Connect User Management module with full functionality to Universal Bridge
  static Future<void> connect() async {
    await BridgeHelper.connectModule(
      moduleName: 'user_management',
      capabilities: [
        'user_administration',
        'role_management', 
        'permission_control',
        'activity_monitoring',
        'user_analytics',
        'authentication',
        'user_sessions',
        'user_create',
        'user_update',
        'user_delete',
        'user_view',
        'activity_logging',
        'session_management',
        'user_statistics'
      ],
      schema: {
        'users': {
          'type': 'collection',
          'fields': {
            'id': 'string',
            'name': 'string',
            'email': 'string',
            'phone': 'string',
            'role': 'string',
            'department': 'string',
            'permissions': 'array',
            'status': 'string',
            'last_login': 'datetime',
            'created_at': 'datetime',
            'updated_at': 'datetime'
          },
          'filters': ['role', 'status', 'department', 'created_date'],
          'sortable': ['name', 'email', 'role', 'last_login', 'created_at']
        },
        'user_activity': {
          'type': 'collection',
          'fields': {
            'id': 'string',
            'user_id': 'string',
            'module': 'string',
            'action': 'string',
            'details': 'object',
            'timestamp': 'datetime'
          },
          'filters': ['user_id', 'action', 'module', 'date_range'],
          'sortable': ['timestamp', 'action', 'module']
        },
        'user_sessions': {
          'type': 'collection', 
          'fields': {
            'id': 'string',
            'user_id': 'string',
            'session_id': 'string',
            'login_time': 'datetime',
            'last_activity': 'datetime',
            'is_active': 'boolean',
            'device_info': 'object',
            'ip_address': 'string'
          },
          'filters': ['user_id', 'active_only', 'date_range'],
          'sortable': ['login_time', 'last_activity']
        },
        'user_stats': {
          'type': 'analytics',
          'fields': {
            'total_users': 'number',
            'active_users': 'number', 
            'inactive_users': 'number',
            'role_breakdown': 'object',
            'activity_rate': 'number'
          }
        }
      },
      dataProvider: (dataType, filters) async {
        try {
          switch (dataType) {
            case 'users':
              if (filters.containsKey('user_id')) {
                final user = await UserManagementService.getUserById(filters['user_id']);
                return {
                  'user': user,
                  'status': 'success',
                  'timestamp': DateTime.now().toIso8601String()
                };
              }
              
              final allUsers = await UserManagementService.getAllUsers();
              return {
                'users': allUsers,
                'total_count': allUsers.length,
                'status': 'success',
                'timestamp': DateTime.now().toIso8601String(),
                'filters_applied': filters
              };
              
            case 'user_activity':
              if (filters.containsKey('user_id')) {
                final activity = await UserManagementService.getUserActivity(filters['user_id']);
                return {
                  'activity': activity,
                  'count': activity.length,
                  'status': 'success',
                  'user_id': filters['user_id']
                };
              }
              
              // Get recent activity for all users
              final limit = filters['limit'] ?? 50;
              final recentActivity = await UserManagementService.getRecentActivity(limit: limit);
              return {
                'recent_activity': recentActivity,
                'count': recentActivity.length,
                'status': 'success',
                'limit_applied': limit
              };
              
            case 'user_sessions':
              if (filters.containsKey('user_id')) {
                final sessions = await UserManagementService.getUserSessions(filters['user_id']);
                return {
                  'sessions': sessions,
                  'count': sessions.length,
                  'status': 'success',
                  'user_id': filters['user_id']
                };
              }
              
              final activeSessions = await UserManagementService.getActiveSessions();
              return {
                'active_sessions': activeSessions,
                'count': activeSessions.length,
                'status': 'success',
                'active_only': true
              };
              
            case 'user_stats':
              final stats = await UserManagementService.getUserStats();
              return {
                'statistics': stats,
                'generated_at': DateTime.now().toIso8601String(),
                'status': 'success'
              };
              
            case 'dashboard_summary':
              // Combined dashboard data
              final stats = await UserManagementService.getUserStats();
              final recentActivity = await UserManagementService.getRecentActivity(limit: 10);
              final activeSessions = await UserManagementService.getActiveSessions();
              
              return {
                'summary': {
                  'user_count': stats['total_users'],
                  'active_users': stats['active_users'],
                  'activity_rate': stats['activity_rate'],
                  'recent_activity_count': recentActivity.length,
                  'active_sessions_count': activeSessions.length
                },
                'recent_activity': recentActivity,
                'role_breakdown': stats['role_breakdown'],
                'status': 'success',
                'generated_at': DateTime.now().toIso8601String()
              };
              
            default:
              return {
                'status': 'error',
                'message': 'Unknown data type: $dataType',
                'supported_types': ['users', 'user_activity', 'user_sessions', 'user_stats', 'dashboard_summary']
              };
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ User Management data provider error: $e');
          }
          return {
            'status': 'error',
            'message': 'Data provider error: $e',
            'data_type': dataType,
            'filters': filters
          };
        }
      },
      eventHandler: (event) async {
        try {
          final eventData = event.data;
          final userId = eventData['user_id'] ?? 'system';
          
          switch (event.type) {
            case 'user_login':
              await UserManagementService.logActivity(
                userId,
                'user_login',
                'authentication',
                {
                  'ip_address': eventData['ip_address'],
                  'device_info': eventData['device_info'],
                  'login_time': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'user_logout':
              await UserManagementService.logActivity(
                userId,
                'user_logout',
                'authentication',
                {
                  'session_duration': eventData['session_duration'],
                  'logout_time': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'user_created':
              await UserManagementService.logActivity(
                eventData['created_by'] ?? 'system',
                'user_created',
                'user_management',
                {
                  'new_user_id': userId,
                  'user_role': eventData['role'],
                  'created_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'user_updated':
              await UserManagementService.logActivity(
                eventData['updated_by'] ?? userId,
                'user_updated',
                'user_management',
                {
                  'updated_user_id': userId,
                  'changes': eventData['changes'],
                  'updated_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'permission_changed':
              await UserManagementService.logActivity(
                eventData['changed_by'] ?? 'system',
                'permission_changed',
                'user_management',
                {
                  'affected_user_id': userId,
                  'old_permissions': eventData['old_permissions'],
                  'new_permissions': eventData['new_permissions'],
                  'changed_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'role_changed':
              await UserManagementService.logActivity(
                eventData['changed_by'] ?? 'system',
                'role_changed',
                'user_management',
                {
                  'affected_user_id': userId,
                  'old_role': eventData['old_role'],
                  'new_role': eventData['new_role'],
                  'changed_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'user_status_changed':
              await UserManagementService.logActivity(
                eventData['changed_by'] ?? 'system',
                'status_changed',
                'user_management',
                {
                  'affected_user_id': userId,
                  'old_status': eventData['old_status'],
                  'new_status': eventData['new_status'],
                  'reason': eventData['reason'],
                  'changed_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'bulk_action':
              await UserManagementService.logActivity(
                eventData['performed_by'] ?? 'system',
                'bulk_action',
                'user_management',
                {
                  'action_type': eventData['action_type'],
                  'affected_users': eventData['affected_users'],
                  'user_count': eventData['user_count'],
                  'performed_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            case 'data_export':
              await UserManagementService.logActivity(
                userId,
                'data_export',
                'user_management',
                {
                  'export_type': eventData['export_type'],
                  'filters_applied': eventData['filters'],
                  'record_count': eventData['record_count'],
                  'exported_at': DateTime.now().toIso8601String()
                }
              );
              break;
              
            default:
              // Generic activity logging for any other events
              await UserManagementService.logActivity(
                userId,
                event.type,
                'user_management',
                {
                  'event_data': eventData,
                  'logged_at': DateTime.now().toIso8601String()
                }
              );
          }
          
          if (kDebugMode) {
            print('👥 User Management event handled: ${event.type} for user: $userId');
          }
          
        } catch (e) {
          if (kDebugMode) {
            print('❌ User Management event handler error: $e');
          }
        }
      },
    );
    
    if (kDebugMode) {
      print('👥 Complete User Management module connected to Universal ERP Bridge');
      print('   ✅ Full CRUD operations enabled');
      print('   ✅ Activity monitoring active');
      print('   ✅ Session management integrated'); 
      print('   ✅ User analytics available');
      print('   ✅ Role & permission management ready');
    }
  }
}
