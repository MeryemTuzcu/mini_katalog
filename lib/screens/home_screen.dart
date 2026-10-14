import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../data/product_repository.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../state/favorites_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cart_snackbar.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

enum SortOption { featured, priceLow, priceHigh, name }

String sortLabel(SortOption option) {
  return switch (option) {
    SortOption.featured => 'Featured',
    SortOption.priceLow => 'Price: low to high',
    SortOption.priceHigh => 'Price: high to low',
    SortOption.name => 'Name: A to Z',
  };
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  String _search = '';
  String _category = 'All';
  SortOption _sort = SortOption.featured;
  bool _loading = true;
  bool _failed = false;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    FavoritesState.instance.addListener(_refresh);
    _getProducts();
  }

  @override
  void dispose() {
    FavoritesState.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _getProducts() async {
    try {
      var products = await ProductRepository.getProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _failed = false;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Products could not be loaded: $e');
      if (!mounted) return;
      setState(() {
        _noInternet = e is SocketException || e is TimeoutException;
        _failed = true;
        _loading = false;
      });
    }
  }

  List<Product> get _visibleProducts {
    var search = _search.trim().toLowerCase();
    var list = _products.where((product) {
      var inCategory = _category == 'All' ||
          (_category == 'Favorites'
              ? FavoritesState.instance.isFavorite(product.id)
              : product.category == _category);
      var matchesSearch = search.isEmpty ||
          product.name.toLowerCase().contains(search) ||
          product.tagline.toLowerCase().contains(search);
      return inCategory && matchesSearch;
    }).toList();

    switch (_sort) {
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.name:
        list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.featured:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_failed) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _noInternet ? Icons.wifi_off : Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _noInternet ? 'No internet connection' : 'Something went wrong',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _noInternet
                      ? 'Please check your connection and try again.'
                      : 'We could not load the products. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _failed = false;
                      });
                      _getProducts();
                    },
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    var products = _visibleProducts;
    var categories = [
      'All',
      'Favorites',
      ..._products.map((product) => product.category).toSet(),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find your perfect device.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: CartState.instance,
                    builder: (context, child) {
                      var count = CartState.instance.count;
                      return Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 1,
                        shadowColor: AppTheme.cardShadow,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              Navigator.pushNamed(context, CartScreen.routeName),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Badge(
                              isLabelVisible: count > 0,
                              label: Text('$count'),
                              child: const Icon(Icons.shopping_bag_outlined),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                onChanged: (value) => setState(() => _search = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/banner.png', fit: BoxFit.cover),
                      const Positioned(
                        right: 18,
                        bottom: 14,
                        child: Icon(
                          Icons.card_giftcard,
                          size: 64,
                          color: Color(0xFFB9A2E8),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GIFT STORE',
                              style: TextStyle(
                                color: Color(0xFF3B2A5A),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Find the perfect gift\nfor everyone you love.',
                              style: TextStyle(
                                color: Color(0xFF6B5A8A),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    var category = categories[index];
                    var selected = category == _category;
                    return ChoiceChip(
                      label: Text(category),
                      avatar: category == 'Favorites'
                          ? Icon(
                              Icons.favorite,
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : Colors.red.shade400,
                            )
                          : null,
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: AppTheme.ink,
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (value) =>
                          setState(() => _category = category),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _category == 'All' ? 'Popular products' : _category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<SortOption>(
                    initialValue: _sort,
                    onSelected: (option) => setState(() => _sort = option),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    itemBuilder: (context) => SortOption.values
                        .map(
                          (option) => PopupMenuItem<SortOption>(
                            value: option,
                            child: Text(sortLabel(option)),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            sortLabel(_sort),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (products.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          _category == 'Favorites'
                              ? Icons.favorite_border
                              : Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _category == 'Favorites'
                              ? 'No favorites yet'
                              : 'No products found',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _category == 'Favorites'
                              ? 'Tap the heart on a product to save it here.'
                              : 'Try a different search or category.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    var product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.pushNamed(
                        context,
                        ProductDetailScreen.routeName,
                        arguments: product,
                      ),
                      onAdd: () {
                        CartState.instance.add(product);
                        showAddedSnackBar(context, product);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
