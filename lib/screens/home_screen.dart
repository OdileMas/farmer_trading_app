import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:badges/badges.dart' as badges;
import 'package:farmer_trading_app/pages/home_page.dart';
import 'package:farmer_trading_app/pages/services_page.dart';
import 'package:farmer_trading_app/pages/cart_page.dart';
import 'package:farmer_trading_app/pages/profile_page.dart';
import 'package:farmer_trading_app/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;

  const HomeScreen({Key? key, this.userName}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int notificationCount = 0;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final data = await DatabaseHelper.instance.getFarmers();

    final normalizedData = data.map((product) {
      return {
        'name': product['product_name'] ?? 'Unknown',
        'harvest': product['product_description'] ?? 'No description',
        'price': product['price']?.toString() ?? '0',
        'image': (product['image'] != null && product['image'].toString().isNotEmpty)
            ? product['image']
            : 'assets/images/default.jpg',
      };
    }).toList();

    final demoProducts = [
      {
        'name': 'Tomatoes',
        'harvest': 'Fresh Tomatoes',
        'price': '1000',
        'image': 'assets/images/tomato.jpg'
      },
      {
        'name': 'Avocadoes',
        'harvest': 'Organic Avocadoes',
        'price': '1500',
        'image': 'assets/images/avocado.jpg'
      },
      {
        'name': 'Potatoes',
        'harvest': 'Irish Potatoes',
        'price': '800',
        'image': 'assets/images/potato.jpg'
      },
      {
        'name': 'Carrots',
        'harvest': 'Fresh Carrots',
        'price': '900',
        'image': 'assets/images/carrots.jpg'
      },
    ];

    setState(() {
      _products = [...demoProducts, ...normalizedData];
      _filteredProducts = _products;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        final name = product['name'].toString().toLowerCase();
        final harvest = product['harvest'].toString().toLowerCase();
        return name.contains(query) || harvest.contains(query);
      }).toList();
    });
  }

  void _showOrderDialog(String productName, String price) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Order $productName',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Price per unit: RWF $price"),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome ${widget.userName ?? "User"} to Farmer Trading App!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.green.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              product['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Harvest: ${product['harvest']}\nPrice: RWF ${product['price']}',
                            style: const TextStyle(height: 1.4),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _showOrderDialog(product['name'], product['price']),
                            child: const Text(
                              "Order",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      ServicesPage(),
      CartPage(),
      ProfilePage(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                setState(() => currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Services'),
              onTap: () {
                setState(() => currentIndex = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text("Farmer Trading App"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: -10, end: -8),
              badgeContent: Text(
                "$notificationCount",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(IconlyBroken.notification),
              ),
            ),
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.home),
            activeIcon: Icon(IconlyBold.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            activeIcon: Icon(IconlyBold.setting),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            activeIcon: Icon(IconlyBold.bag),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(IconlyBold.profile),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
