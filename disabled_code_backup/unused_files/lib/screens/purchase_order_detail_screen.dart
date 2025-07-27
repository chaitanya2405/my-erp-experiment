import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/po_approval_timeline.dart';
import '../widgets/po_status_chip.dart';
import '../widgets/po_document_upload.dart';
import '../widgets/po_supplier_integration.dart';
import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';
import 'purchase_order_form_screen.dart';

class PurchaseOrderDetailScreen extends StatelessWidget {
  final String poId;
  const PurchaseOrderDetailScreen({Key? key, required this.poId}) : super(key: key);

  Future<PurchaseOrder?> _fetchPO() async {
    final service = PurchaseOrderService();
    final pos = await service.fetchPurchaseOrders();
    try {
      return pos.firstWhere((po) => po.id == poId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Order Details')),
      body: FutureBuilder<PurchaseOrder?>(
        future: _fetchPO(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Purchase Order not found.'));
          }
          final po = snapshot.data!;
          final lineItems = po.lineItems;
          double subtotal = lineItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
          double totalDiscount = lineItems.fold(0, (sum, item) => sum + item.discount);
          double totalTax = lineItems.fold(0, (sum, item) => sum + item.tax);
          double grandTotal = subtotal - totalDiscount + totalTax;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Purchase Order', style: Theme.of(context).textTheme.headlineSmall),
                            Text('PO Number: \\${po.poNumber}', style: Theme.of(context).textTheme.titleMedium),
                            Text('Order Date: \\${po.orderDate.toLocal().toString().split(' ')[0]}'),
                            Text('Expected Delivery: \\${po.expectedDelivery.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            POStatusChip(status: po.status),
                            QrImageView(
                              data: po.id,
                              version: QrVersions.auto,
                              size: 80.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Supplier:', style: Theme.of(context).textTheme.titleSmall),
                              Text(po.supplierId),
                              const SizedBox(height: 8),
                              Text('Store ID: \\${po.storeId}'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Terms: \\${po.paymentTerms ?? '-'}'),
                              Text('Delivery Terms: \\${po.deliveryTerms ?? '-'}'),
                              Text('Invoice Number: \\${po.invoiceNumber ?? '-'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Line Items', style: Theme.of(context).textTheme.titleMedium),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('SKU')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Unit Price')),
                        DataColumn(label: Text('Discount')),
                        DataColumn(label: Text('Tax')),
                        DataColumn(label: Text('Subtotal')),
                      ],
                      rows: lineItems.map((item) => DataRow(cells: [
                        DataCell(Text(item.sku)),
                        DataCell(Text(item.quantity.toString())),
                        DataCell(Text('₹\\${item.price.toStringAsFixed(2)}')),
                        DataCell(Text('₹\\${item.discount.toStringAsFixed(2)}')),
                        DataCell(Text('₹\\${item.tax.toStringAsFixed(2)}')),
                        DataCell(Text('₹\\${(item.price * item.quantity - item.discount + item.tax).toStringAsFixed(2)}')),
                      ])).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Subtotal: ₹\\${subtotal.toStringAsFixed(2)}'),
                            Text('Total Discount: ₹\\${totalDiscount.toStringAsFixed(2)}'),
                            Text('Total Tax: ₹\\${totalTax.toStringAsFixed(2)}'),
                            Text('Grand Total: ₹\\${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Remarks: \\${po.remarks ?? '-'}'),
                    const Divider(height: 32),
                    Text('Approval Timeline', style: Theme.of(context).textTheme.titleMedium),
                    PoApprovalTimeline(approvalHistory: po.approvalHistory),
                    const Divider(height: 32),
                    Text('Documents', style: Theme.of(context).textTheme.titleMedium),
                    PoDocumentUpload(poId: po.id),
                    const Divider(height: 32),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          tooltip: 'View PO',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseOrderFormScreen(poId: po.id, viewOnly: true),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit PO',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseOrderFormScreen(poId: po.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
