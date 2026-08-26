import 'package:flutter/cupertino.dart';

import '../theme.dart';
import 'app_icon.dart';
import 'pixel_box.dart';

class TimerBar extends StatelessWidget {
  const TimerBar({
    super.key,
    required this.remaining,
    required this.total,
    required this.running,
    required this.pickerOpen,
    required this.minCtrl,
    required this.secCtrl,
    required this.onToggleRun,
    required this.onReset,
    required this.onTapTime,
    required this.onDurationChanged,
  });

  final int remaining, total;
  final bool running, pickerOpen;
  final FixedExtentScrollController minCtrl, secCtrl;
  final VoidCallback onToggleRun, onReset, onTapTime, onDurationChanged;

  String get _text =>
      '${(remaining ~/ 60).toString().padLeft(2, '0')}:'
      '${(remaining % 60).toString().padLeft(2, '0')}';

  double get _progress => total == 0 ? 0 : (total - remaining) / total;

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      fill: cream,
      border: green,
      borderWidth: 2.5,
      padding: const EdgeInsets.fromLTRB(18, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onTapTime,
                  child: Row(
                    children: [
                      Text(_text, style: display(48, color: ink)),
                      const SizedBox(width: 8),
                      Text(
                        pickerOpen ? '▴' : '▾',
                        style: mono(13, color: inkMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _PixelBtn(
                icon: running ? 'pause' : 'play',
                fallback: running ? '❚❚' : '▶',
                filled: true,
                onTap: onToggleRun,
              ),
              const SizedBox(width: 8),
              _PixelBtn(
                icon: 'reset',
                fallback: '⟳',
                filled: false,
                onTap: onReset,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 8,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 350),
              builder: (context, v, _) =>
                  CustomPaint(painter: _SegmentBar(v), size: Size.infinite),
            ),
          ),
          // AnimatedSize interpola la altura al abrir y cerrar los pickers.
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: pickerOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(height: 140, child: _pickers()),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _pickers() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _wheel(minCtrl),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(':', style: display(32, color: inkMuted)),
      ),
      _wheel(secCtrl),
    ],
  );

  Widget _wheel(FixedExtentScrollController c) => SizedBox(
    width: 76,
    child: CupertinoPicker(
      itemExtent: 34,
      scrollController: c,
      squeeze: 1.1,
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
        background: Color(0x1A3F9142),
      ),
      onSelectedItemChanged: (_) => onDurationChanged(),
      children: List.generate(
        60,
        (i) => Center(
          child: Text(
            i.toString().padLeft(2, '0'),
            style: display(30, color: ink),
          ),
        ),
      ),
    ),
  );
}

/// Barra de progreso hecha de bloques sueltos, no de una línea continua.
class _SegmentBar extends CustomPainter {
  _SegmentBar(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    const seg = 9.0, gap = 3.0;
    final count = (size.width / (seg + gap)).floor();
    final filled = (count * value).round();
    for (var i = 0; i < count; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * (seg + gap), 1, seg, 6),
        Paint()..color = i < filled ? greenBright : line,
      );
    }
  }

  @override
  bool shouldRepaint(_SegmentBar old) => old.value != value;
}

class _PixelBtn extends StatefulWidget {
  const _PixelBtn({
    required this.icon,
    required this.fallback,
    required this.filled,
    required this.onTap,
  });

  final String icon, fallback;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_PixelBtn> createState() => _PixelBtnState();
}

class _PixelBtnState extends State<_PixelBtn> {
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
          child: SizedBox(
            width: 46,
            height: 40,
            child: Center(child: AppIcon(widget.icon, size: 20)),
          ),
        ),
      ),
    );
  }
}
