import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ana_arias_studio/core/constants/app_colors.dart';

/// Widget versátil que renderiza imágenes tanto si provienen de
/// una URL de Firebase Storage (http/https) como de una cadena Base64
/// (data:image/png;base64,...) para compatibilidad 100% gratuita con Spark.
class SmartImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) {
      return _buildPlaceholder();
    }

    // Caso 1: Cadena Base64 Data URL (data:image/...;base64,XXXX)
    if (source.startsWith('data:image') || !source.startsWith('http')) {
      try {
        final base64String = source.contains(',') ? source.split(',').last : source;
        final Uint8List bytes = base64Decode(base64String.replaceAll('\n', '').trim());
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, error, stackTrace) => _buildErrorWidget(),
        );
      } catch (_) {
        return _buildErrorWidget();
      }
    }

    // Caso 2: URL HTTP / HTTPS
    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (ctx, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      child: const Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted)),
    );
  }
}
