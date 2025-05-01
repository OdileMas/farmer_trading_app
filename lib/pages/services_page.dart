import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  void _showServiceDetails(BuildContext context, String title) {
    String content = "";
    if (title == "Buy Products") {
      content = "1. Browse products on the Home page.\n"
          "2. Use the search to find what you need.\n"
          "3. Click 'Order' on the product card.\n"
          "4. Enter the quantity and confirm.\n"
          "5. You will receive a confirmation and delivery timeline.";
    } else if (title == "Support") {
      content = "Need help?\n\n"
          "• Use the Help section in the app for FAQs.\n"
          "• Reach out to our support via call or email:\n"
          "  📞 +250 780 283 130\n"
          "  📧 support@farmerapp.com";
    } else if (title == "Delivery") {
      content = "Steps to Order & Get Delivered:\n\n"
          "1. Select the product and click 'Order'.\n"
          "2. Confirm the quantity and your delivery location.\n"
          "3. You will receive a delivery estimate.\n"
          "4. Our team will contact you for coordination.\n"
          "5. Get your goods delivered safely to your door.\n\n"
          "Having issues?\n📞 Call support: +250 780 283 130";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text("Our Services", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 20),
          _buildServiceTile(context, Icons.shopping_bag, "Buy Products", "Purchase farm products directly from farmers."),
          _buildServiceTile(context, Icons.support_agent, "Support", "24/7 customer support for users."),
          _buildServiceTile(context, Icons.delivery_dining, "Delivery", "Reliable and fast delivery to your location."),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, IconData icon, String title, String subtitle) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () => _showServiceDetails(context, title),
      ),
    );
  }
}
