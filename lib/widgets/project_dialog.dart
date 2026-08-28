import 'package:flutter/material.dart';

import '../theme.dart';
import 'pixel_box.dart';

/// Abre el diálogo y devuelve el nombre escrito, o null si se canceló.
Future<String?> showProjectDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierColor: ink.withValues(alpha: 0.35),
    builder: (_) => const _ProjectDialog(),
  );
}

class _ProjectDialog extends StatefulWidget {
  const _ProjectDialog();

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: PixelBox(
        fill: cream,
        border: green,
        borderWidth: 2.5,
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nuevo proyecto', style: display(30, color: ink)),
              const SizedBox(height: 14),
              PixelBox(
                fill: Colors.white,
                border: line,
                borderWidth: 1.5,
                unit: 2,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _submit(),
                  style: mono(15, color: ink),
                  decoration: InputDecoration(
                    hintText: 'Nombre del proyecto',
                    hintStyle: mono(15, color: inkFaint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _DialogBtn(
                    label: 'Cancelar',
                    filled: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  _DialogBtn(label: 'Crear', filled: true, onTap: _submit),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogBtn extends StatefulWidget {
  const _DialogBtn({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_DialogBtn> createState() => _DialogBtnState();
}

class _DialogBtnState extends State<_DialogBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fill = widget.filled
        ? (_hover ? green : greenBright)
        : (_hover ? greenSoft : cream);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: PixelBox(
          fill: fill,
          border: widget.filled ? green : line,
          borderWidth: 2,
          unit: 2.5,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            widget.label,
            style: mono(
              14,
              color: widget.filled ? Colors.white : inkMuted,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
