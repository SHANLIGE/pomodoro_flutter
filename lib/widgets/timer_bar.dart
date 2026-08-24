import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

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

  final int remaining;
  final int total;
  final bool running;
  final bool pickerOpen;
  final FixedExtentScrollController minCtrl;
  final FixedExtentScrollController secCtrl;
  final VoidCallback onToggleRun;
  final VoidCallback onReset;
  final VoidCallback onTapTime;
  final VoidCallback onDurationChanged;

  String get _formatted =>
      '${(remaining ~/ 60).toString().padLeft(2, '0')}:'
      '${(remaining % 60).toString().padLeft(2, '0')}';

  double get _progress =>
      total == 0 ? 0 : (total - remaining) / total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: dividerColor),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onTapTime,
                  child: Row(
                    children: [
                      Text(
                        _formatted,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: pickerOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.expand_more_rounded,
                          size: 18,
                          color: textColorDone,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _CircleAction(
                icon: running
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                filled: true,
                onTap: onToggleRun,
              ),
              const SizedBox(width: 8),
              _CircleAction(
                icon: Icons.refresh_rounded,
                filled: false,
                onTap: onReset,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: dividerColor,
                valueColor: const AlwaysStoppedAnimation(secondaryColor),
              ),
            ),
          ),
          // AnimatedSize interpola la altura al abrir/cerrar los pickers.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: pickerOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(height: 150, child: _pickers()),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _pickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _wheel(minCtrl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text(':',
              style: TextStyle(fontSize: 22, color: textColorTertiary)),
        ),
        _wheel(secCtrl),
      ],
    );
  }

  Widget _wheel(FixedExtentScrollController controller) {
    return SizedBox(
      width: 76,
      child: CupertinoPicker(
        itemExtent: 36,
        scrollController: controller,
        squeeze: 1.1,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Color(0x14FF85BE),
        ),
        onSelectedItemChanged: (_) => onDurationChanged(),
        children: List.generate(
          60,
          (i) => Center(
            child: Text(
              i.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 21, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatefulWidget {
  const _CircleAction({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<_CircleAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled
        ? (_hover ? primaryColor : secondaryColor)
        : (_hover ? hoverSurface : Colors.transparent);
    final fg = widget.filled ? Colors.white : textColorTertiary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: widget.filled
                ? null
                : Border.all(color: dividerColor),
          ),
          child: Icon(widget.icon, size: 21, color: fg),
        ),
      ),
    );
  }
}