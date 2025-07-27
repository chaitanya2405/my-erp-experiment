import 'package:flutter/material.dart';
import '../widgets/po_list_table.dart';

class PurchaseOrderListScreen extends StatelessWidget {
  const PurchaseOrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      body: const PoListTable(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/po/create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Purchase Order',
      ),
    );
  }
}
