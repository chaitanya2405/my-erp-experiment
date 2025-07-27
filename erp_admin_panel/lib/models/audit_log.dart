import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  final String logId;
  final String eventType;
  final String description;
  final String userId;
  final String entityType;
  final String entityId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String ipAddress;
  final String userAgent;
  final String deviceInfo;

  // Getters for compatibility
  String get id => logId;
  Map<String, dynamic> get additionalData => metadata;

  const AuditLog({
    required this.logId,
    required this.eventType,
    required this.description,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    required this.metadata,
    required this.ipAddress,
    required this.userAgent,
    required this.deviceInfo,
  });

  factory AuditLog.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AuditLog(
      logId: documentId,
      eventType: data['eventType'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      ipAddress: data['ipAddress'] ?? '',
      userAgent: data['userAgent'] ?? '',
      deviceInfo: data['deviceInfo'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventType': eventType,
      'description': description,
      'userId': userId,
      'entityType': entityType,
      'entityId': entityId,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'deviceInfo': deviceInfo,
    };
  }

  AuditLog copyWith({
    String? logId,
    String? eventType,
    String? description,
    String? userId,
    String? entityType,
    String? entityId,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
    String? deviceInfo,
  }) {
    return AuditLog(
      logId: logId ?? this.logId,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}
