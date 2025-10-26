class Product {
  final int? id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final double? buyPrice;
  final int stock;
  final String? imagePath;
  final int? supplierId;
  final String? description;

  Product({
    this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    this.buyPrice,
    required this.stock,
    this.imagePath,
    this.supplierId,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'buyPrice': buyPrice,
      'stock': stock,
      'imagePath': imagePath,
      'supplierId': supplierId,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sku: map['sku'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] ?? 0.0),
      buyPrice: map['buyPrice'] != null ? (map['buyPrice'] is int ? (map['buyPrice'] as int).toDouble() : map['buyPrice']) : null,
      stock: map['stock'] ?? 0,
      imagePath: map['imagePath'],
      supplierId: map['supplierId'],
      description: map['description'],
    );
  }
}
