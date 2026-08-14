import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: borderColor, width: 1.2)),
        ),
        padding: const EdgeInsets.only(left: 14, right: 4),
        child: Row(
          children: [
            const Text(
              'Pomodoro timer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: titleBarTextColor,
              ),
            ),
            const Spacer(),
            _WindowButton(label: '—', onTap: windowManager.minimize),
            _WindowButton(label: '✕', onTap: windowManager.close),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 32,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hover ? titleBarHoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              color: _hover ? Colors.white : titleBarTextColor,
            ),
          ),
        ),
      ),
    );
  }
}