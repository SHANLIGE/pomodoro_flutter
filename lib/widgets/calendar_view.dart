import 'package:flutter/material.dart';
import '../date_utils.dart';
import '../task.dart';
import '../theme.dart';
import 'pixel_box.dart';
import 'task_row.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onEdit,
  });

  final List<Task> tasks;
  final void Function(Task task, bool done) onToggle;
  final void Function(Task task) onEdit;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = dayOnly(DateTime.now());

  /// Agrupa las tareas con fecha por día, para pintar los puntos.
  Map<DateTime, List<Task>> get _byDay {
    final map = <DateTime, List<Task>>{};
    for (final t in widget.tasks) {
      final day = t.anchorDay;
      if (day == null) continue;
      map.putIfAbsent(day, () => []).add(t);
    }
    return map;
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final byDay = _byDay;
    final dayTasks = byDay[_selected] ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 380, child: _grid(byDay)),
        const SizedBox(width: 28),
        Expanded(child: _dayPanel(dayTasks)),
      ],
    );
  }

  Widget _grid(Map<DateTime, List<Task>> byDay) {
    // weekday: 1=lunes ... 7=domingo. Restamos 1 para el offset de la grilla.
    final first = DateTime(_month.year, _month.month, 1);
    final offset = first.weekday - 1;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((offset + daysInMonth) / 7).ceil();

    return PixelBox(
      fill: cream,
      border: line,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _arrow('◀', () => _shiftMonth(-1)),
              Expanded(
                child: Center(
                  child: Text(
                    '${monthNames[_month.month - 1]} ${_month.year}',
                    style: display(26, color: ink),
                  ),
                ),
              ),
              _arrow('▶', () => _shiftMonth(1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final w in weekdayShort)
                Expanded(
                  child: Center(
                    child: Text(w, style: mono(11, color: inkFaint)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(child: _cell(r * 7 + c - offset + 1, byDay)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _arrow(String glyph, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(glyph, style: mono(13, color: inkMuted)),
        ),
      ),
    );
  }

  Widget _cell(int day, Map<DateTime, List<Task>> byDay) {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    if (day < 1 || day > daysInMonth) return const SizedBox(height: 44);

    final date = DateTime(_month.year, _month.month, day);
    final isSelected = sameDay(date, _selected);
    final isToday = sameDay(date, DateTime.now());
    final count = byDay[date]?.length ?? 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selected = date),
        child: SizedBox(
          height: 44,
          child: Center(
            child: PixelBox(
              fill: isSelected ? greenSoft : Colors.transparent,
              border: isSelected
                  ? greenBorder
                  : (isToday ? inkFaint : Colors.transparent),
              borderWidth: 1.5,
              unit: 2,
              child: SizedBox(
                width: 38,
                height: 38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: mono(
                        13,
                        color: isSelected ? green : ink,
                        weight: isToday ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 4,
                      child: count == 0
                          ? null
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < count.clamp(1, 3); i++)
                                  Container(
                                    width: 3,
                                    height: 3,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    color: greenBright,
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayPanel(List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(fmtDate(_selected), style: display(28, color: ink)),
        const SizedBox(height: 4),
        Text(
          tasks.isEmpty
              ? 'Sin tareas para este día'
              : '${tasks.length} tarea${tasks.length == 1 ? '' : 's'}',
          style: mono(13, color: inkMuted),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, i) => SizedBox(
              height: taskRowHeight,
              child: TaskRow(
                task: tasks[i],
                onToggle: (v) => widget.onToggle(tasks[i], v),
                onEdit: () => widget.onEdit(tasks[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}