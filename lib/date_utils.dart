const monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const weekdayShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

String fmtDate(DateTime d) =>
    '${d.day} ${monthNames[d.month - 1].toLowerCase()}';

String fmtLong(DateTime d) =>
    '${d.day} de ${monthNames[d.month - 1].toLowerCase()} ${d.year}';

String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

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