// 📱 PRODUCT DETAIL SCREEN
// Detailed product view with add to cart functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_erp_package/shared_erp_package.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product ?? 
        ModalRoute.of(context)?.settings.arguments as Product?;
    
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement add to favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: product.imageUrls.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage();
                                    },
                                  ),
                                )
                              : _buildPlaceholderImage(),
                        );
                      },
                    ),
                  ),

                  // Image indicators
                  if (product.imageUrls.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        product.imageUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedImageIndex == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.category,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Price
                        Row(
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (product.discountPercent != null && product.discountPercent! > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '₹${(product.price / (1 - product.discountPercent! / 100)).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${product.discountPercent!.toStringAsFixed(0)}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stock Status
                        Row(
                          children: [
                            Icon(
                              product.stockQuantity > 0 ? Icons.check_circle : Icons.error,
                              color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.stockQuantity > 0 
                                  ? 'In Stock (${product.stockQuantity} available)'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        if (product.description.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Quantity Selector
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? () {
                                setState(() {
                                  _quantity--;
                                });
                              } : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _quantity.toString(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < product.stockQuantity ? () {
                                setState(() {
                                  _quantity++;
                                });
                              } : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Add to Cart Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: product.stockQuantity > 0 ? () {
                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addItem(product, _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_quantity ${product.name} to cart'),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                          ),
                        ),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      product.stockQuantity > 0 
                          ? 'Add to Cart - ₹${(product.price * _quantity).toStringAsFixed(2)}'
                          : 'Out of Stock',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }
}
