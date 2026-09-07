class Task {
  Task({
    required this.id,
    required this.text,
    this.projectId,
    this.start,
    this.end,
  });

  final int id;
  String text; // mutable: se puede editar
  int? projectId;
  DateTime? start; // inicio opcional
  DateTime? end; // fin o vencimiento
  bool done = false;

  bool get hasSchedule => start != null || end != null;

  /// Día al que pertenece en el calendario.
  DateTime? get anchorDay {
    final d = start ?? end;
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// Etiqueta corta que se muestra en la fila.
  String? get scheduleLabel {
    if (start != null && end != null) {
      return _sameDay(start!, end!)
          ? '${fmtShort(start!)} – ${_hhmm(end!)}'
          : '${fmtShort(start!)} → ${fmtShort(end!)}';
    }
    if (end != null) return 'Vence ${fmtShort(end!)}';
    if (start != null) return fmtShort(start!);
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  static String fmtShort(DateTime d) {
    final day = '${d.day}/${d.month}';
    final hasTime = d.hour != 0 || d.minute != 0;
    return hasTime ? '$day ${_hhmm(d)}' : day;
  }
}