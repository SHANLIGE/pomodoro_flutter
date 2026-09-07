import 'package:flutter/material.dart';
import '../date_utils.dart';
import '../task.dart';
import '../theme.dart';
import 'pixel_box.dart';

/// Vista mensual estilo Notion: las tareas se ven dentro de su día,
/// no como puntos. Cada celda crece con el alto disponible.
class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    required this.tasks,
    required this.colorOf,
    required this.onEdit,
    required this.onAddOnDate,
  });

  final List<Task> tasks;
  final Color Function(Task) colorOf;
  final void Function(Task task) onEdit;
  final void Function(DateTime day) onAddOnDate;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  /// Una tarea con rango aparece en todos los días que abarca.
  Map<DateTime, List<Task>> get _byDay {
    final map = <DateTime, List<Task>>{};
    for (final t in widget.tasks) {
      final s = t.start ?? t.end;
      if (s == null) continue;
      final from = dayOnly(s);
      final to = t.end == null ? from : dayOnly(t.end!);
      var d = from;
      while (!d.isAfter(to)) {
        map.putIfAbsent(d, () => []).add(t);
        d = DateTime(d.year, d.month, d.day + 1);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final byDay = _byDay;
    final days = monthGrid(_month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final w in weekdayShort)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(w, style: mono(11, color: inkFaint)),
                ),
              ),
          ],
        ),
        Expanded(
          child: PixelBox(
            fill: cream,
            border: line,
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                for (var r = 0; r < 6; r++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var c = 0; c < 7; c++)
                          Expanded(child: _cell(days[r * 7 + c], byDay)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        Text(
          '${monthNames[_month.month - 1]} ${_month.year}',
          style: display(30, color: ink),
        ),
        const SizedBox(width: 14),
        _navBtn('◀', () => setState(
              () => _month = DateTime(_month.year, _month.month - 1),
            )),
        const SizedBox(width: 4),
        _navBtn('▶', () => setState(
              () => _month = DateTime(_month.year, _month.month + 1),
            )),
        const SizedBox(width: 8),
        _navBtn('Hoy', () {
          final n = DateTime.now();
          setState(() => _month = DateTime(n.year, n.month));
        }, wide: true),
      ],
    );
  }

  Widget _navBtn(String label, VoidCallback onTap, {bool wide = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: PixelBox(
          fill: cream,
          border: line,
          borderWidth: 1.5,
          unit: 2,
          padding: EdgeInsets.symmetric(horizontal: wide ? 12 : 9, vertical: 7),
          child: Text(label, style: mono(12, color: inkMuted)),
        ),
      ),
    );
  }

  Widget _cell(DateTime day, Map<DateTime, List<Task>> byDay) {
    final outside = !sameMonth(day, _month);
    final isToday = sameDay(day, DateTime.now());
    final tasks = byDay[day] ?? [];

    return _DayCell(
      day: day,
      outside: outside,
      isToday: isToday,
      tasks: tasks,
      colorOf: widget.colorOf,
      onEdit: widget.onEdit,
      onAdd: () => widget.onAddOnDate(day),
    );
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.outside,
    required this.isToday,
    required this.tasks,
    required this.colorOf,
    required this.onEdit,
    required this.onAdd,
  });

  final DateTime day;
  final bool outside, isToday;
  final List<Task> tasks;
  final Color Function(Task) colorOf;
  final void Function(Task) onEdit;
  final VoidCallback onAdd;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: widget.outside
              ? creamSidebar.withValues(alpha: 0.4)
              : (_hover ? greenSoft.withValues(alpha: 0.35) : Colors.transparent),
          border: Border.all(color: line.withValues(alpha: 0.6)),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (widget.isToday)
                  PixelBox(
                    fill: greenBright,
                    border: green,
                    borderWidth: 1.2,
                    unit: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    child: Text(
                      '${widget.day.day}',
                      style: mono(11, color: Colors.white,
                          weight: FontWeight.w700),
                    ),
                  )
                else
                  Text(
                    '${widget.day.day}',
                    style: mono(
                      11,
                      color: widget.outside ? inkFaint : inkMuted,
                    ),
                  ),
                const Spacer(),
                // El "+" solo aparece al pasar el mouse, como en Notion.
                AnimatedOpacity(
                  opacity: _hover ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: IgnorePointer(
                    ignoring: !_hover,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onAdd,
                        child: Text('+', style: mono(14, color: inkMuted)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                children: [
                  for (final t in widget.tasks)
                    _Chip(
                      task: t,
                      color: widget.colorOf(t),
                      onTap: () => widget.onEdit(t),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatefulWidget {
  const _Chip({required this.task, required this.color, required this.onTap});

  final Task task;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          color: _hover
              ? widget.color.withValues(alpha: 0.28)
              : widget.color.withValues(alpha: 0.16),
          child: Row(
            children: [
              Container(width: 3, height: 11, color: widget.color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  t.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(
                    10,
                    color: t.done ? inkFaint : ink,
                  ).copyWith(
                    decoration: t.done ? TextDecoration.lineThrough : null,
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