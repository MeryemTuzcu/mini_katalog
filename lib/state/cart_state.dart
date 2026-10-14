import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, [this.quantity = 1]);
}

class CartState extends ChangeNotifier {
  CartState._();

  static final CartState instance = CartState._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold<double>(
      0, (sum, item) => sum + item.product.price * item.quantity);

  void add(Product product) {
    var index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product));
    }
    notifyListeners();
  }

  void decrease(Product product) {
    var index = _items.indexWhere((item) => item.product.id == product.id);
    if (index < 0) return;
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
