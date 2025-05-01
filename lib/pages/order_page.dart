import 'package:flutter/material.dart';
import '../../models/product.dart';

class OrderPage extends StatefulWidget {
  final Product product;

  OrderPage({required this.product});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _amountController = TextEditingController();

  void _submitOrder() {
    String amount = _amountController.text;
    if (amount.isEmpty || int.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Order Placed"),
        content: Text("You ordered $amount units of ${widget.product.name}."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order ${widget.product.name}")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Owner: ${widget.product.ownerName}"),
            Text("Contact: ${widget.product.ownerContact}"),
            Text("Cost: ${widget.product.cost} RWF/unit"),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitOrder,
              child: Text("Confirm Order"),
            )
          ],
        ),
      ),
    );
  }
}
