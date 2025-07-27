import 'dart:convert';

class DiscountEngine {
  static const Map<String, double> customerTierDiscounts = {
    'VIP': 0.15,      // 15% discount
    'Premium': 0.10,  // 10% discount
    'Gold': 0.08,     // 8% discount
    'Silver': 0.05,   // 5% discount
    'Regular': 0.02,  // 2% discount
  };

  static const Map<String, double> volumeDiscounts = {
    'bulk_10': 0.05,  // 5% for 10+ items
    'bulk_25': 0.08,  // 8% for 25+ items
    'bulk_50': 0.12,  // 12% for 50+ items
    'bulk_100': 0.15, // 15% for 100+ items
  };

  // Calculate intelligent discount based on various factors
  static Map<String, dynamic> calculateDiscount({
    required List<Map<String, dynamic>> items,
    required String customerTier,
    String? couponCode,
    double totalAmount = 0,
    bool isFirstTimeCustomer = false,
    bool isLoyaltyMember = false,
    DateTime? transactionTime,
  }) {
    double totalDiscount = 0;
    double discountPercentage = 0;
    List<String> appliedDiscounts = [];

    // 1. Customer tier discount
    if (customerTierDiscounts.containsKey(customerTier)) {
      final tierDiscount = customerTierDiscounts[customerTier]!;
      totalDiscount += totalAmount * tierDiscount;
      discountPercentage += tierDiscount;
      appliedDiscounts.add('Customer Tier ($customerTier): ${(tierDiscount * 100).toStringAsFixed(1)}%');
    }

    // 2. Volume discount
    final totalQuantity = items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
    String volumeDiscountKey = '';
    
    if (totalQuantity >= 100) {
      volumeDiscountKey = 'bulk_100';
    } else if (totalQuantity >= 50) {
      volumeDiscountKey = 'bulk_50';
    } else if (totalQuantity >= 25) {
      volumeDiscountKey = 'bulk_25';
    } else if (totalQuantity >= 10) {
      volumeDiscountKey = 'bulk_10';
    }

    if (volumeDiscountKey.isNotEmpty) {
      final volumeDiscount = volumeDiscounts[volumeDiscountKey]!;
      totalDiscount += totalAmount * volumeDiscount;
      discountPercentage += volumeDiscount;
      appliedDiscounts.add('Volume Discount: ${(volumeDiscount * 100).toStringAsFixed(1)}%');
    }

    // 3. First-time customer discount
    if (isFirstTimeCustomer) {
      const firstTimeDiscount = 0.05; // 5%
      totalDiscount += totalAmount * firstTimeDiscount;
      discountPercentage += firstTimeDiscount;
      appliedDiscounts.add('First Time Customer: 5%');
    }

    // 4. Loyalty member discount
    if (isLoyaltyMember) {
      const loyaltyDiscount = 0.03; // 3%
      totalDiscount += totalAmount * loyaltyDiscount;
      discountPercentage += loyaltyDiscount;
      appliedDiscounts.add('Loyalty Member: 3%');
    }

    // 5. Time-based discounts (Happy hours, etc.)
    if (transactionTime != null) {
      final timeDiscount = _calculateTimeBasedDiscount(transactionTime);
      if (timeDiscount > 0) {
        totalDiscount += totalAmount * timeDiscount;
        discountPercentage += timeDiscount;
        appliedDiscounts.add('Happy Hour: ${(timeDiscount * 100).toStringAsFixed(1)}%');
      }
    }

    // 6. Coupon code discount
    if (couponCode != null && couponCode.isNotEmpty) {
      final couponDiscount = _applyCouponCode(couponCode, totalAmount, items);
      totalDiscount += couponDiscount['amount'] as double;
      if (couponDiscount['amount'] > 0) {
        appliedDiscounts.add(couponDiscount['description'] as String);
      }
    }

    // Cap maximum discount at 30%
    if (discountPercentage > 0.30) {
      totalDiscount = totalAmount * 0.30;
      discountPercentage = 0.30;
      appliedDiscounts.add('Maximum discount cap applied (30%)');
    }

    return {
      'total_discount': totalDiscount,
      'discount_percentage': discountPercentage,
      'applied_discounts': appliedDiscounts,
      'final_amount': totalAmount - totalDiscount,
    };
  }

  // Calculate time-based discounts
  static double _calculateTimeBasedDiscount(DateTime transactionTime) {
    final hour = transactionTime.hour;
    final dayOfWeek = transactionTime.weekday;

    // Happy hours: 2-5 PM weekdays (3% discount)
    if (dayOfWeek >= 1 && dayOfWeek <= 5 && hour >= 14 && hour < 17) {
      return 0.03;
    }

    // Weekend evening discount: 6-8 PM (2% discount)
    if ((dayOfWeek == 6 || dayOfWeek == 7) && hour >= 18 && hour < 20) {
      return 0.02;
    }

    // Early bird discount: 8-10 AM (1.5% discount)
    if (hour >= 8 && hour < 10) {
      return 0.015;
    }

    return 0;
  }

  // Apply coupon code discounts
  static Map<String, dynamic> _applyCouponCode(
    String couponCode,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) {
    final normalizedCode = couponCode.toUpperCase().trim();

    switch (normalizedCode) {
      case 'WELCOME10':
        return {
          'amount': totalAmount * 0.10,
          'description': 'Coupon WELCOME10: 10%',
        };

      case 'SAVE20':
        return {
          'amount': totalAmount >= 1000 ? totalAmount * 0.20 : 0,
          'description': totalAmount >= 1000 
              ? 'Coupon SAVE20: 20% (Min ₹1000)'
              : 'Coupon SAVE20: Minimum amount ₹1000 required',
        };

      case 'FLAT50':
        return {
          'amount': totalAmount >= 500 ? 50 : 0,
          'description': totalAmount >= 500
              ? 'Coupon FLAT50: ₹50 off'
              : 'Coupon FLAT50: Minimum amount ₹500 required',
        };

      case 'BULK15':
        final totalQuantity = items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
        return {
          'amount': totalQuantity >= 20 ? totalAmount * 0.15 : 0,
          'description': totalQuantity >= 20
              ? 'Coupon BULK15: 15% (Min 20 items)'
              : 'Coupon BULK15: Minimum 20 items required',
        };

      case 'FESTIVE25':
        // Festival discount - check if it's a festival period
        final now = DateTime.now();
        final isDiwali = _isFestivalPeriod(now, 'diwali');
        final isHoli = _isFestivalPeriod(now, 'holi');
        
        if (isDiwali || isHoli) {
          return {
            'amount': totalAmount * 0.25,
            'description': 'Coupon FESTIVE25: 25% Festival Discount',
          };
        }
        return {
          'amount': 0,
          'description': 'Coupon FESTIVE25: Valid only during festival periods',
        };

      default:
        return {
          'amount': 0,
          'description': 'Invalid coupon code',
        };
    }
  }

  // Check if current date is in festival period
  static bool _isFestivalPeriod(DateTime date, String festival) {
    // This is a simplified check. In a real app, you'd have a festival calendar
    final month = date.month;
    final day = date.day;

    switch (festival.toLowerCase()) {
      case 'diwali':
        // Approximate Diwali period (October-November)
        return (month == 10 && day >= 15) || (month == 11 && day <= 15);
      
      case 'holi':
        // Approximate Holi period (March)
        return month == 3 && day >= 8 && day <= 12;
      
      default:
        return false;
    }
  }

  // Validate coupon code
  static bool isValidCouponCode(String couponCode) {
    const validCoupons = [
      'WELCOME10',
      'SAVE20',
      'FLAT50',
      'BULK15',
      'FESTIVE25',
    ];

    return validCoupons.contains(couponCode.toUpperCase().trim());
  }

  // Get available coupons for display
  static List<Map<String, dynamic>> getAvailableCoupons() {
    return [
      {
        'code': 'WELCOME10',
        'description': 'Get 10% off on your purchase',
        'type': 'percentage',
        'value': 10,
        'minimum_amount': 0,
      },
      {
        'code': 'SAVE20',
        'description': 'Get 20% off on purchases above ₹1000',
        'type': 'percentage',
        'value': 20,
        'minimum_amount': 1000,
      },
      {
        'code': 'FLAT50',
        'description': 'Get ₹50 off on purchases above ₹500',
        'type': 'fixed',
        'value': 50,
        'minimum_amount': 500,
      },
      {
        'code': 'BULK15',
        'description': 'Get 15% off when buying 20+ items',
        'type': 'percentage',
        'value': 15,
        'minimum_quantity': 20,
      },
      {
        'code': 'FESTIVE25',
        'description': 'Get 25% off during festival periods',
        'type': 'percentage',
        'value': 25,
        'seasonal': true,
      },
    ];
  }

  // Get personalized discount recommendations
  static List<String> getDiscountRecommendations({
    required String customerTier,
    required int totalQuantity,
    required double totalAmount,
    required bool isLoyaltyMember,
    required bool isFirstTimeCustomer,
  }) {
    List<String> recommendations = [];

    // Recommend upgrading customer tier
    if (customerTier == 'Regular' && totalAmount > 5000) {
      recommendations.add('Spend ₹5000 more to unlock Silver tier benefits!');
    }

    // Recommend bulk purchase
    if (totalQuantity >= 8 && totalQuantity < 10) {
      recommendations.add('Add 2 more items to get 5% bulk discount!');
    }

    // Recommend loyalty membership
    if (!isLoyaltyMember && totalAmount > 2000) {
      recommendations.add('Join our loyalty program for additional 3% discount!');
    }

    // Recommend specific coupons
    if (totalAmount >= 1000) {
      recommendations.add('Use code SAVE20 for 20% off!');
    } else if (totalAmount >= 500) {
      recommendations.add('Use code FLAT50 for ₹50 off!');
    }

    return recommendations;
  }
}
