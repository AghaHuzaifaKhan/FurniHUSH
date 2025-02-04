import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final String image;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.stock,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      image: map['image'] ?? '',
      stock: map['stock'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'stock': stock,
      'createdAt': createdAt,
    };
  }

  // ... rest of your model code
}
