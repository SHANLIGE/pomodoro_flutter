import 'package:flutter/material.dart';
import '../date_utils.dart';
import '../theme.dart';
import 'pixel_box.dart';
/// Editor de fechas embebido, al estilo Notion: calendario siempre visible,
/// más interruptores para incluir hora y para convertirlo en rango.
class DateEditor extends StatefulWidget {
  const DateEditor({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
  });

  final DateTime? start;
  final DateTime? end;
  final void Function(DateTime? start, DateTime? end) onChanged;

  @override
  State<DateEditor> createState() => _DateEditorState();
}

class _DateEditorState extends State<DateEditor> {
  late DateTime? _start = widget.start;
  late DateTime? _end = widget.end;
  late DateTime _month = DateTime(
    (_start ?? _end ?? DateTime.now()).year,
    (_start ?? _end ?? DateTime.now()).month,
  );

  late bool _hasEnd = widget.end != null;
  late bool _withTime = _anyHasTime();

  bool _anyHasTime() {
    final s = widget.start, e = widget.end;
    return (s != null && (s.hour != 0 || s.minute != 0)) ||
        (e != null && (e.hour != 0 || e.minute != 0));
  }

  void _emit() => widget.onChanged(_start, _hasEnd ? _end : null);

  /// Con rango activo, el primer toque fija el inicio y el segundo el fin.
  /// Tocar antes del inicio reinicia la selección.
  void _tapDay(DateTime day) {
    setState(() {
      final h = _withTime ? (_start?.hour ?? 9) : 0;
      final m = _withTime ? (_start?.minute ?? 0) : 0;
      final picked = withTime(day, h, m);

      if (!_hasEnd) {
        _start = picked;
        _end = null;
      } else if (_start == null || _end != null || picked.isBefore(_start!)) {
        _start = picked;
        _end = null;
      } else {
        _end = withTime(day, _withTime ? 17 : 0, 0);
      }
    });
    _emit();
  }

  void _toggleTime(bool on) {
    setState(() {
      _withTime = on;
      if (!on) {
        if (_start != null) _start = dayOnly(_start!);
        if (_end != null) _end = dayOnly(_end!);
      } else {
        if (_start != null) _start = withTime(_start!, 9, 0);
        if (_end != null) _end = withTime(_end!, 17, 0);
      }
    });
    _emit();
  }

  void _toggleRange(bool on) {
    setState(() {
      _hasEnd = on;
      if (!on) {
        _end = null;
      } else if (_start != null && _end == null) {
        _end = withTime(_start!, _withTime ? 17 : 0, 0);
      }
    });
    _emit();
  }

  void _clear() {
    setState(() {
      _start = null;
      _end = null;
      _hasEnd = false;
    });
    _emit();
  }

  void _quick(DateTime day) {
    setState(() {
      _month = DateTime(day.year, day.month);
      _start = withTime(day, _withTime ? 9 : 0, 0);
      if (!_hasEnd) _end = null;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _summary(),
        const SizedBox(height: 12),
        _grid(),
        const SizedBox(height: 12),
        _SwitchRow(
          label: 'Incluir hora',
          value: _withTime,
          onChanged: _toggleTime,
        ),
        const SizedBox(height: 6),
        _SwitchRow(
          label: 'Fecha de fin',
          value: _hasEnd,
          onChanged: _toggleRange,
        ),
        if (_withTime && _start != null) ...[
          const SizedBox(height: 10),
          _TimeRow(
            label: 'Desde',
            value: _start!,
            onChanged: (d) {
              setState(() => _start = d);
              _emit();
            },
          ),
        ],
        if (_withTime && _hasEnd && _end != null) ...[
          const SizedBox(height: 6),
          _TimeRow(
            label: 'Hasta',
            value: _end!,
            onChanged: (d) {
              setState(() => _end = d);
              _emit();
            },
          ),
        ],
      ],
    );
  }

  Widget _summary() {
    final today = dayOnly(DateTime.now());
    return Row(
      children: [
        Expanded(
          child: Text(
            _start == null
                ? 'Sin fecha'
                : _end == null
                    ? fmtLong(_start!) + (_withTime ? ' · ${hhmm(_start!)}' : '')
                    : '${fmtDate(_start!)} → ${fmtDate(_end!)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: mono(13, color: _start == null ? inkFaint : ink),
          ),
        ),
        _MiniChip(label: 'Hoy', onTap: () => _quick(today)),
        const SizedBox(width: 6),
        _MiniChip(
          label: 'Mañana',
          onTap: () => _quick(today.add(const Duration(days: 1))),
        ),
        const SizedBox(width: 6),
        _MiniChip(label: 'Borrar', onTap: _clear, danger: true),
      ],
    );
  }

  Widget _grid() {
    final days = monthGrid(_month);

    return PixelBox(
      fill: Colors.white,
      border: line,
      borderWidth: 1.5,
      unit: 2,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        children: [
          Row(
            children: [
              _arrow('◀', () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1),
                  )),
              Expanded(
                child: Center(
                  child: Text(
                    '${monthNames[_month.month - 1]} ${_month.year}',
                    style: display(22, color: ink),
                  ),
                ),
              ),
              _arrow('▶', () => setState(
                    () => _month = DateTime(_month.year, _month.month + 1),
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final w in weekdayShort)
                Expanded(
                  child: Center(
                    child: Text(w, style: mono(10, color: inkFaint)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var r = 0; r < 6; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++) Expanded(child: _cell(days[r * 7 + c])),
              ],
            ),
        ],
      ),
    );
  }

  Widget _arrow(String glyph, VoidCallback onTap) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(glyph, style: mono(11, color: inkMuted)),
          ),
        ),
      );

  Widget _cell(DateTime day) {
    final outside = !sameMonth(day, _month);
    final isStart = _start != null && sameDay(day, _start!);
    final isEnd = _end != null && sameDay(day, _end!);
    final inRange = _start != null &&
        _end != null &&
        day.isAfter(_start!) &&
        day.isBefore(_end!);
    final isToday = sameDay(day, DateTime.now());

    final selected = isStart || isEnd;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _tapDay(day),
        child: SizedBox(
          height: 32,
          child: Center(
            child: PixelBox(
              fill: selected
                  ? greenBright
                  : (inRange ? greenSoft : Colors.transparent),
              border: selected
                  ? green
                  : (isToday ? greenBorder : Colors.transparent),
              borderWidth: 1.2,
              unit: 2,
              child: SizedBox(
                width: 28,
                height: 26,
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: mono(
                      11,
                      color: selected
                          ? Colors.white
                          : (outside ? inkFaint : ink),
                      weight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatefulWidget {
  const _MiniChip({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  State<_MiniChip> createState() => _MiniChipState();
}

class _MiniChipState extends State<_MiniChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tone = widget.danger ? projectRed : green;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: PixelBox(
          fill: _hover ? (widget.danger ? dangerSoft : greenSoft) : cream,
          border: line,
          borderWidth: 1.2,
          unit: 2,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            widget.label,
            style: mono(11, color: _hover ? tone : inkMuted),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            // Interruptor de dos posiciones, dibujado con cajas escalonadas.
            PixelBox(
              fill: value ? greenSoft : cream,
              border: value ? greenBorder : line,
              borderWidth: 1.5,
              unit: 2,
              child: SizedBox(
                width: 34,
                height: 18,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 140),
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 13,
                      height: 13,
                      color: value ? greenBright : inkFaint,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: mono(13, color: ink)),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 58, child: Text(label, style: mono(12, color: inkMuted))),
        _Stepper(
          text: value.hour.toString().padLeft(2, '0'),
          onUp: () => onChanged(withTime(value, (value.hour + 1) % 24, value.minute)),
          onDown: () =>
              onChanged(withTime(value, (value.hour + 23) % 24, value.minute)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(':', style: mono(13, color: inkMuted)),
        ),
        _Stepper(
          text: value.minute.toString().padLeft(2, '0'),
          onUp: () =>
              onChanged(withTime(value, value.hour, (value.minute + 5) % 60)),
          onDown: () =>
              onChanged(withTime(value, value.hour, (value.minute + 55) % 60)),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.text,
    required this.onUp,
    required this.onDown,
  });

  final String text;
  final VoidCallback onUp, onDown;

  @override
  Widget build(BuildContext context) {
    return PixelBox(
      fill: Colors.white,
      border: line,
      borderWidth: 1.2,
      unit: 2,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: display(22, color: ink)),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tick('▴', onUp),
              _tick('▾', onDown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tick(String glyph, VoidCallback onTap) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: 12,
            child: Text(glyph, style: mono(9, color: inkMuted)),
          ),
        ),
      );
}