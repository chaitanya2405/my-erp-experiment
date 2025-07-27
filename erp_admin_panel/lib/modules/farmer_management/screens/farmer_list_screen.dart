import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/farmer.dart';
import '../../../services/farmer_service.dart';

class FarmerListScreen extends ConsumerStatefulWidget {
  const FarmerListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends ConsumerState<FarmerListScreen> {
  String _searchQuery = '';
  final _tableKey = GlobalKey<PaginatedDataTableState>();
  final TextEditingController _searchController = TextEditingController();
  List<Farmer> _farmers = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    setState(() => _isLoading = true);
    try {
      final farmers = await FarmerService.getAllFarmers();
      setState(() {
        _farmers = farmers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading farmers: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Farmer> _getFilteredFarmers() {
    if (_searchQuery.isEmpty) return _farmers;
    
    final query = _searchQuery.toLowerCase();
    return _farmers.where((farmer) {
      return farmer.fullName.toLowerCase().contains(query) ||
          farmer.farmerCode.toLowerCase().contains(query) ||
          farmer.mobileNumber.contains(query) ||
          (farmer.village.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFarmers = _getFilteredFarmers();
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, code, mobile or village...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: _loadFarmers,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFarmerTable(filteredFarmers),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerTable(List<Farmer> farmers) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Mobile')),
            DataColumn(label: Text('Village')),
            DataColumn(label: Text('District')),
            DataColumn(label: Text('Total Land')),
            DataColumn(label: Text('Primary Crops')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: farmers.map((farmer) {
            return DataRow(
              cells: [
                DataCell(Text(farmer.farmerCode)),
                DataCell(Text(farmer.fullName)),
                DataCell(Text(farmer.mobileNumber)),
                DataCell(Text(farmer.village)),
                DataCell(Text(farmer.district ?? 'N/A')),
                DataCell(Text('${farmer.totalLandArea} acres')),
                DataCell(Text(farmer.primaryCrops?.join(', ') ?? '-')),
                DataCell(_buildStatusChip(farmer.status)),
                DataCell(_buildActionButtons(farmer)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String text = status ?? 'Unknown';
    
    switch (status?.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.grey;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildActionButtons(Farmer farmer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility),
          tooltip: 'View Details',
          onPressed: () => _viewFarmerDetails(farmer),
        ),
      ],
    );
  }

  void _viewFarmerDetails(Farmer farmer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Farmer Details: ${farmer.fullName}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailsSection('Basic Information', {
                        'Farmer Code': farmer.farmerCode,
                        'Full Name': farmer.fullName,
                        'Mobile Number': farmer.mobileNumber,
                        'Gender': farmer.gender ?? 'Not specified',
                        'Age': farmer.age?.toString() ?? 'Not specified',
                      }),
                      const SizedBox(height: 16),
                      _buildDetailsSection('Location Details', {
                        'Village': farmer.village,
                        'District': farmer.district ?? 'N/A',
                        'State': farmer.state ?? 'Not specified',
                      }),
                      const SizedBox(height: 16),
                      _buildDetailsSection('Farm Details', {
                        'Total Land Area': '${farmer.totalLandArea} acres',
                        'Irrigated Area': '${farmer.irrigatedArea ?? 0} acres',
                        'Rainfed Area': '${farmer.rainfedArea ?? 0} acres',
                        'Primary Crops': farmer.primaryCrops?.join(', ') ?? 'None',
                        'Farming Method': farmer.farmingMethod ?? 'Not specified',
                        'Organic Certified': farmer.isOrganicCertified == true ? 'Yes' : 'No',
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(String title, Map<String, String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...details.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    '${entry.key}:',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(entry.value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
