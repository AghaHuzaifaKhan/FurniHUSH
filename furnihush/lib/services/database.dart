import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Products
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // User Data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update(data);
      }
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }

  // Orders
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Add order to orders collection
        final orderRef = await _firestore.collection('orders').add({
          ...orderData,
          'userId': userId,
          'createdAt': fs.Timestamp.now(),
          'status': 'Processing',
        });

        // Add order reference to user's orders
        await _firestore.collection('users').doc(userId).update({
          'orders': fs.FieldValue.arrayUnion([orderRef.id])
        });
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting user orders: $e');
      return [];
    }
  }

  // Cart
  Future<void> addToCart(Map<String, dynamic> item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'cart': fs.FieldValue.arrayUnion([item])
        });
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(Map<String, dynamic> item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'cart': fs.FieldValue.arrayRemove([item])
        });
      }
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  // Wishlist
  Future<void> toggleWishlist(String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final wishlist = List<String>.from(userDoc.data()?['wishlist'] ?? []);

        if (wishlist.contains(productId)) {
          wishlist.remove(productId);
        } else {
          wishlist.add(productId);
        }

        await _firestore.collection('users').doc(userId).update({
          'wishlist': wishlist,
        });
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      rethrow;
    }
  }

  // Add initialization check
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Add user document creation
  Future<void> createUserDocument(
      String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        ...userData,
        'cart': [],
        'wishlist': [],
        'orders': [],
        'createdAt': fs.Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  // Add cart total calculation
  Future<double> getCartTotal() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        final cart = List<Map<String, dynamic>>.from(doc.data()?['cart'] ?? []);
        return cart.fold(
            0.0,
            (total, item) =>
                total + (item['price'] ?? 0.0) * (item['quantity'] ?? 1));
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error calculating cart total: $e');
      return 0.0;
    }
  }
}
