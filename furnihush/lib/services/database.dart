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
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
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
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
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
  Future<void> createOrder(
      String userId, Map<String, dynamic> orderData) async {
    try {
      await _firestore.collection('orders').add({
        ...orderData,
        'userId': userId,
        'orderDate': fs.Timestamp.now(),
      });
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
  Future<void> updateCart(
      String userId, List<Map<String, dynamic>> items) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'cart': items,
      });
    } catch (e) {
      debugPrint('Error updating cart: $e');
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
        double total = 0.0;
        for (var item in cart) {
          total += ((item['price'] as num?)?.toDouble() ?? 0.0) *
              (item['quantity'] as int? ?? 1);
        }
        return total;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error calculating cart total: $e');
      return 0.0;
    }
  }

  Future<void> initializeProducts() async {
    try {
      final productsRef = _firestore.collection('products');

      final products = [
        // New Arrivals
        {
          'name': 'Modern Sofa',
          'description': 'Comfortable 3-seater sofa with premium fabric',
          'price': 899,
          'image': 'assets/images/furniture/sa1.jpeg',
          'isNewArrival': true,
          'isHotDeal': false,
          'category': 'sofa'
        },
        {
          'name': 'Bedroom Set',
          'description': 'Complete bedroom set with modern design',
          'price': 1599,
          'image': 'assets/images/furniture/be1.jpeg',
          'isNewArrival': true,
          'isHotDeal': false,
          'category': 'bedroom'
        },
        {
          'name': 'Office Chair',
          'description': 'Ergonomic office chair with lumbar support',
          'price': 299,
          'image': 'assets/images/furniture/ca1.jpeg',
          'isNewArrival': true,
          'isHotDeal': false,
          'category': 'chair'
        },
        // Hot Deals
        {
          'name': 'Premium Sofa',
          'description': 'Luxury sofa with premium leather',
          'price': 1299,
          'originalPrice': 1599,
          'discount': '20% OFF',
          'image': 'assets/images/furniture/sa2.jpeg',
          'isNewArrival': false,
          'isHotDeal': true,
          'category': 'sofa'
        },
        {
          'name': 'King Size Bed',
          'description': 'Modern bedroom set with storage',
          'price': 1899,
          'originalPrice': 2299,
          'discount': '30% OFF',
          'image': 'assets/images/furniture/be2.jpeg',
          'isNewArrival': false,
          'isHotDeal': true,
          'category': 'bedroom'
        },
        {
          'name': 'Executive Chair',
          'description': 'Premium office chair with massage',
          'price': 499,
          'originalPrice': 699,
          'discount': '40% OFF',
          'image': 'assets/images/furniture/ca2.jpeg',
          'isNewArrival': false,
          'isHotDeal': true,
          'category': 'chair'
        }
      ];

      // Check if products already exist
      final existingProducts = await productsRef.get();
      if (existingProducts.docs.isEmpty) {
        for (var product in products) {
          await productsRef.add(product);
        }
        debugPrint('Products initialized successfully');
      } else {
        debugPrint('Products already exist in database');
      }
    } catch (e) {
      debugPrint('Error initializing products: $e');
    }
  }
}
