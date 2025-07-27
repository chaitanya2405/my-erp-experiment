# 🔧 Shared ERP Package

## 📋 **Overview**
This package contains all shared components, models, services, and utilities used across the entire ERP ecosystem.

## 📁 **Structure**

```
shared_package/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── enums/
│   │   ├── exceptions/
│   │   ├── utils/
│   │   └── validators/
│   ├── models/
│   │   ├── product/
│   │   ├── store/
│   │   ├── user/
│   │   ├── order/
│   │   ├── inventory/
│   │   └── analytics/
│   ├── services/
│   │   ├── api/
│   │   ├── database/
│   │   ├── storage/
│   │   ├── auth/
│   │   └── notification/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── app_state_provider.dart
│   │   └── connectivity_provider.dart
│   ├── widgets/
│   │   ├── common/
│   │   ├── forms/
│   │   ├── charts/
│   │   └── dialogs/
│   └── themes/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
├── test/
├── pubspec.yaml
└── README.md
```

## 🎯 **Key Features**

### 📊 **Models**
- **Product Models**: Product, Category, Brand, Variant
- **Store Models**: Store, Location, Hours, Staff
- **User Models**: Customer, Admin, Supplier, Staff
- **Order Models**: Order, OrderItem, Payment, Shipping
- **Inventory Models**: Stock, Movement, Adjustment
- **Analytics Models**: Sales, Performance, Reports

### 🔧 **Services**
- **API Service**: RESTful API client
- **Database Service**: Firestore operations
- **Storage Service**: Firebase Storage
- **Auth Service**: Authentication & Authorization
- **Notification Service**: Push notifications

### 🎨 **Widgets**
- **Common Widgets**: Buttons, Cards, Loading indicators
- **Form Widgets**: Input fields, Dropdowns, Validators
- **Chart Widgets**: Bar charts, Line charts, Pie charts
- **Dialog Widgets**: Confirmation, Info, Error dialogs

### 🎨 **Themes**
- Consistent design system
- Color palette
- Typography
- Component styling

## 📋 **Usage**

```dart
// Import shared models
import 'package:shared_package/models/product/product.dart';

// Import shared services
import 'package:shared_package/services/api/api_service.dart';

// Import shared widgets
import 'package:shared_package/widgets/common/loading_widget.dart';

// Import shared providers
import 'package:shared_package/providers/auth_provider.dart';
```

## 🔄 **Version Management**
This package follows semantic versioning and is updated whenever shared components change.

## 🧪 **Testing**
Comprehensive unit and integration tests for all shared components.

## 📖 **Documentation**
Detailed API documentation available in the `/docs` folder.
