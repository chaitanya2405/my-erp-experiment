# Activity Tracker System

## 🔍 Overview

The Activity Tracker system provides comprehensive monitoring of user interactions, navigation patterns, and file usage within the ERP admin application. This system helps developers quickly identify which files and code sections are involved in any specific workflow or user action.

## 🎯 Key Features

### 📊 **Real-time Activity Monitoring**
- **Navigation Tracking**: Records screen transitions with file mappings
- **Interaction Tracking**: Logs button clicks, form submissions, and user actions
- **Data Operations**: Monitors Firestore queries and API calls
- **Error Tracking**: Captures exceptions with affected file references

### 🗂️ **Automatic File Mapping**
- **Screen-to-File Association**: Automatically maps screens to their related files
- **Service Dependencies**: Tracks which service files are used for operations
- **Model Relationships**: Records model files involved in data operations
- **Provider Connections**: Links provider files to UI interactions

### 📈 **Activity Analytics**
- **Session Summary**: Real-time statistics of current session
- **Navigation Patterns**: Most visited screens and user flows
- **File Usage**: Comprehensive list of files used during session
- **Error Reports**: Detailed error tracking with stack traces

## 🚀 Getting Started

### 1. Enable Activity Tracking

The tracker is automatically enabled when the admin app starts. You can manually control it:

```dart
// Enable tracking
ActivityTracker().setEnabled(true);

// Disable tracking
ActivityTracker().setEnabled(false);
```

### 2. Track Navigation

Use `TrackedNavigator` instead of regular `Navigator`:

```dart
// Instead of Navigator.push()
TrackedNavigator.push(
  context,
  screen: MyScreen(),
  screenName: 'MyScreenName',
  relatedFiles: [
    'lib/screens/my_screen.dart',
    'lib/services/my_service.dart',
    'lib/models/my_model.dart',
  ],
);
```

### 3. Track User Interactions

```dart
// Track button clicks and actions
ActivityTracker().trackInteraction(
  action: 'generate_mock_data',
  element: 'generate_button',
  filesInvolved: [
    'lib/core/admin_tools.dart',
    'lib/tool/mock_data_generator.dart',
  ],
);
```

### 4. Track Data Operations

```dart
// Track Firestore operations
TrackedService.trackAsyncFirestoreOperation(
  'fetch_customers',
  () => firestore.collection('customers').get(),
  collection: 'customers',
  serviceFiles: ['lib/services/customer_service.dart'],
);
```

## 📱 Using the Activity Viewer

The Activity Viewer widget is automatically included in the admin dashboard and provides:

### 🎛️ **Control Panel**
- **Enable/Disable Toggle**: Turn tracking on/off
- **Expand/Collapse**: Show detailed activity list
- **Filter Options**: View specific types of activities
- **Refresh Button**: Update activity display

### 📋 **Activity List**
- **Real-time Updates**: Shows latest 10 activities
- **Detailed Information**: Expandable items with full details
- **File References**: Clickable file paths (copies to clipboard)
- **Timestamps**: Precise timing of each activity

### 🔍 **Activity Details Include:**
- **Action Type**: Navigation, Interaction, Data Operation, Error
- **Screen Context**: Which screen the activity occurred in
- **Related Files**: All files involved in the operation
- **Parameters**: Data passed to functions or screens
- **Duration**: Time spent on screens
- **Error Details**: Stack traces and error messages

## 📊 Available Data

### 📈 **Session Summary**
```dart
final summary = ActivityTracker().getCurrentSessionSummary();
print('Total activities: ${summary.totalActivities}');
print('Screens visited: ${summary.uniqueScreensVisited}');
print('Files used: ${summary.totalFilesUsed}');
print('Most visited: ${summary.mostVisitedScreen}');
```

### 🗂️ **File Mapping**
```dart
// Get all files used
final allFiles = ActivityTracker().getUniqueFilesUsed();

// Get files for specific screen
final screenFiles = ActivityTracker().getFilesForScreen('InventoryManagement');

// Get navigation statistics
final navStats = ActivityTracker().getNavigationStats();
```

### 📤 **Export Activity Data**
```dart
// Export to JSON
final jsonData = ActivityTracker().exportToJson();

// Save to file (non-web platforms)
await ActivityTracker().saveToFile('my_activity_log.json');
```

## 🎯 Use Cases

### 🔧 **Development & Debugging**
1. **Feature Development**: See exactly which files need modification for a feature
2. **Bug Investigation**: Track user actions leading to errors with file references
3. **Code Review**: Understand file dependencies and relationships
4. **Performance Analysis**: Identify heavily used code paths

### 📊 **User Experience Analysis**
1. **Navigation Patterns**: Understand user workflows and common paths
2. **Feature Usage**: See which features are used most frequently
3. **Error Tracking**: Monitor and fix user-facing issues
4. **Session Analysis**: Understand user behavior and engagement

### 🎨 **UI/UX Optimization**
1. **Screen Efficiency**: Identify screens with long visit times
2. **Navigation Optimization**: Streamline frequently used paths
3. **Error Prevention**: Fix commonly problematic workflows
4. **Feature Discoverability**: Understand which features are underutilized

## 📝 File Mapping Reference

### 🏠 **Main Screens**
- **UnifiedDashboard**: `lib/screens/unified_dashboard_screen.dart`
- **CustomerApp**: `lib/screens/customer_app_screen.dart`
- **SupplierPortal**: `lib/screens/supplier_portal_screen.dart`

### 📦 **Module Screens**
- **InventoryManagement**: `lib/modules/inventory_management/screens/`
- **POSModule**: `lib/modules/pos_management/screens/`
- **CustomerOrderModule**: `lib/modules/customer_order_management/screens/`
- **PurchaseOrderModule**: `lib/modules/purchase_order_management/screens/`
- **ProductManagement**: `lib/modules/product_management/screens/`
- **StoreManagement**: `lib/modules/store_management/screens/`

### 🔧 **Services**
- **POS Service**: `lib/services/pos_service.dart`
- **Inventory Service**: `lib/services/inventory_service.dart`
- **Customer Service**: `lib/services/customer_profile_service.dart`
- **Product Service**: `lib/services/product_service.dart`

### 🎛️ **Core Components**
- **Activity Tracker**: `lib/core/activity_tracker.dart`
- **Tracked Navigation**: `lib/core/tracked_navigation.dart`
- **Admin Tools**: `lib/core/admin_tools.dart`

## 🎉 Benefits

### ⚡ **Development Speed**
- **Instant File Discovery**: No more searching for relevant files
- **Clear Dependencies**: Understand file relationships immediately
- **Efficient Debugging**: Quick identification of problematic code paths

### 🎯 **Precision**
- **Accurate Tracking**: Real-time, detailed activity monitoring
- **Complete Context**: Full file and data context for every action
- **Granular Control**: Fine-tuned tracking for specific needs

### 📊 **Intelligence**
- **Usage Analytics**: Data-driven insights into application usage
- **Performance Metrics**: Understanding of user interaction patterns
- **Error Intelligence**: Comprehensive error tracking with context

---

## 💡 Pro Tips

1. **Keep Activity Viewer Open**: Monitor real-time activities during development
2. **Export Regularly**: Save activity logs for historical analysis
3. **Use File Mapping**: Leverage pre-defined file mappings for consistency
4. **Filter Activities**: Focus on specific activity types when debugging
5. **Copy File Paths**: Click any file path in the viewer to copy it to clipboard

The Activity Tracker system transforms debugging from guesswork into precision, making it incredibly easy to understand exactly which files and code sections are involved in any user workflow or application feature.
