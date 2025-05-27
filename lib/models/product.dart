class Product {
  int? id;
  String name;
  double price;
  String farmerName;
  String farmerContact;
  String imagePath;
  int farmerId;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.farmerName,
    required this.farmerContact,
    required this.imagePath,
    required this.farmerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'farmerName': farmerName,
      'farmerContact': farmerContact,
      'image': imagePath,
      'farmerId': farmerId,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      farmerName: map['farmerName'],
      farmerContact: map['farmerContact'],
      imagePath: map['imagePath'],
      farmerId: map['farmerId'],
    );
  }
}
