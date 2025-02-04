import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furniture_pred/screens/auth/home_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is admin (you'll need to implement this logic)
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to access admin dashboard'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: [
          _buildDashboardItem(
            context,
            'Manage Items',
            Icons.inventory,
            () => Navigator.pushNamed(context, '/admin/items'),
            Colors.blue.shade50,
          ),
          _buildDashboardItem(
            context,
            'Stock Management',
            Icons.store,
            () => Navigator.pushNamed(context, '/admin/stock'),
            Colors.blue.shade50,
          ),
          _buildDashboardItem(
            context,
            'Price Management',
            Icons.attach_money,
            () => Navigator.pushNamed(context, '/admin/prices'),
            Colors.blue.shade50,
          ),
          _buildDashboardItem(
            context,
            'Sales Analytics',
            Icons.analytics,
            () {
              if (HomeScreen.of(context)?.itemPredictions.isEmpty ?? true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please upload data first to view analytics'),
                  ),
                );
                return;
              }
              Navigator.pushNamed(context, '/admin/analytics');
            },
            Colors.purple.shade50,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    Color? backgroundColor,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
