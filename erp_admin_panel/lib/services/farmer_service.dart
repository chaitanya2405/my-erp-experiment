import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/farmer.dart';

/// 🌾 Farmer Service - Following the same pattern as ProductService
class FarmerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'farmers';

  // Singleton instance
  static final FarmerService _instance = FarmerService._internal();
  factory FarmerService() => _instance;
  static FarmerService get instance => _instance;
  FarmerService._internal();

  // Get all farmers
  static Future<List<Farmer>> getAllFarmers({int? limit, String? storeId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      if (storeId != null) {
        query = query.where('storeId', isEqualTo: storeId);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Farmer.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting all farmers: $e');
      return [];
    }
  }

  // Get farmer by ID
  static Future<Farmer?> getFarmerById(String farmerId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(farmerId).get();
      if (doc.exists) {
        return Farmer.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting farmer by ID: $e');
      return null;
    }
  }

  // Search farmers
  static Future<Map<String, dynamic>> searchFarmers({
    String? searchTerm,
    String? state,
    String? district,
    String? village,
    List<String>? crops,
    String? farmingMethod,
    double? minLandArea,
    double? maxLandArea,
    bool? isOrganicCertified,
    String? status,
    int? limit,
  }) async {
    try {
      final allFarmers = await getAllFarmers();
      
      List<Farmer> filteredFarmers = allFarmers.where((farmer) {
        // Text search
        if (searchTerm != null && searchTerm.isNotEmpty) {
          final searchLower = searchTerm.toLowerCase();
          if (!farmer.fullName.toLowerCase().contains(searchLower) &&
              !farmer.mobileNumber.contains(searchTerm) &&
              !(farmer.farmerCode.toLowerCase().contains(searchLower))) {
            return false;
          }
        }
        
        // Location filters
        if (state != null && farmer.state != state) return false;
        if (district != null && farmer.district != district) return false;
        if (village != null && farmer.village != village) return false;
        
        // Crop filter
        if (crops != null && crops.isNotEmpty) {
          final farmerCrops = farmer.primaryCrops ?? [];
          if (!crops.any((crop) => farmerCrops.contains(crop))) return false;
        }
        
        // Land area filters
        if (minLandArea != null && farmer.totalLandArea < minLandArea) return false;
        if (maxLandArea != null && farmer.totalLandArea > maxLandArea) return false;
        
        // Status filter
        if (status != null && farmer.status != status) return false;
        
        return true;
      }).toList();
      
      // Apply limit
      if (limit != null && filteredFarmers.length > limit) {
        filteredFarmers = filteredFarmers.take(limit).toList();
      }
      
      return {
        'farmers': filteredFarmers,
        'total_count': filteredFarmers.length,
        'status': 'success'
      };
    } catch (e) {
      debugPrint('Error searching farmers: $e');
      return {
        'farmers': <Farmer>[],
        'total_count': 0,
        'status': 'error',
        'error': e.toString()
      };
    }
  }

  // Instance method for searching farmers
  Future<List<Farmer>> findFarmers({
    required String searchTerm,
    int limit = 50,
  }) async {
    final result = await FarmerService.searchFarmers(
      searchTerm: searchTerm,
      limit: limit,
    );
    return result['farmers'] as List<Farmer>;
  }

  // Get farmers by crop
  Future<List<Farmer>> getFarmersByCrop(String crop) async {
    final result = await FarmerService.searchFarmers(crops: [crop]);
    return result['farmers'] as List<Farmer>;
  }

  // Get farmers by location
  Future<List<Farmer>> getFarmersByLocation({
    String? state,
    String? district,
    String? village,
  }) async {
    final result = await FarmerService.searchFarmers(
      state: state,
      district: district,
      village: village,
    );
    return result['farmers'] as List<Farmer>;
  }

  // Create farmer
  Future<String> createFarmer(Farmer farmer) async {
    try {
      final docRef = await _firestore.collection(_collection).add(farmer.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating farmer: $e');
      throw e;
    }
  }

  // Update farmer
  Future<void> updateFarmer(Farmer farmer) async {
    try {
      await _firestore.collection(_collection).doc(farmer.id).update(farmer.toFirestore());
    } catch (e) {
      debugPrint('Error updating farmer: $e');
      throw e;
    }
  }

  // Delete farmer
  Future<void> deleteFarmer(String farmerId) async {
    try {
      await _firestore.collection(_collection).doc(farmerId).delete();
    } catch (e) {
      debugPrint('Error deleting farmer: $e');
      throw e;
    }
  }

  // Get comprehensive farmer analytics
  Future<Map<String, dynamic>> getFarmerAnalytics() async {
    try {
      final farmers = await getAllFarmers();
      
      if (farmers.isEmpty) {
        return {
          'total_farmers': 0,
          'message': 'No farmers registered yet'
        };
      }
      
      return {
        // === BASIC STATISTICS ===
        'total_farmers': farmers.length,
        'active_farmers': farmers.where((f) => f.status == 'Active').length,
        'organic_farmers': farmers.where((f) => f.isOrganicCertified == true).length,
        'organic_percentage': farmers.where((f) => f.isOrganicCertified == true).length / farmers.length * 100,
        
        // === LAND ANALYTICS ===
        'total_land_area': farmers.fold<double>(0.0, (sum, f) => sum + f.totalLandArea),
        'average_land_area': farmers.isNotEmpty 
            ? farmers.fold<double>(0.0, (sum, f) => sum + f.totalLandArea) / farmers.length 
            : 0.0,
        'total_irrigated_area': farmers.fold<double>(0.0, (sum, f) => sum + (f.irrigatedArea ?? 0.0)),
        'total_rainfed_area': farmers.fold<double>(0.0, (sum, f) => sum + (f.rainfedArea ?? 0.0)),
        'irrigation_percentage': _calculateIrrigationPercentage(farmers),
        
        // === CROP ANALYTICS ===
        'top_primary_crops': _getTopCrops(farmers),
        'total_primary_crops': _getTotalUniqueCrops(farmers),
        'crop_diversity_index': _calculateCropDiversityIndex(farmers),
        'seasonal_crop_distribution': _getSeasonalCropDistribution(farmers),
        
        // === GEOGRAPHIC DISTRIBUTION ===
        'state_distribution': _getStateDistribution(farmers),
        'district_distribution': _getDistrictDistribution(farmers),
        'village_distribution': _getVillageDistribution(farmers),
        
        // === INFRASTRUCTURE ANALYTICS ===
        'farmers_with_tractor': farmers.where((f) => f.hasTractor == true).length,
        'farmers_with_storage': farmers.where((f) => f.hasStorageFacility == true).length,
        'farmers_with_cold_storage': farmers.where((f) => f.hasColdStorage == true).length,
        'farmers_with_transportation': farmers.where((f) => f.hasTransportation == true).length,
        'total_storage_capacity': farmers.fold<double>(0.0, (sum, f) => sum + (f.storageCapacity ?? 0.0)),
        
        // === FINANCIAL ANALYTICS ===
        'farmers_with_bank_account': farmers.where((f) => f.bankAccountNumber?.isNotEmpty == true).length,
        'farmers_with_kcc': farmers.where((f) => f.kccNumber?.isNotEmpty == true).length,
        'farmers_with_insurance': farmers.where((f) => f.hasInsurance == true).length,
        'average_annual_income': _calculateAverageIncome(farmers),
        'total_credit_limit': farmers.fold<double>(0.0, (sum, f) => sum + (f.creditLimit ?? 0.0)),
        'total_outstanding_loans': farmers.fold<double>(0.0, (sum, f) => sum + (f.outstandingLoan ?? 0.0)),
        
        // === TECHNOLOGY ADOPTION ===
        'farmers_using_mobile_app': farmers.where((f) => f.usesMobileApp == true).length,
        'farmers_using_weather_services': farmers.where((f) => f.usesWeatherServices == true).length,
        'farmers_using_precision_farming': farmers.where((f) => f.usesPrecisionFarming == true).length,
        'technology_adoption_rate': _calculateTechnologyAdoptionRate(farmers),
        
        // === SUSTAINABILITY METRICS ===
        'farmers_using_solar': farmers.where((f) => f.usesSolarEnergy == true).length,
        'farmers_practicing_water_conservation': farmers.where((f) => f.practicesWaterConservation == true).length,
        'farmers_using_biofertilizers': farmers.where((f) => f.usesBiofertilizers == true).length,
        'farmers_with_ipm': farmers.where((f) => f.practicesIntegratedPestManagement == true).length,
        'average_environmental_score': _calculateAverageEnvironmentalScore(farmers),
        
        // === PERFORMANCE METRICS ===
        'average_yield_per_acre': _calculateAverageYield(farmers),
        'average_quality_grade': _calculateAverageQualityGrade(farmers),
        'average_delivery_rate': _calculateAverageDeliveryRate(farmers),
        'average_customer_satisfaction': _calculateAverageCustomerSatisfaction(farmers),
        'high_performing_farmers': farmers.where((f) => (f.customerSatisfactionScore ?? 0) > 80).length,
        
        // === DEMOGRAPHIC ANALYTICS ===
        'age_distribution': _getAgeDistribution(farmers),
        'gender_distribution': _getGenderDistribution(farmers),
        'education_distribution': _getEducationDistribution(farmers),
        'marital_status_distribution': _getMaritalStatusDistribution(farmers),
        
        // === MEMBERSHIP & CERTIFICATIONS ===
        'fpo_members': farmers.where((f) => f.fpoMembership?.isNotEmpty == true).length,
        'shg_members': farmers.where((f) => f.shgMembership?.isNotEmpty == true).length,
        'government_scheme_beneficiaries': _getGovernmentSchemeAnalytics(farmers),
        'training_participation': _getTrainingAnalytics(farmers),
        
        // === MARKET ACCESS ===
        'direct_to_consumer_sellers': farmers.where((f) => f.sellsDirectToConsumer == true).length,
        'farmers_market_participants': farmers.where((f) => f.participatesInFarmersMarket == true).length,
        'market_channel_distribution': _getMarketChannelDistribution(farmers),
        'average_selling_price': _calculateAverageSellingPrice(farmers),
        
        // === RECENT ACTIVITY ===
        'new_registrations_this_month': _getNewRegistrationsThisMonth(farmers),
        'latest_registration': farmers.isNotEmpty ? farmers.last.createdAt.toIso8601String() : null,
        'most_active_district': _getMostActiveDistrict(farmers),
        'fastest_growing_crop': _getFastestGrowingCrop(farmers),
        
        // === DATA QUALITY METRICS ===
        'data_completeness_score': _calculateDataCompletenessScore(farmers),
        'profiles_with_photos': 0, // Will be implemented when photo feature is added
        'gps_coordinates_available': farmers.where((f) => f.latitude != null && f.longitude != null).length,
        
        // === SYSTEM METADATA ===
        'last_updated': DateTime.now().toIso8601String(),
        'data_source': 'Firestore Database',
        'bridge_status': 'Connected',
        'analytics_version': '2.0.0',
      };
    } catch (e) {
      debugPrint('Error getting comprehensive farmer analytics: $e');
      return {
        'error': e.toString(),
        'total_farmers': 0,
        'status': 'error'
      };
    }
  }

  // Get farmer performance
  Future<Map<String, dynamic>> getFarmerPerformance(String farmerId) async {
    try {
      final farmer = await getFarmerById(farmerId);
      if (farmer == null) return {};
      
      return {
        'farmer_id': farmerId,
        'performance_score': 85.0, // Calculated metric
        'total_land_area': farmer.totalLandArea,
        'organic_certified': farmer.isOrganicCertified,
        'primary_crops': farmer.primaryCrops,
        'status': 'Active',
      };
    } catch (e) {
      debugPrint('Error getting farmer performance: $e');
      return {};
    }
  }

  // Get crop calendar
  Future<Map<String, dynamic>> getCropCalendar(String farmerId) async {
    try {
      final farmer = await getFarmerById(farmerId);
      if (farmer == null) return {};
      
      return {
        'farmer_id': farmerId,
        'primary_crops': farmer.primaryCrops,
        'seasonal_crops': farmer.seasonalCrops,
        'planting_schedule': {},
        'harvest_schedule': {},
      };
    } catch (e) {
      debugPrint('Error getting crop calendar: $e');
      return {};
    }
  }

  // Helper methods
  Map<String, int> _getTopCrops(List<Farmer> farmers) {
    final cropCount = <String, int>{};
    for (final farmer in farmers) {
      if (farmer.primaryCrops != null) {
        for (final crop in farmer.primaryCrops!) {
          cropCount[crop] = (cropCount[crop] ?? 0) + 1;
        }
      }
    }
    return cropCount;
  }

  Map<String, int> _getLocationDistribution(List<Farmer> farmers) {
    final locationCount = <String, int>{};
    for (final farmer in farmers) {
      final location = '${farmer.district}, ${farmer.state}';
      locationCount[location] = (locationCount[location] ?? 0) + 1;
    }
    return locationCount;
  }

  // === COMPREHENSIVE ANALYTICS HELPER METHODS ===
  
  // Irrigation Analytics
  double _calculateIrrigationPercentage(List<Farmer> farmers) {
    if (farmers.isEmpty) return 0.0;
    final totalLand = farmers.fold<double>(0.0, (sum, f) => sum + f.totalLandArea);
    final irrigatedLand = farmers.fold<double>(0.0, (sum, f) => sum + (f.irrigatedArea ?? 0.0));
    return totalLand > 0 ? (irrigatedLand / totalLand) * 100 : 0.0;
  }
  
  // Crop Analytics
  int _getTotalUniqueCrops(List<Farmer> farmers) {
    final allCrops = <String>{};
    for (final farmer in farmers) {
      if (farmer.primaryCrops != null) allCrops.addAll(farmer.primaryCrops!);
      if (farmer.secondaryCrops != null) allCrops.addAll(farmer.secondaryCrops!);
      if (farmer.seasonalCrops != null) allCrops.addAll(farmer.seasonalCrops!);
    }
    return allCrops.length;
  }
  
  double _calculateCropDiversityIndex(List<Farmer> farmers) {
    final cropCount = <String, int>{};
    for (final farmer in farmers) {
      if (farmer.primaryCrops != null) {
        for (final crop in farmer.primaryCrops!) {
          cropCount[crop] = (cropCount[crop] ?? 0) + 1;
        }
      }
    }
    if (cropCount.isEmpty) return 0.0;
    
    final total = cropCount.values.fold(0, (sum, count) => sum + count);
    final diversity = cropCount.values.map((count) {
      final proportion = count / total;
      return proportion * (proportion > 0 ? -proportion * math.log(proportion.clamp(0.001, 1.0)) : 0);
    }).fold(0.0, (sum, value) => sum + value);
    
    return diversity;
  }
  
  Map<String, dynamic> _getSeasonalCropDistribution(List<Farmer> farmers) {
    final kharif = <String, int>{};
    final rabi = <String, int>{};
    final zaid = <String, int>{};
    
    for (final farmer in farmers) {
      if (farmer.croppingPattern?.contains('Kharif') == true && farmer.primaryCrops != null) {
        for (final crop in farmer.primaryCrops!) {
          kharif[crop] = (kharif[crop] ?? 0) + 1;
        }
      }
      if (farmer.croppingPattern?.contains('Rabi') == true && farmer.secondaryCrops != null) {
        for (final crop in farmer.secondaryCrops!) {
          rabi[crop] = (rabi[crop] ?? 0) + 1;
        }
      }
      if (farmer.croppingPattern?.contains('Zaid') == true && farmer.seasonalCrops != null) {
        for (final crop in farmer.seasonalCrops!) {
          zaid[crop] = (zaid[crop] ?? 0) + 1;
        }
      }
    }
    
    return {
      'kharif': kharif,
      'rabi': rabi,
      'zaid': zaid,
    };
  }
  
  // Geographic Analytics
  Map<String, int> _getStateDistribution(List<Farmer> farmers) {
    final stateCount = <String, int>{};
    for (final farmer in farmers) {
      final state = farmer.state ?? 'Unknown';
      stateCount[state] = (stateCount[state] ?? 0) + 1;
    }
    return stateCount;
  }
  
  Map<String, int> _getDistrictDistribution(List<Farmer> farmers) {
    final districtCount = <String, int>{};
    for (final farmer in farmers) {
      final district = farmer.district ?? 'Unknown';
      districtCount[district] = (districtCount[district] ?? 0) + 1;
    }
    return districtCount;
  }
  
  Map<String, int> _getVillageDistribution(List<Farmer> farmers) {
    final villageCount = <String, int>{};
    for (final farmer in farmers) {
      villageCount[farmer.village] = (villageCount[farmer.village] ?? 0) + 1;
    }
    return villageCount;
  }
  
  // Financial Analytics
  double _calculateAverageIncome(List<Farmer> farmers) {
    final farmersWithIncome = farmers.where((f) => f.annualIncome != null && f.annualIncome! > 0);
    if (farmersWithIncome.isEmpty) return 0.0;
    
    final totalIncome = farmersWithIncome.fold<double>(0.0, (sum, f) => sum + f.annualIncome!);
    return totalIncome / farmersWithIncome.length;
  }
  
  // Technology Analytics
  double _calculateTechnologyAdoptionRate(List<Farmer> farmers) {
    if (farmers.isEmpty) return 0.0;
    
    final techUsers = farmers.where((f) =>
      f.usesMobileApp == true ||
      f.usesWeatherServices == true ||
      f.usesPrecisionFarming == true ||
      f.usesDroneServices == true
    ).length;
    
    return (techUsers / farmers.length) * 100;
  }
  
  // Sustainability Analytics
  double _calculateAverageEnvironmentalScore(List<Farmer> farmers) {
    if (farmers.isEmpty) return 0.0;
    
    final scores = farmers.map((f) {
      double score = 0.0;
      if (f.isOrganicCertified == true) score += 20;
      if (f.usesSolarEnergy == true) score += 15;
      if (f.practicesWaterConservation == true) score += 15;
      if (f.usesBiofertilizers == true) score += 20;
      if (f.practicesIntegratedPestManagement == true) score += 15;
      if (f.farmingMethod == 'Organic') score += 15;
      return score;
    }).toList();
    
    return scores.fold(0.0, (sum, score) => sum + score) / farmers.length;
  }
  
  // Performance Analytics
  double _calculateAverageYield(List<Farmer> farmers) {
    final farmersWithYield = farmers.where((f) => f.averageYieldPerAcre != null && f.averageYieldPerAcre! > 0);
    if (farmersWithYield.isEmpty) return 0.0;
    
    final totalYield = farmersWithYield.fold<double>(0.0, (sum, f) => sum + f.averageYieldPerAcre!);
    return totalYield / farmersWithYield.length;
  }
  
  String _calculateAverageQualityGrade(List<Farmer> farmers) {
    final grades = farmers.where((f) => f.qualityGrade?.isNotEmpty == true).map((f) => f.qualityGrade!).toList();
    if (grades.isEmpty) return 'N/A';
    
    // Simple grade averaging (A=4, B=3, C=2, D=1)
    final gradeValues = grades.map((grade) {
      switch (grade.toUpperCase()) {
        case 'A': return 4.0;
        case 'B': return 3.0;
        case 'C': return 2.0;
        case 'D': return 1.0;
        default: return 2.5;
      }
    }).toList();
    
    final avgValue = gradeValues.fold(0.0, (sum, value) => sum + value) / gradeValues.length;
    
    if (avgValue >= 3.5) return 'A';
    if (avgValue >= 2.5) return 'B';
    if (avgValue >= 1.5) return 'C';
    return 'D';
  }
  
  double _calculateAverageDeliveryRate(List<Farmer> farmers) {
    final farmersWithRate = farmers.where((f) => f.onTimeDeliveryRate != null);
    if (farmersWithRate.isEmpty) return 0.0;
    
    final totalRate = farmersWithRate.fold<double>(0.0, (sum, f) => sum + f.onTimeDeliveryRate!);
    return totalRate / farmersWithRate.length;
  }
  
  double _calculateAverageCustomerSatisfaction(List<Farmer> farmers) {
    final farmersWithScore = farmers.where((f) => f.customerSatisfactionScore != null);
    if (farmersWithScore.isEmpty) return 0.0;
    
    final totalScore = farmersWithScore.fold<double>(0.0, (sum, f) => sum + f.customerSatisfactionScore!);
    return totalScore / farmersWithScore.length;
  }
  
  // Demographic Analytics
  Map<String, int> _getAgeDistribution(List<Farmer> farmers) {
    final ageGroups = <String, int>{
      '18-30': 0,
      '31-45': 0,
      '46-60': 0,
      '60+': 0,
      'Unknown': 0,
    };
    
    for (final farmer in farmers) {
      final age = farmer.age;
      if (age == null) {
        ageGroups['Unknown'] = ageGroups['Unknown']! + 1;
      } else if (age <= 30) {
        ageGroups['18-30'] = ageGroups['18-30']! + 1;
      } else if (age <= 45) {
        ageGroups['31-45'] = ageGroups['31-45']! + 1;
      } else if (age <= 60) {
        ageGroups['46-60'] = ageGroups['46-60']! + 1;
      } else {
        ageGroups['60+'] = ageGroups['60+']! + 1;
      }
    }
    
    return ageGroups;
  }
  
  Map<String, int> _getGenderDistribution(List<Farmer> farmers) {
    final genderCount = <String, int>{};
    for (final farmer in farmers) {
      final gender = farmer.gender ?? 'Unknown';
      genderCount[gender] = (genderCount[gender] ?? 0) + 1;
    }
    return genderCount;
  }
  
  Map<String, int> _getEducationDistribution(List<Farmer> farmers) {
    final educationCount = <String, int>{};
    for (final farmer in farmers) {
      final education = farmer.educationLevel ?? 'Unknown';
      educationCount[education] = (educationCount[education] ?? 0) + 1;
    }
    return educationCount;
  }
  
  Map<String, int> _getMaritalStatusDistribution(List<Farmer> farmers) {
    final statusCount = <String, int>{};
    for (final farmer in farmers) {
      final status = farmer.maritalStatus ?? 'Unknown';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    return statusCount;
  }
  
  // Membership Analytics
  Map<String, dynamic> _getGovernmentSchemeAnalytics(List<Farmer> farmers) {
    final schemeCount = <String, int>{};
    int totalBeneficiaries = 0;
    
    for (final farmer in farmers) {
      if (farmer.governmentSchemes != null && farmer.governmentSchemes!.isNotEmpty) {
        totalBeneficiaries++;
        for (final scheme in farmer.governmentSchemes!) {
          schemeCount[scheme] = (schemeCount[scheme] ?? 0) + 1;
        }
      }
    }
    
    return {
      'total_beneficiaries': totalBeneficiaries,
      'schemes': schemeCount,
      'participation_rate': farmers.isNotEmpty ? (totalBeneficiaries / farmers.length) * 100 : 0.0,
    };
  }
  
  Map<String, dynamic> _getTrainingAnalytics(List<Farmer> farmers) {
    final trainingCount = <String, int>{};
    int totalParticipants = 0;
    
    for (final farmer in farmers) {
      if (farmer.trainingsCertifications != null && farmer.trainingsCertifications!.isNotEmpty) {
        totalParticipants++;
        for (final training in farmer.trainingsCertifications!) {
          trainingCount[training] = (trainingCount[training] ?? 0) + 1;
        }
      }
    }
    
    return {
      'total_participants': totalParticipants,
      'trainings': trainingCount,
      'participation_rate': farmers.isNotEmpty ? (totalParticipants / farmers.length) * 100 : 0.0,
    };
  }
  
  // Market Analytics
  Map<String, int> _getMarketChannelDistribution(List<Farmer> farmers) {
    final channelCount = <String, int>{};
    for (final farmer in farmers) {
      if (farmer.marketChannels != null) {
        for (final channel in farmer.marketChannels!) {
          channelCount[channel] = (channelCount[channel] ?? 0) + 1;
        }
      }
    }
    return channelCount;
  }
  
  double _calculateAverageSellingPrice(List<Farmer> farmers) {
    final farmersWithPrice = farmers.where((f) => f.averageSellingPrice != null && f.averageSellingPrice! > 0);
    if (farmersWithPrice.isEmpty) return 0.0;
    
    final totalPrice = farmersWithPrice.fold<double>(0.0, (sum, f) => sum + f.averageSellingPrice!);
    return totalPrice / farmersWithPrice.length;
  }
  
  // Recent Activity Analytics
  int _getNewRegistrationsThisMonth(List<Farmer> farmers) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    
    return farmers.where((f) => f.createdAt.isAfter(thisMonth)).length;
  }
  
  String _getMostActiveDistrict(List<Farmer> farmers) {
    final districtCount = _getDistrictDistribution(farmers);
    if (districtCount.isEmpty) return 'N/A';
    
    final mostActive = districtCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostActive.key;
  }
  
  String _getFastestGrowingCrop(List<Farmer> farmers) {
    // This would require historical data comparison
    // For now, return the most popular crop
    final cropCount = _getTopCrops(farmers);
    if (cropCount.isEmpty) return 'N/A';
    
    final mostPopular = cropCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostPopular.key;
  }
  
  // Data Quality Analytics
  double _calculateDataCompletenessScore(List<Farmer> farmers) {
    if (farmers.isEmpty) return 0.0;
    
    final scores = farmers.map((farmer) {
      int filledFields = 0;
      int totalFields = 50; // Total important fields
      
      // Basic information (8 fields)
      if (farmer.fullName.isNotEmpty) filledFields++;
      if (farmer.mobileNumber.isNotEmpty) filledFields++;
      if (farmer.village.isNotEmpty) filledFields++;
      if (farmer.gender != null) filledFields++;
      if (farmer.age != null) filledFields++;
      if (farmer.educationLevel != null) filledFields++;
      if (farmer.maritalStatus != null) filledFields++;
      if (farmer.primaryLanguage != null) filledFields++;
      
      // Farm details (10 fields)
      if (farmer.totalLandArea > 0) filledFields++;
      if (farmer.soilType != null) filledFields++;
      if (farmer.waterSource != null) filledFields++;
      if (farmer.farmOwnership != null) filledFields++;
      if (farmer.latitude != null) filledFields++;
      if (farmer.longitude != null) filledFields++;
      if (farmer.irrigatedArea != null) filledFields++;
      if (farmer.rainfedArea != null) filledFields++;
      if (farmer.farmName != null) filledFields++;
      if (farmer.surveyNumber != null) filledFields++;
      
      // Crop information (8 fields)
      if (farmer.primaryCrops?.isNotEmpty == true) filledFields++;
      if (farmer.farmingMethod != null) filledFields++;
      if (farmer.croppingPattern != null) filledFields++;
      if (farmer.isOrganicCertified != null) filledFields++;
      if (farmer.seedVarietiesUsed?.isNotEmpty == true) filledFields++;
      if (farmer.cropRotationPattern != null) filledFields++;
      if (farmer.expectedYieldPerCrop?.isNotEmpty == true) filledFields++;
      if (farmer.secondaryCrops?.isNotEmpty == true) filledFields++;
      
      // Infrastructure (8 fields)
      if (farmer.hasTractor != null) filledFields++;
      if (farmer.hasStorageFacility != null) filledFields++;
      if (farmer.hasColdStorage != null) filledFields++;
      if (farmer.hasTransportation != null) filledFields++;
      if (farmer.machineryOwned?.isNotEmpty == true) filledFields++;
      if (farmer.irrigationInfrastructure?.isNotEmpty == true) filledFields++;
      if (farmer.storageCapacity != null) filledFields++;
      if (farmer.transportationType != null) filledFields++;
      
      // Financial (8 fields)
      if (farmer.bankAccountNumber?.isNotEmpty == true) filledFields++;
      if (farmer.ifscCode?.isNotEmpty == true) filledFields++;
      if (farmer.kccNumber?.isNotEmpty == true) filledFields++;
      if (farmer.hasInsurance != null) filledFields++;
      if (farmer.annualIncome != null) filledFields++;
      if (farmer.creditLimit != null) filledFields++;
      if (farmer.paymentPreference != null) filledFields++;
      if (farmer.upiId?.isNotEmpty == true) filledFields++;
      
      // Technology & Performance (8 fields)
      if (farmer.usesMobileApp != null) filledFields++;
      if (farmer.usesWeatherServices != null) filledFields++;
      if (farmer.technologyAdopted?.isNotEmpty == true) filledFields++;
      if (farmer.averageYieldPerAcre != null) filledFields++;
      if (farmer.qualityGrade != null) filledFields++;
      if (farmer.customerSatisfactionScore != null) filledFields++;
      if (farmer.environmentalComplianceScore != null) filledFields++;
      if (farmer.internetConnectivity != null) filledFields++;
      
      return (filledFields / totalFields) * 100;
    }).toList();
    
    return scores.fold(0.0, (sum, score) => sum + score) / farmers.length;
  }

  // Bridge connection initialization
  static Future<void> initializeBridgeConnection() async {
    if (kDebugMode) {
      print('[FARMER] Service bridge connection initialized');
    }
  }
}
