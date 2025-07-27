import 'package:flutter/material.dart';
import '../models/supplier.dart';
import 'supplier_analytics_editor.dart';

class SupplierDetailScreen extends StatelessWidget {
  final Supplier supplier;
  const SupplierDetailScreen({required this.supplier, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final events = <Map<String, String>>[];
    if (supplier.contractStartDate != null) {
      events.add({'label': 'Contract Start', 'date': supplier.contractStartDate!.toLocal().toString().split(' ')[0]});
    }
    if (supplier.contractEndDate != null) {
      events.add({'label': 'Contract End', 'date': supplier.contractEndDate!.toLocal().toString().split(' ')[0]});
    }
    if (supplier.lastSuppliedDate != null) {
      events.add({'label': 'Last Supplied', 'date': supplier.lastSuppliedDate!.toLocal().toString().split(' ')[0]});
    }
    events.add({'label': 'Created', 'date': supplier.createdAt.toDate().toLocal().toString().split(' ')[0]});
    events.add({'label': 'Updated', 'date': supplier.updatedAt.toDate().toLocal().toString().split(' ')[0]});

    return Scaffold(
      appBar: AppBar(
        title: Text('Supplier: ${supplier.supplierName}'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Add Edit Analytics Button ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Analytics'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => SupplierAnalyticsEditor(supplier: supplier),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Text('Scorecard', style: Theme.of(context).textTheme.titleLarge),
                        if (supplier.isPreferredSupplier)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Chip(label: Text('Preferred'), backgroundColor: Colors.greenAccent, visualDensity: VisualDensity.compact),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _kpi('Rating', supplier.rating.toString()),
                        _kpi('On-Time Delivery', '${supplier.onTimeDeliveryRate}%'),
                        _kpi('Avg. Lead Time', '${supplier.averageLeadTimeDays} days'),
                        _kpi('Total Orders', supplier.totalOrdersSupplied.toString()),
                        _kpi('Total Value', '${supplier.totalOrderValue} ${supplier.defaultCurrency}'),
                        _kpi('Status', supplier.status),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('Contact: ${supplier.contactPersonName} (${supplier.contactPersonMobile})'),
                    if (supplier.alternateContactNumber != null && supplier.alternateContactNumber!.isNotEmpty)
                      Text('Alternate: ${supplier.alternateContactNumber}'),
                    Text('Email: ${supplier.email}'),
                    Text('Type: ${supplier.supplierType}'),
                    const SizedBox(height: 8),
                    Text('Address:', style: Theme.of(context).textTheme.titleSmall),
                    Text('${supplier.addressLine1}${supplier.addressLine2 != null && supplier.addressLine2!.isNotEmpty ? ", " + supplier.addressLine2! : ""}'),
                    Text('${supplier.city}, ${supplier.state}, ${supplier.postalCode}, ${supplier.country}'),
                    const SizedBox(height: 8),
                    Text('GSTIN: ${supplier.gstin}'),
                    Text('PAN: ${supplier.panNumber}'),
                    if (supplier.businessRegistrationNo != null && supplier.businessRegistrationNo!.isNotEmpty)
                      Text('Business Reg. No: ${supplier.businessRegistrationNo}'),
                    if (supplier.website != null && supplier.website!.isNotEmpty)
                      Text('Website: ${supplier.website}'),
                    const SizedBox(height: 8),
                    Text('Bank: ${supplier.bankName} (${supplier.bankAccountNumber})'),
                    Text('IFSC: ${supplier.bankIfscCode}'),
                    if (supplier.upiId != null && supplier.upiId!.isNotEmpty)
                      Text('UPI ID: ${supplier.upiId}'),
                    Text('Payment Terms: ${supplier.paymentTerms}'),
                    Text('Preferred Payment: ${supplier.preferredPaymentMode}'),
                    Text('Credit Limit: ${supplier.creditLimit} ${supplier.defaultCurrency}'),
                    const SizedBox(height: 8),
                    Text('Products Supplied: ${supplier.productsSupplied.join(", ")}'),
                    if (supplier.contractStartDate != null)
                      Text('Contract Start: ${supplier.contractStartDate!.toLocal().toString().split(" ")[0]}'),
                    if (supplier.contractEndDate != null)
                      Text('Contract End: ${supplier.contractEndDate!.toLocal().toString().split(" ")[0]}'),
                    if (supplier.lastSuppliedDate != null)
                      Text('Last Supplied: ${supplier.lastSuppliedDate!.toLocal().toString().split(" ")[0]}'),
                    if (supplier.complianceDocuments.isNotEmpty)
                      Text('Compliance Docs: ${supplier.complianceDocuments.join(", ")}'),
                    if (supplier.notes != null && supplier.notes!.isNotEmpty)
                      Text('Notes: ${supplier.notes}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Relationship Timeline', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    ...events.map((e) => Row(
                      children: [
                        const Icon(Icons.circle, size: 12, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text('${e['label']}: ${e['date']}'),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Communication Log', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(supplier.notes ?? 'No communication log yet.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
