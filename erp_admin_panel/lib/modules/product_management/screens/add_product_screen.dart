import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  final VoidCallback? onProductAdded;
  const AddProductScreen({Key? key, this.onProductAdded}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    // TODO: Add Firestore integration here
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    setState(() => _isSubmitting = false);
    if (widget.onProductAdded != null) widget.onProductAdded!();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added!')),
    );
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Product', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
            validator: (v) => v == null || v.isEmpty ? 'Enter product name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _skuController,
            decoration: const InputDecoration(labelText: 'SKU'),
            validator: (v) => v == null || v.isEmpty ? 'Enter SKU' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter price';
              final n = num.tryParse(v);
              if (n == null || n < 0) return 'Enter valid price';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Product'),
            ),
          ),
        ],
      ),
    );
  }
}
