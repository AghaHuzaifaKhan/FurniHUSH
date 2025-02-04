import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/order.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class DatabaseService {
  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Products
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Orders
  Future<void> createOrder(
      List<OrderItem> items, double total, String address) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    await _db.collection('orders').add({
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': 'pending',
      'createdAt': fs.FieldValue.serverTimestamp(),
      'shippingAddress': address,
    });
  }

  Stream<List<Order>> getUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data(), doc.id))
            .toList());
  }

  // User Profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    await _db.collection('users').doc(userId).update({
      ...data,
      'updatedAt': fs.FieldValue.serverTimestamp(),
    });
  }

  Future<fs.DocumentSnapshot> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    return await _db.collection('users').doc(userId).get();
  }

  void exampleMethod() {
    try {
      // ... code
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
