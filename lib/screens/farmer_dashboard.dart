import 'dart:io';
import '../models/product.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmer_trading_app/database_helper.dart';

class FarmerDashboard extends StatefulWidget {
  final int farmerId;
  final String farmerName;

  const FarmerDashboard({
    Key? key,
    required this.farmerId,
    required this.farmerName,
  }) : super(key: key);

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  final _formKey = GlobalKey<FormState>();

  // Form input controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Image file picked from gallery or camera
  File? _selectedImage;

  // List of products fetched from database
  List<Product> products = [];

  // Flag to toggle product add form visibility
  bool showAddProductForm = false;

  // For editing products
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Load products from SQLite database for the current farmer
void _loadProducts() async {
  final db = DatabaseHelper.instance;
  final fetchedProducts = await db.getProducts(farmerId: widget.farmerId);
  setState(() {
    products = fetchedProducts;
  });
}


  // Pick image using image_picker plugin
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Add or update product in the database
  Future<void> _addOrUpdateProduct() async {
    if (_formKey.currentState?.validate() != true) return;

    final db = DatabaseHelper.instance;
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    double price = double.parse(_priceController.text.trim());

    if (_editingProduct == null) {
      // Adding new product
      Product newProduct = Product(
        farmerId: widget.farmerId, // fixed: remove int.tryParse, farmerId is already int
        name: name,
        description: description,
        price: price,
        imagePath: _selectedImage?.path,
      );
      await db.insertProduct(newProduct.toMap());
    } else {
      // Updating existing product
      _editingProduct!
        ..name = name
        ..description = description
        ..price = price
        ..imagePath = _selectedImage?.path ?? _editingProduct!.imagePath;

      await db.updateProduct(_editingProduct!);
      _editingProduct = null;
    }

    // Reset form and reload product list
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _selectedImage = null;
      showAddProductForm = false;
    });
    _loadProducts();
  }

  // Start editing a product: fill form fields and image
  void _startEditProduct(Product product) {
    setState(() {
      _editingProduct = product;
      showAddProductForm = true;
      _nameController.text = product.name ?? '';
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      if (product.imagePath != null) {
        _selectedImage = File(product.imagePath!);
      } else {
        _selectedImage = null;
      }
    });
  }

  // Delete product by id
  Future<void> _deleteProduct(int id) async {
    final db = DatabaseHelper.instance;
    await db.deleteProduct(id);
    _loadProducts();

  }

  // Show AI recommendation history placeholder dialog
  void _showRecommendationHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recommendation History"),
        content: const Text("This feature is under development."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))
        ],
      ),
    );
  }

  // Show settings dialog with edit profile and logout options
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showProfileEditDialog();
              },
              child: const Text("Edit Profile"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutConfirmation();
              },
              child: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // Show profile edit dialog (only name for now)
  void _showProfileEditDialog() {
    final TextEditingController _profileNameController = TextEditingController(text: widget.farmerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: TextField(
          controller: _profileNameController,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // TODO: Save profile changes to DB or state management
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Show logout confirmation dialog
  void _logoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close dashboard and go back to login screen
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // Build UI card for each product with edit/delete buttons
  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: product.imagePath != null
            ? Image.file(
                File(product.imagePath!),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        title: Text(product.name ?? 'No Name'),
        subtitle: Text(
          '${product.description ?? 'No Description'}\nPrice: \$${product.price?.toStringAsFixed(2) ?? '0.00'}',
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _startEditProduct(product),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteProduct(product.id!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show confirmation dialog before deleting a product
  void _confirmDeleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteProduct(productId);
            },
            child: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.farmerName}'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: _showRecommendationHistory,
            icon: const Icon(Icons.history),
            tooltip: "AI Recommendation History",
          ),
          IconButton(
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showAddProductForm = !showAddProductForm;
                if (!showAddProductForm) {
                  // Reset form if hiding
                  _editingProduct = null;
                  _nameController.clear();
                  _descriptionController.clear();
                  _priceController.clear();
                  _selectedImage = null;
                }
              });
            },
            child: Text(showAddProductForm ? 'Cancel Add/Edit' : 'Add Product'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          if (showAddProductForm)
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter product name' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter description' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter price';
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) return 'Please enter a valid price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Image.file(
                        _selectedImage!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addOrUpdateProduct,
                    child: Text(_editingProduct == null ? 'Add Product' : 'Update Product'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Your Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No products added yet.'),
            )
          else
            ...products.map(_buildProductCard).toList(),
        ],
      ),
    );
  }
}
