import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:furnihush/models/user.dart';
import 'package:furnihush/models/order.dart';
import 'package:path_provider/path_provider.dart';
import 'package:furnihush/models/cart_item.dart';

class UserProvider with ChangeNotifier {
  User _user = User(
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

  Future<void> updateUser({
    String? name,
    String? email,
    String? profilePicture,
    String? address,
  }) async {
    String? savedImagePath;

    if (profilePicture != null) {
      savedImagePath = await _saveProfileImage(profilePicture);
    }

    _user = User(
      name: name ?? _user.name,
      email: email ?? _user.email,
      profilePicture: savedImagePath ?? _user.profilePicture,
      address: address ?? _user.address,
      paymentMethods: _user.paymentMethods,
    );
    notifyListeners();
  }

  Future<String> _saveProfileImage(String imagePath) async {
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

  void addPaymentMethod(String cardNumber) {
    final maskedNumber =
        '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    _user.paymentMethods.add(maskedNumber);
    notifyListeners();
  }

  Future<void> processOrder(List<CartItem> items, double total) async {
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: items,
      total: total,
      status: 'Processing',
    );

    _orders.add(order);
    notifyListeners();
  }
}
