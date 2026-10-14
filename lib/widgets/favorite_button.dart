import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/favorites_state.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatelessWidget {
  final Product product;

  const FavoriteButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesState.instance,
      builder: (context, child) {
        var isFavorite = FavoritesState.instance.isFavorite(product.id);
        return Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: AppTheme.cardShadow,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => FavoritesState.instance.toggle(product),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFavorite ? Colors.red.shade400 : AppTheme.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}
