import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/supplier.dart';

class SupplierAnalyticsEditor extends StatefulWidget {
  final Supplier supplier;
  const SupplierAnalyticsEditor({Key? key, required this.supplier}) : super(key: key);

  @override
  State<SupplierAnalyticsEditor> createState() => _SupplierAnalyticsEditorState();
}

class _SupplierAnalyticsEditorState extends State<SupplierAnalyticsEditor> {
  late TextEditingController tagsController;
  late TextEditingController totalSpendController;
  late TextEditingController orderVolumeController;
  late TextEditingController averageLeadTimeController;

  @override
  void initState() {
    super.initState();
    tagsController = TextEditingController(
      text: (widget.supplier.tags != null) ? widget.supplier.tags!.join(', ') : '',
    );
    totalSpendController = TextEditingController(
      text: (widget.supplier.totalSpend != null) ? widget.supplier.totalSpend.toString() : '',
    );
    orderVolumeController = TextEditingController(
      text: (widget.supplier.orderVolume != null) ? widget.supplier.orderVolume.toString() : '',
    );
    averageLeadTimeController = TextEditingController(
      text: (widget.supplier.averageLeadTime != null) ? widget.supplier.averageLeadTime.toString() : '',
    );
  }

  @override
  void dispose() {
    tagsController.dispose();
    totalSpendController.dispose();
    orderVolumeController.dispose();
    averageLeadTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Analytics'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            TextField(
              controller: totalSpendController,
              decoration: const InputDecoration(labelText: 'Total Spend'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: orderVolumeController,
              decoration: const InputDecoration(labelText: 'Order Volume'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: averageLeadTimeController,
              decoration: const InputDecoration(labelText: 'Average Lead Time'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final tags = tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            final totalSpend = double.tryParse(totalSpendController.text) ?? 0.0;
            final orderVolume = int.tryParse(orderVolumeController.text) ?? 0;
            final averageLeadTime = double.tryParse(averageLeadTimeController.text) ?? 0.0;
            await FirebaseFirestore.instance.collection('suppliers').doc(widget.supplier.supplierId).update({
              'tags': tags,
              'totalSpend': totalSpend,
              'orderVolume': orderVolume,
              'averageLeadTime': averageLeadTime,
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
