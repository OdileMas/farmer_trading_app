import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> allProducts = [
    {
      'name': 'Tomatoes',
      'image': 'assets/images/tomato.jpg',
      'price': 1500,
      'amount': '10 Kg',
      'description': 'Fresh organic tomatoes grown locally.',
    },
    {
      'name': 'Avocados',
      'image': 'assets/images/avocado.jpg',
      'price': 1200,
      'amount': '8 Kg',
      'description': 'Ripe and creamy avocados ready for sale.',
    },
    {
      'name': 'Potatoes',
      'image': 'assets/images/potato.jpg',
      'price': 1000,
      'amount': '20 Kg',
      'description': 'High-quality potatoes from mountain farms.',
    },
    {
      'name': 'Carrots',
      'image': 'assets/images/carrots.jpg',
      'price': 1300,
      'amount': '12 Kg',
      'description': 'Crunchy and sweet carrots harvested recently.',
    },
  ];

  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = allProducts;
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = allProducts.where((product) {
        final name = product['name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  void _showOrderDialog(String productName, String productPrice) {
  final TextEditingController amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Order $productName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Price per unit: RWF $productPrice"),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = amountController.text;
              if (quantity.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ordered $quantity of $productName')),
                );
              }
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Products"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for harvests...",
                prefixIcon: const Icon(IconlyLight.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Explore available harvests:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(child: Text("No products found."))
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.green.shade50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                child: Image.asset(
                                  product['image'],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Price: ${product['price']} RWF"),
                                      Text("Amount: ${product['amount']}"),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['description'],
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          onPressed: () =>_showOrderDialog(product['name'], product['price']),
                                          child: const Text("Order"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
