class Product {
  int? id;
  String name;
  String? description;
  double? price;
  String? imagePath;
  int farmerId;

  Product({
    this.id,
    required this.name,
    this.description,
    this.price,
    this.imagePath,
    required this.farmerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'farmerId': farmerId,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imagePath: map['imagePath'],
      farmerId: map['farmerId'],
    );
  }
}
