import '../models/product.dart';

class ProductService {
  static List<Product> getProducts() {
    return (trailing: ElevatedButton(
  onPressed: () {
    print("Navigating to OrderPage for ${product.name}");
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => OrderPage(product: product),
    ));
  },
  child: Text("Order"),
),
    ),

  }
}
