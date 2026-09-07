import 'date_utils.dart';

class Task {
  Task({
    required this.id,
    required this.text,
    this.projectId,
    this.start,
    this.end,
  });

  final int id;
  String text;
  int? projectId;
  DateTime? start;
  DateTime? end;
  bool done = false;

  bool get hasSchedule => start != null || end != null;

  DateTime? get anchorDay {
    final d = start ?? end;
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// Etiqueta corta que se muestra en la fila.
  String? get scheduleLabel {
    if (start != null && end != null) {
      // Mismo día: no repetimos la fecha, solo la hora de fin.
      return sameDay(start!, end!)
          ? '${fmtDateTime(start!)} – ${hhmm(end!)}'
          : '${fmtDate(start!)} → ${fmtDate(end!)}';
    }
    if (end != null) return 'Vence ${fmtDateTime(end!)}';
    if (start != null) return fmtDateTime(start!);
    return null;
  }
}