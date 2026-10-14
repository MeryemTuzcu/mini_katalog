import 'package:flutter/foundation.dart';

import '../models/product.dart';

class FavoritesState extends ChangeNotifier {
  FavoritesState._();

  static final FavoritesState instance = FavoritesState._();

  final Set<int> _ids = {};

  bool isFavorite(int productId) => _ids.contains(productId);

  void toggle(Product product) {
    if (!_ids.remove(product.id)) {
      _ids.add(product.id);
    }
    notifyListeners();
  }
}
