import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({Key? key}) : super(key: key);

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Suppliers'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 250,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name, code, city...',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                ),
                onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('suppliers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No suppliers found.'));
                }
                final allSuppliers = snapshot.data!.docs
                    .map((doc) => Supplier.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                final suppliers = _search.isEmpty
                    ? allSuppliers
                    : allSuppliers.where((s) =>
                        s.supplierName.toLowerCase().contains(_search) ||
                        s.supplierCode.toLowerCase().contains(_search) ||
                        s.city.toLowerCase().contains(_search)
                      ).toList();

                return Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: SupplierDataTable(suppliers: suppliers),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SupplierDataTable extends StatefulWidget {
  final List<Supplier> suppliers;
  const SupplierDataTable({required this.suppliers, Key? key}) : super(key: key);

  @override
  State<SupplierDataTable> createState() => _SupplierDataTableState();
}

class _SupplierDataTableState extends State<SupplierDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final ScrollController _horizontal = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontal,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          // Set a large enough width for all columns, or calculate dynamically if needed
          width: 2000,
          child: PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Code')),
              DataColumn(label: Text('Contact')),
              DataColumn(label: Text('Mobile')),
              DataColumn(label: Text('Alternate Mobile')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Address 1')),
              DataColumn(label: Text('Address 2')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('State')),
              DataColumn(label: Text('Postal Code')),
              DataColumn(label: Text('Country')),
              DataColumn(label: Text('GSTIN')),
              DataColumn(label: Text('PAN')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Business Reg. No')),
              DataColumn(label: Text('Website')),
              DataColumn(label: Text('Bank Acc')),
              DataColumn(label: Text('IFSC')),
              DataColumn(label: Text('Bank Name')),
              DataColumn(label: Text('UPI ID')),
              DataColumn(label: Text('Payment Terms')),
              DataColumn(label: Text('Preferred Payment')),
              DataColumn(label: Text('Credit Limit')),
              DataColumn(label: Text('Currency')),
              DataColumn(label: Text('Products')),
              DataColumn(label: Text('Contract Start')),
              DataColumn(label: Text('Contract End')),
              DataColumn(label: Text('Rating')),
              DataColumn(label: Text('On-Time Delivery')),
              DataColumn(label: Text('Lead Time')),
              DataColumn(label: Text('Last Supplied')),
              DataColumn(label: Text('Total Orders')),
              DataColumn(label: Text('Total Value')),
              DataColumn(label: Text('Compliance Docs')),
              DataColumn(label: Text('Preferred')),
              DataColumn(label: Text('Notes')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Details')),
            ],
            source: _SupplierTableSource(widget.suppliers, context),
            rowsPerPage: _rowsPerPage,
            onRowsPerPageChanged: (v) {
              if (v != null) setState(() => _rowsPerPage = v);
            },
            showFirstLastButtons: true,
          ),
        ),
      ),
    );
  }
}

class _SupplierTableSource extends DataTableSource {
  final List<Supplier> suppliers;
  final BuildContext context;

  _SupplierTableSource(this.suppliers, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= suppliers.length) return const DataRow(cells: []);
    final s = suppliers[index];
    return DataRow(
      cells: [
        DataCell(Text(s.supplierName)),
        DataCell(Text(s.supplierCode)),
        DataCell(Text(s.contactPersonName)),
        DataCell(Text(s.contactPersonMobile)),
        DataCell(Text(s.alternateContactNumber ?? '-')),
        DataCell(Text(s.email)),
        DataCell(Text(s.addressLine1)),
        DataCell(Text(s.addressLine2 ?? '-')),
        DataCell(Text(s.city)),
        DataCell(Text(s.state)),
        DataCell(Text(s.postalCode)),
        DataCell(Text(s.country)),
        DataCell(Text(s.gstin)),
        DataCell(Text(s.panNumber)),
        DataCell(Text(s.supplierType)),
        DataCell(Text(s.businessRegistrationNo ?? '-')),
        DataCell(Text(s.website ?? '-')),
        DataCell(Text(s.bankAccountNumber ?? '-')),
        DataCell(Text(s.bankIfscCode ?? '-')),
        DataCell(Text(s.bankName ?? '-')),
        DataCell(Text(s.upiId ?? '-')),
        DataCell(Text(s.paymentTerms ?? '-')),
        DataCell(Text(s.preferredPaymentMode ?? '-')),
        DataCell(Text(s.creditLimit?.toString() ?? '-')),
        DataCell(Text(s.defaultCurrency ?? '-')),
        DataCell(Text(s.productsSupplied?.join(', ') ?? '-')),
        DataCell(Text(s.contractStartDate?.toString().split(' ').first ?? '-')),
        DataCell(Text(s.contractEndDate?.toString().split(' ').first ?? '-')),
        DataCell(Text(s.rating?.toStringAsFixed(1) ?? '-')),
        DataCell(Text(s.onTimeDeliveryRate?.toString() ?? '-')),
        DataCell(Text(s.averageLeadTimeDays?.toString() ?? '-')),
        DataCell(Text(s.lastSuppliedDate?.toString().split(' ').first ?? '-')),
        DataCell(Text(s.totalOrdersSupplied?.toString() ?? '-')),
        DataCell(Text(s.totalOrderValue?.toString() ?? '-')),
        DataCell(Text(s.complianceDocuments?.join(', ') ?? '-')),
        DataCell(Text(s.isPreferredSupplier == true ? 'Yes' : 'No')),
        DataCell(Text(s.notes ?? '-')),
        DataCell(Text(s.status)),
        DataCell(Text(s.createdAt.toDate().toString().split(' ').first)),
        DataCell(Text(s.updatedAt.toDate().toString().split(' ').first)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SupplierDetailScreen(supplier: s),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => suppliers.length;
  @override
  int get selectedRowCount => 0;
}
