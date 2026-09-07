import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';
import 'app_icon.dart';
import 'pixel_box.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
  });

  final Task task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  bool _hover = false;

  bool get _overdue {
    final end = widget.task.end;
    if (end == null || widget.task.done) return false;
    return end.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.task.scheduleLabel;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      // Anima solo cuando cambia el valor destino; sin controller ni dispose.
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: widget.task.done ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          return Row(
            children: [
              _PixelCheckbox(
                value: widget.task.done,
                onChanged: widget.onToggle,
              ),
              const SizedBox(width: 12),
              // Flexible + ellipsis: el texto largo se corta en vez de
              // desbordar la fila.
              Flexible(
                child: CustomPaint(
                  foregroundPainter: _StrikePainter(progress),
                  child: Text(
                    widget.task.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(
                      15,
                      color: Color.lerp(ink, inkFaint, progress)!,
                    ),
                  ),
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 10),
                PixelBox(
                  fill: _overdue ? dangerSoft : greenSoft,
                  border: _overdue ? projectRed : greenBorder,
                  borderWidth: 1.2,
                  unit: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(11, color: _overdue ? projectRed : green),
                  ),
                ),
              ],
              const Spacer(),
              // AnimatedOpacity mantiene el espacio reservado, así el texto
              // no se mueve al aparecer el icono.
              AnimatedOpacity(
                opacity: _hover ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: _EditButton(enabled: _hover, onTap: widget.onEdit),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditButton extends StatefulWidget {
  const _EditButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    // IgnorePointer evita que se pueda clicar mientras está invisible.
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: PixelBox(
            fill: _hover ? greenSoft : Colors.transparent,
            border: _hover ? greenBorder : Colors.transparent,
            borderWidth: 1.5,
            unit: 2,
            child: const SizedBox(
              width: 32,
              height: 30,
              child: Center(child: AppIcon('edit', size: 16)),
            ),
          ),
        ),
      ),
    );
  }
}

class _StrikePainter extends CustomPainter {
  _StrikePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = inkFaint
      ..strokeWidth = 2;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width * progress, y), paint);
  }

  @override
  bool shouldRepaint(_StrikePainter old) => old.progress != progress;
}

class _PixelCheckbox extends StatefulWidget {
  const _PixelCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_PixelCheckbox> createState() => _PixelCheckboxState();
}

class _PixelCheckboxState extends State<_PixelCheckbox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final borderTone = widget.value ? green : (_hover ? greenBorder : inkFaint);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: PixelBox(
          fill: widget.value ? greenBright : Colors.transparent,
          border: borderTone,
          borderWidth: 2,
          unit: 2,
          child: SizedBox(
            width: 20,
            height: 20,
            child: widget.value
                ? const Center(
                    child: Text(
                      '✓',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}