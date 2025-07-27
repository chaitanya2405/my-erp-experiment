import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/unified_models.dart';

class CustomerOrderFormScreen extends StatefulWidget {
  final UnifiedCustomerOrder? order;
  const CustomerOrderFormScreen({Key? key, this.order}) : super(key: key);

  @override
  State<CustomerOrderFormScreen> createState() => _CustomerOrderFormScreenState();
}

class _CustomerOrderFormScreenState extends State<CustomerOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController orderNumberController;
  late TextEditingController customerIdController;
  late TextEditingController storeIdController;
  late TextEditingController totalAmountController;
  late TextEditingController discountController;
  late TextEditingController taxAmountController;
  late TextEditingController deliveryChargesController;
  late TextEditingController grandTotalController;
  late TextEditingController remarksController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController postalCodeController;
  late TextEditingController countryController;
  late TextEditingController deliverySlotController;
  late TextEditingController deliveryPersonController;
  late TextEditingController invoiceIdController;
  late TextEditingController walletUsedController;
  late TextEditingController subscriptionPlanController;

  String orderStatus = 'New';
  String paymentStatus = 'Unpaid';
  String paymentMode = 'UPI';
  String deliveryMode = 'Home Delivery';
  bool subscriptionFlag = false;

  List<Map<String, dynamic>> selectedProducts = [];
  List<Map<String, dynamic>> inventoryProducts = [];

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    orderNumberController = TextEditingController(text: o?.orderNumber ?? '');
    customerIdController = TextEditingController(text: o?.customerId ?? '');
    storeIdController = TextEditingController(text: o?.storeId ?? '');
    totalAmountController = TextEditingController(text: o?.totalAmount.toString() ?? '');
    discountController = TextEditingController(text: o?.discount.toString() ?? '');
    taxAmountController = TextEditingController(text: o?.taxAmount.toString() ?? '');
    deliveryChargesController = TextEditingController(text: o?.deliveryCharges.toString() ?? '');
    grandTotalController = TextEditingController(text: o?.grandTotal.toString() ?? '');
    remarksController = TextEditingController(text: o?.remarks ?? '');
    orderStatus = o?.orderStatus ?? 'New';
    paymentStatus = o?.paymentStatus ?? 'Unpaid';
    paymentMode = o?.paymentMode ?? 'UPI';
    deliveryMode = o?.deliveryMode ?? 'Home Delivery';
    subscriptionFlag = o?.subscriptionFlag ?? false;
    addressLine1Controller = TextEditingController(text: o?.deliveryAddress?['line1'] ?? '');
    addressLine2Controller = TextEditingController(text: o?.deliveryAddress?['line2'] ?? '');
    cityController = TextEditingController(text: o?.deliveryAddress?['city'] ?? '');
    stateController = TextEditingController(text: o?.deliveryAddress?['state'] ?? '');
    postalCodeController = TextEditingController(text: o?.deliveryAddress?['postal_code'] ?? '');
    countryController = TextEditingController(text: o?.deliveryAddress?['country'] ?? '');
    deliverySlotController = TextEditingController(text: o?.deliverySlot ?? '');
    deliveryPersonController = TextEditingController(text: o?.deliveryPersonId ?? '');
    invoiceIdController = TextEditingController(text: o?.invoiceId ?? '');
    walletUsedController = TextEditingController(text: o?.walletUsed.toString() ?? '0.0');
    subscriptionPlanController = TextEditingController(text: o?.subscriptionPlan ?? '');

    selectedProducts = o?.productsOrdered ?? [];

    // Fetch inventory products
    FirebaseFirestore.instance.collection('products').get().then((snapshot) {
      setState(() {
        inventoryProducts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    });
  }

  @override
  void dispose() {
    orderNumberController.dispose();
    customerIdController.dispose();
    storeIdController.dispose();
    totalAmountController.dispose();
    discountController.dispose();
    taxAmountController.dispose();
    deliveryChargesController.dispose();
    grandTotalController.dispose();
    remarksController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    deliverySlotController.dispose();
    deliveryPersonController.dispose();
    invoiceIdController.dispose();
    walletUsedController.dispose();
    subscriptionPlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (inventoryProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.order == null ? 'Create Order' : 'Edit Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: orderNumberController,
                decoration: const InputDecoration(labelText: 'Order Number'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: customerIdController,
                decoration: const InputDecoration(labelText: 'Customer ID'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: storeIdController,
                decoration: const InputDecoration(labelText: 'Store ID'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: orderStatus,
                decoration: const InputDecoration(labelText: 'Order Status'),
                items: ['New', 'Confirmed', 'Packed', 'Out for Delivery', 'Completed', 'Cancelled']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => orderStatus = v ?? 'New'),
              ),
              DropdownButtonFormField<String>(
                value: paymentStatus,
                decoration: const InputDecoration(labelText: 'Payment Status'),
                items: ['Paid', 'Unpaid', 'Partially Paid', 'Refunded']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => paymentStatus = v ?? 'Unpaid'),
              ),
              DropdownButtonFormField<String>(
                value: paymentMode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: ['UPI', 'Card', 'COD', 'Wallet']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => paymentMode = v ?? 'UPI'),
              ),
              DropdownButtonFormField<String>(
                value: deliveryMode,
                decoration: const InputDecoration(labelText: 'Delivery Mode'),
                items: ['Home Delivery', 'Pickup', 'Subscription Delivery']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => deliveryMode = v ?? 'Home Delivery'),
              ),
              SwitchListTile(
                value: subscriptionFlag,
                onChanged: (v) => setState(() => subscriptionFlag = v),
                title: const Text('Subscription Order'),
              ),
              TextFormField(
                controller: totalAmountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: discountController,
                decoration: const InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: taxAmountController,
                decoration: const InputDecoration(labelText: 'Tax Amount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: deliveryChargesController,
                decoration: const InputDecoration(labelText: 'Delivery Charges'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: grandTotalController,
                decoration: const InputDecoration(labelText: 'Grand Total'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: remarksController,
                decoration: const InputDecoration(labelText: 'Remarks'),
                maxLines: 2,
              ),
              const Divider(),
              const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: addressLine1Controller, decoration: const InputDecoration(labelText: 'Address Line 1')),
              TextFormField(controller: addressLine2Controller, decoration: const InputDecoration(labelText: 'Address Line 2')),
              TextFormField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextFormField(controller: stateController, decoration: const InputDecoration(labelText: 'State')),
              TextFormField(controller: postalCodeController, decoration: const InputDecoration(labelText: 'Postal Code')),
              TextFormField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
              const Divider(),
              const Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: selectedProducts.map((p) => ListTile(
                  title: Text(p['name'] ?? ''),
                  subtitle: Text('Qty: ${p['quantity']}  Price: ${p['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        selectedProducts.remove(p);
                      });
                    },
                  ),
                )).toList(),
              ),
              DropdownButtonFormField<Map<String, dynamic>>(
                hint: const Text('Add Product'),
                items: inventoryProducts.map((prod) => DropdownMenuItem(
                  value: prod,
                  child: Text(prod['product_name'] ?? ''), // <-- use 'product_name'
                )).toList(),
                onChanged: (prod) {
                  if (prod != null) {
                    setState(() {
                      selectedProducts.add({
                        'name': prod['product_name'], // <-- use 'product_name'
                        'sku': prod['sku'],
                        'quantity': 1,
                        'price': prod['selling_price'], // <-- use 'selling_price'
                      });
                    });
                  }
                },
              ),
              const Divider(),
              TextFormField(controller: deliverySlotController, decoration: const InputDecoration(labelText: 'Delivery Slot')),
              TextFormField(controller: deliveryPersonController, decoration: const InputDecoration(labelText: 'Delivery Person ID')),
              TextFormField(controller: invoiceIdController, decoration: const InputDecoration(labelText: 'Invoice ID')),
              TextFormField(controller: walletUsedController, decoration: const InputDecoration(labelText: 'Wallet Used'), keyboardType: TextInputType.number),
              TextFormField(controller: subscriptionPlanController, decoration: const InputDecoration(labelText: 'Subscription Plan')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final order = UnifiedCustomerOrder(
                      id: widget.order?.id ?? '',
                      orderId: widget.order?.orderId ?? UnifiedCustomerOrder.generateOrderId(),
                      customerId: customerIdController.text,
                      customerName: 'Customer Name', // You may want to add a field for this
                      storeId: storeIdController.text,
                      status: orderStatus,
                      items: selectedProducts.map((p) => UnifiedPOSTransactionItem(
                        productId: p['sku'] ?? '',
                        productName: p['name'] ?? '',
                        quantity: p['quantity'] ?? 1,
                        unitPrice: (p['price'] ?? 0.0).toDouble(),
                        totalPrice: ((p['quantity'] ?? 1) * (p['price'] ?? 0.0)).toDouble(),
                        discount: 0.0,
                        metadata: {
                          'category': '',
                          'tax_rate': 0.0,
                          'tax_amount': 0.0,
                          'discount_amount': 0.0,
                          'final_amount': ((p['quantity'] ?? 1) * (p['price'] ?? 0.0)).toDouble(),
                        },
                      )).toList(),
                      subtotal: double.tryParse(totalAmountController.text) ?? 0.0,
                      taxAmount: double.tryParse(taxAmountController.text) ?? 0.0,
                      discount: double.tryParse(discountController.text) ?? 0.0,
                      totalAmount: double.tryParse(grandTotalController.text) ?? 0.0,
                      paymentStatus: paymentStatus,
                      deliveryStatus: 'pending',
                      orderDate: DateTime.now(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      // Optional compatibility fields
                      orderNumber: orderNumberController.text,
                      deliveryCharges: double.tryParse(deliveryChargesController.text),
                      grandTotal: double.tryParse(grandTotalController.text),
                      remarks: remarksController.text,
                      orderStatus: orderStatus,
                      paymentMode: paymentMode,
                      deliveryMode: deliveryMode,
                      subscriptionFlag: subscriptionFlag,
                      deliveryAddress: {
                        'line1': addressLine1Controller.text,
                        'line2': addressLine2Controller.text,
                        'city': cityController.text,
                        'state': stateController.text,
                        'postal_code': postalCodeController.text,
                        'country': countryController.text,
                      },
                      deliverySlot: deliverySlotController.text,
                      deliveryPersonId: deliveryPersonController.text,
                      invoiceId: invoiceIdController.text,
                      walletUsed: double.tryParse(walletUsedController.text),
                      subscriptionPlan: subscriptionPlanController.text,
                      productsOrdered: selectedProducts,
                    );
                    await FirebaseFirestore.instance.collection('orders').doc(order.orderId).set(order.toFirestore());
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.order == null ? 'Create Order' : 'Update Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
