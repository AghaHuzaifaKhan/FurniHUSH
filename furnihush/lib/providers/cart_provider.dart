import 'package:flutter/foundation.dart';
import 'package:furnihush/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  void addItem({
    required String id,
    required String name,
    required double price,
    required String image,
  }) {
    // ignore: unrelated_type_equality_checks
    final existingItemIndex = _items.indexWhere((item) => item.id == id);

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          id: int.parse(id),
          name: name,
          price: price,
          image: image,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(int id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
