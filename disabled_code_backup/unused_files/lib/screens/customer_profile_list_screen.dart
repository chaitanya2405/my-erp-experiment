import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_profile.dart';
import '../services/customer_profile_service.dart';
import 'customer_profile_form_screen.dart';

class CustomerProfileListScreen extends StatefulWidget {
  const CustomerProfileListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerProfileListScreen> createState() => _CustomerProfileListScreenState();
}

class _CustomerProfileListScreenState extends State<CustomerProfileListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 250,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name, mobile, email...',
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
            child: StreamBuilder<List<CustomerProfile>>(
              stream: CustomerProfileService().streamCustomers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final allCustomers = snapshot.data!;

                final customers = _search.isEmpty
                    ? allCustomers
                    : allCustomers.where((c) =>
                        c.fullName.toLowerCase().contains(_search) ||
                        c.mobileNumber.toLowerCase().contains(_search) ||
                        c.email.toLowerCase().contains(_search)
                      ).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: CustomerProfileDataTable(customers: customers),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerProfileDataTable extends StatefulWidget {
  final List<CustomerProfile> customers;
  const CustomerProfileDataTable({required this.customers, Key? key}) : super(key: key);

  @override
  State<CustomerProfileDataTable> createState() => _CustomerProfileDataTableState();
}

class _CustomerProfileDataTableState extends State<CustomerProfileDataTable> {
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
          width: 1800, // Adjust width as needed for all columns
          child: PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('Customer ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Mobile')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Segment')),
              DataColumn(label: Text('Loyalty')),
              DataColumn(label: Text('Orders')),
              DataColumn(label: Text('First Order')),
              DataColumn(label: Text('Last Activity')),
              DataColumn(label: Text('Churn Risk')),
              DataColumn(label: Text('Preferred Channel')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('Updated')),
              DataColumn(label: Text('Actions')),
            ],
            source: _CustomerProfileTableSource(widget.customers, context),
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

class _CustomerProfileTableSource extends DataTableSource {
  final List<CustomerProfile> customers;
  final BuildContext context;

  _CustomerProfileTableSource(this.customers, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= customers.length) return const DataRow(cells: []);
    final c = customers[index];
    return DataRow(
      cells: [
        DataCell(Text(c.customerId)),
        DataCell(Text(c.fullName)),
        DataCell(Text(c.mobileNumber)),
        DataCell(Text(c.email)),
        DataCell(Text(c.customerSegment)),
        DataCell(Text(c.loyaltyPoints.toString())),
        DataCell(Text(c.totalOrders.toString())),
        DataCell(Text(c.firstOrderDate != null ? c.firstOrderDate!.toString().split(' ').first : '-')),
        DataCell(Text(c.lastActivityDate != null ? c.lastActivityDate!.toString().split(' ').first : '-')),
        DataCell(Text(c.churnRiskScore?.toStringAsFixed(2) ?? '-')),
        DataCell(Text(c.preferredChannel ?? '-')),
        DataCell(Text(c.createdAt.toDate().toString().split(' ').first)),
        DataCell(Text(c.updatedAt.toDate().toString().split(' ').first)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerProfileFormScreen(profile: c),
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
  int get rowCount => customers.length;
  @override
  int get selectedRowCount => 0;
}