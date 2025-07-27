import 'package:flutter/material.dart';
import '../../../models/farmer.dart';
import '../../../services/farmer_service.dart';
import '../../../core/activity_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SimpleFarmerListScreen extends StatefulWidget {
  const SimpleFarmerListScreen({Key? key}) : super(key: key);

  @override
  State<SimpleFarmerListScreen> createState() => _SimpleFarmerListScreenState();
}

class _SimpleFarmerListScreenState extends State<SimpleFarmerListScreen> {
  final FarmerService _service = FarmerService.instance;
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _trackNavigation();
  }

  void _trackNavigation() {
    ActivityTracker().trackNavigation(
      screenName: 'SimpleFarmerList',
      routeName: '/farmers/list',
      relatedFiles: [
        'lib/modules/farmer_management/screens/simple_farmer_list_screen.dart',
        'lib/models/farmer.dart',
        'lib/services/farmer_service.dart',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌾 Farmers'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFarmerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSort(),
          Expanded(
            child: _buildFarmersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search farmers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'village', child: Text('Village')),
              DropdownMenuItem(value: 'landArea', child: Text('Land Area')),
            ],
            onChanged: (value) => setState(() => _sortBy = value!),
          ),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () => setState(() => _sortAscending = !_sortAscending),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmersList() {
    return FutureBuilder<List<Farmer>>(
      future: FarmerService.getAllFarmers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final farmers = snapshot.data ?? [];
        final filteredFarmers = _filterAndSortFarmers(farmers);

        if (filteredFarmers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.agriculture, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('No farmers found'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredFarmers.length,
          itemBuilder: (context, index) => _buildFarmerCard(filteredFarmers[index]),
        );
      },
    );
  }

  List<Farmer> _filterAndSortFarmers(List<Farmer> farmers) {
    var filtered = farmers.where((farmer) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return farmer.fullName.toLowerCase().contains(query) ||
             farmer.village.toLowerCase().contains(query) ||
             farmer.farmerCode.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.fullName.compareTo(b.fullName);
          break;
        case 'village':
          comparison = a.village.compareTo(b.village);
          break;
        case 'landArea':
          comparison = a.totalLandArea.compareTo(b.totalLandArea);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildFarmerCard(Farmer farmer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            farmer.fullName.isNotEmpty ? farmer.fullName[0].toUpperCase() : 'F',
            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          farmer.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 ${farmer.village}'),
            Text('📞 ${farmer.mobileNumber}'),
            Text('🏞️ ${farmer.totalLandArea} acres'),
            if (farmer.primaryCrops?.isNotEmpty == true)
              Text('🌱 ${farmer.primaryCrops!.join(', ')}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (farmer.isOrganicCertified == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🌿 Organic',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFarmer(farmer),
            ),
          ],
        ),
        onTap: () => _showFarmerDetails(farmer),
      ),
    );
  }

  void _showFarmerDetails(Farmer farmer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🌾 ${farmer.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Farmer Code', farmer.farmerCode),
              _buildDetailRow('Mobile', farmer.mobileNumber),
              if (farmer.email != null) _buildDetailRow('Email', farmer.email!),
              _buildDetailRow('Village', farmer.village),
              if (farmer.district != null) _buildDetailRow('District', farmer.district!),
              if (farmer.state != null) _buildDetailRow('State', farmer.state!),
              if (farmer.pincode != null) _buildDetailRow('Pincode', farmer.pincode!),
              _buildDetailRow('Land Area', '${farmer.totalLandArea} acres'),
              if (farmer.soilType != null) _buildDetailRow('Soil Type', farmer.soilType!),
              if (farmer.primaryCrops?.isNotEmpty == true)
                _buildDetailRow('Primary Crops', farmer.primaryCrops!.join(', ')),
              if (farmer.secondaryCrops?.isNotEmpty == true)
                _buildDetailRow('Secondary Crops', farmer.secondaryCrops!.join(', ')),
              _buildDetailRow('Organic Certified', farmer.isOrganicCertified == true ? 'Yes' : 'No'),
              _buildDetailRow('Status', farmer.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddFarmerDialog() {
    final formKey = GlobalKey<FormState>();
    final controllers = {
      'fullName': TextEditingController(),
      'mobile': TextEditingController(),
      'email': TextEditingController(),
      'village': TextEditingController(),
      'district': TextEditingController(),
      'state': TextEditingController(),
      'pincode': TextEditingController(),
      'landArea': TextEditingController(),
      'soilType': TextEditingController(),
      'crops': TextEditingController(),
    };

    bool isOrganic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🌾 Add New Farmer'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controllers['fullName'],
                      decoration: const InputDecoration(labelText: 'Full Name *'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: controllers['mobile'],
                      decoration: const InputDecoration(labelText: 'Mobile Number *'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: controllers['email'],
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextFormField(
                      controller: controllers['village'],
                      decoration: const InputDecoration(labelText: 'Village *'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: controllers['district'],
                      decoration: const InputDecoration(labelText: 'District'),
                    ),
                    TextFormField(
                      controller: controllers['state'],
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    TextFormField(
                      controller: controllers['pincode'],
                      decoration: const InputDecoration(labelText: 'Pincode'),
                    ),
                    TextFormField(
                      controller: controllers['landArea'],
                      decoration: const InputDecoration(labelText: 'Land Area (acres) *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: controllers['soilType'],
                      decoration: const InputDecoration(labelText: 'Soil Type'),
                    ),
                    TextFormField(
                      controller: controllers['crops'],
                      decoration: const InputDecoration(
                        labelText: 'Primary Crops (comma-separated)',
                        hintText: 'Rice, Wheat, Sugarcane',
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text('Organic Certified'),
                      value: isOrganic,
                      onChanged: (value) => setDialogState(() => isOrganic = value!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveFarmer(formKey, controllers, isOrganic),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveFarmer(GlobalKey<FormState> formKey, Map<String, TextEditingController> controllers, bool isOrganic) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final cropsList = controllers['crops']!.text.isNotEmpty
          ? controllers['crops']!.text.split(',').map((e) => e.trim()).toList()
          : <String>[];

      final farmer = Farmer(
        id: '', // Will be set by Firestore
        farmerCode: 'F${DateTime.now().millisecondsSinceEpoch}',
        fullName: controllers['fullName']!.text,
        mobileNumber: controllers['mobile']!.text,
        email: controllers['email']!.text.isNotEmpty ? controllers['email']!.text : null,
        village: controllers['village']!.text,
        district: controllers['district']!.text.isNotEmpty ? controllers['district']!.text : null,
        state: controllers['state']!.text.isNotEmpty ? controllers['state']!.text : null,
        pincode: controllers['pincode']!.text.isNotEmpty ? controllers['pincode']!.text : null,
        totalLandArea: double.parse(controllers['landArea']!.text),
        soilType: controllers['soilType']!.text.isNotEmpty ? controllers['soilType']!.text : null,
        primaryCrops: cropsList.isNotEmpty ? cropsList : null,
        isOrganicCertified: isOrganic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.createFarmer(farmer);
      
      if (mounted) {
        Navigator.pop(context);
        setState(() {}); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Farmer ${farmer.fullName} added successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteFarmer(Farmer farmer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farmer'),
        content: Text('Are you sure you want to delete ${farmer.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteFarmer(farmer.id);
        setState(() {}); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${farmer.fullName} deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
