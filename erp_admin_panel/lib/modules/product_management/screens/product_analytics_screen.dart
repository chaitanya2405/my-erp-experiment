import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../../services/store_service.dart';
import '../../../models/store_models.dart';

class ProductAnalyticsScreen extends StatelessWidget {
  const ProductAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No products found.'));
            }

            // Count products by category, always storing int values
            final Map<String, int> categoryCounts = {};
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final category = data['category']?.toString() ?? 'Unknown';
              final prevInt = categoryCounts[category] ?? 0;
              print('category: $category, prev: $prevInt');
              categoryCounts[category] = prevInt + 1;
            }
            final categories = categoryCounts.keys.toList();
            final counts = categoryCounts.values.map((e) => e.toDouble()).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Product Count by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: List.generate(categories.length, (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: counts[i],
                            color: Colors.blue,
                          )
                        ],
                        showingTooltipIndicators: [0],
                      )),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final idx = value.toInt();
                              String label = '';
                              if (idx >= 0 && idx < categories.length) {
                                label = categories[idx].toString();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  label,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildStoreProductFlowchartCard(),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final productName = data['product_name']?.toString() ?? '';
                      final barcode = data['barcode']?.toString() ?? '';
                      final category = data['category']?.toString() ?? '';
                      final price = double.tryParse(data['selling_price']?.toString() ?? '') ?? 0.0;
                      final status = data['product_status']?.toString() ?? '';
                      return ListTile(
                        title: Text(productName),
                        subtitle: Text('Barcode: $barcode | Category: $category | Price: $price | Status: $status'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoreProductFlowchartCard() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_tree, size: 32, color: Colors.blue[800]),
                  const SizedBox(width: 12),
                  const Text(
                    '🏪 Store-Product Distribution Flowchart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 500,
              child: FutureBuilder<List<Store>>(
                future: _getStores(),
                builder: (context, storeSnapshot) {
                  if (storeSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading stores and products...'),
                        ],
                      ),
                    );
                  }
                  
                  if (storeSnapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading stores: ${storeSnapshot.error}'),
                        ],
                      ),
                    );
                  }
                  
                  final stores = storeSnapshot.data ?? [];
                  
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').snapshots(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final products = productSnapshot.data?.docs ?? [];
                      
                      if (stores.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No stores found. Please add stores first.'),
                            ],
                          ),
                        );
                      }
                      
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue[300]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: max(1000, stores.length * 250.0),
                            height: 500,
                            child: CustomPaint(
                              painter: EnhancedStoreProductFlowchartPainter(stores, products),
                              size: Size(max(1000, stores.length * 250.0), 500),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildFlowchartLegend(),
          ],
        ),
      ),
    );
  }

  Future<List<Store>> _getStores() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('stores').get();
      return snapshot.docs.map((doc) => Store.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching stores: $e');
      return [];
    }
  }

  Widget _buildFlowchartLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Flowchart Legend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildLegendItem(Colors.green[600]!, 'Active Store'),
              _buildLegendItem(Colors.red[600]!, 'Inactive Store'),
              _buildLegendItem(Colors.purple[600]!, 'Product Hub'),
              _buildLegendItem(Colors.orange[600]!, 'Product Count'),
              _buildLegendItem(Colors.blue[400]!, 'Data Flow'),
              _buildLegendItem(Colors.purple[400]!, 'Categories'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)
          ),
        ],
      ),
    );
  }
}

class EnhancedStoreProductFlowchartPainter extends CustomPainter {
  final List<Store> stores;
  final List<QueryDocumentSnapshot> products;

  EnhancedStoreProductFlowchartPainter(this.stores, this.products);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Clean background with subtle gradient
    _drawGradientBackground(canvas, size);

    if (stores.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    // Group products by category
    Map<String, List<QueryDocumentSnapshot>> productsByCategory = {};
    for (var product in products) {
      final data = product.data() as Map<String, dynamic>;
      final category = data['category']?.toString() ?? 'Unknown';
      productsByCategory.putIfAbsent(category, () => []).add(product);
    }

    // Calculate clean layout
    double centerX = size.width / 2;
    double centerY = size.height * 0.3;
    double storeRadius = min(size.width / (stores.length + 2) / 2, 80);
    double connectionRadius = min(size.width * 0.35, 250);

    // Draw title
    _drawCleanTitle(canvas, size);

    // Draw central hub with modern design
    _drawModernHub(canvas, centerX, centerY, products.length);

    // Draw stores in a clean circle layout
    for (int i = 0; i < stores.length; i++) {
      final store = stores[i];
      double angle = (2 * pi * i / stores.length) - pi / 2; // Start from top
      double storeX = centerX + connectionRadius * cos(angle);
      double storeY = centerY + connectionRadius * sin(angle);

      // Draw connection with smooth curve
      _drawSmoothConnection(canvas, centerX, centerY, storeX, storeY);

      // Draw store with clean design
      _drawCleanStore(canvas, store, storeX, storeY, i, products.length, stores.length);
    }

    // Draw category overview
    _drawCategoryOverview(canvas, size, productsByCategory);

    // Draw clean statistics
    _drawCleanStatistics(canvas, size, stores.length, products.length, productsByCategory.length);
  }

  void _drawGradientBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue[50]!, Colors.white, Colors.blue[25]!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    _drawText(canvas, '🏪', Offset(size.width / 2, size.height / 2 - 40), 
              const TextStyle(fontSize: 48, color: Colors.grey));
    _drawText(canvas, 'No stores available', 
              Offset(size.width / 2, size.height / 2), 
              const TextStyle(fontSize: 16, color: Colors.grey));
  }

  void _drawCleanTitle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.blue[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Title background
    final titleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 20, size.width - 40, 50),
      const Radius.circular(12),
    );
    canvas.drawRRect(titleRect, paint);
    canvas.drawRRect(titleRect, strokePaint);

    _drawText(canvas, '🏪 Store-Product Distribution', 
              Offset(size.width / 2, 45), 
              TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[800]));
  }

  void _drawModernHub(Canvas canvas, double centerX, double centerY, int productCount) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Outer glow
    paint.shader = RadialGradient(
      colors: [Colors.purple[400]!.withOpacity(0.3), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: 60));
    canvas.drawCircle(Offset(centerX, centerY), 60, paint);

    // Main hub circle
    paint.shader = RadialGradient(
      colors: [Colors.purple[600]!, Colors.purple[800]!],
    ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: 35));
    canvas.drawCircle(Offset(centerX, centerY), 35, paint);

    // Hub border
    strokePaint.color = Colors.purple[200]!;
    canvas.drawCircle(Offset(centerX, centerY), 35, strokePaint);

    // Hub content
    _drawText(canvas, '📦', Offset(centerX, centerY - 10), 
              const TextStyle(fontSize: 20));
    _drawText(canvas, '$productCount Products', 
              Offset(centerX, centerY + 8), 
              const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
  }

  void _drawSmoothConnection(Canvas canvas, double centerX, double centerY, double storeX, double storeY) {
    final paint = Paint()
      ..color = Colors.blue[300]!.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(centerX, centerY);
    
    // Create a smooth curve
    double midX = (centerX + storeX) / 2;
    double midY = (centerY + storeY) / 2;
    path.quadraticBezierTo(midX, midY - 30, storeX, storeY);
    
    canvas.drawPath(path, paint);

    // Draw data flow indicator
    _drawFlowIndicator(canvas, centerX, centerY, storeX, storeY);
  }

  void _drawFlowIndicator(Canvas canvas, double centerX, double centerY, double storeX, double storeY) {
    final paint = Paint()
      ..color = Colors.blue[600]!
      ..style = PaintingStyle.fill;

    // Calculate position along the curve
    double t = 0.7; // Position along the curve
    double x = centerX + t * (storeX - centerX);
    double y = centerY + t * (storeY - centerY) - 15; // Slight curve

    // Draw arrow
    canvas.drawCircle(Offset(x, y), 4, paint);
    
    // Direction arrow
    double angle = atan2(storeY - centerY, storeX - centerX);
    _drawSmallArrow(canvas, Offset(x, y), angle);
  }

  void _drawSmallArrow(Canvas canvas, Offset position, double angle) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double arrowLength = 8;
    double arrowAngle = 0.4;

    Offset arrowPoint1 = Offset(
      position.dx + arrowLength * cos(angle - arrowAngle),
      position.dy + arrowLength * sin(angle - arrowAngle),
    );
    
    Offset arrowPoint2 = Offset(
      position.dx + arrowLength * cos(angle + arrowAngle),
      position.dy + arrowLength * sin(angle + arrowAngle),
    );

    canvas.drawLine(position, arrowPoint1, paint);
    canvas.drawLine(position, arrowPoint2, paint);
  }

  void _drawCleanStore(Canvas canvas, Store store, double x, double y, int index, int totalProducts, int totalStores) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Color statusColor = store.storeStatus == 'Active' ? Colors.green[500]! : Colors.orange[500]!;
    
    // Store shadow
    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawCircle(Offset(x + 2, y + 2), 30, paint);

    // Store background
    paint.color = statusColor.withOpacity(0.1);
    canvas.drawCircle(Offset(x, y), 32, paint);

    // Store main circle
    paint.shader = RadialGradient(
      colors: [statusColor.withOpacity(0.8), statusColor],
    ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 28));
    canvas.drawCircle(Offset(x, y), 28, paint);

    // Store border
    strokePaint.color = statusColor;
    canvas.drawCircle(Offset(x, y), 28, strokePaint);

    // Store icon
    paint.shader = null;
    paint.color = Colors.white;
    _drawText(canvas, '🏪', Offset(x, y - 5), const TextStyle(fontSize: 16));

    // Store name (clean, truncated)
    String displayName = store.storeName.length > 12 
        ? '${store.storeName.substring(0, 12)}...' 
        : store.storeName;
    _drawText(canvas, displayName, Offset(x, y - 50), 
              TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.blue[800]));

    // Product count badge
    int storeProductCount = (totalProducts / totalStores).round();
    if (index < totalProducts % totalStores) storeProductCount++;

    paint.color = Colors.white;
    canvas.drawCircle(Offset(x + 20, y - 20), 12, paint);
    strokePaint.color = Colors.orange[600]!;
    canvas.drawCircle(Offset(x + 20, y - 20), 12, strokePaint);
    
    _drawText(canvas, storeProductCount.toString(), 
              Offset(x + 20, y - 20), 
              TextStyle(color: Colors.orange[600], fontSize: 10, fontWeight: FontWeight.bold));

    // Status indicator
    String statusText = store.storeStatus == 'Active' ? '● Online' : '● Offline';
    Color statusTextColor = store.storeStatus == 'Active' ? Colors.green[600]! : Colors.orange[600]!;
    _drawText(canvas, statusText, Offset(x, y + 45), 
              TextStyle(color: statusTextColor, fontSize: 10, fontWeight: FontWeight.w600));
  }

  void _drawCategoryOverview(Canvas canvas, Size size, Map<String, List<QueryDocumentSnapshot>> productsByCategory) {
    if (productsByCategory.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.blue[200]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Category panel background
    paint.color = Colors.white.withOpacity(0.9);
    final categoryRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, size.height - 120, 250, 80),
      const Radius.circular(8),
    );
    canvas.drawRRect(categoryRect, paint);
    canvas.drawRRect(categoryRect, strokePaint);

    // Category title
    _drawText(canvas, '📊 Categories', Offset(145, size.height - 105), 
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue[800]));

    // Category items
    int displayCount = min(productsByCategory.length, 4);
    double startX = 35;
    
    for (int i = 0; i < displayCount; i++) {
      var entry = productsByCategory.entries.elementAt(i);
      double itemX = startX + (i * 50);
      
      // Category color
      Color categoryColor = _getCategoryColor(i);
      paint.color = categoryColor;
      canvas.drawCircle(Offset(itemX, size.height - 80), 8, paint);
      
      // Category name and count
      String categoryText = '${entry.key.length > 6 ? entry.key.substring(0, 6) : entry.key}\n${entry.value.length}';
      _drawText(canvas, categoryText, Offset(itemX, size.height - 60), 
                const TextStyle(fontSize: 8, fontWeight: FontWeight.w500));
    }
  }

  void _drawCleanStatistics(Canvas canvas, Size size, int storeCount, int productCount, int categoryCount) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.blue[200]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Stats panel background
    paint.color = Colors.white.withOpacity(0.9);
    final statsRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 270, size.height - 120, 250, 80),
      const Radius.circular(8),
    );
    canvas.drawRRect(statsRect, paint);
    canvas.drawRRect(statsRect, strokePaint);

    // Stats content
    _drawText(canvas, '📈 Live Stats', Offset(size.width - 145, size.height - 105), 
              TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue[800]));

    String statsText = 'Stores: $storeCount  |  Products: $productCount  |  Categories: $categoryCount';
    _drawText(canvas, statsText, Offset(size.width - 145, size.height - 85), 
              TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.w500));

    String distribution = 'Avg per Store: ${(productCount / max(storeCount, 1)).round()}  |  🟢 Real-time Sync';
    _drawText(canvas, distribution, Offset(size.width - 145, size.height - 65), 
              TextStyle(fontSize: 9, color: Colors.green[600], fontWeight: FontWeight.w500));
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.purple[400]!, 
      Colors.orange[400]!, 
      Colors.teal[400]!, 
      Colors.pink[400]!, 
      Colors.indigo[400]!,
      Colors.amber[400]!,
      Colors.cyan[400]!,
      Colors.lime[400]!
    ];
    return colors[index % colors.length];
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}