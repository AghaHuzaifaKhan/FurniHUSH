import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  String _filterBy = 'all'; // 'all', 'low', 'medium', 'high'

  Future<void> _refreshStock() async {
    setState(() {}); // This will refresh the StreamBuilder
  }

  Future<void> _updateStock(String itemId, int currentStock, int change) async {
    try {
      final newStock = currentStock + change;
      if (newStock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock cannot be negative')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('items').doc(itemId).update({
        'stock': newStock,
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating stock: ${e.toString()}')),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Items'),
              leading: Radio(
                value: 'all',
                groupValue: _filterBy,
                onChanged: (value) {
                  setState(() => _filterBy = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Low Stock'),
              leading: Radio(
                value: 'low',
                groupValue: _filterBy,
                onChanged: (value) {
                  setState(() => _filterBy = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Medium Stock'),
              leading: Radio(
                value: 'medium',
                groupValue: _filterBy,
                onChanged: (value) {
                  setState(() => _filterBy = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('High Stock'),
              leading: Radio(
                value: 'high',
                groupValue: _filterBy,
                onChanged: (value) {
                  setState(() => _filterBy = value.toString());
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Query<Map<String, dynamic>> _getFilteredQuery() {
    final query = FirebaseFirestore.instance.collection('items');
    switch (_filterBy) {
      case 'low':
        return query.where('stock', isLessThan: 20);
      case 'medium':
        return query
            .where('stock', isGreaterThanOrEqualTo: 20)
            .where('stock', isLessThan: 50);
      case 'high':
        return query.where('stock', isGreaterThanOrEqualTo: 50);
      default:
        return query;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStock,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data?.docs ?? [];
          final lowStockCount = items.where((doc) {
            final item = doc.data() as Map<String, dynamic>;
            return (item['stock'] as int? ?? 0) < 20;
          }).length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildSummaryCard(
                      'Total Items',
                      items.length.toString(),
                      Icons.inventory,
                      Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      'Low Stock',
                      lowStockCount.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final item = doc.data() as Map<String, dynamic>;
                    final stock = item['stock'] as int? ?? 0;
                    const maxStock = 100; // You can adjust this value

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildStockStatus(stock),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: stock / maxStock,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                stock < 20 ? Colors.red : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'In Stock: $stock',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          _updateStock(doc.id, stock, -1),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          _updateStock(doc.id, stock, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatus(int quantity) {
    Color color;
    String text;

    if (quantity < 20) {
      color = Colors.red;
      text = 'Low Stock';
    } else if (quantity < 50) {
      color = Colors.orange;
      text = 'Medium Stock';
    } else {
      color = Colors.green;
      text = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
