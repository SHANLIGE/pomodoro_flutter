import 'package:flutter/material.dart';

import '../theme.dart';
import 'app_icon.dart';
import 'pixel_box.dart';

/// Enum con datos adjuntos (Dart 3): cada sección lleva su etiqueta e icono.
enum AppSection {
  hoy('Hoy', 'trash'),
  completadas('Completadas', '✅'),
  todas('Todas', '📄'),
  calendario('Calendario', '📅');

  const AppSection(this.label, this.image);
  final String label;
  final String image;
}

class Project {
  Project(this.id, this.name, this.color);
  final int id;
  final String name;
  final Color color;
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.current,
    required this.onSelect,
    required this.projects,
    required this.currentProject,
    required this.onSelectProject,
    required this.onAddProject,
    required this.onOpenSettings,
  });

  final AppSection current;
  final ValueChanged<AppSection> onSelect;
  final List<Project> projects;
  final int? currentProject;
  final ValueChanged<int> onSelectProject;
  final VoidCallback onAddProject;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: creamSidebar,
        border: Border(right: BorderSide(color: line, width: 2)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 12),
                    child: Text(
                      'SECCIONES',
                      style: mono(
                        13,
                        color: green,
                        weight: FontWeight.w700,
                        spacing: 1.6,
                      ),
                    ),
                  ),
                  for (final s in AppSection.values)
                    _NavRow(
                      label: s.label,
                      emoji: '',
                      image: s.image,
                      selected: s == current && currentProject == null,
                      onTap: () => onSelect(s),
                    ),
                  const SizedBox(height: 26),
                  _ProjectsHeader(onAdd: onAddProject),
                  const SizedBox(height: 8),
                  for (var i = 0; i < projects.length; i++)
                    _ProjectRow(
                      project: projects[i],
                      isLast: i == projects.length - 1,
                      selected: currentProject == projects[i].id,
                      onTap: () => onSelectProject(projects[i].id),
                    ),
                  const SizedBox(height: 180),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PixelScene('shelf'),
          ),
          Positioned(
            left: 22,
            bottom: 120,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onOpenSettings,
                child: Row(
                  children: [
                    const AppIcon('gear', size: 22),
                    const SizedBox(width: 10),
                    Text('Ajustes', style: mono(15, color: ink)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatefulWidget {
  const _NavRow({
    required this.label,
    required this.image,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label, image, emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          AppIcon(widget.image, size: 22),
          const SizedBox(width: 12),
          Text(
            widget.label,
            style: mono(
              15,
              color: ink,
              weight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: active
              ? PixelBox(fill: greenSoft, border: greenBorder, child: body)
              : Container(
                  color: _hover
                      ? line.withValues(alpha: 0.35)
                      : Colors.transparent,
                  child: body,
                ),
        ),
      ),
    );
  }
}

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      fill: cream,
      border: line,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          const AppIcon('folder', size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Proyects',
              style: mono(15, color: ink, weight: FontWeight.w700),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onAdd,
              child: Text('+', style: mono(20, color: inkMuted)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Guía punteada vertical con la ramita horizontal hacia cada proyecto.
class _TreePainter extends CustomPainter {
  _TreePainter({required this.isLast});
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = inkFaint
      ..strokeWidth = 1.4;
    final midY = size.height / 2;
    const x = 8.0;

    final end = isLast ? midY : size.height;
    for (double y = 0; y < end; y += 5) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + 2.5).clamp(0, end)), p);
    }
    for (double dx = x; dx < size.width; dx += 5) {
      canvas.drawLine(Offset(dx, midY), Offset(dx + 2.5, midY), p);
    }
  }

  @override
  bool shouldRepaint(_TreePainter old) => old.isLast != isLast;
}

class _ProjectRow extends StatefulWidget {
  const _ProjectRow({
    required this.project,
    required this.isLast,
    required this.selected,
    required this.onTap,
  });

  final Project project;
  final bool isLast, selected;
  final VoidCallback onTap;

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 40,
                child: CustomPaint(
                  painter: _TreePainter(isLast: widget.isLast),
                ),
              ),
              PixelBox(
                fill: widget.project.color,
                border: ink.withValues(alpha: 0.35),
                borderWidth: 1.5,
                unit: 2,
                child: const SizedBox(width: 20, height: 16),
              ),
              const SizedBox(width: 10),
              Text(
                widget.project.name,
                style: mono(
                  14,
                  color: _hover || widget.selected ? ink : inkMuted,
                  weight: widget.selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
