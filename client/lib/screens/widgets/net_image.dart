import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFEFFCF7),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFEFFCF7),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_rounded, size: 32, color: Color(0xFF64748B)),
      ),
    );
  }
}
