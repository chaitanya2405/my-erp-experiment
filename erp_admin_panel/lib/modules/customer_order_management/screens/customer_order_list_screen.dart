import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/unified_models.dart';
import '../../../services/enhanced_services.dart';
import 'customer_order_detail_screen.dart';

class CustomerOrderListScreen extends StatefulWidget {
  const CustomerOrderListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerOrderListScreen> createState() => _CustomerOrderListScreenState();
}

class _CustomerOrderListScreenState extends State<CustomerOrderListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 250,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by order number, customer, status...',
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: EnhancedCustomerOrderService.getCustomerOrdersWithInvoices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No customer orders found.'),
                        SizedBox(height: 8),
                        Text('Orders created from POS will appear here.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                final allOrdersWithInvoices = snapshot.data!;
                final filteredOrders = _search.isEmpty
                    ? allOrdersWithInvoices
                    : allOrdersWithInvoices.where((orderData) {
                        final order = orderData['order'] as CustomerOrder;
                        return order.orderId.toLowerCase().contains(_search) ||
                               order.customerId.toLowerCase().contains(_search) ||
                               order.status.toLowerCase().contains(_search);
                      }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: CustomerOrderDataTable(ordersWithInvoices: filteredOrders),
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

class CustomerOrderDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> ordersWithInvoices;
  const CustomerOrderDataTable({required this.ordersWithInvoices, Key? key}) : super(key: key);

  @override
  State<CustomerOrderDataTable> createState() => _CustomerOrderDataTableState();
}

class _CustomerOrderDataTableState extends State<CustomerOrderDataTable> {
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
          width: 2400, // Adjust width as needed for all columns
          child: PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('Order #')),
              DataColumn(label: Text('Customer ID')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Payment')),
              DataColumn(label: Text('Grand Total')),
              DataColumn(label: Text('Invoice')),
              DataColumn(label: Text('Actions')),
            ],
            source: _CustomerOrderTableSource(widget.ordersWithInvoices, context),
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

class _CustomerOrderTableSource extends DataTableSource {
  final List<Map<String, dynamic>> ordersWithInvoices;
  final BuildContext context;

  _CustomerOrderTableSource(this.ordersWithInvoices, this.context);

  @override
  DataRow getRow(int index) {
    if (index >= ordersWithInvoices.length) return const DataRow(cells: []);
    
    final orderData = ordersWithInvoices[index];
    final order = orderData['order'] as CustomerOrder;
    final invoice = orderData['invoice'] as PosTransaction?;
    
    return DataRow(
      cells: [
        DataCell(Text(order.orderId)),
        DataCell(Text(order.customerId)),
        DataCell(Text(order.orderDate.toString().split(' ').first)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPaymentStatusColor(order.paymentStatus),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.paymentStatus,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        DataCell(Text('₹${order.totalAmount.toStringAsFixed(2)}')),
        DataCell(
          invoice != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Invoice Available',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              : const Text('No Invoice', style: TextStyle(color: Colors.grey)),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerOrderDetailScreen(order: order, invoice: invoice),
                    ),
                  );
                },
                tooltip: 'View Details',
              ),
              if (invoice != null)
                IconButton(
                  icon: const Icon(Icons.receipt),
                  onPressed: () {
                    _showInvoiceDialog(context, invoice);
                  },
                  tooltip: 'View Invoice',
                ),
            ],
          ),
        ),
      ],
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
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showInvoiceDialog(BuildContext context, PosTransaction invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice - ${invoice.transactionId}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction Date: ${invoice.transactionTime}'),
              Text('Payment Method: ${invoice.paymentMode}'),
              Text('Cashier: ${invoice.cashierId}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...invoice.items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('${item.productName} x ${item.quantity} = ₹${item.totalPrice}'),
              )),
              const Divider(),
              Text('Subtotal: ₹${invoice.subTotal}'),
              Text('Tax: ₹${invoice.taxAmount}'),
              Text('Discount: ₹${invoice.discountApplied}'),
              Text('Total: ₹${invoice.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  int get rowCount => ordersWithInvoices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
