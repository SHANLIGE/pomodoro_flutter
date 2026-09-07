import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';
import 'date_editor.dart';
import 'pixel_box.dart';
import 'pixel_ui.dart';
import 'sidebar.dart';
// ------------------------------------------------------------- nombre

/// Sirve para crear y para renombrar: cambian el título y el valor inicial.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = 'Nombre',
}) {
  return showDialog<String>(
    context: context,
    barrierColor: ink.withValues(alpha: 0.35),
    builder: (_) => _NameDialog(title: title, initial: initial, hint: hint),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.initial,
    required this.hint,
  });

  final String title, initial, hint;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _controller.text.trim();
    if (v.isEmpty) return;
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    return PixelDialog(
      title: widget.title,
      actions: [
        const Spacer(),
        PixelButton(
          label: 'Cancelar',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
        PixelButton(label: 'Guardar', filled: true, onTap: _submit),
      ],
      child: PixelField(
        controller: _controller,
        hint: widget.hint,
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}

// ----------------------------------------------------------- confirmar

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Eliminar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: ink.withValues(alpha: 0.35),
    builder: (ctx) => PixelDialog(
      title: title,
      width: 400,
      actions: [
        const Spacer(),
        PixelButton(
          label: 'Cancelar',
          onTap: () => Navigator.of(ctx).pop(false),
        ),
        const SizedBox(width: 10),
        PixelButton(
          label: confirmLabel,
          filled: true,
          danger: true,
          onTap: () => Navigator.of(ctx).pop(true),
        ),
      ],
      child: Text(message, style: mono(14, color: inkMuted)),
    ),
  );
  return result ?? false;
}

// --------------------------------------------------------- editar tarea
class TaskEditResult {
  TaskEditResult({
    required this.text,
    this.start,
    this.end,
    this.projectId,
    this.deleted = false,
  });

  final String text;
  final DateTime? start;
  final DateTime? end;
  final int? projectId;
  final bool deleted;
}

Future<TaskEditResult?> showTaskDialog(
  BuildContext context,
  Task task, {
  required List<Project> projects,
  required Future<Project?> Function() onCreateProject,
}) {
  return showDialog<TaskEditResult>(
    context: context,
    barrierColor: ink.withValues(alpha: 0.35),
    builder: (_) => _TaskDialog(
      task: task,
      projects: projects,
      onCreateProject: onCreateProject,
    ),
  );
}

class _TaskDialog extends StatefulWidget {
  const _TaskDialog({
    required this.task,
    required this.projects,
    required this.onCreateProject,
  });

  final Task task;
  final List<Project> projects;
  final Future<Project?> Function() onCreateProject;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final _controller = TextEditingController(text: widget.task.text);
  late DateTime? _start = widget.task.start;
  late DateTime? _end = widget.task.end;
  late int? _projectId = widget.task.projectId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(
      TaskEditResult(
        text: text,
        start: _start,
        end: _end,
        projectId: _projectId,
      ),
    );
  }

  /// Abre el diálogo de nombre encima de este y selecciona el resultado.
  Future<void> _createProject() async {
    final project = await widget.onCreateProject();
    if (project == null) return;
    setState(() => _projectId = project.id);
  }

  @override
  Widget build(BuildContext context) {
    return PixelDialog(
      title: 'Editar tarea',
      width: 440,
      actions: [
        PixelButton(
          label: 'Eliminar',
          danger: true,
          onTap: () => Navigator.of(context).pop(
            TaskEditResult(text: widget.task.text, deleted: true),
          ),
        ),
        const Spacer(),
        PixelButton(
          label: 'Cancelar',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
        PixelButton(label: 'Guardar', filled: true, onTap: _save),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PixelField(
            controller: _controller,
            hint: 'Descripción',
            autofocus: true,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          _ProjectPicker(
            projects: widget.projects,
            selected: _projectId,
            onSelect: (id) => setState(() => _projectId = id),
            onCreate: _createProject,
          ),
          const SizedBox(height: 16),
          // El editor avisa en cada cambio; el diálogo solo guarda el estado.
          DateEditor(
            start: _start,
            end: _end,
            onChanged: (s, e) {
              _start = s;
              _end = e;
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({
    required this.projects,
    required this.selected,
    required this.onSelect,
    required this.onCreate,
  });

  final List<Project> projects;
  final int? selected;
  final ValueChanged<int?> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proyecto', style: mono(12, color: inkMuted)),
        const SizedBox(height: 8),
        // Wrap en vez de Row: con muchos proyectos pasa a la línea siguiente.
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _ProjectChip(
              label: 'Sin proyecto',
              active: selected == null,
              onTap: () => onSelect(null),
            ),
            for (final p in projects)
              _ProjectChip(
                label: p.name,
                color: p.color,
                active: selected == p.id,
                onTap: () => onSelect(p.id),
              ),
            _ProjectChip(
              label: '+ Nuevo',
              active: false,
              dashed: true,
              onTap: onCreate,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectChip extends StatefulWidget {
  const _ProjectChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
    this.dashed = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;
  final bool dashed;

  @override
  State<_ProjectChip> createState() => _ProjectChipState();
}

class _ProjectChipState extends State<_ProjectChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.color ?? green;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: PixelBox(
          fill: widget.active
              ? accent.withValues(alpha: 0.18)
              : (_hover ? greenSoft.withValues(alpha: 0.5) : cream),
          border: widget.active ? accent : line,
          borderWidth: widget.active ? 2 : 1.2,
          unit: 2,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.color != null) ...[
                Container(width: 10, height: 10, color: widget.color),
                const SizedBox(width: 7),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(
                    12,
                    color: widget.active ? ink : inkMuted,
                    weight:
                        widget.active ? FontWeight.w700 : FontWeight.w400,
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