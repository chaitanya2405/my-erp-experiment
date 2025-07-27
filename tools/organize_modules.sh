#!/bin/bash

# Ravali ERP Ecosystem Modular Organization Script

BASE_DIR="/Users/chaitanyabharath/Documents/copy of my software/ravali_erp_ecosystem_modular/erp_admin_panel"

echo "🏗️ Organizing Ravali ERP into Modular Structure..."

cd "$BASE_DIR"

# Create comprehensive module structure
echo "📁 Creating module directories..."

# Product Management Module
mkdir -p lib/modules/product_management/{models,services,providers,screens,widgets}
echo "  ✅ Product Management module created"

# Inventory Management Module  
mkdir -p lib/modules/inventory_management/{models,services,providers,screens,widgets}
echo "  ✅ Inventory Management module created"

# Store Management Module
mkdir -p lib/modules/store_management/{models,services,providers,screens,widgets}
echo "  ✅ Store Management module created"

# User Management Module
mkdir -p lib/modules/user_management/{models,services,providers,screens,widgets}
echo "  ✅ User Management module created"

# Order Management Module
mkdir -p lib/modules/order_management/{models,services,providers,screens,widgets}
echo "  ✅ Order Management module created"

# Analytics Module
mkdir -p lib/modules/analytics/{models,services,providers,screens,widgets}
echo "  ✅ Analytics module created"

# POS System Module
mkdir -p lib/modules/pos_system/{models,services,providers,screens,widgets}
echo "  ✅ POS System module created"

# Core and Shared directories
mkdir -p lib/core/{constants,routes,themes,utils}
mkdir -p lib/shared/{widgets,utils,constants}
echo "  ✅ Core and Shared directories created"

# Move files to appropriate modules
echo "📋 Organizing existing files..."

# Product Management Files
if [ -d "lib/screens" ]; then
    find lib/screens -name "*product*" -type f -exec mv {} lib/modules/product_management/screens/ \; 2>/dev/null
    echo "  📦 Product screens moved"
fi

if [ -d "lib/models" ]; then
    find lib/models -name "*product*" -type f -exec mv {} lib/modules/product_management/models/ \; 2>/dev/null
    echo "  📦 Product models moved"
fi

if [ -d "lib/services" ]; then
    find lib/services -name "*product*" -type f -exec mv {} lib/modules/product_management/services/ \; 2>/dev/null
    echo "  📦 Product services moved"
fi

if [ -d "lib/providers" ]; then
    find lib/providers -name "*product*" -type f -exec mv {} lib/modules/product_management/providers/ \; 2>/dev/null
    echo "  📦 Product providers moved"
fi

# Store Management Files
if [ -d "lib/screens" ]; then
    find lib/screens -name "*store*" -type f -exec mv {} lib/modules/store_management/screens/ \; 2>/dev/null
    echo "  🏪 Store screens moved"
fi

if [ -d "lib/models" ]; then
    find lib/models -name "*store*" -type f -exec mv {} lib/modules/store_management/models/ \; 2>/dev/null
    echo "  🏪 Store models moved"
fi

if [ -d "lib/services" ]; then
    find lib/services -name "*store*" -type f -exec mv {} lib/modules/store_management/services/ \; 2>/dev/null
    echo "  🏪 Store services moved"
fi

# Inventory Management Files
if [ -d "lib/screens" ]; then
    find lib/screens -name "*inventory*" -type f -exec mv {} lib/modules/inventory_management/screens/ \; 2>/dev/null
    echo "  📊 Inventory screens moved"
fi

if [ -d "lib/models" ]; then
    find lib/models -name "*inventory*" -type f -exec mv {} lib/modules/inventory_management/models/ \; 2>/dev/null
    echo "  📊 Inventory models moved"
fi

# User Management Files
if [ -d "lib/screens" ]; then
    find lib/screens -name "*user*" -type f -exec mv {} lib/modules/user_management/screens/ \; 2>/dev/null
    echo "  👥 User screens moved"
fi

if [ -d "lib/models" ]; then
    find lib/models -name "*user*" -type f -exec mv {} lib/modules/user_management/models/ \; 2>/dev/null
    echo "  👥 User models moved"
fi

# Analytics Files
if [ -d "lib/screens" ]; then
    find lib/screens -name "*analytic*" -type f -exec mv {} lib/modules/analytics/screens/ \; 2>/dev/null
    echo "  📈 Analytics screens moved"
fi

# Move core application files
if [ -f "lib/main.dart" ]; then
    # Keep main.dart in lib root
    echo "  🚀 Main application file preserved"
fi

# Move remaining common files to shared
if [ -d "lib/models" ]; then
    find lib/models -name "*.dart" -type f -exec mv {} lib/shared/models/ \; 2>/dev/null
    echo "  🔗 Shared models moved"
fi

if [ -d "lib/services" ]; then
    find lib/services -name "*.dart" -type f -exec mv {} lib/shared/services/ \; 2>/dev/null
    echo "  🔗 Shared services moved"
fi

if [ -d "lib/providers" ]; then
    find lib/providers -name "*.dart" -type f -exec mv {} lib/shared/providers/ \; 2>/dev/null
    echo "  🔗 Shared providers moved"
fi

# Clean up empty directories
echo "🧹 Cleaning up empty directories..."
find lib -type d -empty -delete 2>/dev/null

echo "✅ Modular organization complete!"
echo ""
echo "📁 New structure:"
echo "  📦 Product Management"
echo "  📊 Inventory Management" 
echo "  🏪 Store Management"
echo "  👥 User Management"
echo "  📋 Order Management"
echo "  📈 Analytics"
echo "  💰 POS System"
echo "  🔗 Shared Components"
echo "  ⚙️ Core Utilities"
