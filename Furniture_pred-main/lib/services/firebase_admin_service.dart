import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new item
  Future<void> addItem({
    required String name,
    required double price,
    required int quantity,
    required String description,
    required String category,
  }) async {
    try {
      await _firestore.collection('current_stock').doc(name).set({
        'name': name,
        'price': price,
        'quantity': quantity,
        'description': description,
        'category': category,
        'min_stock': 10,
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to add item: $e';
    }
  }

  // Update item
  Future<void> updateItem({
    required String name,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('current_stock').doc(name).update({
        ...data,
        'last_updated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update item: $e';
    }
  }

  // Delete item
  Future<void> deleteItem(String name) async {
    try {
      await _firestore.collection('current_stock').doc(name).delete();
    } catch (e) {
      throw 'Failed to delete item: $e';
    }
  }

  // Get predictions
  Stream<QuerySnapshot> getPredictions() {
    return _firestore
        .collection('predictions')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // Get inventory summary
  Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('current_stock').get();
      final int totalItems = snapshot.docs.length;
      final int lowStockItems = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['quantity'] < data['min_stock'];
      }).length;

      return {
        'totalItems': totalItems,
        'lowStockItems': lowStockItems,
      };
    } catch (e) {
      throw 'Failed to get inventory summary: $e';
    }
  }
}
