import 'package:flutter_riverpod/flutter_riverpod.dart';

// Re-export all service providers from core_services.dart
// This file serves as a central access point for all service providers
// while the actual implementations are in core_services.dart

export '../services/core_services.dart' show 
  // Core utility service providers
  cacheServiceProvider,
  validationServiceProvider,
  auditServiceProvider,
  
  // Module-specific service providers
  productServiceProvider,
  inventoryServiceProvider,
  supplierServiceProvider,
  customerProfileServiceProvider,
  purchaseOrderServiceProvider,
  customerOrderServiceProvider,
  userProfileServiceProvider,
  storeServiceProvider;

// Additional providers can be defined here if needed in the future
// For example, composite providers that combine multiple services
