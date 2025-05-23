import 'package:flutter/material.dart';
import '../../database_helper.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final harvestController = TextEditingController();
  final priceController = TextEditingController();

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.instance.insertFarmer({
        'name': nameController.text,
        'contact': contactController.text,
        'harvest': harvestController.text,
        'price': double.parse(priceController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: "Farmer Name"), validator: (value) => value!.isEmpty ? 'Enter name' : null),
              TextFormField(controller: contactController, decoration: InputDecoration(labelText: "Contact"), validator: (value) => value!.isEmpty ? 'Enter contact' : null),
              TextFormField(controller: harvestController, decoration: InputDecoration(labelText: "Harvest Item"), validator: (value) => value!.isEmpty ? 'Enter harvest' : null),
              TextFormField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Enter price' : null),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProduct, child: Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
