import 'package:flutter/material.dart';
import '../theme.dart';
import 'pixel_box.dart';

/// Cascarón de ajustes: los controles se ven pero todavía no hacen nada.
/// Cada uno queda listo para conectarse cuando montemos el sistema de temas.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Card(
            title: 'Idioma',
            hint: 'Aún no conectado',
            child: Row(
              children: [
                _Chip(label: 'Español', selected: true),
                SizedBox(width: 8),
                _Chip(label: 'English', selected: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Card(
            title: 'Apariencia',
            hint: 'Aún no conectado',
            child: Row(
              children: [
                _Chip(label: 'Claro', selected: true),
                SizedBox(width: 8),
                _Chip(label: 'Oscuro', selected: false),
                SizedBox(width: 8),
                _Chip(label: 'Sistema', selected: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            title: 'Plantilla',
            hint: 'Aún no conectado',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Las plantillas definirán colores, fuentes y sprites. '
                  'Se podrán importar como archivo y compartir.',
                  style: mono(13, color: inkMuted),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _Chip(label: 'Mori (por defecto)', selected: true),
                    SizedBox(width: 8),
                    _Chip(label: 'Importar…', selected: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.hint, required this.child});

  final String title, hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      fill: cream,
      border: line,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: display(26, color: ink)),
              const SizedBox(width: 10),
              PixelBox(
                fill: Colors.transparent,
                border: inkFaint,
                borderWidth: 1.2,
                unit: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                child: Text(hint, style: mono(10, color: inkFaint)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: PixelBox(
        fill: selected ? greenSoft : cream,
        border: selected ? greenBorder : line,
        borderWidth: 1.5,
        unit: 2,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Text(
          label,
          style: mono(13, color: selected ? green : inkMuted),
        ),
      ),
    );
  }
}