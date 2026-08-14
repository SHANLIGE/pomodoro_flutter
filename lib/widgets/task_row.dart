import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, required this.onToggle});
  final Task task;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    // TweenAnimationBuilder anima solo al cambiar el valor destino.
    // Es el equivalente de tu QPropertyAnimation, sin controller ni dispose.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: task.done ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return Row(
          children: [
            _AppCheckbox(value: task.done, onChanged: onToggle),
            const SizedBox(width: 10),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomPaint(
                  foregroundPainter: _StrikePainter(progress),
                  child: Text(
                    task.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.lerp(textColor, textColorDone, progress),
                    ),
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

/// Equivalente exacto de tu StrikeLabel.paintEvent.
class _StrikePainter extends CustomPainter {
  _StrikePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = textColorDone
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width * progress, y), paint);
  }

  @override
  bool shouldRepaint(_StrikePainter old) => old.progress != progress;
}

class _AppCheckbox extends StatefulWidget {
  const _AppCheckbox({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<_AppCheckbox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final borderTone = widget.value
        ? secondaryColor
        : (_hover ? secondaryColor : textColorTertiary);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: widget.value ? secondaryColor : Colors.transparent,
            border: Border.all(color: borderTone, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.value
              ? const Icon(Icons.check, size: 13, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}