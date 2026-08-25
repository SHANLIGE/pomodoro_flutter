import 'package:flutter/material.dart';
import '../theme.dart';

/// Contorno escalonado del pixel art: en vez de una curva, las esquinas
/// bajan en dos peldaños de un pixel lógico cada uno.
Path pixelPath(Size size, double u) {
  final w = size.width, h = size.height;
  return Path()
    ..moveTo(2 * u, 0)
    ..lineTo(w - 2 * u, 0)
    ..lineTo(w - 2 * u, u)
    ..lineTo(w - u, u)
    ..lineTo(w - u, 2 * u)
    ..lineTo(w, 2 * u)
    ..lineTo(w, h - 2 * u)
    ..lineTo(w - u, h - 2 * u)
    ..lineTo(w - u, h - u)
    ..lineTo(w - 2 * u, h - u)
    ..lineTo(w - 2 * u, h)
    ..lineTo(2 * u, h)
    ..lineTo(2 * u, h - u)
    ..lineTo(u, h - u)
    ..lineTo(u, h - 2 * u)
    ..lineTo(0, h - 2 * u)
    ..lineTo(0, 2 * u)
    ..lineTo(u, 2 * u)
    ..lineTo(u, u)
    ..lineTo(2 * u, u)
    ..close();
}

class _PixelPainter extends CustomPainter {
  _PixelPainter({this.fill, this.border, this.width = 2, this.unit = px});

  final Color? fill;
  final Color? border;
  final double width;
  final double unit;

  @override
  void paint(Canvas canvas, Size size) {
    final path = pixelPath(size, unit);
    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill!);
    }
    if (border != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = border!
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.miter,
      );
    }
  }

  @override
  bool shouldRepaint(_PixelPainter old) =>
      old.fill != fill || old.border != border || old.width != width;
}

class PixelBox extends StatelessWidget {
  const PixelBox({
    super.key,
    this.fill,
    this.border,
    this.borderWidth = 2,
    this.unit = px,
    this.padding = EdgeInsets.zero,
    required this.child,
  });

  final Color? fill;
  final Color? border;
  final double borderWidth;
  final double unit;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PixelPainter(
        fill: fill,
        border: border,
        width: borderWidth,
        unit: unit,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Recorta la ventana con la misma silueta escalonada.
class PixelClipper extends CustomClipper<Path> {
  const PixelClipper({this.unit = px});
  final double unit;

  @override
  Path getClip(Size size) => pixelPath(size, unit);

  @override
  bool shouldReclip(PixelClipper old) => old.unit != unit;
}