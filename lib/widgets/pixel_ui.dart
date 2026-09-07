import 'package:flutter/material.dart';
import '../theme.dart';
import 'pixel_box.dart';

class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool danger;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.danger ? projectRed : green;
    final accentBright =
        widget.danger ? const Color(0xFFEC7565) : greenBright;
    final softBg = widget.danger ? const Color(0xFFF6E3E0) : greenSoft;

    final fill = widget.filled
        ? (_hover ? accent : accentBright)
        : (_hover ? softBg : cream);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: PixelBox(
          fill: fill,
          border: widget.filled ? accent : line,
          borderWidth: 2,
          unit: 2.5,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            widget.label,
            style: mono(
              14,
              color: widget.filled
                  ? Colors.white
                  : (widget.danger ? projectRed : inkMuted),
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class PixelField extends StatelessWidget {
  const PixelField({
    super.key,
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      fill: Colors.white,
      border: line,
      borderWidth: 1.5,
      unit: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onSubmitted: onSubmitted,
        style: mono(15, color: ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: mono(15, color: inkFaint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class PixelDialog extends StatelessWidget {
  const PixelDialog({
    super.key,
    required this.title,
    required this.child,
    this.width = 380,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final double width;
  final List<Widget> actions;

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
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: display(30, color: ink)),
              const SizedBox(height: 14),
              child,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}