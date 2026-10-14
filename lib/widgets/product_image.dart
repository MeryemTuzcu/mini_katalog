import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final double padding;

  const ProductImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.padding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F2F5),
      padding: EdgeInsets.all(padding),
      child: Image.network(
        image,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
