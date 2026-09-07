import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';
import 'date_editor.dart';
import 'pixel_ui.dart';

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
    this.deleted = false,
  });

  final String text;
  final DateTime? start;
  final DateTime? end;
  final bool deleted;
}

Future<TaskEditResult?> showTaskDialog(BuildContext context, Task task) {
  return showDialog<TaskEditResult>(
    context: context,
    barrierColor: ink.withValues(alpha: 0.35),
    builder: (_) => _TaskDialog(task: task),
  );
}

class _TaskDialog extends StatefulWidget {
  const _TaskDialog({required this.task});
  final Task task;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final _controller = TextEditingController(text: widget.task.text);
  late DateTime? _start = widget.task.start;
  late DateTime? _end = widget.task.end;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(
      TaskEditResult(text: text, start: _start, end: _end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PixelDialog(
      title: 'Editar tarea',
      width: 420,
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