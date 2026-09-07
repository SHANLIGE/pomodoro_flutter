import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';
import 'pixel_box.dart';
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

  /// Pide primero el día y luego la hora. Si se cancela la hora, queda como
  /// fecha sin hora, útil para un vencimiento de día completo.
  Future<DateTime?> _pick(DateTime? initial) async {
    final base = initial ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    if (!mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
          _DateRow(
            label: 'Inicio',
            value: _start,
            onPick: () async {
              final d = await _pick(_start);
              if (d != null) setState(() => _start = d);
            },
            onClear: () => setState(() => _start = null),
          ),
          const SizedBox(height: 8),
          _DateRow(
            label: 'Vence',
            value: _end,
            onPick: () async {
              final d = await _pick(_end);
              if (d != null) setState(() => _end = d);
            },
            onClear: () => setState(() => _end = null),
          ),
          const SizedBox(height: 10),
          Text(
            'Deja el inicio vacío si solo quieres una fecha de vencimiento.',
            style: mono(12, color: inkFaint),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick, onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(label, style: mono(14, color: inkMuted)),
        ),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onPick,
              child: PixelBox(
                fill: Colors.white,
                border: value != null ? greenBorder : line,
                borderWidth: 1.5,
                unit: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  value != null ? Task.fmtShort(value!) : 'Sin fecha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(14, color: value != null ? ink : inkFaint),
                ),
              ),
            ),
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text('✕', style: mono(13, color: inkMuted)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}