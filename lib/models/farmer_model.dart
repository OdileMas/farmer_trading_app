class Farmer {
  int? id;
  String? name;
  String? contact;
  String? harvest;
  double? price;
  String? imagePath;
  String? username;
  String? password;
  int? farmerId;

  Farmer({
    this.id,
    this.name,
    this.contact,
    this.harvest,
    this.price,
    this.imagePath,
    this.username,
    this.password,
    this.farmerId,
  });

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      harvest: map['harvest'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      imagePath: map['imagePath'],
      username: map['username'],
      password: map['password'],
      farmerId: map['farmerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'harvest': harvest,
      'price': price,
      'imagePath': imagePath,
      'username': username,
      'password': password,
      'farmerId': farmerId,
    };
  }
}
