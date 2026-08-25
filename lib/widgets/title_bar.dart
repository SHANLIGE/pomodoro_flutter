import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme.dart';
import 'app_icon.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 52,
        decoration: const BoxDecoration(
          color: creamBar,
          border: Border(bottom: BorderSide(color: line, width: 2)),
        ),
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            const AppIcon('cat', size: 26, fallback: '🐈'),
            const SizedBox(width: 10),
            Text('Mori Taimu', style: display(28)),
            const Spacer(),
            _WinBtn(label: '—', onTap: windowManager.minimize),
            _WinBtn(label: '✕', onTap: windowManager.close),
          ],
        ),
      ),
    );
  }
}

class _WinBtn extends StatefulWidget {
  const _WinBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 42,
          height: 34,
          alignment: Alignment.center,
          color: _hover ? line.withValues(alpha: 0.5) : Colors.transparent,
          child: Text(widget.label, style: mono(15, color: ink)),
        ),
      ),
    );
  }
}