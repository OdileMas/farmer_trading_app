import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems = [
    {"name": "Tomatoes", "quantity": 2, "price": 1000},
    {"name": "Avocadoes", "quantity": 1, "price": 1500},
  ];

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']).toDouble(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Here are the items you want to order. Review before checkout!",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Text(
                        "Your cart is empty. Go to Home and add products!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.shopping_cart, color: Colors.green),
                            title: Text(item['name']),
                            subtitle: Text("Quantity: ${item['quantity']}"),
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
                const Text("Total:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("RWF $total", style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (cartItems.isEmpty) return;
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Confirm Checkout"),
                    content: const Text("Do you want to proceed with the order?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Order placed successfully!")),
                          );
                          // Add order processing logic here
                        },
                        child: const Text("Yes, Confirm"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Checkout"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
