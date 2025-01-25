import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furnihush/consts/firebase_consts.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('orders')
            .where('userId', isEqualTo: currentUser?.uid)
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderDate = (order['orderDate'] as Timestamp).toDate();
              final items = List<Map<String, dynamic>>.from(order['items']);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Order #${orders[index].id}'),
                  subtitle: Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(orderDate)}\n'
                    'Status: ${order['status']}\n'
                    'Total: \$${order['total'].toStringAsFixed(2)}',
                  ),
                  children: items.map((item) {
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(item['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(item['name']),
                      subtitle: Text('Quantity: ${item['quantity']}'),
                      trailing: Text('\$${item['price']}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
