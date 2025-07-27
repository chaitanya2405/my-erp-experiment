import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/original_models.dart';

class CustomerOrderDetailScreen extends StatelessWidget {
  final CustomerOrder order;
  final PosTransaction? invoice;
  const CustomerOrderDetailScreen({Key? key, required this.order, this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order: ${order.orderNumber}'),
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
                    Text('Order Status: ${order.orderStatus}', style: Theme.of(context).textTheme.titleMedium),
                    Text('Payment Status: ${order.paymentStatus}'),
                    Text('Payment Mode: ${order.paymentMode}'),
                    Text('Delivery Mode: ${order.deliveryMode}'),
                    if (order.deliveryAddress != null)
                      Text('Delivery Address: ${order.deliveryAddress}'),
                    Text('Order Date: ${order.orderDate.toDate()}'),
                    Text('Total Amount: ₹${order.totalAmount.toStringAsFixed(2)}'),
                    Text('Discount: ₹${order.discount.toStringAsFixed(2)}'),
                    Text('Tax: ₹${order.taxAmount.toStringAsFixed(2)}'),
                    Text('Delivery Charges: ₹${order.deliveryCharges.toStringAsFixed(2)}'),
                    Text('Grand Total: ₹${order.grandTotal.toStringAsFixed(2)}'),
                    if (order.subscriptionFlag)
                      Text('Subscription Plan: ${order.subscriptionPlan ?? "-"}'),
                    if (order.walletUsed > 0)
                      Text('Wallet Used: ₹${order.walletUsed.toStringAsFixed(2)}'),
                    if (order.deliverySlot != null)
                      Text('Delivery Slot: ${order.deliverySlot}'),
                    if (order.deliveryPersonId != null)
                      Text('Delivery Person: ${order.deliveryPersonId}'),
                    if (order.invoiceId != null)
                      Text('Invoice: ${order.invoiceId}'),
                    if (order.remarks != null)
                      Text('Remarks: ${order.remarks}'),
                    Text('Created: ${order.createdAt.toDate()}'),
                    Text('Updated: ${order.updatedAt.toDate()}'),
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
                    ...order.productsOrdered.map((p) => Text('${p['name']} x${p['qty']} - ₹${p['price']}')).toList(),
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
