import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/unified_models.dart';

class CustomerOrderDetailScreen extends StatelessWidget {
  final CustomerOrder order;
  final UnifiedPOSTransaction? invoice;
  const CustomerOrderDetailScreen({Key? key, required this.order, this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order: ${order.orderId}'),
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
                    Text('Order Status: ${order.status}', style: Theme.of(context).textTheme.titleMedium),
                    Text('Payment Status: ${order.paymentStatus}'),
                    Text('Delivery Status: ${order.deliveryStatus}'),
                    Text('Customer: ${order.customerName}'),
                    Text('Order Date: ${order.orderDate}'),
                    Text('Total Amount: ₹${order.totalAmount.toStringAsFixed(2)}'),
                    Text('Discount: ₹${order.discount.toStringAsFixed(2)}'),
                    Text('Tax: ₹${order.taxAmount.toStringAsFixed(2)}'),
                    Text('Subtotal: ₹${order.subtotal.toStringAsFixed(2)}'),
                    if (order.metadata['subscriptionFlag'] == true)
                      Text('Subscription Plan: ${order.metadata['subscriptionPlan'] ?? "-"}'),
                    if ((order.metadata['walletUsed'] ?? 0) > 0)
                      Text('Wallet Used: ₹${(order.metadata['walletUsed'] ?? 0).toStringAsFixed(2)}'),
                    if (order.metadata['deliverySlot'] != null)
                      Text('Delivery Slot: ${order.metadata['deliverySlot']}'),
                    if (order.metadata['deliveryPersonId'] != null)
                      Text('Delivery Person: ${order.metadata['deliveryPersonId']}'),
                    if (order.metadata['invoiceId'] != null)
                      Text('Invoice: ${order.metadata['invoiceId']}'),
                    if (order.metadata['remarks'] != null)
                      Text('Remarks: ${order.metadata['remarks']}'),
                    Text('Created: ${order.createdAt}'),
                    Text('Updated: ${order.updatedAt}'),
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
                    Text('Products Ordered', style: Theme.of(context).textTheme.titleMedium),
                    ...order.items.map((p) => Text('${p.productName} x${p.quantity} - ₹${p.totalPrice}')).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
