import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/cart_screen.dart';

void showAddedSnackBar(BuildContext context, Product product) {
  var messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text('${product.name} added to cart'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'VIEW',
        onPressed: () => Navigator.pushNamed(context, CartScreen.routeName),
      ),
    ),
  );
}
