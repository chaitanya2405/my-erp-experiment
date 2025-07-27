# 🎯 **Business Template Usage Guide**

Welcome to the comprehensive usage guide for the Business Template system! This guide will walk you through everything you need to know to successfully integrate and use the business template in your ERP modules.

## 📋 **Table of Contents**

1. [Quick Start](#quick-start)
2. [Integration Steps](#integration-steps)
3. [Component Usage](#component-usage)
4. [Template Examples](#template-examples)
5. [Migration Guide](#migration-guide)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Features](#advanced-features)

---

## 🚀 **Quick Start**

### Step 1: Import the Business Template
```dart
import 'package:your_app/business_template/design_system/business_themes.dart';
import 'package:your_app/business_template/components/business_card.dart';
import 'package:your_app/business_template/migration/template_wrapper.dart';
```

### Step 2: Apply Business Theme
```dart
MaterialApp(
  theme: BusinessThemes.lightTheme,
  darkTheme: BusinessThemes.darkTheme,
  home: YourHomePage(),
)
```

### Step 3: Wrap Your Widgets
```dart
TemplateMigrationWrapper(
  useBusinessTemplate: true,
  child: YourExistingWidget(),
)
```

That's it! Your app now uses the professional business template styling.

---

## 🔧 **Integration Steps**

### Phase 1: Theme Integration (5 minutes)
1. **Update your main.dart:**
```dart
import 'business_template/design_system/business_themes.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your ERP App',
      theme: BusinessThemes.lightTheme,
      darkTheme: BusinessThemes.darkTheme,
      themeMode: ThemeMode.system, // Automatic light/dark switching
      home: HomePage(),
    );
  }
}
```

### Phase 2: Gradual Migration (Per Module)
1. **Wrap individual modules:**
```dart
// Before
class InventoryModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return YourExistingWidget();
  }
}

// After
class InventoryModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TemplateMigrationWrapper(
      useBusinessTemplate: true,
      mode: MigrationMode.gradual,
      child: YourExistingWidget(),
    );
  }
}
```

### Phase 3: Component Replacement (As Needed)
1. **Replace existing cards:**
```dart
// Before
Card(child: ListTile(...))

// After
BusinessCard(child: ListTile(...))
```

2. **Use professional colors:**
```dart
// Before
Container(color: Colors.blue)

// After
Container(color: BusinessColors.primaryBlue)
```

---

## 🧩 **Component Usage**

### BusinessCard
Professional card component with hover effects and elevation.

```dart
BusinessCard(
  variant: BusinessCardVariant.elevated,
  onTap: () => navigateToDetails(),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Card Title'),
        Text('Card Content'),
      ],
    ),
  ),
)
```

**Variants:**
- `flat` - Minimal styling
- `elevated` - Subtle shadow
- `outlined` - Border styling
- `filled` - Background color

### BusinessKPICard
Specialized card for displaying key performance indicators.

```dart
BusinessKPICard(
  title: 'Total Revenue',
  value: '\$2.4M',
  trend: TrendDirection.up,
  trendValue: 12.5,
  icon: Icons.attach_money,
  onTap: () => showRevenueDetails(),
)
```

### BusinessInfoCard
General information display card with icon and description.

```dart
BusinessInfoCard(
  title: 'System Status',
  description: 'All systems operational',
  icon: Icons.check_circle,
  iconColor: Colors.green,
  actions: [
    TextButton(
      onPressed: () => showSystemDetails(),
      child: Text('View Details'),
    ),
  ],
)
```

---

## 📄 **Template Examples**

### Dashboard Template
Complete dashboard layout with KPIs, quick actions, and activity feed.

```dart
DashboardTemplate(
  title: 'ERP Dashboard',
  kpiCards: [
    KPICardData(
      title: 'Total Sales',
      value: '\$145K',
      trend: TrendDirection.up,
      trendValue: 8.5,
    ),
    // Add more KPIs...
  ],
  quickActions: [
    DashboardAction(
      title: 'New Order',
      icon: Icons.add_shopping_cart,
      onTap: () => createNewOrder(),
    ),
    // Add more actions...
  ],
  recentActivities: [
    'Order #1234 completed',
    'New customer registered',
    // Add more activities...
  ],
)
```

### List Template
Professional list view with search, filters, and sorting.

```dart
ListTemplate<Product>(
  title: 'Product Inventory',
  items: products,
  itemBuilder: (context, product) => ProductListItem(product),
  searchFields: ['name', 'sku', 'category'],
  searchPlaceholder: 'Search products...',
  onAdd: () => addNewProduct(),
  onRefresh: () => refreshProducts(),
  filters: [
    FilterOption(
      key: 'category',
      title: 'Category',
      options: ['Electronics', 'Clothing', 'Books'],
    ),
  ],
  sortOptions: [
    SortOption(key: 'name', title: 'Name'),
    SortOption(key: 'price', title: 'Price'),
  ],
)
```

### Form Template
Structured form with sections, validation, and progress.

```dart
FormTemplate(
  title: 'New Product',
  sections: [
    FormSection(
      title: 'Basic Information',
      icon: Icons.info,
      fields: [
        FormField(
          key: 'name',
          label: 'Product Name',
          type: FormFieldType.text,
          isRequired: true,
          validator: (value) => value?.isEmpty ?? true 
              ? 'Name is required' 
              : null,
        ),
        FormField(
          key: 'price',
          label: 'Price',
          type: FormFieldType.currency,
          isRequired: true,
        ),
      ],
    ),
  ],
  onSave: (data) => saveProduct(data),
  onCancel: () => Navigator.pop(context),
)
```

### Analytics Template
Interactive analytics dashboard with charts and KPIs.

```dart
AnalyticsTemplate(
  title: 'Sales Analytics',
  dateRange: DateRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  ),
  kpiCards: [
    AnalyticsKPI(
      title: 'Total Sales',
      value: '\$145,250',
      trend: 15.3,
      subtitle: 'vs last month',
    ),
  ],
  charts: [
    AnalyticsChart(
      title: 'Sales Over Time',
      type: ChartType.line,
      data: salesData,
    ),
  ],
  onExport: (format) => exportData(format),
)
```

### Detail Template
Comprehensive detail view with sections and related items.

```dart
DetailTemplate(
  title: product.name,
  subtitle: 'SKU: ${product.sku}',
  headerActions: [
    DetailAction(
      icon: Icons.edit,
      label: 'Edit',
      onTap: () => editProduct(),
    ),
  ],
  sections: [
    DetailSection(
      title: 'Basic Information',
      items: [
        DetailItem(label: 'Name', value: product.name),
        DetailItem(label: 'Category', value: product.category),
      ],
    ),
  ],
  relatedItems: [
    RelatedItem(
      title: 'Recent Orders',
      items: recentOrders,
      onViewAll: () => viewAllOrders(),
    ),
  ],
)
```

---

## 🔄 **Migration Guide**

### Migration Modes

The template system supports different migration modes to suit your needs:

#### 1. Legacy Mode
Keep existing styling completely unchanged.
```dart
TemplateMigrationWrapper(
  mode: MigrationMode.legacy,
  child: YourWidget(),
)
```

#### 2. Business Only Mode
Apply business template styling only.
```dart
TemplateMigrationWrapper(
  mode: MigrationMode.businessOnly,
  child: YourWidget(),
)
```

#### 3. Gradual Mode (Recommended)
Conditionally apply business template based on feature flags.
```dart
TemplateMigrationWrapper(
  mode: MigrationMode.gradual,
  useBusinessTemplate: shouldUseBusiness,
  child: YourWidget(),
)
```

#### 4. Comparison Mode
Show both versions side by side for testing.
```dart
TemplateMigrationWrapper(
  mode: MigrationMode.comparison,
  child: YourWidget(),
)
```

### Component Adaptation

Use the `LegacyComponentAdapter` to automatically style existing components:

```dart
// Adapt existing AppBar
AppBar originalAppBar = AppBar(title: Text('My App'));
PreferredSizeWidget businessAppBar = LegacyComponentAdapter.adaptAppBar(
  originalAppBar,
  useBusiness: true,
);

// Adapt existing Card
Widget originalCard = Card(child: ListTile(...));
Widget businessCard = LegacyComponentAdapter.adaptCard(
  originalCard,
  useBusiness: true,
);

// Adapt existing Button
ElevatedButton originalButton = ElevatedButton(...);
Widget businessButton = LegacyComponentAdapter.adaptButton(
  originalButton,
  useBusiness: true,
);
```

### Migration Tracking

Track your migration progress:

```dart
// Mark module as migrated
MigrationProgressTracker.markModuleMigrated('inventory_module');

// Mark module in progress
MigrationProgressTracker.markModuleInProgress('orders_module');

// Mark module with issues
MigrationProgressTracker.markModuleIssues('analytics_module', 'Chart library conflict');

// Get progress report
String report = MigrationProgressTracker.getReport();
print(report);
```

---

## 💡 **Best Practices**

### 1. Color Usage
```dart
// ✅ Good - Use semantic colors
Container(color: BusinessColors.primaryBlue)
Container(color: BusinessColors.successGreen)
Container(color: BusinessColors.warningOrange)

// ❌ Avoid - Hardcoded colors
Container(color: Colors.blue)
Container(color: Color(0xFF007AFF))
```

### 2. Typography
```dart
// ✅ Good - Use business typography
Text(
  'Heading',
  style: BusinessTypography.headingLarge(context),
)

// ❌ Avoid - Custom font sizes
Text(
  'Heading',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)
```

### 3. Spacing
```dart
// ✅ Good - Use business spacing
Padding(
  padding: EdgeInsets.all(BusinessSpacing.medium),
  child: child,
)

// ❌ Avoid - Arbitrary values
Padding(
  padding: EdgeInsets.all(16),
  child: child,
)
```

### 4. Responsive Design
```dart
// ✅ Good - Use platform-aware components
PlatformResponsiveBuilder(
  builder: (context, platformInfo) {
    if (platformInfo.isDesktop) {
      return DesktopLayout();
    }
    return MobileLayout();
  },
)
```

### 5. Error Handling
```dart
// ✅ Good - Provide fallbacks
TemplateMigrationWrapper(
  useBusinessTemplate: true,
  errorFallback: YourFallbackWidget(),
  child: YourWidget(),
)
```

---

## 🐛 **Troubleshooting**

### Common Issues

#### Issue: Colors not applying
**Problem:** Custom colors overriding business theme
```dart
// ❌ Problem
Container(
  color: Colors.blue, // This overrides the theme
  child: child,
)

// ✅ Solution
Container(
  color: Theme.of(context).primaryColor, // Respects theme
  child: child,
)
```

#### Issue: Fonts not working
**Problem:** Missing font assets or incorrect font family
```dart
// Check pubspec.yaml has fonts configured
fonts:
  - family: Inter
    fonts:
      - asset: fonts/Inter-Regular.ttf
      - asset: fonts/Inter-Bold.ttf
        weight: 700
```

#### Issue: Layout breaking on different platforms
**Problem:** Fixed sizes don't work across platforms
```dart
// ❌ Problem
Container(width: 300, height: 200)

// ✅ Solution
PlatformResponsiveBuilder(
  builder: (context, platformInfo) {
    return Container(
      width: platformInfo.isDesktop ? 400 : double.infinity,
      height: platformInfo.screenHeight * 0.3,
    );
  },
)
```

#### Issue: Migration wrapper not working
**Problem:** Wrapper not being applied correctly
```dart
// ✅ Ensure proper nesting
Scaffold(
  body: TemplateMigrationWrapper( // Wrap the body content
    useBusinessTemplate: true,
    child: YourPageContent(),
  ),
)
```

### Debug Mode

Enable debug mode to see migration information:
```dart
TemplateMigrationWrapper(
  useBusinessTemplate: true,
  onMigrationAnalytics: () {
    debugPrint('Business template applied to ${widget.runtimeType}');
  },
  child: YourWidget(),
)
```

---

## 🔥 **Advanced Features**

### Custom Theme Extensions

Extend the business theme with your own colors:
```dart
class CustomBusinessTheme {
  static ThemeData get customLightTheme {
    return BusinessThemes.lightTheme.copyWith(
      // Add your customizations
      appBarTheme: BusinessThemes.lightTheme.appBarTheme.copyWith(
        backgroundColor: Colors.purple,
      ),
    );
  }
}
```

### Platform-Specific Adaptations

Create platform-specific behaviors:
```dart
class PlatformAdaptiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformResponsiveBuilder(
      builder: (context, platformInfo) {
        if (platformInfo.isWeb) {
          return WebOptimizedView();
        } else if (platformInfo.isDesktop) {
          return DesktopView();
        } else {
          return MobileView();
        }
      },
    );
  }
}
```

### Dynamic Theme Switching

Implement runtime theme switching:
```dart
class ThemeProvider extends ChangeNotifier {
  bool _useBusinessTheme = true;
  
  bool get useBusinessTheme => _useBusinessTheme;
  
  void toggleTheme() {
    _useBusinessTheme = !_useBusinessTheme;
    notifyListeners();
  }
  
  ThemeData get currentTheme {
    return _useBusinessTheme 
        ? BusinessThemes.lightTheme 
        : ThemeData.light();
  }
}
```

### Custom Analytics

Track template usage:
```dart
class TemplateAnalytics {
  static void trackTemplateUsage(String templateName) {
    // Your analytics implementation
    print('Template used: $templateName');
  }
  
  static void trackMigrationEvent(String moduleName, bool success) {
    // Track migration success/failure
    print('Migration $moduleName: ${success ? 'Success' : 'Failed'}');
  }
}
```

---

## 📞 **Support**

If you encounter any issues or need help:

1. **Check the examples** in `business_template/examples/`
2. **Run the demo app** to see working implementations
3. **Review the troubleshooting** section above
4. **Check the migration tracker** for progress issues

---

## 🎉 **Congratulations!**

You're now ready to use the Business Template system! Start with the quick start guide, then gradually migrate your modules using the provided tools and examples.

The template system is designed to be:
- ✅ **Safe** - No impact on existing code
- ✅ **Gradual** - Migrate at your own pace  
- ✅ **Professional** - Enterprise-grade styling
- ✅ **Responsive** - Works on all platforms
- ✅ **Accessible** - Follows accessibility guidelines

Happy coding! 🚀
