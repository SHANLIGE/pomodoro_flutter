import 'package:flutter/material.dart';

/// Carga un sprite de assets/icons/<name>.png sin suavizado.
/// Si el archivo aún no existe, cae al emoji de respaldo.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, this.size = 22, this.fallback = '•'});

  final String name;
  final double size;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/$name.png',
      width: size,
      height: size,
      // Sin esto Flutter interpola al escalar y el pixel art se ve borroso.
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(fallback, style: TextStyle(fontSize: size * 0.82)),
        ),
      ),
    );
  }
}

/// Escena decorativa a lo ancho (repisa, pasto). Desaparece si falta el PNG.
class PixelScene extends StatelessWidget {
  const PixelScene(this.name, {super.key});
  final String name;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Image.asset(
        'assets/scenes/$name.png',
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}