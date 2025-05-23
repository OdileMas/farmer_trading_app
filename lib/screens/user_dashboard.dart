import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../database_helper.dart';
import 'order_page.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
        List<Product> staticProducts = ProductService.getProducts();

    
    final dbProductsRaw = await DatabaseHelper.instance.getAllProducts();

    List<Product> dbProducts = dbProductsRaw.map((item) {
      return Product(
        id: item['id'],
        name: item['name'],
        ownerId: item['owner_id'],
        cost: item['cost'] is int
            ? (item['cost'] as int).toDouble()
            : item['cost'] is double
                ? item['cost'] as double
                : 0.0,
      );
    }).toList();

    // Debug print
    print("DB Products:");
    for (var p in dbProducts) {
      print("Product: ${p.name}, Cost: ${p.cost}, Owner ID: ${p.ownerId}");
    }

    // Merge static and db products
    setState(() {
      _products = [...staticProducts, ...dbProducts];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Products")),
      body: _products.isEmpty
          ? Center(child: Text("No products available"))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Farmer ID: ${product.ownerId}"),
                        Text("Cost: ${product.cost} RWF/unit"),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderPage(product: product),
                          ),
                        );
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
