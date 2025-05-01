import 'package:flutter/material.dart';
import 'database_helper.dart';

class FarmerScreen extends StatefulWidget {
  @override
  _FarmerScreenState createState() => _FarmerScreenState();
}

class _FarmerScreenState extends State<FarmerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _harvestController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Insert farmer data into the database
 // In your FarmerScreen widget, insert farmer data:
void _insertFarmer() async {
  // Ensure the input fields are not empty
  if (_nameController.text.isNotEmpty && 
      _harvestController.text.isNotEmpty && 
      _priceController.text.isNotEmpty) {
    Map<String, dynamic> farmer = {
      'name': _nameController.text,
      'harvest': _harvestController.text,
      'price': double.parse(_priceController.text),
    };
    await DatabaseHelper.instance.insertFarmer(farmer);
    _nameController.clear();
    _harvestController.clear();
    _priceController.clear();
    setState(() {});  // Ensure the UI updates after adding data
  } else {
    print('Please fill in all fields');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Farmer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Farmer Name'),
            ),
            TextField(
              controller: _harvestController,
              decoration: InputDecoration(labelText: 'Harvest'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            ElevatedButton(
              onPressed: _insertFarmer,
              child: Text('Add Farmer'),
            ),
          ],
        ),
      ),
    );
  }
}
