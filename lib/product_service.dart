import '../models/product.dart';

class ProductService {
  static List<Product> getProducts() {
    return [
      Product(name: "Tomatoes", ownerName: "John", ownerContact: "0781234567", cost: 400),
      Product(name: "Carrots", ownerName: "Alice", ownerContact: "0788765432", cost: 300),
    ];
  }
}
