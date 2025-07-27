import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/original_models.dart';
import '../models/store_models.dart';
import '../services/enhanced_services.dart';
import '../services/store_service.dart';

/// 🏪📦 Store-Aware Product Management Screen
/// Shows product information with store-specific availability and inventory
class StoreAwareProductScreen extends StatefulWidget {
  const StoreAwareProductScreen({super.key});

  @override
  State<StoreAwareProductScreen> createState() => _StoreAwareProductScreenState();
}

class _StoreAwareProductScreenState extends State<StoreAwareProductScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStoreFilter = 'All Stores';
  String _availabilityFilter = 'All';
  
  List<Store> _stores = [];
  List<Product> _products = [];
  Map<String, Map<String, int>> _storeInventory = {}; // productId -> storeId -> quantity
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load stores and products
      final stores = await StoreService.searchStores();
      final products = await EnhancedProductService.getAllProducts();
      
      // Load store-specific inventory
      final inventory = await _loadStoreInventory(products.map((p) => p.productId).toList());
      
      setState(() {
        _stores = stores;
        _products = products;
        _storeInventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<Map<String, Map<String, int>>> _loadStoreInventory(List<String> productIds) async {
    final inventory = <String, Map<String, int>>{};
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('inventory')
          .where('product_id', whereIn: productIds.take(10).toList()) // Firestore limit
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final productId = data['product_id'] as String;
        final storeId = data['store_id'] as String;
        final quantity = data['quantity_available'] as int? ?? 0;
        
        inventory[productId] ??= {};
        inventory[productId]![storeId] = quantity;
      }
    } catch (e) {
      print('Error loading store inventory: $e');
    }
    
    return inventory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store-Aware Product Management'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Products & Availability'),
            Tab(icon: Icon(Icons.store), text: 'Store Comparison'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildStoreComparisonTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        _buildFiltersRow(),
        Expanded(child: _buildProductsList()),
      ],
    );
  }

  Widget _buildFiltersRow() {
    final categories = ['All', ...Set.from(_products.map((p) => p.category))];
    final availabilityOptions = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products by name, SKU, or category...',
              prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: categories.map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStoreFilter,
                  decoration: const InputDecoration(
                    labelText: 'Store Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(value: 'All Stores', child: Text('All Stores')),
                    ..._stores.map((store) => DropdownMenuItem<String>(
                      value: store.storeId,
                      child: Text(store.storeName),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedStoreFilter = value!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _availabilityFilter,
                  decoration: const InputDecoration(
                    labelText: 'Availability',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: availabilityOptions.map((opt) => DropdownMenuItem<String>(value: opt, child: Text(opt))).toList(),
                  onChanged: (value) => setState(() => _availabilityFilter = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    final filteredProducts = _getFilteredProducts();
    
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found matching your filters',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) => _buildStoreAwareProductCard(filteredProducts[index]),
    );
  }

  List<Product> _getFilteredProducts() {
    return _products.where((product) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.productName.toLowerCase().contains(query) &&
            !product.sku.toLowerCase().contains(query) &&
            !product.category.toLowerCase().contains(query) &&
            !(product.barcode?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      
      // Category filter
      if (_selectedCategory != 'All' && product.category != _selectedCategory) {
        return false;
      }
      
      // Store filter
      if (_selectedStoreFilter != 'All Stores') {
        final storeInventory = _storeInventory[product.productId];
        if (storeInventory == null || !storeInventory.containsKey(_selectedStoreFilter)) {
          return false;
        }
      }
      
      // Availability filter
      if (_availabilityFilter != 'All') {
        final totalStock = _getTotalStock(product.productId);
        switch (_availabilityFilter) {
          case 'In Stock':
            if (totalStock <= product.minStockLevel) return false;
            break;
          case 'Low Stock':
            if (totalStock > product.minStockLevel || totalStock == 0) return false;
            break;
          case 'Out of Stock':
            if (totalStock > 0) return false;
            break;
        }
      }
      
      return true;
    }).toList();
  }

  int _getTotalStock(String productId) {
    final storeInventory = _storeInventory[productId];
    if (storeInventory == null) return 0;
    return storeInventory.values.fold(0, (sum, quantity) => sum + quantity);
  }

  Widget _buildStoreAwareProductCard(Product product) {
    final storeInventory = _storeInventory[product.productId] ?? {};
    final totalStock = storeInventory.values.fold(0, (sum, quantity) => sum + quantity);
    final storesWithStock = storeInventory.entries.where((e) => e.value > 0).length;
    final totalStores = _stores.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStockStatusColor(totalStock, product.minStockLevel),
          child: Text(
            storesWithStock.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${product.sku} • ${product.category}'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStockChip('Total: $totalStock', _getStockStatusColor(totalStock, product.minStockLevel)),
                const SizedBox(width: 8),
                _buildStockChip('$storesWithStock/$totalStores stores', Colors.blue),
                const SizedBox(width: 8),
                _buildPriceChip('₹${product.sellingPrice.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
        children: [
          _buildStoreInventoryDetails(product, storeInventory),
        ],
      ),
    );
  }

  Widget _buildStockChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStoreInventoryDetails(Product product, Map<String, int> storeInventory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store Availability',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ..._stores.map((store) {
            final quantity = storeInventory[store.storeId] ?? 0;
            final isAvailable = quantity > 0;
            final isLowStock = quantity > 0 && quantity <= product.minStockLevel;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAvailable 
                      ? (isLowStock ? Colors.orange[300]! : Colors.green[300]!)
                      : Colors.red[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    store.storeType == 'Warehouse' ? Icons.warehouse : Icons.store,
                    color: isAvailable 
                        ? (isLowStock ? Colors.orange : Colors.green)
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.storeName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${store.storeCode} • ${store.city}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable 
                          ? (isLowStock ? Colors.orange : Colors.green)
                          : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isAvailable ? '$quantity units' : 'Out of Stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _transferStock(product),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transfer Stock'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _adjustInventory(product),
                  icon: const Icon(Icons.tune),
                  label: const Text('Adjust Inventory'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStockStatusColor(int stock, int minLevel) {
    if (stock == 0) return Colors.red;
    if (stock <= minLevel) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStoreComparisonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Inventory Comparison',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._stores.map((store) => _buildStoreOverviewCard(store)),
        ],
      ),
    );
  }

  Widget _buildStoreOverviewCard(Store store) {
    final storeProducts = _storeInventory.entries
        .where((entry) => entry.value.containsKey(store.storeId))
        .length;
    final totalStoreStock = _storeInventory.entries
        .fold<int>(0, (sum, entry) => sum + (entry.value[store.storeId] ?? 0));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  store.storeType == 'Warehouse' ? Icons.warehouse : Icons.store,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${store.storeCode} • ${store.city} • ${store.storeType}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: store.storeStatus == 'Active' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    store.storeStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Products', storeProducts.toString(), Icons.inventory_2),
                ),
                Expanded(
                  child: _buildStatCard('Total Stock', totalStoreStock.toString(), Icons.warehouse),
                ),
                Expanded(
                  child: _buildStatCard('Utilization', '${((storeProducts / _products.length) * 100).toStringAsFixed(0)}%', Icons.donut_small),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.indigo, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final totalProducts = _products.length;
    final totalStores = _stores.length;
    final productsInStock = _products.where((p) => _getTotalStock(p.productId) > 0).length;
    final lowStockProducts = _products.where((p) {
      final stock = _getTotalStock(p.productId);
      return stock > 0 && stock <= p.minStockLevel;
    }).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store & Product Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildAnalyticsCard('Total Products', totalProducts.toString(), Icons.inventory_2, Colors.blue),
              _buildAnalyticsCard('Total Stores', totalStores.toString(), Icons.store, Colors.green),
              _buildAnalyticsCard('In Stock', productsInStock.toString(), Icons.check_circle, Colors.green),
              _buildAnalyticsCard('Low Stock', lowStockProducts.toString(), Icons.warning, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Category Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._buildCategoryAnalytics(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryAnalytics() {
    final categoryMap = <String, int>{};
    for (final product in _products) {
      categoryMap[product.category] = (categoryMap[product.category] ?? 0) + 1;
    }
    
    return categoryMap.entries.map((entry) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: const Text('This will open the product creation form with store assignment options.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to add product screen
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _transferStock(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer Stock - ${product.productName}'),
        content: const Text('This will open the stock transfer interface between stores.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open transfer stock screen
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  void _adjustInventory(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Inventory - ${product.productName}'),
        content: const Text('This will open the inventory adjustment interface for all stores.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open inventory adjustment screen
            },
            child: const Text('Adjust'),
          ),
        ],
      ),
    );
  }
}
