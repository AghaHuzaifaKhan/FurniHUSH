import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/product.dart';

class ProductListScreen extends StatelessWidget {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: StreamBuilder<List<Product>>(
        stream: db.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price}'),
                trailing: Text('Stock: ${product.stock}'),
              );
            },
          );
        },
      ),
    );
  }
}
