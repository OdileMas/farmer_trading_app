class Farmer {
  final int? id;
  final String name;
  final String harvest;
  final double price;
  final int? contact;

  Farmer({this.id, required this.name, required this.harvest, required this.price, this.contact});

  // Convert a Farmer into a Map object for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'harvest': harvest,
      'price': price,
    };
  }

  // Convert a Map object into a Farmer object
  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      name: map['name'],
      harvest: map['harvest'],
      price: map['price'],
    );
  }
}
