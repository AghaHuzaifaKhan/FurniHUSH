import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:flutter/foundation.dart';
import 'package:furnihush/models/user.dart';
import 'package:furnihush/models/order.dart';
import 'package:path_provider/path_provider.dart';
import 'package:furnihush/models/cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserProvider with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  auth.User? _currentUser;
  Map<String, dynamic>? _userData;

  auth.User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;

  final User _user = User(
    name: 'John Doe',
    email: 'john.doe@example.com',
    address: '123 Main St, City, Country',
    paymentMethods: [
      '**** **** **** 1234',
      '**** **** **** 5678',
    ],
  );

  final List<Order> _orders = [];
  final List<String> _wishlist = [];

  User get user => _user;
  List<Order> get orders => _orders;
  List<String> get wishlist => _wishlist;

  Future<void> fetchUserData() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      try {
        final doc =
            await _firestore.collection('users').doc(_currentUser!.uid).get();
        if (doc.exists) {
          _userData = doc.data();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  Future<void> updateUser({
    String? name,
    String? email,
    String? profilePicture,
    String? address,
  }) async {
    try {
      if (_currentUser != null) {
        final updates = {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
        };

        // Handle profile picture separately
        if (profilePicture != null) {
          final savedPath = await saveProfileImage(profilePicture);
          updates['image'] = savedPath;
        }

        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .update(updates);

        await fetchUserData();
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  Future<String> saveProfileImage(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File('${directory.path}/$fileName');

      // Copy the picked image to app's directory
      await File(imagePath).copy(savedImage.path);
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      rethrow;
    }
  }

  void addToWishlist(String productId) {
    if (!_wishlist.contains(productId)) {
      _wishlist.add(productId);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    _wishlist.remove(productId);
    notifyListeners();
  }

  void addPaymentMethod(String cardNumber) async {
    try {
      final maskedNumber =
          '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
      await _firestore.collection('users').doc(_currentUser?.uid).update({
        'paymentMethods': fs.FieldValue.arrayUnion([maskedNumber])
      });
      await fetchUserData();
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      rethrow;
    }
  }

  Future<void> processOrder(List<CartItem> items, double total) async {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw 'User not authenticated';

    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      items: items
          .map((item) => OrderItem(
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                price: item.product.price,
              ))
          .toList(),
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
      shippingAddress: '',
    );

    _orders.add(order);
    notifyListeners();
  }

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }
}
