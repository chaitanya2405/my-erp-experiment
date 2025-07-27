# 🛠️ Ravali ERP - Troubleshooting & Error Resolution Guide

## 🎯 Common Issues & Solutions

This guide covers the most frequent errors encountered in the Ravali ERP system and their step-by-step solutions.

---

## 🔥 Critical Errors

### 1. 🚨 MultiProvider/Nested Empty Children Error

**Error Message:**
```
Assertion failed: children.isNotEmpty is not true
```

**Root Cause:** Empty `MultiProvider` providers list in main.dart

**Solution:**
```dart
// ❌ WRONG - Empty providers
runApp(
  ProviderScope(
    child: MultiProvider(
      providers: [], // Empty list causes error
      child: const MyApp(),
    ),
  ),
);

// ✅ CORRECT - Use ProviderScope only
runApp(
  ProviderScope(
    child: const MyApp(),
  ),
);
```

**Fix Steps:**
1. Open `lib/main.dart`
2. Remove empty `MultiProvider` wrapper
3. Keep only `ProviderScope` for Riverpod
4. Rebuild application

---

### 2. 🔥 Firebase Initialization Error

**Error Message:**
```
Firebase has not been correctly initialized
```

**Root Cause:** Missing Firebase configuration or incorrect setup

**Solution:**
```dart
// Ensure proper Firebase initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(MyApp());
}
```

**Fix Steps:**
1. Verify `firebase_options.dart` exists and is configured
2. Check internet connection
3. Ensure Firebase project is properly set up
4. Run `flutter clean && flutter pub get`

---

### 3. 🚨 Unified Models Import Conflicts

**Error Message:**
```
Ambiguous import: 'Product' is defined in multiple libraries
```

**Root Cause:** Conflicting imports between legacy and unified models

**Solution:**
```dart
// ❌ WRONG - Ambiguous imports
import 'package:app/models/product.dart';
import 'package:app/core/models/unified_models.dart';

// ✅ CORRECT - Use qualified imports
import 'package:app/models/product.dart' hide Product;
import 'package:app/core/models/unified_models.dart';

// OR use 'as' qualifier
import 'package:app/models/product.dart' as legacy;
import 'package:app/core/models/unified_models.dart';
```

**Fix Steps:**
1. Identify conflicting imports
2. Use `hide` clause to exclude conflicts
3. Use qualified imports with `as` when needed
4. Prefer unified models over legacy models

---

## ⚠️ Compilation Errors

### 4. 🔧 Missing Method Errors

**Error Message:**
```
The method 'someMethod' isn't defined for the type 'UnifiedModel'
```

**Root Cause:** Using legacy method names with unified models

**Solution:**
```dart
// ❌ WRONG - Legacy method names
final product = UnifiedProduct(...);
final price = product.getPrice(); // Method doesn't exist

// ✅ CORRECT - Use direct properties
final product = UnifiedProduct(...);
final price = product.salePrice; // Direct property access
```

**Common Method Mappings:**
```dart
// Legacy → Unified
item.getPrice() → item.salePrice
item.getName() → item.name
item.getQuantity() → item.quantity
order.getTotal() → order.totalAmount
customer.getId() → customer.id
```

---

### 5. 🔧 Type Conversion Errors

**Error Message:**
```
A value of type 'Map<String, dynamic>' can't be assigned to type 'UnifiedProduct'
```

**Root Cause:** Missing model conversion methods

**Solution:**
```dart
// ❌ WRONG - Direct assignment
final product = productData; // Map<String, dynamic>

// ✅ CORRECT - Use fromMap constructor
final product = UnifiedProduct.fromMap(productData);

// For Firebase documents
final product = UnifiedProduct.fromFirestore(doc);
```

**Common Conversions:**
```dart
// From Map
UnifiedProduct.fromMap(map)
UnifiedCustomerOrder.fromMap(map)
UnifiedPOSTransaction.fromMap(map)

// To Map
product.toMap()
order.toMap()
transaction.toMap()
```

---

### 6. 🔧 Provider Not Found Error

**Error Message:**
```
Could not find the correct Provider<SomeService> above this Widget
```

**Root Cause:** Service not registered in provider tree

**Solution:**
```dart
// Ensure service is registered in main.dart
runApp(
  ProviderScope(
    overrides: [
      productServiceProvider.overrideWithValue(ProductService()),
    ],
    child: const MyApp(),
  ),
);

// Or access via ref.read/watch in Consumer widgets
Consumer(
  builder: (context, ref, child) {
    final productService = ref.watch(productServiceProvider);
    return SomeWidget();
  },
)
```

---

## 🌐 Runtime Errors

### 7. 🌍 Firestore Permission Denied

**Error Message:**
```
Insufficient permissions for operation
```

**Root Cause:** Firestore security rules blocking access

**Solution:**
```javascript
// Add to Firestore rules (firestore.rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Or for development (LESS SECURE)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

### 8. 🌍 Network Connection Issues

**Error Message:**
```
SocketException: Failed host lookup
```

**Root Cause:** Network connectivity or Firebase configuration issues

**Solution:**
1. Check internet connection
2. Verify Firebase project configuration
3. Test with other Firebase operations
4. Check corporate firewall settings
5. Use offline persistence:

```dart
// Enable offline persistence
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

### 9. 🌍 Stream Subscription Memory Leaks

**Error Message:**
```
Memory usage continually increasing
```

**Root Cause:** Unclosed stream subscriptions

**Solution:**
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // ✅ IMPORTANT: Cancel subscription
    super.dispose();
  }
}

// Or use StreamBuilder for automatic management
StreamBuilder<List<Product>>(
  stream: productService.getProductsStream(),
  builder: (context, snapshot) {
    // Build UI
  },
)
```

---

## 🎨 UI/UX Issues

### 10. 📱 RenderFlex Overflow Errors

**Error Message:**
```
RenderFlex overflowed by X pixels on the right
```

**Root Cause:** UI elements exceeding screen boundaries

**Solution:**
```dart
// ❌ WRONG - Fixed width without constraints
Row(
  children: [
    Container(width: 300, child: Text('Long text...')),
    Container(width: 300, child: Text('More text...')),
  ],
)

// ✅ CORRECT - Use Expanded or Flexible
Row(
  children: [
    Expanded(child: Text('Long text...')),
    Expanded(child: Text('More text...')),
  ],
)

// Or wrap in SingleChildScrollView
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(children: [...]),
)
```

---

### 11. 📱 Dropdown State Issues

**Error Message:**
```
There should be exactly one item with [DropdownButton]'s value
```

**Root Cause:** Dropdown value not in items list

**Solution:**
```dart
// ❌ WRONG - Value not in items
DropdownButton<String>(
  value: selectedValue, // This might not exist in items
  items: dropdownItems,
  onChanged: (value) => setState(() => selectedValue = value),
)

// ✅ CORRECT - Validate value exists
DropdownButton<String>(
  value: dropdownItems.any((item) => item.value == selectedValue) 
         ? selectedValue 
         : null,
  items: dropdownItems,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

---

## 🔍 Development & Testing Issues

### 12. 🧪 Mock Data Generation Errors

**Error Message:**
```
Mock data generation failed
```

**Root Cause:** Missing dependencies or service initialization

**Solution:**
```dart
// Ensure proper initialization order
Future<void> generateMockData() async {
  try {
    // 1. Initialize Firebase first
    await Firebase.initializeApp();
    
    // 2. Initialize services
    await RoleBasedAccessService.instance.initializeDefaultUsers();
    
    // 3. Generate data
    await StoreMockDataGenerator.generateMockStores();
    await UnifiedERPMockDataGenerator.generateUnifiedMockData();
    
    print('✅ Mock data generated successfully');
  } catch (e) {
    print('❌ Mock data generation failed: $e');
  }
}
```

---

### 13. 🧪 Flutter Analyze Errors

**Error Message:**
```
Avoid using deprecated members
```

**Root Cause:** Using outdated Flutter/Dart APIs

**Solution:**
```dart
// Update deprecated usages
// ❌ OLD
FlatButton(child: Text('Button'), onPressed: () {})

// ✅ NEW
TextButton(child: Text('Button'), onPressed: () {})

// ❌ OLD
RaisedButton(child: Text('Button'), onPressed: () {})

// ✅ NEW
ElevatedButton(child: Text('Button'), onPressed: () {})
```

**Fix Steps:**
1. Run `flutter analyze`
2. Address each warning/error
3. Update deprecated APIs
4. Follow Flutter migration guides

---

## 🚀 Performance Issues

### 14. ⚡ Slow Initial Load

**Root Cause:** Heavy initialization or excessive data loading

**Solution:**
```dart
// Use lazy loading and progressive initialization
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Show loading
          }
          return const HomePage();
        },
      ),
    );
  }
  
  Future<void> _initializeApp() async {
    // Initialize only essential services first
    await Firebase.initializeApp();
    
    // Load other data in background
    unawaited(_loadOptionalData());
  }
}
```

---

### 15. ⚡ Excessive Firestore Reads

**Root Cause:** Inefficient queries or missing caching

**Solution:**
```dart
// ❌ INEFFICIENT - Reading all documents
final allProducts = await FirebaseFirestore.instance
    .collection('products')
    .get();

// ✅ EFFICIENT - Use pagination and caching
class ProductService {
  static final List<Product> _cache = [];
  static DateTime? _lastFetch;
  
  Future<List<Product>> getProducts({int limit = 20}) async {
    // Check cache first
    if (_cache.isNotEmpty && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < Duration(minutes: 5)) {
      return _cache.take(limit).toList();
    }
    
    // Fetch with limit
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .limit(limit)
        .get();
    
    _cache.clear();
    _cache.addAll(snapshot.docs.map((doc) => Product.fromFirestore(doc)));
    _lastFetch = DateTime.now();
    
    return _cache;
  }
}
```

---

## 🔧 Quick Fix Commands

### Flutter Commands
```bash
# Clean and rebuild
flutter clean && flutter pub get && flutter build web

# Fix dependency issues
flutter pub deps
flutter pub upgrade

# Analyze code issues
flutter analyze

# Run with verbose logging
flutter run -v

# Clear device logs
flutter logs --clear
```

### Firestore Commands
```bash
# Export Firestore data
gcloud firestore export gs://[BUCKET_NAME]

# Import Firestore data
gcloud firestore import gs://[BUCKET_NAME]/[EXPORT_NAME]

# Delete all Firestore data (BE CAREFUL!)
gcloud firestore databases delete --database=[DATABASE_ID]
```

---

## 📋 Error Prevention Checklist

### Before Making Changes
- [ ] Backup current working state
- [ ] Run `flutter analyze` to check for issues
- [ ] Test with mock data first
- [ ] Verify Firebase configuration
- [ ] Check provider registrations

### After Making Changes
- [ ] Run `flutter analyze` again
- [ ] Test all affected modules
- [ ] Verify data flow end-to-end
- [ ] Check for memory leaks
- [ ] Test in different browsers (for web)

---

## 🆘 Emergency Recovery Steps

### If App Won't Start
1. **Check main.dart** for syntax errors
2. **Verify Firebase configuration** in firebase_options.dart
3. **Clear Flutter cache**: `flutter clean`
4. **Reinstall dependencies**: `flutter pub get`
5. **Check for conflicting imports**
6. **Revert to last working state** if needed

### If Data is Corrupted
1. **Stop all operations** immediately
2. **Check Firebase Console** for data integrity
3. **Restore from backup** if available
4. **Regenerate mock data** for testing
5. **Verify service configurations**

### If Performance Degrades
1. **Check memory usage** in DevTools
2. **Cancel unnecessary streams**
3. **Clear cache** if needed
4. **Optimize Firestore queries**
5. **Remove debug prints** in production

---

## 📞 Getting Help

### Debug Information to Collect
1. **Error message** (full stack trace)
2. **Steps to reproduce** the error
3. **Flutter version**: `flutter --version`
4. **Dependencies**: Check `pubspec.yaml`
5. **Browser console logs** (for web)
6. **Firebase project settings**

### Useful Debug Commands
```dart
// Add debug prints
print('Debug: Variable value = $variable');
debugPrint('Debug: Complex object = ${object.toString()}');

// Log to Firestore for tracking
FirebaseFirestore.instance.collection('debug_logs').add({
  'message': 'Debug information',
  'timestamp': FieldValue.serverTimestamp(),
  'data': debugData,
});
```

This troubleshooting guide covers the most common issues you'll encounter while working with the Ravali ERP system. Keep this handy for quick problem resolution!
