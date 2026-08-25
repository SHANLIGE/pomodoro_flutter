import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';
import 'pixel_box.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, required this.onToggle});

  final Task task;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    // Anima solo cuando cambia el valor destino; sin controller ni dispose.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: task.done ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return Row(
          children: [
            _PixelCheckbox(value: task.done, onChanged: onToggle),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomPaint(
                  foregroundPainter: _StrikePainter(progress),
                  child: Text(
                    task.text,
                    style: mono(15, color: Color.lerp(ink, inkFaint, progress)!),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
    final borderTone = widget.value
        ? green
        : (_hover ? greenBorder : inkFaint);

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