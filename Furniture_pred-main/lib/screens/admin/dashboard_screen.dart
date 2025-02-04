import 'package:flutter/material.dart';
import '../../services/database.dart';
import '../../widgets/admin_card.dart';

class AdminDashboard extends StatelessWidget {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          AdminCard(
            title: 'Products',
            icon: Icons.inventory,
            onTap: () => Navigator.pushNamed(context, '/products'),
          ),
          AdminCard(
            title: 'Orders',
            icon: Icons.shopping_cart,
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          AdminCard(
            title: 'Sales Prediction',
            icon: Icons.trending_up,
            onTap: () => Navigator.pushNamed(context, '/predictions'),
          ),
          AdminCard(
            title: 'Customers',
            icon: Icons.people,
            onTap: () => Navigator.pushNamed(context, '/customers'),
          ),
        ],
      ),
    );
  }
}
