import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/pos_transaction.dart';

class PosAiAssistant {
  // AI-powered product recommendations
  static List<Map<String, dynamic>> getUpsellRecommendations({
    required List<Map<String, dynamic>> currentItems,
    required String customerTier,
    required double currentTotal,
    required List<Map<String, dynamic>> availableProducts,
    required List<PosTransaction> customerHistory,
  }) {
    List<Map<String, dynamic>> recommendations = [];

    // 1. Complementary products based on current items
    final complementaryProducts = _getComplementaryProducts(currentItems, availableProducts);
    recommendations.addAll(complementaryProducts);

    // 2. Customer tier-based recommendations
    final tierBasedProducts = _getTierBasedRecommendations(customerTier, availableProducts, currentTotal);
    recommendations.addAll(tierBasedProducts);

    // 3. Historical purchase patterns
    final historyBasedProducts = _getHistoryBasedRecommendations(customerHistory, availableProducts, currentItems);
    recommendations.addAll(historyBasedProducts);

    // 4. Seasonal and trending products
    final seasonalProducts = _getSeasonalRecommendations(availableProducts);
    recommendations.addAll(seasonalProducts);

    // 5. Bundle offers
    final bundleOffers = _getBundleRecommendations(currentItems, availableProducts);
    recommendations.addAll(bundleOffers);

    // Remove duplicates and sort by confidence score
    final uniqueRecommendations = _removeDuplicatesAndScore(recommendations);

    // Return top 5 recommendations
    return uniqueRecommendations.take(5).toList();
  }

  // Smart stock alerts and suggestions
  static Map<String, dynamic> getStockInsights({
    required List<Map<String, dynamic>> currentStock,
    required List<PosTransaction> recentTransactions,
    required DateTime analysisDate,
  }) {
    final insights = <String, dynamic>{};

    // 1. Low stock alerts
    insights['low_stock_items'] = _getLowStockItems(currentStock);

    // 2. Fast-moving items
    insights['fast_moving_items'] = _getFastMovingItems(recentTransactions, currentStock);

    // 3. Slow-moving items
    insights['slow_moving_items'] = _getSlowMovingItems(recentTransactions, currentStock);

    // 4. Optimal reorder suggestions
    insights['reorder_suggestions'] = _getReorderSuggestions(currentStock, recentTransactions);

    // 5. Demand forecast
    insights['demand_forecast'] = _generateDemandForecast(recentTransactions, analysisDate);

    // 6. Revenue impact analysis
    insights['revenue_impact'] = _analyzeRevenueImpact(recentTransactions, currentStock);

    return insights;
  }

  // Dynamic pricing suggestions
  static Map<String, dynamic> getPricingRecommendations({
    required List<Map<String, dynamic>> products,
    required List<PosTransaction> marketData,
    required String customerTier,
    required DateTime currentTime,
  }) {
    final pricingInsights = <String, dynamic>{};

    // 1. Dynamic pricing based on demand
    pricingInsights['demand_based_pricing'] = _getDemandBasedPricing(products, marketData);

    // 2. Time-based pricing (happy hours, etc.)
    pricingInsights['time_based_pricing'] = _getTimeBasedPricing(products, currentTime);

    // 3. Customer tier pricing
    pricingInsights['tier_based_pricing'] = _getTierBasedPricing(products, customerTier);

    // 4. Competitive pricing insights
    pricingInsights['competitive_analysis'] = _getCompetitivePricingAnalysis(products);

    // 5. Profit optimization
    pricingInsights['profit_optimization'] = _getProfitOptimization(products, marketData);

    return pricingInsights;
  }

  // Customer behavior analysis
  static Map<String, dynamic> analyzeCustomerBehavior({
    required List<PosTransaction> transactions,
    required String customerId,
    required DateTime analysisDate,
  }) {
    final customerTransactions = transactions.where(
      (t) => t.customerPhone.isNotEmpty && t.customerPhone == customerId,
    ).toList();

    if (customerTransactions.isEmpty) {
      return {'error': 'No transaction history found'};
    }

    return {
      'purchase_frequency': _calculatePurchaseFrequency(customerTransactions),
      'average_basket_size': _calculateAverageBasketSize(customerTransactions),
      'preferred_categories': _getPreferredCategories(customerTransactions),
      'price_sensitivity': _analyzePriceSensitivity(customerTransactions),
      'seasonal_patterns': _analyzeSeasonalPatterns(customerTransactions),
      'loyalty_score': _calculateLoyaltyScore(customerTransactions, analysisDate),
      'churn_risk': _assessChurnRisk(customerTransactions, analysisDate),
      'lifetime_value': _calculateCustomerLifetimeValue(customerTransactions),
      'next_purchase_prediction': _predictNextPurchase(customerTransactions),
    };
  }

  // Sales optimization suggestions
  static Map<String, dynamic> getSalesOptimizationTips({
    required List<PosTransaction> transactions,
    required DateTime analysisDate,
    required String storeId,
  }) {
    return {
      'peak_hours': _identifyPeakHours(transactions),
      'staff_optimization': _getStaffOptimizationTips(transactions),
      'layout_suggestions': _getLayoutSuggestions(transactions),
      'promotion_opportunities': _identifyPromotionOpportunities(transactions),
      'cross_sell_opportunities': _identifyCrossSellOpportunities(transactions),
      'customer_retention_tips': _getCustomerRetentionTips(transactions),
      'revenue_optimization': _getRevenueOptimizationTips(transactions),
    };
  }

  // Private helper methods

  static List<Map<String, dynamic>> _getComplementaryProducts(
    List<Map<String, dynamic>> currentItems,
    List<Map<String, dynamic>> availableProducts,
  ) {
    final complementaryMap = {
      'electronics': ['accessories', 'cables', 'cases'],
      'clothing': ['accessories', 'footwear', 'bags'],
      'food_grains': ['spices', 'oil', 'pulses'],
      'dairy': ['bread', 'fruits', 'cereals'],
      'fruits': ['dairy', 'nuts', 'juices'],
      'vegetables': ['spices', 'oil', 'grains'],
    };

    List<Map<String, dynamic>> recommendations = [];
    
    for (final item in currentItems) {
      final category = item['category'] as String? ?? '';
      final complementaryCategories = complementaryMap[category] ?? [];
      
      for (final complementaryCategory in complementaryCategories) {
        final complementaryProducts = availableProducts.where(
          (p) => p['category'] == complementaryCategory,
        ).toList();
        
        for (final product in complementaryProducts.take(2)) {
          recommendations.add({
            ...product,
            'recommendation_type': 'complementary',
            'confidence_score': 0.8,
            'reason': 'Goes well with ${item['product_name']}',
          });
        }
      }
    }

    return recommendations;
  }

  static List<Map<String, dynamic>> _getTierBasedRecommendations(
    String customerTier,
    List<Map<String, dynamic>> availableProducts,
    double currentTotal,
  ) {
    final tierPriceRanges = {
      'VIP': {'min': 1000.0, 'max': 10000.0},
      'Premium': {'min': 500.0, 'max': 5000.0},
      'Gold': {'min': 200.0, 'max': 2000.0},
      'Silver': {'min': 100.0, 'max': 1000.0},
      'Regular': {'min': 50.0, 'max': 500.0},
    };

    final priceRange = tierPriceRanges[customerTier] ?? tierPriceRanges['Regular']!;
    
    return availableProducts.where((product) {
      final price = (product['unit_price'] as num?)?.toDouble() ?? 0.0;
      return price >= priceRange['min']! && price <= priceRange['max']!;
    }).map((product) => {
      ...product,
      'recommendation_type': 'tier_based',
      'confidence_score': 0.7,
      'reason': 'Perfect for $customerTier customers',
    }).take(3).toList();
  }

  static List<Map<String, dynamic>> _getHistoryBasedRecommendations(
    List<PosTransaction> customerHistory,
    List<Map<String, dynamic>> availableProducts,
    List<Map<String, dynamic>> currentItems,
  ) {
    if (customerHistory.isEmpty) return [];

    // Analyze customer's purchase patterns
    Map<String, int> categoryFrequency = {};
    Map<String, int> productFrequency = {};

    for (final transaction in customerHistory) {
      for (final item in transaction.productItems) {
        final category = item['category'] as String? ?? '';
        final productName = item['product_name'] as String? ?? '';
        
        categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
        productFrequency[productName] = (productFrequency[productName] ?? 0) + 1;
      }
    }

    // Recommend products from frequently purchased categories
    final topCategories = categoryFrequency.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    List<Map<String, dynamic>> recommendations = [];
    
    for (final categoryEntry in topCategories.take(2)) {
      final category = categoryEntry.key;
      final categoryProducts = availableProducts.where(
        (p) => p['category'] == category,
      ).toList();

      for (final product in categoryProducts.take(2)) {
        // Don't recommend items already in cart
        final isInCart = currentItems.any(
          (item) => item['product_name'] == product['product_name'],
        );
        
        if (!isInCart) {
          recommendations.add({
            ...product,
            'recommendation_type': 'history_based',
            'confidence_score': 0.9,
            'reason': 'Based on your previous purchases',
          });
        }
      }
    }

    return recommendations;
  }

  static List<Map<String, dynamic>> _getSeasonalRecommendations(
    List<Map<String, dynamic>> availableProducts,
  ) {
    final currentMonth = DateTime.now().month;
    final seasonalCategories = <String>[];

    // Define seasonal categories
    if (currentMonth >= 3 && currentMonth <= 6) {
      // Spring/Summer
      seasonalCategories.addAll(['fruits', 'vegetables', 'beverages', 'cooling_products']);
    } else if (currentMonth >= 7 && currentMonth <= 10) {
      // Monsoon/Early Winter
      seasonalCategories.addAll(['warm_clothing', 'umbrellas', 'hot_beverages']);
    } else {
      // Winter
      seasonalCategories.addAll(['warm_clothing', 'heaters', 'winter_foods']);
    }

    return availableProducts.where((product) {
      final category = product['category'] as String? ?? '';
      return seasonalCategories.contains(category);
    }).map((product) => {
      ...product,
      'recommendation_type': 'seasonal',
      'confidence_score': 0.6,
      'reason': 'Trending this season',
    }).take(2).toList();
  }

  static List<Map<String, dynamic>> _getBundleRecommendations(
    List<Map<String, dynamic>> currentItems,
    List<Map<String, dynamic>> availableProducts,
  ) {
    // Define bundle combinations
    final bundles = {
      'electronics_bundle': {
        'items': ['smartphone', 'charger', 'case'],
        'discount': 0.1,
        'description': 'Mobile Essentials Bundle',
      },
      'kitchen_bundle': {
        'items': ['rice', 'dal', 'spices'],
        'discount': 0.08,
        'description': 'Kitchen Basics Bundle',
      },
      'office_bundle': {
        'items': ['notebook', 'pen', 'stapler'],
        'discount': 0.12,
        'description': 'Office Supplies Bundle',
      },
    };

    List<Map<String, dynamic>> recommendations = [];

    for (final bundleEntry in bundles.entries) {
      final bundleData = bundleEntry.value as Map<String, dynamic>;
      final bundleItems = bundleData['items'] as List<String>;
      
      // Check if any current item is part of this bundle
      final hasItemFromBundle = currentItems.any(
        (item) => bundleItems.contains(item['product_name']?.toString().toLowerCase()),
      );

      if (hasItemFromBundle) {
        final missingItems = bundleItems.where((bundleItem) {
          return !currentItems.any(
            (item) => item['product_name']?.toString().toLowerCase() == bundleItem,
          );
        }).toList();

        for (final missingItem in missingItems) {
          final product = availableProducts.firstWhere(
            (p) => p['product_name']?.toString().toLowerCase().contains(missingItem) == true,
            orElse: () => <String, dynamic>{},
          );

          if (product.isNotEmpty) {
            recommendations.add({
              ...product,
              'recommendation_type': 'bundle',
              'confidence_score': 0.85,
              'reason': 'Complete your ${bundleData['description']} and save ${((bundleData['discount'] as double) * 100).toInt()}%',
              'bundle_discount': bundleData['discount'],
            });
          }
        }
      }
    }

    return recommendations;
  }

  static List<Map<String, dynamic>> _removeDuplicatesAndScore(
    List<Map<String, dynamic>> recommendations,
  ) {
    final uniqueRecommendations = <String, Map<String, dynamic>>{};

    for (final recommendation in recommendations) {
      final productName = recommendation['product_name'] as String? ?? '';
      
      if (!uniqueRecommendations.containsKey(productName) ||
          (recommendation['confidence_score'] as double? ?? 0) >
          (uniqueRecommendations[productName]!['confidence_score'] as double? ?? 0)) {
        uniqueRecommendations[productName] = recommendation;
      }
    }

    final sortedRecommendations = uniqueRecommendations.values.toList()
      ..sort((a, b) => (b['confidence_score'] as double).compareTo(a['confidence_score'] as double));

    return sortedRecommendations;
  }

  static List<Map<String, dynamic>> _getLowStockItems(
    List<Map<String, dynamic>> currentStock,
  ) {
    return currentStock.where((item) {
      final currentQty = (item['current_quantity'] as num?)?.toInt() ?? 0;
      final minQty = (item['minimum_quantity'] as num?)?.toInt() ?? 10;
      return currentQty <= minQty;
    }).map((item) => {
      ...item,
      'alert_level': (item['current_quantity'] as num?)?.toInt() == 0 ? 'critical' : 'low',
      'suggested_reorder_qty': ((item['minimum_quantity'] as num?)?.toInt() ?? 10) * 3,
    }).toList();
  }

  static List<Map<String, dynamic>> _getFastMovingItems(
    List<PosTransaction> recentTransactions,
    List<Map<String, dynamic>> currentStock,
  ) {
    Map<String, int> salesCount = {};

    for (final transaction in recentTransactions) {
      for (final item in transaction.productItems) {
        final productName = item['product_name'] as String? ?? '';
        final quantity = item['quantity'] as int? ?? 0;
        salesCount[productName] = (salesCount[productName] ?? 0) + quantity;
      }
    }

    final fastMovingThreshold = salesCount.values.isNotEmpty 
        ? salesCount.values.reduce((a, b) => a > b ? a : b) * 0.7 
        : 0;

    return currentStock.where((item) {
      final productName = item['product_name'] as String? ?? '';
      return (salesCount[productName] ?? 0) >= fastMovingThreshold;
    }).map((item) => {
      ...item,
      'sales_velocity': salesCount[item['product_name']] ?? 0,
      'turnover_rate': 'high',
    }).toList();
  }

  static List<Map<String, dynamic>> _getSlowMovingItems(
    List<PosTransaction> recentTransactions,
    List<Map<String, dynamic>> currentStock,
  ) {
    Map<String, int> salesCount = {};

    for (final transaction in recentTransactions) {
      for (final item in transaction.productItems) {
        final productName = item['product_name'] as String? ?? '';
        final quantity = item['quantity'] as int? ?? 0;
        salesCount[productName] = (salesCount[productName] ?? 0) + quantity;
      }
    }

    final slowMovingThreshold = salesCount.values.isNotEmpty 
        ? salesCount.values.reduce((a, b) => a < b ? a : b) * 1.5 
        : 0;

    return currentStock.where((item) {
      final productName = item['product_name'] as String? ?? '';
      return (salesCount[productName] ?? 0) <= slowMovingThreshold;
    }).map((item) => {
      ...item,
      'sales_velocity': salesCount[item['product_name']] ?? 0,
      'turnover_rate': 'slow',
      'suggested_action': 'Consider promotion or discount',
    }).toList();
  }

  static List<Map<String, dynamic>> _getReorderSuggestions(
    List<Map<String, dynamic>> currentStock,
    List<PosTransaction> recentTransactions,
  ) {
    Map<String, double> averageDailySales = {};

    // Calculate average daily sales for each product
    for (final transaction in recentTransactions) {
      for (final item in transaction.productItems) {
        final productName = item['product_name'] as String? ?? '';
        final quantity = item['quantity'] as int? ?? 0;
        averageDailySales[productName] = (averageDailySales[productName] ?? 0) + quantity;
      }
    }

    final daysCovered = recentTransactions.isNotEmpty 
        ? recentTransactions.map((t) => t.transactionTime.day).toSet().length 
        : 1;

    averageDailySales.updateAll((key, value) => value / daysCovered);

    return currentStock.where((item) {
      final currentQty = (item['current_quantity'] as num?)?.toInt() ?? 0;
      final minQty = (item['minimum_quantity'] as num?)?.toInt() ?? 10;
      return currentQty <= minQty * 2; // Suggest reorder when stock is twice the minimum
    }).map((item) {
      final productName = item['product_name'] as String? ?? '';
      final dailySales = averageDailySales[productName] ?? 1.0;
      final leadTimeDays = (item['lead_time_days'] as num?)?.toInt() ?? 7;
      final safetyStock = dailySales * 3; // 3 days safety stock
      final reorderQty = (dailySales * leadTimeDays + safetyStock).ceil();

      return {
        ...item,
        'suggested_reorder_qty': reorderQty,
        'average_daily_sales': dailySales,
        'estimated_stockout_days': dailySales > 0 ? ((item['current_quantity'] as num?)?.toInt() ?? 0) / dailySales : 0,
        'priority': ((item['current_quantity'] as num?)?.toInt() ?? 0) <= ((item['minimum_quantity'] as num?)?.toInt() ?? 0) 
            ? 'high' : 'medium',
      };
    }).toList();
  }

  static Map<String, dynamic> _generateDemandForecast(
    List<PosTransaction> recentTransactions,
    DateTime analysisDate,
  ) {
    // Simplified demand forecasting based on recent trends
    Map<String, List<int>> dailySales = {};

    for (final transaction in recentTransactions) {
      final dayKey = '${transaction.transactionTime.year}-${transaction.transactionTime.month}-${transaction.transactionTime.day}';
      
      for (final item in transaction.productItems) {
        final productName = item['product_name'] as String? ?? '';
        final quantity = item['quantity'] as int? ?? 0;
        
        dailySales[productName] ??= [];
        dailySales[productName]!.add(quantity);
      }
    }

    Map<String, dynamic> forecast = {};

    for (final productEntry in dailySales.entries) {
      final productName = productEntry.key;
      final salesData = productEntry.value;
      
      if (salesData.length >= 3) {
        final average = salesData.reduce((a, b) => a + b) / salesData.length;
        final trend = _calculateTrend(salesData);
        final nextWeekForecast = (average + trend * 7).round();
        
        forecast[productName] = {
          'current_average': average,
          'trend': trend > 0 ? 'increasing' : trend < 0 ? 'decreasing' : 'stable',
          'next_week_forecast': nextWeekForecast,
          'confidence': salesData.length >= 7 ? 'high' : 'medium',
        };
      }
    }

    return forecast;
  }

  static double _calculateTrend(List<int> data) {
    if (data.length < 2) return 0;
    
    final firstHalf = data.take(data.length ~/ 2).toList();
    final secondHalf = data.skip(data.length ~/ 2).toList();
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    return secondAvg - firstAvg;
  }

  static Map<String, dynamic> _analyzeRevenueImpact(
    List<PosTransaction> recentTransactions,
    List<Map<String, dynamic>> currentStock,
  ) {
    Map<String, double> productRevenue = {};
    
    for (final transaction in recentTransactions) {
      for (final item in transaction.productItems) {
        final productName = item['product_name'] as String? ?? '';
        final totalPrice = (item['total_price'] as num?)?.toDouble() ?? 0.0;
        productRevenue[productName] = (productRevenue[productName] ?? 0) + totalPrice;
      }
    }

    final sortedByRevenue = productRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'top_revenue_products': sortedByRevenue.take(10).map((entry) => {
        'product_name': entry.key,
        'revenue': entry.value,
        'percentage_of_total': entry.value / productRevenue.values.reduce((a, b) => a + b) * 100,
      }).toList(),
      'total_revenue': productRevenue.values.reduce((a, b) => a + b),
      'revenue_concentration': _calculateRevenueConcentration(sortedByRevenue),
    };
  }

  static double _calculateRevenueConcentration(List<MapEntry<String, double>> sortedRevenue) {
    if (sortedRevenue.isEmpty) return 0;
    
    final totalRevenue = sortedRevenue.map((e) => e.value).reduce((a, b) => a + b);
    final top20PercentCount = (sortedRevenue.length * 0.2).ceil();
    final top20PercentRevenue = sortedRevenue.take(top20PercentCount).map((e) => e.value).reduce((a, b) => a + b);
    
    return (top20PercentRevenue / totalRevenue) * 100; // Pareto principle percentage
  }

  // Additional helper methods for customer behavior analysis
  static double _calculatePurchaseFrequency(List<PosTransaction> transactions) {
    if (transactions.isEmpty) return 0;
    
    final dateRange = transactions.last.transactionTime.difference(transactions.first.transactionTime).inDays;
    return dateRange > 0 ? transactions.length / dateRange : transactions.length.toDouble();
  }

  static double _calculateAverageBasketSize(List<PosTransaction> transactions) {
    if (transactions.isEmpty) return 0;
    
    final totalAmount = transactions.fold<double>(0, (sum, t) => sum + t.totalAmount);
    return totalAmount / transactions.length;
  }

  static Map<String, int> _getPreferredCategories(List<PosTransaction> transactions) {
    Map<String, int> categoryCount = {};
    
    for (final transaction in transactions) {
      for (final item in transaction.productItems) {
        final category = item['category'] as String? ?? '';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }
    
    return categoryCount;
  }

  static String _analyzePriceSensitivity(List<PosTransaction> transactions) {
    if (transactions.isEmpty) return 'unknown';
    
    final averageBasketValue = _calculateAverageBasketSize(transactions);
    
    if (averageBasketValue > 2000) return 'low'; // Premium customers
    if (averageBasketValue > 800) return 'medium';
    return 'high'; // Price-sensitive customers
  }

  static Map<String, int> _analyzeSeasonalPatterns(List<PosTransaction> transactions) {
    Map<String, int> monthlyPurchases = {};
    
    for (final transaction in transactions) {
      final month = transaction.transactionTime.month.toString();
      monthlyPurchases[month] = (monthlyPurchases[month] ?? 0) + 1;
    }
    
    return monthlyPurchases;
  }

  static double _calculateLoyaltyScore(List<PosTransaction> transactions, DateTime analysisDate) {
    if (transactions.isEmpty) return 0;
    
    final totalTransactions = transactions.length;
    final daysSinceFirstPurchase = analysisDate.difference(transactions.first.transactionTime).inDays;
    final frequency = totalTransactions / (daysSinceFirstPurchase > 0 ? daysSinceFirstPurchase : 1);
    final averageBasketSize = _calculateAverageBasketSize(transactions);
    
    // Loyalty score based on frequency and spending
    return ((frequency * 365) + (averageBasketSize / 1000)) * 10;
  }

  static String _assessChurnRisk(List<PosTransaction> transactions, DateTime analysisDate) {
    if (transactions.isEmpty) return 'high';
    
    final lastPurchase = transactions.last.transactionTime;
    final daysSinceLastPurchase = analysisDate.difference(lastPurchase).inDays;
    
    if (daysSinceLastPurchase > 90) return 'high';
    if (daysSinceLastPurchase > 30) return 'medium';
    return 'low';
  }

  static double _calculateCustomerLifetimeValue(List<PosTransaction> transactions) {
    if (transactions.isEmpty) return 0;
    
    final totalSpent = transactions.fold<double>(0, (sum, t) => sum + t.totalAmount);
    final avgOrderValue = totalSpent / transactions.length;
    final frequency = _calculatePurchaseFrequency(transactions);
    
    // Simplified CLV calculation
    return avgOrderValue * frequency * 365 * 2; // Assuming 2-year customer lifespan
  }

  static DateTime? _predictNextPurchase(List<PosTransaction> transactions) {
    if (transactions.length < 2) return null;
    
    final frequency = _calculatePurchaseFrequency(transactions);
    final lastPurchase = transactions.last.transactionTime;
    
    return lastPurchase.add(Duration(days: (1 / frequency).round()));
  }

  // Sales optimization helper methods
  static Map<String, int> _identifyPeakHours(List<PosTransaction> transactions) {
    Map<String, int> hourlyTransactions = {};
    
    for (final transaction in transactions) {
      final hour = transaction.transactionTime.hour.toString();
      hourlyTransactions[hour] = (hourlyTransactions[hour] ?? 0) + 1;
    }
    
    return hourlyTransactions;
  }

  static List<String> _getStaffOptimizationTips(List<PosTransaction> transactions) {
    final peakHours = _identifyPeakHours(transactions);
    final sortedHours = peakHours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<String> tips = [];
    
    if (sortedHours.isNotEmpty) {
      final peakHour = sortedHours.first.key;
      tips.add('Schedule more staff during ${peakHour}:00 - ${(int.parse(peakHour) + 1) % 24}:00 (peak hour)');
    }
    
    tips.addAll([
      'Consider implementing queue management during busy hours',
      'Train staff on upselling techniques for better revenue',
      'Use mobile POS during peak times to reduce wait times',
    ]);
    
    return tips;
  }

  static List<String> _getLayoutSuggestions(List<PosTransaction> transactions) {
    // Analyze which products are frequently bought together
    Map<String, Map<String, int>> coOccurrence = {};
    
    for (final transaction in transactions) {
      for (int i = 0; i < transaction.productItems.length; i++) {
        for (int j = i + 1; j < transaction.productItems.length; j++) {
          final product1 = transaction.productItems[i]['product_name'] as String? ?? '';
          final product2 = transaction.productItems[j]['product_name'] as String? ?? '';
          
          coOccurrence[product1] ??= {};
          coOccurrence[product1]![product2] = (coOccurrence[product1]![product2] ?? 0) + 1;
        }
      }
    }
    
    return [
      'Place frequently bought together items near each other',
      'Position high-margin items at eye level',
      'Create clear pathways to avoid congestion',
      'Use end-caps for promotional items',
      'Place essential items at the back to encourage browsing',
    ];
  }

  static List<Map<String, dynamic>> _identifyPromotionOpportunities(List<PosTransaction> transactions) {
    // Identify slow-moving but potentially profitable items
    Map<String, double> productRevenue = {};
    Map<String, int> productSales = {};
    
    for (final transaction in transactions) {
      for (final item in transaction.productItems) {
        final productName = item['product_name'] as String? ?? '';
        final revenue = (item['total_price'] as num?)?.toDouble() ?? 0.0;
        final quantity = item['quantity'] as int? ?? 0;
        
        productRevenue[productName] = (productRevenue[productName] ?? 0) + revenue;
        productSales[productName] = (productSales[productName] ?? 0) + quantity;
      }
    }
    
    return productSales.entries.where((entry) {
      return entry.value < 10; // Low sales
    }).map((entry) {
      final productName = entry.key;
      final avgPrice = productRevenue[productName]! / entry.value;
      
      return {
        'product_name': productName,
        'current_sales': entry.value,
        'average_price': avgPrice,
        'suggested_promotion': avgPrice > 500 ? 'Bundle offer' : 'Volume discount',
        'potential_impact': 'Increase sales by 30-50%',
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _identifyCrossSellOpportunities(List<PosTransaction> transactions) {
    // Find products frequently bought with popular items
    Map<String, Map<String, int>> crossSellMatrix = {};
    
    for (final transaction in transactions) {
      for (final item1 in transaction.productItems) {
        final product1 = item1['product_name'] as String? ?? '';
        crossSellMatrix[product1] ??= {};
        
        for (final item2 in transaction.productItems) {
          final product2 = item2['product_name'] as String? ?? '';
          if (product1 != product2) {
            crossSellMatrix[product1]![product2] = (crossSellMatrix[product1]![product2] ?? 0) + 1;
          }
        }
      }
    }
    
    return crossSellMatrix.entries.map((entry) {
      final mainProduct = entry.key;
      final crossSellProducts = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return {
        'main_product': mainProduct,
        'cross_sell_products': crossSellProducts.take(3).map((e) => {
          'product_name': e.key,
          'frequency': e.value,
        }).toList(),
        'opportunity_score': crossSellProducts.isNotEmpty ? crossSellProducts.first.value : 0,
      };
    }).where((item) => (item['opportunity_score'] as int) > 2).toList();
  }

  static List<String> _getCustomerRetentionTips(List<PosTransaction> transactions) {
    return [
      'Implement a loyalty program with points and rewards',
      'Send personalized offers based on purchase history',
      'Follow up with customers who haven\'t visited recently',
      'Offer birthday and anniversary discounts',
      'Create a VIP program for high-value customers',
      'Use SMS/email marketing for new product announcements',
      'Provide excellent customer service training',
    ];
  }

  static List<String> _getRevenueOptimizationTips(List<PosTransaction> transactions) {
    final averageBasketSize = transactions.isNotEmpty 
        ? transactions.fold<double>(0, (sum, t) => sum + t.totalAmount) / transactions.length 
        : 0;
    
    return [
      'Focus on increasing average basket size (current: ₹${averageBasketSize.toStringAsFixed(2)})',
      'Train staff on suggestive selling techniques',
      'Create product bundles with attractive pricing',
      'Implement minimum order value for free delivery',
      'Use dynamic pricing during peak hours',
      'Promote high-margin items prominently',
      'Offer volume discounts to encourage bulk purchases',
    ];
  }

  // Additional methods for demand-based and time-based pricing
  static Map<String, dynamic> _getDemandBasedPricing(
    List<Map<String, dynamic>> products,
    List<PosTransaction> marketData,
  ) {
    Map<String, dynamic> pricingRecommendations = {};
    
    for (final product in products) {
      final productName = product['product_name'] as String? ?? '';
      final currentPrice = (product['unit_price'] as num?)?.toDouble() ?? 0.0;
      
      // Calculate demand score based on recent sales
      int demandScore = 0;
      for (final transaction in marketData) {
        for (final item in transaction.productItems) {
          if (item['product_name'] == productName) {
            demandScore += item['quantity'] as int? ?? 0;
          }
        }
      }
      
      double suggestedPrice = currentPrice;
      String priceAction = 'maintain';
      
      if (demandScore > 50) {
        suggestedPrice = currentPrice * 1.05; // Increase by 5%
        priceAction = 'increase';
      } else if (demandScore < 10) {
        suggestedPrice = currentPrice * 0.95; // Decrease by 5%
        priceAction = 'decrease';
      }
      
      pricingRecommendations[productName] = {
        'current_price': currentPrice,
        'suggested_price': suggestedPrice,
        'action': priceAction,
        'demand_score': demandScore,
        'expected_impact': priceAction == 'increase' ? 'Higher profit margins' : 'Increased sales volume',
      };
    }
    
    return pricingRecommendations;
  }

  static Map<String, dynamic> _getTimeBasedPricing(
    List<Map<String, dynamic>> products,
    DateTime currentTime,
  ) {
    final hour = currentTime.hour;
    Map<String, dynamic> timeBasedPricing = {};
    
    String priceStrategy = 'regular';
    double priceMultiplier = 1.0;
    
    if (hour >= 8 && hour <= 10) {
      priceStrategy = 'early_bird';
      priceMultiplier = 0.95; // 5% discount
    } else if (hour >= 14 && hour <= 17) {
      priceStrategy = 'happy_hour';
      priceMultiplier = 0.97; // 3% discount
    } else if (hour >= 18 && hour <= 20) {
      priceStrategy = 'peak_hour';
      priceMultiplier = 1.03; // 3% premium
    }
    
    for (final product in products) {
      final productName = product['product_name'] as String? ?? '';
      final currentPrice = (product['unit_price'] as num?)?.toDouble() ?? 0.0;
      
      timeBasedPricing[productName] = {
        'current_price': currentPrice,
        'suggested_price': currentPrice * priceMultiplier,
        'strategy': priceStrategy,
        'valid_until': _getStrategyEndTime(currentTime, priceStrategy),
      };
    }
    
    return timeBasedPricing;
  }

  static String _getStrategyEndTime(DateTime currentTime, String strategy) {
    switch (strategy) {
      case 'early_bird':
        return '10:00 AM';
      case 'happy_hour':
        return '5:00 PM';
      case 'peak_hour':
        return '8:00 PM';
      default:
        return 'End of day';
    }
  }

  static Map<String, dynamic> _getTierBasedPricing(
    List<Map<String, dynamic>> products,
    String customerTier,
  ) {
    final tierDiscounts = {
      'VIP': 0.15,
      'Premium': 0.10,
      'Gold': 0.08,
      'Silver': 0.05,
      'Regular': 0.02,
    };
    
    final discount = tierDiscounts[customerTier] ?? 0.0;
    Map<String, dynamic> tierPricing = {};
    
    for (final product in products) {
      final productName = product['product_name'] as String? ?? '';
      final currentPrice = (product['unit_price'] as num?)?.toDouble() ?? 0.0;
      final discountedPrice = currentPrice * (1 - discount);
      
      tierPricing[productName] = {
        'regular_price': currentPrice,
        'tier_price': discountedPrice,
        'discount_percentage': (discount * 100).toInt(),
        'savings': currentPrice - discountedPrice,
      };
    }
    
    return tierPricing;
  }

  static Map<String, dynamic> _getCompetitivePricingAnalysis(List<Map<String, dynamic>> products) {
    // Simplified competitive analysis
    // In a real implementation, you'd fetch competitor prices from external sources
    Map<String, dynamic> competitiveAnalysis = {};
    
    for (final product in products) {
      final productName = product['product_name'] as String? ?? '';
      final currentPrice = (product['unit_price'] as num?)?.toDouble() ?? 0.0;
      
      // Simulate competitor prices (in reality, you'd fetch these)
      final marketPrice = currentPrice * (0.9 + Random().nextDouble() * 0.2); // ±10% variation
      
      String competitivePosition = 'competitive';
      if (currentPrice > marketPrice * 1.1) {
        competitivePosition = 'above_market';
      } else if (currentPrice < marketPrice * 0.9) {
        competitivePosition = 'below_market';
      }
      
      competitiveAnalysis[productName] = {
        'our_price': currentPrice,
        'market_average': marketPrice,
        'position': competitivePosition,
        'recommendation': _getCompetitivePricingRecommendation(competitivePosition),
      };
    }
    
    return competitiveAnalysis;
  }

  static String _getCompetitivePricingRecommendation(String position) {
    switch (position) {
      case 'above_market':
        return 'Consider reducing price to match market or highlight unique value propositions';
      case 'below_market':
        return 'Opportunity to increase price while remaining competitive';
      default:
        return 'Price is well-positioned in the market';
    }
  }

  static Map<String, dynamic> _getProfitOptimization(
    List<Map<String, dynamic>> products,
    List<PosTransaction> marketData,
  ) {
    Map<String, dynamic> profitOptimization = {};
    
    for (final product in products) {
      final productName = product['product_name'] as String? ?? '';
      final currentPrice = (product['unit_price'] as num?)?.toDouble() ?? 0.0;
      final cost = (product['cost_price'] as num?)?.toDouble() ?? currentPrice * 0.7;
      final currentMargin = currentPrice - cost;
      final currentMarginPercent = (currentMargin / currentPrice) * 100;
      
      // Calculate demand elasticity (simplified)
      final demandElasticity = _calculateDemandElasticity(productName, marketData);
      
      // Suggest optimal price based on demand elasticity
      double optimalPrice = currentPrice;
      if (demandElasticity < -0.5) { // Elastic demand
        optimalPrice = cost * 1.2; // Lower margin, higher volume
      } else if (demandElasticity > -0.2) { // Inelastic demand
        optimalPrice = cost * 1.5; // Higher margin possible
      }
      
      profitOptimization[productName] = {
        'current_price': currentPrice,
        'cost_price': cost,
        'current_margin_percent': currentMarginPercent,
        'optimal_price': optimalPrice,
        'projected_margin_percent': ((optimalPrice - cost) / optimalPrice) * 100,
        'demand_elasticity': demandElasticity,
        'optimization_potential': optimalPrice > currentPrice ? 'increase_price' : 'decrease_price',
      };
    }
    
    return profitOptimization;
  }

  static double _calculateDemandElasticity(String productName, List<PosTransaction> marketData) {
    // Simplified demand elasticity calculation
    // In reality, you'd need historical price and quantity data
    return -0.3 - (Random().nextDouble() * 0.4); // Random elasticity between -0.3 and -0.7
  }
}
