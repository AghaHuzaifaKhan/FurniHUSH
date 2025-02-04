import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Products Collection
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _db.collection('products').add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      await _db.collection('products').doc(productId).update(data);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Orders Collection
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _db.collection('orders').add({
        ...orderData,
        'userId': userId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Customer Management
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _db.collection('users').doc(userId).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }

  // Sales Predictions
  Future<void> savePrediction(Map<String, dynamic> predictionData) async {
    try {
      await _db.collection('predictions').add({
        ...predictionData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving prediction: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getPredictions() {
    return _db
        .collection('predictions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final orders = await _db.collection('orders').get();
      final products = await _db.collection('products').get();
      final users = await _db.collection('users').get();

      return {
        'totalOrders': orders.size,
        'totalProducts': products.size,
        'totalCustomers': users.size,
        // Add more analytics as needed
      };
    } catch (e) {
      print('Error getting analytics: $e');
      rethrow;
    }
  }
}
