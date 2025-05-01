import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text("Our Services", style: Theme.of(context).textTheme.headlineLarge),  // Updated here
          const SizedBox(height: 20),
          _buildServiceTile(Icons.shopping_bag, "Buy Products", "Purchase farm products directly from farmers."),
          _buildServiceTile(Icons.support_agent, "Support", "24/7 customer support for users."),
          _buildServiceTile(Icons.delivery_dining, "Delivery", "Reliable and fast delivery to your location."),
        ],
      ),
    );
  }

  Widget _buildServiceTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
