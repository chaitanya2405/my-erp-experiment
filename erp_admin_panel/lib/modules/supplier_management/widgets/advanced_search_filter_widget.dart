import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier.dart';

class AdvancedSearchFilterWidget extends StatefulWidget {
  const AdvancedSearchFilterWidget({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchFilterWidget> createState() => _AdvancedSearchFilterWidgetState();
}

class _AdvancedSearchFilterWidgetState extends State<AdvancedSearchFilterWidget> {
  String? supplierType;
  String? status;
  String? rating;
  String? city;
  String? state;
  String? compliance;
  bool? preferred;
  String searchText = '';

  List<Supplier> filteredSuppliers = [];

  void applyFilters(List<Supplier> allSuppliers) {
    setState(() {
      filteredSuppliers = allSuppliers.where((supplier) {
        final matchesSearch = searchText.isEmpty ||
            supplier.supplierName.toLowerCase().contains(searchText.toLowerCase()) ||
            supplier.supplierCode.toLowerCase().contains(searchText.toLowerCase()) ||
            supplier.contactPersonName.toLowerCase().contains(searchText.toLowerCase());
        final matchesType = supplierType == null || supplier.supplierType == supplierType;
        final matchesStatus = status == null || supplier.status == status;
        final matchesRating = rating == null || supplier.rating.toString() == rating;
        final matchesCity = city == null || city!.isEmpty || supplier.city.toLowerCase().contains(city!.toLowerCase());
        final matchesState = state == null || state!.isEmpty || supplier.state.toLowerCase().contains(state!.toLowerCase());
        final matchesCompliance = compliance == null || ((supplier.complianceDocuments.isNotEmpty && supplier.gstin.isNotEmpty && supplier.panNumber.isNotEmpty) ? 'Compliant' : 'Non-Compliant') == compliance;
        final matchesPreferred = preferred == null || supplier.isPreferredSupplier == preferred;
        return matchesSearch && matchesType && matchesStatus && matchesRating && matchesCity && matchesState && matchesCompliance && matchesPreferred;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // Convert Firestore docs to List<Map<String, dynamic>>
        final allSuppliers = snapshot.data!.docs
            .map((doc) => Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // If no filters applied yet, show all
        if (filteredSuppliers.isEmpty && allSuppliers.isNotEmpty) {
          filteredSuppliers = List.from(allSuppliers);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search by Name, Code, or Contact',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => searchText = value),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                        value: supplierType,
                        items: ['Manufacturer', 'Distributor', 'Wholesaler', 'Retailer', 'Other']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => setState(() => supplierType = value),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                        value: status,
                        items: ['Active', 'Inactive', 'Pending']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => setState(() => status = value),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Rating', border: OutlineInputBorder()),
                        value: rating,
                        items: ['5', '4', '3', '2', '1']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => setState(() => rating = value),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => city = value),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setState(() => state = value),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Compliance', border: OutlineInputBorder()),
                        value: compliance,
                        items: ['Compliant', 'Non-Compliant']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => setState(() => compliance = value),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<bool>(
                        decoration: const InputDecoration(labelText: 'Preferred', border: OutlineInputBorder()),
                        value: preferred,
                        items: const [
                          DropdownMenuItem(value: true, child: Text('Yes')),
                          DropdownMenuItem(value: false, child: Text('No')),
                        ],
                        onChanged: (value) => setState(() => preferred = value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Apply Filters'),
                  onPressed: () => applyFilters(allSuppliers),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredSuppliers.isEmpty
                    ? const Center(child: Text('No suppliers match the filters.'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Code')),
                            DataColumn(label: Text('Contact')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Rating')),
                            DataColumn(label: Text('City')),
                            DataColumn(label: Text('State')),
                            DataColumn(label: Text('Compliance')),
                            DataColumn(label: Text('Preferred')),
                          ],
                          rows: filteredSuppliers.map((supplier) {
                            return DataRow(cells: [
                              DataCell(Text(supplier.supplierName)),
                              DataCell(Text(supplier.supplierCode)),
                              DataCell(Text(supplier.contactPersonName)),
                              DataCell(Text(supplier.supplierType)),
                              DataCell(Text(supplier.status)),
                              DataCell(Text(supplier.rating.toString())),
                              DataCell(Text(supplier.city)),
                              DataCell(Text(supplier.state)),
                              DataCell(Text((supplier.complianceDocuments.isNotEmpty && supplier.gstin.isNotEmpty && supplier.panNumber.isNotEmpty) ? 'Compliant' : 'Non-Compliant')),
                              DataCell(Text(supplier.isPreferredSupplier ? 'Yes' : 'No')),
                            ]);
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}