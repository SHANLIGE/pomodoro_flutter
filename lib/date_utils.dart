import 'package:intl/intl.dart';

const monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const weekdayShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

/// Formato corto con día de la semana: "mar, 13 sept".
String fmtDate(DateTime d) => DateFormat("EEE, d MMM", 'es').format(d);

/// El mismo, con año: "mar, 13 sept 2026".
String fmtLong(DateTime d) => DateFormat("EEE, d MMM y", 'es').format(d);

String hhmm(DateTime d) => DateFormat.Hm('es').format(d);

/// Fecha con hora si la tiene: "mar, 13 sept · 09:00".
String fmtDateTime(DateTime d) {
  final hasTime = d.hour != 0 || d.minute != 0;
  return hasTime ? '${fmtDate(d)} · ${hhmm(d)}' : fmtDate(d);
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 42 celdas (6 semanas) empezando en lunes. Incluye días de los meses
/// vecinos, que se pintan atenuados — como hace Notion.
List<DateTime> monthGrid(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final offset = first.weekday - 1; // lunes = 0
  return List.generate(
    42,
    (i) => DateTime(first.year, first.month, first.day - offset + i),
  );
}

/// Copia una fecha cambiando solo la hora.
DateTime withTime(DateTime date, int hour, int minute) =>
    DateTime(date.year, date.month, date.day, hour, minute);