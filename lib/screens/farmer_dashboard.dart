// [Keep your existing imports]
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../database_helper.dart';

class FarmerDashboard extends StatefulWidget {
  final int farmerId;
  final String farmerName;

  const FarmerDashboard({super.key, required this.farmerName, required this.farmerId});

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  List<Map<String, dynamic>> products = [];
  List<String> recommendations = [];
  bool showForm = false;
  bool showSettings = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _harvestController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String farmerContact = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _nameController.text = '';
    _passwordController.text = '';
  }

  Future<void> _loadProducts() async {
    final data = await DatabaseHelper.instance.getFarmers();
    setState(() {
      products = data;
    });
  }

  Future<void> _addProduct() async {
    if (_harvestController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _nameController.text.isEmpty) return;

    await DatabaseHelper.instance.insertFarmer({
      'name': _nameController.text,
      'contact': _contactController.text,
      'harvest': _harvestController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
    });
    _clearFields();
    _loadProducts();
    setState(() {
      showForm = false;
    });
  }

  void _clearFields() {
    _nameController.clear();
    _contactController.clear();
    _harvestController.clear();
    _priceController.clear();
  }

  Future<void> _deleteProduct(int id) async {
    await DatabaseHelper.instance.deleteFarmer(id);
    _loadProducts();
  }

  void _editProductDialog(Map<String, dynamic> product) {
    _nameController.text = product['name'] ?? '';
    _contactController.text = product['contact'] ?? '';
    _harvestController.text = product['harvest'] ?? '';
    _priceController.text = product['price']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, 'Farmer Name'),
            _buildTextField(_contactController, 'Contact'),
            _buildTextField(_harvestController, 'Harvest Product'),
            _buildTextField(_priceController, 'Price', isNumber: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearFields();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              await DatabaseHelper.instance.updateFarmer(product['id'], {
                'name': _nameController.text,
                'contact': _contactController.text,
                'harvest': _harvestController.text,
                'price': double.tryParse(_priceController.text) ?? 0.0,
              });
              Navigator.of(context).pop();
              _clearFields();
              _loadProducts();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget buildProductList() {
    if (products.isEmpty) {
      return Text('No products found.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          color: Colors.green.shade50,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(
              product['harvest'] ?? 'Unknown Harvest',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Price: \$${(product['price'] ?? 0).toStringAsFixed(2)}\nFarmer: ${product['name'] ?? 'Unknown'}\nContact: ${product['contact'] ?? 'N/A'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editProductDialog(product),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(product['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProductForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_nameController, 'Farmer Name'),
          _buildTextField(_contactController, 'Contact'),
          _buildTextField(_harvestController, 'Harvest Product'),
          _buildTextField(_priceController, 'Price', isNumber: true),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _addProduct,
            child: Text('Save Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget buildSettingsPanel() {
    return Card(
      margin: EdgeInsets.only(top: 20),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Name: ${widget.farmerName}'),
            Text('Contact: $farmerContact'),
            SizedBox(height: 10),
           ElevatedButton(
  onPressed: _viewOrderHistory,
  child: Text('View Order History'),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
),
            ElevatedButton(
              onPressed: () {},
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void toggleSettings() {
    setState(() {
      showSettings = !showSettings;
    });
  }

  
Future<Position> getFarmerLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final apiKey = 'd8f8b9773c72f4930368a5cb9a85843f';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temperature = data['main']['temp']?.toDouble() ?? 0.0;
        double rainfall = 0.0;
        if (data.containsKey('rain')) {
          if (data['rain'].containsKey('1h')) {
            rainfall = data['rain']['1h']?.toDouble() ?? 0.0;
          } else if (data['rain'].containsKey('3h')) {
            rainfall = data['rain']['3h']?.toDouble() ?? 0.0;
          }
        }
        return {
          'temperature': temperature,
          'rainfall': rainfall,
        };
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return {'temperature': 25, 'rainfall': 0};
    }
  }

  Future<Map<String, dynamic>> getSoil(double lat, double lon) async {
    await Future.delayed(Duration(seconds: 1));
    return {'soilType': 'Loamy', 'ph': 6.5};
  }

  String recommendCrop({
    required double soilPh,
    required String soilType,
    required double rainfall,
    required double temperature,
    required String season,
  }) {
    if (soilType == 'Loamy' && soilPh >= 6 && rainfall > 50 && temperature >= 20) {
      return 'Maize';
    } else if (soilPh < 6 && rainfall > 70) {
      return 'Beans';
    }
    return 'Cassava';
  }

  void getAIRecommendation() async {
    try {
      final pos = await getFarmerLocation();
      final weather = await getWeather(pos.latitude, pos.longitude);
      final soil = await getSoil(pos.latitude, pos.longitude);

      final crop = recommendCrop(
        soilPh: soil['ph'],
        soilType: soil['soilType'],
        rainfall: weather['rainfall'],
        temperature: weather['temperature'],
        season: 'Summer',
      );

      final explanation =
          'Based on ${soil['soilType']} soil with pH ${soil['ph']} and temperature ${weather['temperature']}°C and rainfall ${weather['rainfall']}mm';

      setState(() {
        recommendations.add('$crop — $explanation');
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('AI Recommendation'),
          content: Text('$crop\n\n$explanation'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            )
          ],
        ),
      );
    } catch (e) {
      print('Error getting AI recommendation: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('AI Recommendation'),
          content: Text('Unable to fetch location or weather data. Try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            )
          ],
        ),
      );
    }
  }
  Future<void> _viewOrderHistory() async {
  final orders = await DatabaseHelper.instance.getOrdersByFarmer(widget.farmerId);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Order History'),
      content: orders.isEmpty
          ? Text('No orders yet.')
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text('${order['productName']} (x${order['amount']})'),
                    subtitle: Text('User: ${order['userName']}\nDate: ${order['createdAt']}'),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        )
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: toggleSettings),
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: getAIRecommendation,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Welcome ${widget.farmerName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (showForm) buildProductForm(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() => showForm = !showForm);
              },
              child: Text(showForm ? 'Cancel' : 'Add New Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: showForm ? Colors.red : Colors.green,
              ),
            ),
            buildProductList(),
            if (showSettings) buildSettingsPanel(),
            SizedBox(height: 20),
            if (recommendations.isNotEmpty) ...[
              Text("Recommendations:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...recommendations.map((rec) => Text("🌾 $rec")).toList()
            ]
          ],
        ),
      ),
    );
  }
}
