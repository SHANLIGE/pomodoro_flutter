import 'package:flutter/material.dart';
import '../theme.dart';

/// Enum "mejorado" de Dart 3: lleva datos adjuntos, no solo un nombre.
enum AppSection {
  hoy('Hoy', Icons.wb_twilight_outlined),
  completadas('Completadas', Icons.done_all_rounded),
  todas('Todas', Icons.inbox_outlined),
  ajustes('Ajustes', Icons.tune_rounded);

  const AppSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.current,
    required this.onSelect,
    required this.counts,
  });

  final AppSection current;
  final ValueChanged<AppSection> onSelect;
  final Map<AppSection, int> counts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarWidth,
      color: sidebarColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 14),
            child: Text(
              'SECCIONES',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: textColorDone,
              ),
            ),
          ),
          for (final section in AppSection.values)
            _SidebarItem(
              section: section,
              selected: section == current,
              count: counts[section],
              onTap: () => onSelect(section),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final fg = active ? secondaryColor : textColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: active
                ? primaryColor.withValues(alpha: 0.45)
                : (_hover ? hoverSurface : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.section.icon, size: 17, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.section.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: fg,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (widget.count != null && widget.count! > 0)
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? secondaryColor : textColorDone,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}