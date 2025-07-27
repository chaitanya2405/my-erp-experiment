import 'package:cloud_firestore/cloud_firestore.dart';

/// 🌾 Complete Farmer Model - Comprehensive Agricultural ERP System
/// Following our detailed discussion with 50+ fields for complete farmer management
class Farmer {
  // === BASIC INFORMATION ===
  final String id;
  final String farmerCode;
  final String fullName;
  final String? fatherSpouseName;
  final DateTime? dateOfBirth;
  final int? age;
  final String? gender;
  final String? maritalStatus;
  final String? educationLevel;
  final String? primaryLanguage;

  // === CONTACT DETAILS ===
  final String mobileNumber;
  final String? whatsappNumber;
  final String? alternateContact;
  final String? email;
  final String? preferredCommunicationMode;
  final String village;
  final String? district;
  final String? state;
  final String? pincode;
  final String? fullAddress;

  // === IDENTIFICATION DOCUMENTS ===
  final String? aadharNumber;
  final String? panNumber;
  final String? voterIdNumber;
  final String? drivingLicenseNumber;
  final String? passportNumber;

  // === FARM DETAILS ===
  final String? farmName;
  final String? surveyNumber;
  final double totalLandArea;
  final String? landAreaUnit; // Acres/Hectares
  final double? irrigatedArea;
  final double? rainfedArea;
  final double? latitude;
  final double? longitude;
  final String? soilType;
  final String? waterSource;
  final String? farmOwnership; // Own/Leased/Shared
  final String? leaseAgreementNumber;
  final DateTime? leaseExpiryDate;

  // === CROP INFORMATION ===
  final List<String>? primaryCrops;
  final List<String>? secondaryCrops;
  final List<String>? seasonalCrops;
  final List<String>? cashCrops;
  final String? croppingPattern; // Kharif/Rabi/Zaid
  final bool? isOrganicCertified;
  final String? organicCertificationNumber;
  final DateTime? organicCertificationDate;
  final DateTime? organicCertificationExpiry;
  final String? farmingMethod; // Organic/Conventional/Mixed
  final List<String>? seedVarietiesUsed;
  final Map<String, double>? expectedYieldPerCrop;
  final String? cropRotationPattern;

  // === INFRASTRUCTURE & RESOURCES ===
  final List<String>? machineryOwned;
  final bool? hasTractor;
  final String? tractorModel;
  final bool? hasHarvester;
  final bool? hasStorageFacility;
  final double? storageCapacity;
  final String? storageType;
  final bool? hasProcessingEquipment;
  final bool? hasColdStorage;
  final double? coldStorageCapacity;
  final bool? hasTransportation;
  final String? transportationType;
  final List<String>? irrigationInfrastructure;

  // === FINANCIAL INFORMATION ===
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? upiId;
  final String? paymentPreference;
  final String? kccNumber; // Kisan Credit Card
  final double? creditLimit;
  final double? outstandingLoan;
  final bool? hasInsurance;
  final String? insuranceCompany;
  final String? insurancePolicyNumber;
  final double? annualIncome;
  final double? farmIncome;
  final double? nonFarmIncome;

  // === CERTIFICATIONS & MEMBERSHIPS ===
  final String? fpoMembership; // Farmer Producer Organization
  final String? shgMembership; // Self Help Group
  final List<String>? governmentSchemes;
  final List<String>? subsidiesReceived;
  final List<String>? awardsRecognition;
  final List<String>? trainingsCertifications;
  final List<String>? skillsCertifications;

  // === TECHNOLOGY & EQUIPMENT ===
  final List<String>? technologyAdopted;
  final bool? usesMobileApp;
  final bool? usesWeatherServices;
  final bool? usesMarketInformation;
  final bool? usesDroneServices;
  final bool? usesPrecisionFarming;
  final String? internetConnectivity;

  // === PERFORMANCE METRICS ===
  final double? averageYieldPerAcre;
  final String? qualityGrade;
  final double? onTimeDeliveryRate;
  final double? paymentReliabilityScore;
  final double? customerSatisfactionScore;
  final double? environmentalComplianceScore;
  final double? creditScore;

  // === SUSTAINABILITY & ENVIRONMENT ===
  final double? carbonFootprint;
  final double? waterUsageEfficiency;
  final bool? usesSolarEnergy;
  final bool? practicesWaterConservation;
  final bool? usesBiofertilizers;
  final bool? practicesIntegratedPestManagement;

  // === MARKET & SALES ===
  final List<String>? marketChannels;
  final List<String>? buyersList;
  final String? preferredSellingMethod;
  final bool? sellsDirectToConsumer;
  final bool? participatesInFarmersMarket;
  final double? averageSellingPrice;

  // === SYSTEM FIELDS ===
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? storeId;
  final String? createdBy;
  final String? updatedBy;
  final Map<String, dynamic>? additionalData;
  final List<String>? tags;
  final String? notes;

  Farmer({
    required this.id,
    required this.farmerCode,
    required this.fullName,
    this.fatherSpouseName,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.maritalStatus,
    this.educationLevel,
    this.primaryLanguage,
    
    required this.mobileNumber,
    this.whatsappNumber,
    this.alternateContact,
    this.email,
    this.preferredCommunicationMode,
    required this.village,
    this.district,
    this.state,
    this.pincode,
    this.fullAddress,
    
    this.aadharNumber,
    this.panNumber,
    this.voterIdNumber,
    this.drivingLicenseNumber,
    this.passportNumber,
    
    required this.totalLandArea,
    this.farmName,
    this.surveyNumber,
    this.landAreaUnit,
    this.irrigatedArea,
    this.rainfedArea,
    this.latitude,
    this.longitude,
    this.soilType,
    this.waterSource,
    this.farmOwnership,
    this.leaseAgreementNumber,
    this.leaseExpiryDate,
    
    this.primaryCrops,
    this.secondaryCrops,
    this.seasonalCrops,
    this.cashCrops,
    this.croppingPattern,
    this.isOrganicCertified,
    this.organicCertificationNumber,
    this.organicCertificationDate,
    this.organicCertificationExpiry,
    this.farmingMethod,
    this.seedVarietiesUsed,
    this.expectedYieldPerCrop,
    this.cropRotationPattern,
    
    this.machineryOwned,
    this.hasTractor,
    this.tractorModel,
    this.hasHarvester,
    this.hasStorageFacility,
    this.storageCapacity,
    this.storageType,
    this.hasProcessingEquipment,
    this.hasColdStorage,
    this.coldStorageCapacity,
    this.hasTransportation,
    this.transportationType,
    this.irrigationInfrastructure,
    
    this.bankAccountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.upiId,
    this.paymentPreference,
    this.kccNumber,
    this.creditLimit,
    this.outstandingLoan,
    this.hasInsurance,
    this.insuranceCompany,
    this.insurancePolicyNumber,
    this.annualIncome,
    this.farmIncome,
    this.nonFarmIncome,
    
    this.fpoMembership,
    this.shgMembership,
    this.governmentSchemes,
    this.subsidiesReceived,
    this.awardsRecognition,
    this.trainingsCertifications,
    this.skillsCertifications,
    
    this.technologyAdopted,
    this.usesMobileApp,
    this.usesWeatherServices,
    this.usesMarketInformation,
    this.usesDroneServices,
    this.usesPrecisionFarming,
    this.internetConnectivity,
    
    this.averageYieldPerAcre,
    this.qualityGrade,
    this.onTimeDeliveryRate,
    this.paymentReliabilityScore,
    this.customerSatisfactionScore,
    this.environmentalComplianceScore,
    this.creditScore,
    
    this.carbonFootprint,
    this.waterUsageEfficiency,
    this.usesSolarEnergy,
    this.practicesWaterConservation,
    this.usesBiofertilizers,
    this.practicesIntegratedPestManagement,
    
    this.marketChannels,
    this.buyersList,
    this.preferredSellingMethod,
    this.sellsDirectToConsumer,
    this.participatesInFarmersMarket,
    this.averageSellingPrice,
    
    this.status = 'Active',
    required this.createdAt,
    required this.updatedAt,
    this.storeId,
    this.createdBy,
    this.updatedBy,
    this.additionalData,
    this.tags,
    this.notes,
  });

  // Add factory empty constructor
  factory Farmer.empty() {
    return Farmer(
      id: '',
      farmerCode: 'F${DateTime.now().millisecondsSinceEpoch}',
      fullName: '',
      mobileNumber: '',
      village: '',
      totalLandArea: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'Active',
    );
  }

  // Add fromFirestore factory constructor with proper field mapping
  factory Farmer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Farmer(
      id: doc.id,
      farmerCode: data['farmerCode'] ?? '',
      fullName: data['fullName'] ?? '',
      fatherSpouseName: data['fatherSpouseName'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      age: data['age'],
      gender: data['gender'],
      maritalStatus: data['maritalStatus'],
      educationLevel: data['educationLevel'],
      primaryLanguage: data['primaryLanguage'],
      mobileNumber: data['mobileNumber'] ?? '',
      whatsappNumber: data['whatsappNumber'],
      alternateContact: data['alternateContact'],
      email: data['email'],
      preferredCommunicationMode: data['preferredCommunicationMode'],
      village: data['village'] ?? '',
      district: data['district'],
      state: data['state'],
      pincode: data['pincode'],
      fullAddress: data['fullAddress'],
      aadharNumber: data['aadharNumber'],
      panNumber: data['panNumber'],
      voterIdNumber: data['voterIdNumber'],
      drivingLicenseNumber: data['drivingLicenseNumber'],
      passportNumber: data['passportNumber'],
      farmName: data['farmName'],
      surveyNumber: data['surveyNumber'],
      totalLandArea: (data['totalLandArea'] ?? 0.0).toDouble(),
      landAreaUnit: data['landAreaUnit'],
      irrigatedArea: data['irrigatedArea']?.toDouble(),
      rainfedArea: data['rainfedArea']?.toDouble(),
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      soilType: data['soilType'],
      waterSource: data['waterSource'],
      farmOwnership: data['farmOwnership'],
      leaseAgreementNumber: data['leaseAgreementNumber'],
      leaseExpiryDate: data['leaseExpiryDate']?.toDate(),
      primaryCrops: List<String>.from(data['primaryCrops'] ?? []),
      secondaryCrops: List<String>.from(data['secondaryCrops'] ?? []),
      seasonalCrops: List<String>.from(data['seasonalCrops'] ?? []),
      cashCrops: List<String>.from(data['cashCrops'] ?? []),
      croppingPattern: data['croppingPattern'],
      isOrganicCertified: data['isOrganicCertified'],
      organicCertificationNumber: data['organicCertificationNumber'],
      organicCertificationDate: data['organicCertificationDate']?.toDate(),
      organicCertificationExpiry: data['organicCertificationExpiry']?.toDate(),
      farmingMethod: data['farmingMethod'],
      seedVarietiesUsed: List<String>.from(data['seedVarietiesUsed'] ?? []),
      expectedYieldPerCrop: Map<String, double>.from(data['expectedYieldPerCrop'] ?? {}),
      cropRotationPattern: data['cropRotationPattern'],
      machineryOwned: List<String>.from(data['machineryOwned'] ?? []),
      hasTractor: data['hasTractor'],
      tractorModel: data['tractorModel'],
      hasHarvester: data['hasHarvester'],
      hasStorageFacility: data['hasStorageFacility'],
      storageCapacity: data['storageCapacity']?.toDouble(),
      storageType: data['storageType'],
      hasProcessingEquipment: data['hasProcessingEquipment'],
      hasColdStorage: data['hasColdStorage'],
      coldStorageCapacity: data['coldStorageCapacity']?.toDouble(),
      hasTransportation: data['hasTransportation'],
      transportationType: data['transportationType'],
      irrigationInfrastructure: List<String>.from(data['irrigationInfrastructure'] ?? []),
      bankAccountNumber: data['bankAccountNumber'],
      ifscCode: data['ifscCode'],
      bankName: data['bankName'],
      branchName: data['branchName'],
      upiId: data['upiId'],
      paymentPreference: data['paymentPreference'],
      kccNumber: data['kccNumber'],
      creditLimit: data['creditLimit']?.toDouble(),
      outstandingLoan: data['outstandingLoan']?.toDouble(),
      hasInsurance: data['hasInsurance'],
      insuranceCompany: data['insuranceCompany'],
      insurancePolicyNumber: data['insurancePolicyNumber'],
      annualIncome: data['annualIncome']?.toDouble(),
      farmIncome: data['farmIncome']?.toDouble(),
      nonFarmIncome: data['nonFarmIncome']?.toDouble(),
      fpoMembership: data['fpoMembership'],
      shgMembership: data['shgMembership'],
      governmentSchemes: List<String>.from(data['governmentSchemes'] ?? []),
      skillsCertifications: List<String>.from(data['skillsCertifications'] ?? []),
      trainingsCertifications: List<String>.from(data['trainingsCertifications'] ?? []),
      usesMobileApp: data['usesMobileApp'],
      usesWeatherServices: data['usesWeatherServices'],
      usesPrecisionFarming: data['usesPrecisionFarming'],
      usesDroneServices: data['usesDroneServices'],
      technologyAdopted: List<String>.from(data['technologyAdopted'] ?? []),
      usesSolarEnergy: data['usesSolarEnergy'],
      practicesWaterConservation: data['practicesWaterConservation'],
      usesBiofertilizers: data['usesBiofertilizers'],
      practicesIntegratedPestManagement: data['practicesIntegratedPestManagement'],
      averageYieldPerAcre: data['averageYieldPerAcre']?.toDouble(),
      qualityGrade: data['qualityGrade'],
      onTimeDeliveryRate: data['onTimeDeliveryRate']?.toDouble(),
      paymentReliabilityScore: data['paymentReliabilityScore']?.toDouble(),
      customerSatisfactionScore: data['customerSatisfactionScore']?.toDouble(),
      environmentalComplianceScore: data['environmentalComplianceScore']?.toDouble(),
      sellsDirectToConsumer: data['sellsDirectToConsumer'],
      participatesInFarmersMarket: data['participatesInFarmersMarket'],
      marketChannels: List<String>.from(data['marketChannels'] ?? []),
      averageSellingPrice: data['averageSellingPrice']?.toDouble(),
      status: data['status'] ?? 'Active',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      // Basic Information
      'farmerCode': farmerCode,
      'fullName': fullName,
      'fatherSpouseName': fatherSpouseName,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'educationLevel': educationLevel,
      'primaryLanguage': primaryLanguage,
      
      // Contact Details
      'mobileNumber': mobileNumber,
      'whatsappNumber': whatsappNumber,
      'alternateContact': alternateContact,
      'email': email,
      'preferredCommunicationMode': preferredCommunicationMode,
      'village': village,
      'district': district,
      'state': state,
      'pincode': pincode,
      'fullAddress': fullAddress,
      
      // Identification Documents
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'voterIdNumber': voterIdNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'passportNumber': passportNumber,
      
      // Farm Details
      'farmName': farmName,
      'surveyNumber': surveyNumber,
      'totalLandArea': totalLandArea,
      'landAreaUnit': landAreaUnit,
      'irrigatedArea': irrigatedArea,
      'rainfedArea': rainfedArea,
      'latitude': latitude,
      'longitude': longitude,
      'soilType': soilType,
      'waterSource': waterSource,
      'farmOwnership': farmOwnership,
      'leaseAgreementNumber': leaseAgreementNumber,
      'leaseExpiryDate': leaseExpiryDate,
      
      // Crop Information
      'primaryCrops': primaryCrops,
      'secondaryCrops': secondaryCrops,
      'seasonalCrops': seasonalCrops,
      'cashCrops': cashCrops,
      'croppingPattern': croppingPattern,
      'isOrganicCertified': isOrganicCertified,
      'organicCertificationNumber': organicCertificationNumber,
      'organicCertificationDate': organicCertificationDate,
      'organicCertificationExpiry': organicCertificationExpiry,
      'farmingMethod': farmingMethod,
      'seedVarietiesUsed': seedVarietiesUsed,
      'expectedYieldPerCrop': expectedYieldPerCrop,
      'cropRotationPattern': cropRotationPattern,
      
      // Infrastructure & Resources
      'machineryOwned': machineryOwned,
      'hasTractor': hasTractor,
      'tractorModel': tractorModel,
      'hasHarvester': hasHarvester,
      'hasStorageFacility': hasStorageFacility,
      'storageCapacity': storageCapacity,
      'storageType': storageType,
      'hasProcessingEquipment': hasProcessingEquipment,
      'hasColdStorage': hasColdStorage,
      'coldStorageCapacity': coldStorageCapacity,
      'hasTransportation': hasTransportation,
      'transportationType': transportationType,
      'irrigationInfrastructure': irrigationInfrastructure,
      
      // Financial Information
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'branchName': branchName,
      'upiId': upiId,
      'paymentPreference': paymentPreference,
      'kccNumber': kccNumber,
      'creditLimit': creditLimit,
      'outstandingLoan': outstandingLoan,
      'hasInsurance': hasInsurance,
      'insuranceCompany': insuranceCompany,
      'insurancePolicyNumber': insurancePolicyNumber,
      'annualIncome': annualIncome,
      'farmIncome': farmIncome,
      'nonFarmIncome': nonFarmIncome,
      
      // Certifications & Memberships
      'fpoMembership': fpoMembership,
      'shgMembership': shgMembership,
      'governmentSchemes': governmentSchemes,
      'trainingsCertifications': trainingsCertifications,
      'skillsCertifications': skillsCertifications,
      
      // Technology & Equipment
      'technologyAdopted': technologyAdopted,
      'usesMobileApp': usesMobileApp,
      'usesWeatherServices': usesWeatherServices,
      'usesPrecisionFarming': usesPrecisionFarming,
      'usesDroneServices': usesDroneServices,
      'internetConnectivity': internetConnectivity,
      
      // Performance Metrics
      'averageYieldPerAcre': averageYieldPerAcre,
      'qualityGrade': qualityGrade,
      'onTimeDeliveryRate': onTimeDeliveryRate,
      'paymentReliabilityScore': paymentReliabilityScore,
      'customerSatisfactionScore': customerSatisfactionScore,
      'environmentalComplianceScore': environmentalComplianceScore,
      'creditScore': creditScore,
      
      // Sustainability & Environment
      'carbonFootprint': carbonFootprint,
      'waterUsageEfficiency': waterUsageEfficiency,
      'usesSolarEnergy': usesSolarEnergy,
      'practicesWaterConservation': practicesWaterConservation,
      'usesBiofertilizers': usesBiofertilizers,
      'practicesIntegratedPestManagement': practicesIntegratedPestManagement,
      
      // Market & Sales
      'marketChannels': marketChannels,
      'buyersList': buyersList,
      'preferredSellingMethod': preferredSellingMethod,
      'sellsDirectToConsumer': sellsDirectToConsumer,
      'participatesInFarmersMarket': participatesInFarmersMarket,
      'averageSellingPrice': averageSellingPrice,
      
      // System Fields
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'storeId': storeId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'additionalData': additionalData,
      'tags': tags,
      'notes': notes,
    };
  }

  // Basic compatibility getters that don't duplicate existing properties
  String get farmerId => id;
  String get phone => mobileNumber;
  String get city => village;
  String get zipCode => pincode ?? '';
  String get farmAddress => '$village${district != null ? ', $district' : ''}';
  String get farmCity => village;
  String get farmState => state ?? '';
  String get farmZip => pincode ?? '';
  double get farmLatitude => latitude ?? 0.0;
  double get farmLongitude => longitude ?? 0.0;
  double get totalAcreage => totalLandArea;
  double get cultivatedAcreage => totalLandArea * 0.8;
  double get irrigatedAcreage => irrigatedArea ?? (totalLandArea * 0.6);
  String get farmType => farmingMethod ?? 'Mixed';
  String get ownershipType => farmOwnership ?? 'Owned';
  double get elevation => 0.0;
  String get climateZone => 'Temperate';
  DateTime? get farmEstablishedDate => null;
  bool get organicCertified => isOrganicCertified ?? false;
  String get currentSeasonCrop => primaryCrops?.isNotEmpty == true ? primaryCrops!.first : '';
  String get previousSeasonCrop => secondaryCrops?.isNotEmpty == true ? secondaryCrops!.first : '';
  double get averageYield => 0.0;
  String get emergencyContactName => '';
  String get emergencyContactPhone => '';
  String get nationalId => aadharNumber ?? '';
  String get taxId => panNumber ?? '';
  double get farmingIncome => farmIncome ?? 0.0;
  double get nonFarmingIncome => nonFarmIncome ?? 0.0;
  double get totalAssets => 0.0;
  double get totalLiabilities => outstandingLoan ?? 0.0;
  String get accountNumber => bankAccountNumber ?? '';
  String get creditRating => '0';
  double get outstandingLoans => outstandingLoan ?? 0.0;
  String get loanRepaymentStatus => 'Good';
  int get livestockCount => 0;
  List<String> get livestockTypes => [];
  bool get usesSmartFarming => usesPrecisionFarming ?? false;
  bool get usesSolarPower => usesSolarEnergy ?? false;
  bool get usesWaterConservation => practicesWaterConservation ?? false;
  bool get usesBioFertilizers => usesBiofertilizers ?? false;
  bool get usesPestManagement => practicesIntegratedPestManagement ?? false;
  double get sustainabilityScore => 0.0;
  double get productivityIndex => 0.0;
  double get profitabilityRatio => 0.0;
  double get resourceEfficiency => 0.0;
  double get marketReach => 0.0;
  Map<String, dynamic> get harvestMonths => {};
  List<String> get croppingSeasons => [];
  Map<String, dynamic> get expectedYield => expectedYieldPerCrop ?? {};
  Map<String, dynamic> get qualityGrades => {};
  Map<String, dynamic> get cropProductionData => {};
  double get qualityGradeAchievement => 0.0;
  DateTime? get lastSupplyDate => null;
  double get profitMarginPercentage => 0.0;
  double get soilHealthIndex => 0.0;
  String get digitalLiteracyLevel => 'Basic';
  int get totalDeliveries => 0;
  double get totalRevenueGenerated => 0.0;
  int get consecutiveSuccessfulSeasons => 0;
  double get revenuePerAcre => 0.0;
  double get outstandingAmount => outstandingLoan ?? 0.0;
  String get paymentTerms => 'COD';
  String get preferredPaymentMode => paymentPreference ?? 'Cash';
  String get insuranceProvider => insuranceCompany ?? '';
  double get insuranceCoverage => 0.0;
  double get kccLimit => creditLimit ?? 0.0;
  List<Map<String, dynamic>> get communicationLog => [];
  List<Map<String, dynamic>> get loansAvailed => [];
  List<Map<String, dynamic>> get subsidyRecords => subsidiesReceived?.map((s) => {'subsidy': s}).toList() ?? [];
  bool get receivesPriceAlerts => true;
  bool get receivesMarketInformation => usesMarketInformation ?? true;
  bool get hasKisanCreditCard => kccNumber != null;
  int get version => 1;

  // copyWith method for updates
  Farmer copyWith({
    String? id,
    String? farmerCode,
    String? fullName,
    String? mobileNumber,
    String? email,
    String? village,
    String? district,
    String? state,
    String? pincode,
    double? totalLandArea,
    String? soilType,
    List<String>? primaryCrops,
    List<String>? secondaryCrops,
    List<String>? seasonalCrops,
    bool? isOrganicCertified,
    String? bankAccountNumber,
    String? ifscCode,
    String? bankName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeId,
    String? aadharNumber,
    String? panNumber,
    String? waterSource,
    String? farmingMethod,
    Map<String, dynamic>? additionalData,
  }) {
    return Farmer(
      id: id ?? this.id,
      farmerCode: farmerCode ?? this.farmerCode,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      totalLandArea: totalLandArea ?? this.totalLandArea,
      soilType: soilType ?? this.soilType,
      primaryCrops: primaryCrops ?? this.primaryCrops,
      secondaryCrops: secondaryCrops ?? this.secondaryCrops,
      seasonalCrops: seasonalCrops ?? this.seasonalCrops,
      isOrganicCertified: isOrganicCertified ?? this.isOrganicCertified,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      storeId: storeId ?? this.storeId,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      waterSource: waterSource ?? this.waterSource,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'Farmer(id: $id, farmerCode: $farmerCode, fullName: $fullName, village: $village, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Farmer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
