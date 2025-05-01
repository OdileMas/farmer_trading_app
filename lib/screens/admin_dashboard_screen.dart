import 'package:flutter/material.dart';
import 'package:farmer_trading_app/database_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _farmers = [];

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    final data = await DatabaseHelper.instance.getFarmers();
    setState(() {
      _farmers = data;
    });
  }

  Future<void> _deleteFarmer(int id) async {
    await DatabaseHelper.instance.deleteFarmer(id);
    _loadFarmers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: ListView.builder(
        itemCount: _farmers.length,
        itemBuilder: (context, index) {
          final farmer = _farmers[index];
          return ListTile(
            title: Text(farmer['name']),
            subtitle: Text('Harvest: ${farmer['harvest']}, Price: \$${farmer['price']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteFarmer(farmer['id']),
            ),
          );
        },
      ),
    );
  }
}
