import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/purchase_order.dart';
import '../services/purchase_order_service.dart';

class PoCommunicationTab extends StatefulWidget {
  @override
  State<PoCommunicationTab> createState() => _PoCommunicationTabState();
}

class _PoCommunicationTabState extends State<PoCommunicationTab> {
  String? _selectedPoId;
  bool _isLoading = false;
  String? _statusMessage;

  Future<List<Map<String, dynamic>>> _fetchPOs() async {
    final pos = await PurchaseOrderService().fetchPurchaseOrders();
    return pos.map((po) => {
      'id': po.id,
      'poNumber': po.id, // Assuming PO number is the same as ID
      'status': po.status,
    }).toList();
  }

  Future<void> _exportPdf(String poId) async {
    setState(() { _isLoading = true; _statusMessage = null; });
    final po = (await PurchaseOrderService().fetchPurchaseOrders()).firstWhere((po) => po.id == poId);
    final doc = pw.Document();
    // Load Unicode font for ₹ and other symbols
    final font = await PdfGoogleFonts.notoSansRegular();
    doc.addPage(
      pw.Page(
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Purchase Order', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
              pw.SizedBox(height: 8),
              pw.Text('#${po.poNumber}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font)),
              pw.SizedBox(height: 12),
              pw.Text('Supplier: ${po.supplierId}', style: pw.TextStyle(font: font)),
              pw.Text('Date: ${po.date.toLocal().toString().split(' ')[0]}', style: pw.TextStyle(font: font)),
              pw.Text('Status: ${po.status}', style: pw.TextStyle(font: font)),
              pw.Text('Total: ₹${po.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 16),
              pw.Row(children: [
                pw.Expanded(child: pw.Text('Billing Address:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
                pw.Expanded(child: pw.Text('Shipping Address:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
              ]),
              pw.Row(children: [
                pw.Expanded(child: pw.Text(po.billingAddress, style: pw.TextStyle(font: font))),
                pw.Expanded(child: pw.Text(po.shippingAddress, style: pw.TextStyle(font: font))),
              ]),
              pw.SizedBox(height: 16),
              pw.Text('Line Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('SKU', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Discount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Tax', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font))),
                    ],
                  ),
                  ...po.lineItems.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.sku, style: pw.TextStyle(font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.quantity.toString(), style: pw.TextStyle(font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('₹${item.price}', style: pw.TextStyle(font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('₹${item.discount}', style: pw.TextStyle(font: font))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('₹${item.tax}', style: pw.TextStyle(font: font))),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text('Grand Total: ₹${po.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
    setState(() { _isLoading = false; _statusMessage = 'PDF exported successfully!'; });
  }

  Future<void> _printPo(String poId) async {
    setState(() { _isLoading = true; _statusMessage = null; });
    await _exportPdf(poId); // Printing is handled by the same PDF
    setState(() { _isLoading = false; _statusMessage = 'PO sent to printer!'; });
  }

  Future<void> _emailPo(String poId) async {
    setState(() { _isLoading = true; _statusMessage = null; });
    final po = (await PurchaseOrderService().fetchPurchaseOrders()).firstWhere((po) => po.id == poId);
    final subject = Uri.encodeComponent('Purchase Order #${po.id}');
    final body = Uri.encodeComponent('Please find attached the details for PO #${po.id}.\nSupplier: ${po.supplierId}\nTotal: ₹${po.totalAmount}\nStatus: ${po.status}');
    final url = 'mailto:?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
      setState(() { _statusMessage = 'Email sent!'; });
    }
    setState(() { _isLoading = false; });
  }

  Future<void> _whatsappPo(String poId) async {
    setState(() { _isLoading = true; _statusMessage = null; });
    final po = (await PurchaseOrderService().fetchPurchaseOrders()).firstWhere((po) => po.id == poId);
    final text = Uri.encodeComponent('Purchase Order #${po.id}\nSupplier: ${po.supplierId}\nTotal: ₹${po.totalAmount}\nStatus: ${po.status}');
    final url = 'https://wa.me/?text=$text';
    if (await canLaunch(url)) {
      await launch(url);
      setState(() { _statusMessage = 'WhatsApp message sent!'; });
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Purchase Order Communication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchPOs(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final pos = snapshot.data!;
              return DropdownButtonFormField<String>(
                value: _selectedPoId,
                items: pos.map<DropdownMenuItem<String>>((po) => DropdownMenuItem<String>(
                  value: po['id'] as String,
                  child: Text('PO# ${po['poNumber']} - ${po['status']}'),
                )).toList(),
                onChanged: (v) => setState(() => _selectedPoId = v),
                decoration: const InputDecoration(labelText: 'Select Purchase Order'),
              );
            },
          ),
          const SizedBox(height: 24),
          if (_selectedPoId != null)
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export as PDF'),
                  onPressed: _isLoading ? null : () => _exportPdf(_selectedPoId!),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  onPressed: _isLoading ? null : () => _printPo(_selectedPoId!),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Email'),
                  onPressed: _isLoading ? null : () => _emailPo(_selectedPoId!),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                  onPressed: _isLoading ? null : () => _whatsappPo(_selectedPoId!),
                ),
              ],
            ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            Text(_statusMessage!, style: const TextStyle(color: Colors.green)),
          ],
        ],
      ),
    );
  }
}
