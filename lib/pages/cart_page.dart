import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems = [
    {"name": "Tomatoes", "quantity": 2, "price": 1000},
    {"name": "Avocadoes", "quantity": 1, "price": 1500},
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure the total is calculated as a double, not an int, since price * quantity can be a decimal
    double total = cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']).toDouble());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("My Cart", style: Theme.of(context).textTheme.headlineLarge),  // Updated here
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text("Qty: ${item['quantity']}"),
                      trailing: Text("RWF ${item['price'] * item['quantity']}"),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("RWF $total", style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Checkout"),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
