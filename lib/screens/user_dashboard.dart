import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'order_page.dart';

class UserDashboard extends StatelessWidget {
  final List<Product> products = ProductService.getProducts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Owner: ${product.ownerName}"),
                  Text("Contact: ${product.ownerContact}"),
                  Text("Cost: ${product.cost} RWF/unit"),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => OrderPage(product: product),
                  ));
                },
                child: Text("Order"),
              ),
            ),
          );
        },
      ),
    );
  }
}
