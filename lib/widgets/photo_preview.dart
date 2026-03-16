import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({
    super.key,
    required this.imagePath,
    this.height = 280,
  });

  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(24),
          minScale: 1,
          maxScale: 5,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Colors.black12,
              child: Center(child: Icon(Icons.broken_image_outlined, size: 48)),
            ),
          ),
        ),
      ),
    );
  }
}
