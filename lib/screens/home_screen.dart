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
  int notificationCount = 5;

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
        // 'image': 'assets/images/carrots.jpg'
      },
    ];

    setState(() {
      _products = [...demoProducts, ...data];
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
          title: Text('Order $productName'),
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
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome ${widget.userName ?? "User"} to Farmer Trading App!",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: "Search products...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(child: Text('No products found.'))
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: product['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product['image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image_not_supported, size: 60),
                        title: Text(product['name']),
                        subtitle: Text('Harvest: ${product['harvest']}, Price: RWF ${product['price']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _showOrderDialog(product['name'], product['price']),
                          child: const Text("Order"),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      ServicesPage(),
      CartPage(),
      ProfilePage(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
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
        centerTitle: false,
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
