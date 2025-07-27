import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pos_transaction.dart';
import '../services/gst_calculator.dart';

class PosTransactionScreen extends StatefulWidget {
  final PosTransaction transaction;

  const PosTransactionScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  State<PosTransactionScreen> createState() => _PosTransactionScreenState();
}

class _PosTransactionScreenState extends State<PosTransactionScreen> {
  bool _isRefunding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${widget.transaction.invoiceNumber}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
            tooltip: 'Share Invoice',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printInvoice,
            tooltip: 'Print Invoice',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicate Transaction'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refund',
                child: Row(
                  children: [
                    Icon(Icons.undo, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Process Refund'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 8),
                    Text('Email Invoice'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: 24),
            _buildCustomerInfo(),
            const SizedBox(height: 24),
            _buildProductItems(),
            const SizedBox(height: 24),
            _buildCalculationSummary(),
            const SizedBox(height: 24),
            _buildPaymentInfo(),
            const SizedBox(height: 24),
            _buildGstDetails(),
            if (widget.transaction.remarks?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              _buildRemarks(),
            ],
            const SizedBox(height: 24),
            _buildTransactionMeta(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INVOICE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.transaction.invoiceNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.transaction.transactionStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.transaction.transactionStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDate(widget.transaction.transactionTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(widget.transaction.transactionTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', 
                          widget.transaction.customerName.isEmpty 
                              ? 'Walk-in Customer' 
                              : widget.transaction.customerName),
                      if (widget.transaction.customerPhone.isNotEmpty)
                        _buildInfoRow('Phone', widget.transaction.customerPhone),
                      if (widget.transaction.customerEmail.isNotEmpty)
                        _buildInfoRow('Email', widget.transaction.customerEmail),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTierColor(widget.transaction.customerTier),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.transaction.customerTier,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                ...widget.transaction.productItems.map((item) => _buildItemRow({
                  'product_name': item.productName,
                  'product_code': item.sku,
                  'quantity': item.quantity,
                  'unit_price': item.sellingPrice,
                  'total_price': item.totalAmount,
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildItemRow(Map<String, dynamic> item) {
    final productName = item['product_name'] ?? 'Unknown Product';
    final productCode = item['product_code'] ?? '';
    final quantity = item['quantity'] ?? 0;
    final unitPrice = (item['unit_price'] ?? 0.0) as double;
    final totalPrice = (item['total_price'] ?? 0.0) as double;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (productCode.isNotEmpty)
                Text(
                  'Code: $productCode',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            quantity.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '₹${unitPrice.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '₹${totalPrice.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', widget.transaction.subtotalAmount),
            if (widget.transaction.discountApplied > 0)
              _buildSummaryRow(
                'Discount',
                -widget.transaction.discountApplied,
                color: Colors.orange,
              ),
            _buildSummaryRow('Tax (GST)', widget.transaction.taxAmount),
            const Divider(thickness: 1),
            _buildSummaryRow(
              'Total Amount',
              widget.transaction.totalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: color ?? (isTotal ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow('Payment Mode', widget.transaction.paymentMode),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPaymentModeColor(widget.transaction.paymentMode),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.transaction.paymentMode.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Sales Channel', widget.transaction.channel),
            _buildInfoRow('Cashier ID', widget.transaction.cashierId),
            if (widget.transaction.refundStatus != 'None')
              _buildInfoRow('Refund Status', widget.transaction.refundStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildGstDetails() {
    if (widget.transaction.taxBreakup == null) return const SizedBox();

    final gstDetails = widget.transaction.taxBreakup as Map<String, dynamic>;
    final isInterState = gstDetails['is_inter_state'] ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GST Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Supply Type', isInterState ? 'Inter-State' : 'Intra-State'),
            _buildInfoRow('Total Taxable Value', 
                '₹${(gstDetails['total_base_amount'] ?? 0.0).toStringAsFixed(2)}'),
            
            if (isInterState) ...[
              _buildInfoRow('IGST', 
                  '₹${(gstDetails['total_igst_amount'] ?? 0.0).toStringAsFixed(2)}'),
            ] else ...[
              _buildInfoRow('CGST', 
                  '₹${(gstDetails['total_cgst_amount'] ?? 0.0).toStringAsFixed(2)}'),
              _buildInfoRow('SGST', 
                  '₹${(gstDetails['total_sgst_amount'] ?? 0.0).toStringAsFixed(2)}'),
            ],
            
            _buildInfoRow('Total Tax', 
                '₹${(gstDetails['total_gst_amount'] ?? 0.0).toStringAsFixed(2)}'),

            // GST rate-wise breakup
            if (gstDetails['gst_breakup'] != null && 
                gstDetails['gst_breakup'] is Map &&
                (gstDetails['gst_breakup'] as Map).isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Tax Rate Breakup:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...((gstDetails['gst_breakup'] as Map<String, dynamic>).entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${entry.key} GST'),
                      Text('₹${(entry.value as num).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemarks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remarks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.transaction.remarks ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionMeta() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Transaction ID', widget.transaction.transactionId),
            _buildInfoRow('Store ID', widget.transaction.storeId),
            _buildInfoRow('Created', _formatDateTime(widget.transaction.createdAt)),
            _buildInfoRow('Updated', _formatDateTime(widget.transaction.updatedAt)),
            _buildInfoRow('Sync Status', 
                widget.transaction.syncedToServer ? 'Synced' : 'Pending Sync'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'vip':
        return Colors.purple;
      case 'premium':
        return Colors.amber;
      case 'gold':
        return Colors.orange;
      case 'silver':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getPaymentModeColor(String paymentMode) {
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'upi':
        return Colors.purple;
      case 'wallet':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        _duplicateTransaction();
        break;
      case 'refund':
        _showRefundDialog();
        break;
      case 'email':
        _emailInvoice();
        break;
    }
  }

  void _shareInvoice() {
    // TODO: Implement invoice sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _printInvoice() {
    // TODO: Implement invoice printing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }

  void _duplicateTransaction() {
    // TODO: Navigate to add transaction screen with copied data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplicate functionality coming soon')),
    );
  }

  void _showRefundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invoice: ${widget.transaction.invoiceNumber}'),
            Text('Amount: ₹${widget.transaction.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Refund Amount',
                prefixText: '₹',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason for Refund',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isRefunding ? null : () {
              Navigator.pop(context);
              _processRefund();
            },
            child: _isRefunding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  void _processRefund() {
    // TODO: Implement refund processing
    setState(() {
      _isRefunding = true;
    });

    // Simulate refund processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRefunding = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refund processed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _emailInvoice() {
    // TODO: Implement email invoice
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email functionality coming soon')),
    );
  }
}
