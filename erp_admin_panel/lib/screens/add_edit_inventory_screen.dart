import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_models.dart';
import '../providers/inventory_providers.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddEditInventoryScreen({Key? key, this.item}) : super(key: key);

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final item = widget.item!;
    _nameController.text = item.itemName;
    _skuController.text = item.sku ?? '';
    _categoryController.text = item.category ?? '';
    _currentStockController.text = item.currentStock.toString();
    _minStockController.text = item.minStockLevel.toString();
    _costPriceController.text = item.costPrice.toString();
    _salePriceController.text = item.salePrice.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Inventory Item' : 'Edit Inventory Item'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _currentStockController,
                      decoration: const InputDecoration(
                        labelText: 'Current Stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: const InputDecoration(
                        labelText: 'Min Stock Level',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.item == null ? 'Add Item' : 'Update Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      
      final item = InventoryItem(
        itemId: widget.item?.itemId ?? 'item_${DateTime.now().millisecondsSinceEpoch}',
        itemName: _nameController.text,
        sku: _skuController.text.isEmpty ? null : _skuController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        currentStock: int.parse(_currentStockController.text),
        minStockLevel: int.parse(_minStockController.text),
        costPrice: double.parse(_costPriceController.text),
        salePrice: double.parse(_salePriceController.text),
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        productId: widget.item?.productId ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
        storeId: widget.item?.storeId ?? 'default_store',
        availableStock: int.parse(_currentStockController.text),
        maxStockLevel: int.parse(_minStockController.text) * 10, // Default 10x min stock
        reservedStock: widget.item?.reservedStock ?? 0,
        status: widget.item?.status ?? 'active',
        lastUpdated: DateTime.now(),
      );

      if (widget.item == null) {
        await inventoryProvider.addItem(item);
      } else {
        await inventoryProvider.updateItem(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item == null ? 'Item added successfully' : 'Item updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _costPriceController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }
}
