class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int companyId;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.companyId,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        description: j['description'] as String?,
        price: (j['price'] as num).toDouble(),
        stock: (j['stock'] as num).toInt(),
        companyId: (j['companyId'] as num).toInt(),
      );
}
