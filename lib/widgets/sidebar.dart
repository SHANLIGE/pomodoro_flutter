import 'package:flutter/material.dart';

import '../theme.dart';
import 'app_icon.dart';
import 'pixel_box.dart';

/// Enum con datos adjuntos (Dart 3): cada sección lleva su etiqueta e icono.
enum AppSection {
  hoy('Hoy', 'today'),
  completadas('Completadas', 'complete'),
  todas('Todas', 'all'),
  calendario('Calendario', 'calendar');

  const AppSection(this.label, this.image);
  final String label;
  final String image;
}

enum ProjectAction { rename, pin, delete }

class Project {
  Project(this.id, this.name, this.color, {this.pinned = false});

  final int id;
  String name; // mutable: se puede renombrar
  final Color color;
  bool pinned;
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
    required this.onProjectAction,
    required this.onOpenSettings,
    required this.settingsOpen,
  });

  final AppSection current;
  final ValueChanged<AppSection> onSelect;
  final List<Project> projects;
  final int? currentProject;
  final ValueChanged<int> onSelectProject;
  final VoidCallback onAddProject;
  final void Function(Project project, ProjectAction action) onProjectAction;
  final VoidCallback onOpenSettings;
  final bool settingsOpen;

  /// Los fijados suben al principio conservando su orden relativo.
  List<Project> get _sorted {
    final pinned = projects.where((p) => p.pinned).toList();
    final rest = projects.where((p) => !p.pinned).toList();
    return [...pinned, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final list = _sorted;

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
                      image: s.image,
                      selected: s == current &&
                          currentProject == null &&
                          !settingsOpen,
                      onTap: () => onSelect(s),
                    ),
                  const SizedBox(height: 26),
                  _ProjectsHeader(onAdd: onAddProject),
                  const SizedBox(height: 8),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 4),
                      child: Text(
                        'Sin proyectos aún',
                        style: mono(13, color: inkFaint),
                      ),
                    )
                  else
                    for (var i = 0; i < list.length; i++)
                      _ProjectRow(
                        project: list[i],
                        isLast: i == list.length - 1,
                        selected: currentProject == list[i].id,
                        onTap: () => onSelectProject(list[i].id),
                        onAction: (a) => onProjectAction(list[i], a),
                      ),
                  const SizedBox(height: 190),
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
                    Text(
                      'Ajustes',
                      style: mono(
                        15,
                        color: ink,
                        weight:
                            settingsOpen ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
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
    required this.selected,
    required this.onTap,
  });

  final String label, image;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
  bool _hover = false;

  // size general de los iconos del sidebar
  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          AppIcon(widget.image, size: 38),
          const SizedBox(width: 8),
          // Expanded + ellipsis: etiquetas largas se cortan en vez de desbordar.
          Expanded(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mono(
                17,
                color: ink,
                weight: active ? FontWeight.w700 : FontWeight.w400,
              ),
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
          const AppIcon('projects', size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Proyectos',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mono(15, color: ink, weight: FontWeight.w700),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onAdd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('+', style: mono(20, color: inkMuted)),
              ),
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
    required this.onAction,
  });

  final Project project;
  final bool isLast, selected;
  final VoidCallback onTap;
  final ValueChanged<ProjectAction> onAction;

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

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
                fill: p.color,
                border: ink.withValues(alpha: 0.35),
                borderWidth: 1.5,
                unit: 2,
                child: const SizedBox(width: 20, height: 16),
              ),
              const SizedBox(width: 10),
              if (p.pinned) ...[
                const AppIcon('pin', size: 12),
                const SizedBox(width: 4),
              ],
              // Expanded + ellipsis: nombres largos se cortan.
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(
                    14,
                    color: _hover || widget.selected ? ink : inkMuted,
                    weight: widget.selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _hover ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: IgnorePointer(
                  ignoring: !_hover,
                  child: _ProjectMenu(
                    pinned: p.pinned,
                    onAction: widget.onAction,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectMenu extends StatelessWidget {
  const _ProjectMenu({required this.pinned, required this.onAction});

  final bool pinned;
  final ValueChanged<ProjectAction> onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProjectAction>(
      tooltip: '',
      padding: EdgeInsets.zero,
      splashRadius: 1,
      color: cream,
      elevation: 4,
      // Bevel en vez de curva: más cerca del pixel art que un borde redondo.
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        side: BorderSide(color: line, width: 2),
      ),
      onSelected: onAction,
      itemBuilder: (_) => [
        _item(ProjectAction.rename, 'edit', 'Renombrar'),
        _item(ProjectAction.pin, 'pin', pinned ? 'Desfijar' : 'Fijar'),
        _item(ProjectAction.delete, 'trash', 'Eliminar', danger: true),
      ],
      child: SizedBox(
        width: 28,
        height: 30,
        child: Center(child: Text('⋯', style: mono(18, color: inkMuted))),
      ),
    );
  }

  PopupMenuItem<ProjectAction> _item(
    ProjectAction value,
    String image,
    String label, {
    bool danger = false,
  }) {
    return PopupMenuItem<ProjectAction>(
      value: value,
      height: 40,
      child: Row(
        children: [
          AppIcon(image, size: 16),
          const SizedBox(width: 10),
          Text(label, style: mono(14, color: danger ? projectRed : ink)),
        ],
      ),
    );
  }
}