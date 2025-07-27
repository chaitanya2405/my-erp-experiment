import 'package:flutter/material.dart';
import '../../../models/farmer.dart';

/// Placeholder for Add/Edit Farmer Screen
/// Currently disabled as farmer module is used in read-only supplier view mode
class AddEditFarmerScreen extends StatefulWidget {
  final Farmer? farmer;
  const AddEditFarmerScreen({Key? key, this.farmer}) : super(key: key);

  @override
  State<AddEditFarmerScreen> createState() => _AddEditFarmerScreenState();
}

class _AddEditFarmerScreenState extends State<AddEditFarmerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.farmer == null ? 'Add Farmer' : 'Edit Farmer'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 64,
              color: Colors.brown,
            ),
            SizedBox(height: 16),
            Text(
              'Farmer Add/Edit Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is currently disabled.\nFarmer module is used in read-only supplier view mode.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Use the farmer list to view supplier information.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
