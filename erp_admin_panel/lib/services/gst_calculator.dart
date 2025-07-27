class GstCalculator {
  // GST rates in India
  static const Map<String, double> gstRates = {
    'exempt': 0.0,     // Exempt items
    'zero': 0.0,       // Zero-rated items
    'gst_5': 5.0,      // 5% GST
    'gst_12': 12.0,    // 12% GST
    'gst_18': 18.0,    // 18% GST
    'gst_28': 28.0,    // 28% GST
  };

  // Product category to GST mapping
  static const Map<String, String> categoryGstMapping = {
    // Food items - 5%
    'food_grains': 'gst_5',
    'dairy': 'gst_5',
    'fruits': 'gst_5',
    'vegetables': 'gst_5',
    'spices': 'gst_5',
    'tea_coffee': 'gst_5',
    
    // Essential items - 5%
    'medicines': 'gst_5',
    'medical_equipment': 'gst_5',
    
    // General items - 12%
    'packaged_food': 'gst_12',
    'industrial_inputs': 'gst_12',
    'home_appliances': 'gst_12',
    
    // Most goods - 18%
    'electronics': 'gst_18',
    'clothing': 'gst_18',
    'footwear': 'gst_18',
    'furniture': 'gst_18',
    'cosmetics': 'gst_18',
    'stationery': 'gst_18',
    'books': 'gst_18',
    
    // Luxury items - 28%
    'automobiles': 'gst_28',
    'luxury_goods': 'gst_28',
    'tobacco': 'gst_28',
    'aerated_drinks': 'gst_28',
  };

  // Calculate GST for a single item
  static Map<String, dynamic> calculateItemGst({
    required double amount,
    required String category,
    bool inclusive = true, // Whether GST is included in the price
  }) {
    final gstCategory = categoryGstMapping[category] ?? 'gst_18';
    final gstRate = gstRates[gstCategory] ?? 18.0;
    
    double baseAmount;
    double gstAmount;
    double totalAmount;

    if (inclusive) {
      // GST is included in the price
      totalAmount = amount;
      baseAmount = amount * 100 / (100 + gstRate);
      gstAmount = amount - baseAmount;
    } else {
      // GST is to be added to the price
      baseAmount = amount;
      gstAmount = amount * gstRate / 100;
      totalAmount = amount + gstAmount;
    }

    // For CGST + SGST (intra-state) or IGST (inter-state)
    final cgstAmount = gstAmount / 2;
    final sgstAmount = gstAmount / 2;
    final igstAmount = gstAmount;

    return {
      'base_amount': double.parse(baseAmount.toStringAsFixed(2)),
      'gst_rate': gstRate,
      'gst_amount': double.parse(gstAmount.toStringAsFixed(2)),
      'cgst_amount': double.parse(cgstAmount.toStringAsFixed(2)),
      'sgst_amount': double.parse(sgstAmount.toStringAsFixed(2)),
      'igst_amount': double.parse(igstAmount.toStringAsFixed(2)),
      'total_amount': double.parse(totalAmount.toStringAsFixed(2)),
      'gst_category': gstCategory,
    };
  }

  // Calculate GST for multiple items
  static Map<String, dynamic> calculateTransactionGst({
    required List<Map<String, dynamic>> items,
    required String stateFrom,
    required String stateTo,
    bool inclusive = true,
  }) {
    double totalBaseAmount = 0;
    double totalGstAmount = 0;
    double totalCgstAmount = 0;
    double totalSgstAmount = 0;
    double totalIgstAmount = 0;
    double totalAmount = 0;
    
    Map<String, double> gstBreakup = {};
    List<Map<String, dynamic>> itemWiseGst = [];
    
    final isInterState = stateFrom.toLowerCase() != stateTo.toLowerCase();

    for (final item in items) {
      final amount = (item['total_price'] as num?)?.toDouble() ?? 0.0;
      final category = item['category'] as String? ?? 'electronics';
      final quantity = item['quantity'] as int? ?? 1;
      final itemName = item['product_name'] as String? ?? 'Unknown';

      final itemGst = calculateItemGst(
        amount: amount,
        category: category,
        inclusive: inclusive,
      );

      totalBaseAmount += itemGst['base_amount'];
      totalGstAmount += itemGst['gst_amount'];
      totalAmount += itemGst['total_amount'];

      if (isInterState) {
        // Inter-state: IGST
        totalIgstAmount += itemGst['igst_amount'];
      } else {
        // Intra-state: CGST + SGST
        totalCgstAmount += itemGst['cgst_amount'];
        totalSgstAmount += itemGst['sgst_amount'];
      }

      // GST rate wise breakup
      final gstRate = itemGst['gst_rate'];
      final gstKey = '${gstRate.toStringAsFixed(0)}%';
      gstBreakup[gstKey] = (gstBreakup[gstKey] ?? 0) + itemGst['gst_amount'];

      // Item-wise GST details
      itemWiseGst.add({
        'item_name': itemName,
        'quantity': quantity,
        'base_amount': itemGst['base_amount'],
        'gst_rate': itemGst['gst_rate'],
        'gst_amount': itemGst['gst_amount'],
        'total_amount': itemGst['total_amount'],
        'cgst_amount': isInterState ? 0 : itemGst['cgst_amount'],
        'sgst_amount': isInterState ? 0 : itemGst['sgst_amount'],
        'igst_amount': isInterState ? itemGst['igst_amount'] : 0,
      });
    }

    return {
      'total_base_amount': double.parse(totalBaseAmount.toStringAsFixed(2)),
      'total_gst_amount': double.parse(totalGstAmount.toStringAsFixed(2)),
      'total_cgst_amount': double.parse(totalCgstAmount.toStringAsFixed(2)),
      'total_sgst_amount': double.parse(totalSgstAmount.toStringAsFixed(2)),
      'total_igst_amount': double.parse(totalIgstAmount.toStringAsFixed(2)),
      'total_amount': double.parse(totalAmount.toStringAsFixed(2)),
      'is_inter_state': isInterState,
      'gst_breakup': gstBreakup,
      'item_wise_gst': itemWiseGst,
      'state_from': stateFrom,
      'state_to': stateTo,
    };
  }

  // Get HSN code for product category
  static String getHsnCode(String category) {
    const hsnCodes = {
      // Food and beverages
      'food_grains': '1006',
      'dairy': '0401',
      'fruits': '0805',
      'vegetables': '0702',
      'spices': '0907',
      'tea_coffee': '0901',
      'packaged_food': '2106',
      
      // Textiles and clothing
      'clothing': '6203',
      'footwear': '6403',
      
      // Electronics
      'electronics': '8517',
      'home_appliances': '8516',
      
      // Others
      'medicines': '3004',
      'cosmetics': '3304',
      'stationery': '4802',
      'books': '4901',
      'furniture': '9403',
      'automobiles': '8703',
      'tobacco': '2402',
    };
    
    return hsnCodes[category] ?? '9999';
  }

  // Generate GST summary for invoice
  static Map<String, dynamic> generateGstSummary({
    required Map<String, dynamic> gstCalculation,
    required String invoiceNumber,
    required String gstin,
    required String customerGstin,
  }) {
    final isInterState = gstCalculation['is_inter_state'] as bool;
    final gstBreakup = gstCalculation['gst_breakup'] as Map<String, double>;
    
    return {
      'invoice_number': invoiceNumber,
      'supplier_gstin': gstin,
      'customer_gstin': customerGstin,
      'supply_type': isInterState ? 'Inter-State' : 'Intra-State',
      'total_taxable_value': gstCalculation['total_base_amount'],
      'total_tax_amount': gstCalculation['total_gst_amount'],
      'total_invoice_value': gstCalculation['total_amount'],
      'cgst_amount': gstCalculation['total_cgst_amount'],
      'sgst_amount': gstCalculation['total_sgst_amount'],
      'igst_amount': gstCalculation['total_igst_amount'],
      'gst_rate_wise_breakup': gstBreakup,
      'reverse_charge': false, // Assuming normal supply
      'item_details': gstCalculation['item_wise_gst'],
    };
  }

  // Validate GSTIN format
  static bool isValidGstin(String gstin) {
    if (gstin.length != 15) return false;
    
    final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$');
    return gstinRegex.hasMatch(gstin);
  }

  // Get state code from GSTIN
  static String getStateCodeFromGstin(String gstin) {
    if (!isValidGstin(gstin)) return '';
    return gstin.substring(0, 2);
  }

  // Get state name from state code
  static String getStateName(String stateCode) {
    const stateCodes = {
      '01': 'Jammu and Kashmir',
      '02': 'Himachal Pradesh',
      '03': 'Punjab',
      '04': 'Chandigarh',
      '05': 'Uttarakhand',
      '06': 'Haryana',
      '07': 'Delhi',
      '08': 'Rajasthan',
      '09': 'Uttar Pradesh',
      '10': 'Bihar',
      '11': 'Sikkim',
      '12': 'Arunachal Pradesh',
      '13': 'Nagaland',
      '14': 'Manipur',
      '15': 'Mizoram',
      '16': 'Tripura',
      '17': 'Meghalaya',
      '18': 'Assam',
      '19': 'West Bengal',
      '20': 'Jharkhand',
      '21': 'Odisha',
      '22': 'Chhattisgarh',
      '23': 'Madhya Pradesh',
      '24': 'Gujarat',
      '25': 'Daman and Diu',
      '26': 'Dadra and Nagar Haveli',
      '27': 'Maharashtra',
      '29': 'Karnataka',
      '30': 'Goa',
      '31': 'Lakshadweep',
      '32': 'Kerala',
      '33': 'Tamil Nadu',
      '34': 'Puducherry',
      '35': 'Andaman and Nicobar Islands',
      '36': 'Telangana',
      '37': 'Andhra Pradesh',
    };
    
    return stateCodes[stateCode] ?? 'Unknown';
  }

  // Calculate reverse charge if applicable
  static bool isReverseChargeApplicable({
    required String supplierGstin,
    required String customerGstin,
    required String category,
  }) {
    // Simplified logic - in reality, this would be more complex
    // Reverse charge applies in specific scenarios like:
    // - Unregistered supplier to registered customer
    // - Specific goods/services as per GST law
    
    if (supplierGstin.isEmpty && customerGstin.isNotEmpty) {
      return true; // Unregistered supplier to registered customer
    }
    
    // Specific categories where reverse charge may apply
    const reverseChargeCategories = [
      'scrap',
      'cotton',
      'cashew_nuts',
      'tobacco_leaves',
    ];
    
    return reverseChargeCategories.contains(category);
  }
}
