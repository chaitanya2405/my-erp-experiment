import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/original_models.dart';
import '../services/enhanced_services.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<CartItem> _cartItems = [];
  final _customerController = TextEditingController();
  double _total = 0.0;
  double _tax = 0.0;
  double _discount = 0.0;
  String _paymentMethod = 'Cash';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showTransactionHistory(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Products
          Expanded(
            flex: 2,
            child: _buildProductPanel(),
          ),
          
          // Right Panel - Cart and Checkout
          Expanded(
            flex: 1,
            child: _buildCartPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPanel() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: EnhancedProductService.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final products = snapshot.data ?? [];
                final activeProducts = products.where((p) => p.productStatus == 'active').toList();
                
                if (activeProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Products Available',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: activeProducts.length,
                  itemBuilder: (context, index) {
                    final product = activeProducts[index];
                    return _buildProductCard(product.productId, {
                      'name': product.productName,
                      'sale_price': product.sellingPrice,
                      'cost_price': product.costPrice,
                      'category': product.category,
                      'product_status': product.productStatus,
                      'current_stock': product.currentStock,
                      'min_stock_level': product.minStockLevel,
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String productId, Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addToCart(productId, product),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product['name'] ?? 'Unknown Product',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '₹${product['sale_price']?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stock: ${product['current_stock'] ?? 0}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartPanel() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cart Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade700,
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_cartItems.length} items',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Customer Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _customerController,
              decoration: InputDecoration(
                labelText: 'Customer Mobile (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ),
          
          // Cart Items
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is Empty',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const Text('Add products to start sale'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
          ),
          
          // Total and Checkout Section
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('₹${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _updateQuantity(index, item.quantity - 1),
                  icon: const Icon(Icons.remove),
                  iconSize: 16,
                ),
                Text('${item.quantity}'),
                IconButton(
                  onPressed: () => _updateQuantity(index, item.quantity + 1),
                  icon: const Icon(Icons.add),
                  iconSize: 16,
                ),
                IconButton(
                  onPressed: () => _removeFromCart(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    _calculateTotals();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Payment Method
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: ['Cash', 'Card', 'UPI', 'Wallet'].map((method) {
              return DropdownMenuItem(value: method, child: Text(method));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _paymentMethod = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Totals
          _buildTotalRow('Subtotal', _total - _tax),
          _buildTotalRow('Tax (18%)', _tax),
          if (_discount > 0) _buildTotalRow('Discount', -_discount),
          const Divider(),
          _buildTotalRow('Total', _total, isTotal: true),
          
          const SizedBox(height: 16),
          
          // Checkout Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cartItems.isEmpty ? null : _clearCart,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(String productId, Map<String, dynamic> product) {
    final existingIndex = _cartItems.indexWhere((item) => item.id == productId);
    
    if (existingIndex >= 0) {
      _updateQuantity(existingIndex, _cartItems[existingIndex].quantity + 1);
    } else {
      setState(() {
        _cartItems.add(CartItem(
          id: productId,
          name: product['name'] ?? 'Unknown Product',
          price: (product['sale_price'] ?? 0).toDouble(),
          quantity: 1,
        ));
      });
    }
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _cartItems[index].quantity = newQuantity;
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _calculateTotals() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    _tax = subtotal * 0.18; // 18% tax
    _total = subtotal + _tax - _discount;
  }

  void _processCheckout() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Processing transaction...'),
            ],
          ),
        ),
      );

      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      final now = Timestamp.now();
      
      // Prepare transaction items with product IDs
      final transactionItems = _cartItems.map((item) => {
        'product_id': item.id,
        'product_name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'total': item.price * item.quantity,
      }).toList();

      // Create POS transaction object
      final transaction = PosTransaction(
        transactionId: transactionId,
        storeId: 'default_store',
        customerId: _customerController.text.trim().isEmpty ? null : _customerController.text.trim(),
        cashierId: 'current_user',
        transactionDate: now,
        items: transactionItems,
        subtotal: _total - _tax,
        discountAmount: _discount,
        taxAmount: _tax,
        totalAmount: _total,
        paymentMethod: _paymentMethod,
        transactionStatus: 'completed',
        receiptNumber: transactionId,
        customerInfo: _customerController.text.trim().isEmpty ? null : {
          'mobile': _customerController.text.trim(),
        },
        notes: 'POS Sale',
        createdAt: now,
        updatedAt: now,
      );

      // Process transaction with automatic inventory updates
      final success = await EnhancedPosService.addTransaction(transaction);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (success != null) {
        _showReceiptDialog(transactionId);
        _clearCart();
        _customerController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Transaction completed! Inventory updated automatically.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Transaction failed! Insufficient stock or error occurred.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReceiptDialog(String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('Transaction ID: $transactionId'),
            Text('Amount: ₹${_total.toStringAsFixed(2)}'),
            Text('Payment: $_paymentMethod'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would print the receipt
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt printed successfully!')),
              );
            },
            child: const Text('Print Receipt'),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionHistoryScreen(),
      ),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pos_transactions')
            .orderBy('transaction_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final transactions = snapshot.data?.docs ?? [];
          
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Transaction #${transaction['transaction_id']}'),
                subtitle: Text('₹${transaction['total_amount']?.toStringAsFixed(2)} - ${transaction['payment_method']}'),
                trailing: Text(_formatTimestamp(transaction['transaction_time'])),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return timestamp.toString();
  }
}
