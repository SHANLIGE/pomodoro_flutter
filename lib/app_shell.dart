import 'dart:async';
import 'package:flutter/material.dart';

import 'task.dart';
import 'theme.dart';
import 'widgets/sidebar.dart';
import 'widgets/task_list.dart';
import 'widgets/timer_bar.dart';
import 'widgets/title_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _tasks = <Task>[];
  final _input = TextEditingController();
  int _nextId = 0;

  AppSection _section = AppSection.hoy;

  final _minCtrl = FixedExtentScrollController(initialItem: 25);
  final _secCtrl = FixedExtentScrollController(initialItem: 0);
  bool _pickerOpen = false;

  int _totalSeconds = 25 * 60;
  int _remaining = 25 * 60;
  Timer? _ticker;

  bool get _running => _ticker != null;

  @override
  void dispose() {
    _ticker?.cancel();
    _input.dispose();
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  // --- Tareas ---

  List<Task> get _pending => _tasks.where((t) => !t.done).toList();
  List<Task> get _done => _tasks.where((t) => t.done).toList();
  List<Task> get _ordered => [..._pending, ..._done];

  void _addTask(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    setState(() => _tasks.add(Task(id: _nextId++, text: text)));
    _input.clear();
  }

  // --- Timer ---

  void _syncDuration() {
    setState(() {
      _totalSeconds = _minCtrl.selectedItem * 60 + _secCtrl.selectedItem;
      _remaining = _totalSeconds;
    });
  }

  void _toggleRun() {
    if (_running) {
      _ticker!.cancel();
      setState(() => _ticker = null);
      return;
    }
    if (_remaining == 0) return;
    setState(() => _pickerOpen = false);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() {
          _ticker = null;
          _remaining = 0;
        });
      } else {
        setState(() => _remaining--);
      }
    });
    setState(() {});
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _ticker = null;
      _remaining = _totalSeconds;
    });
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Sidebar(
                  current: _section,
                  onSelect: (s) => setState(() => _section = s),
                  counts: {
                    AppSection.hoy: _pending.length,
                    AppSection.completadas: _done.length,
                    AppSection.todas: _tasks.length,
                  },
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // El timer vive en el shell, así aparece en todas las secciones
          // y sigue corriendo aunque cambies de una a otra.
          TimerBar(
            remaining: _remaining,
            total: _totalSeconds,
            running: _running,
            pickerOpen: _pickerOpen,
            minCtrl: _minCtrl,
            secCtrl: _secCtrl,
            onToggleRun: _toggleRun,
            onReset: _reset,
            onTapTime: () => setState(() => _pickerOpen = !_pickerOpen),
            onDurationChanged: _syncDuration,
          ),
          const SizedBox(height: 22),
          Expanded(child: _buildSection()),
        ],
      ),
    );
  }

  Widget _buildSection() {
    if (_section == AppSection.ajustes) {
      return const Center(
        child: Text(
          'Aquí van las preferencias.',
          style: TextStyle(color: textColorTertiary, fontSize: 14),
        ),
      );
    }

    final showInput = _section != AppSection.completadas;
    final tasks = switch (_section) {
      AppSection.hoy => _pending,
      AppSection.completadas => _done,
      _ => _ordered,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _section.label,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (showInput) ...[
          const SizedBox(height: 4),
          TextField(
            controller: _input,
            autofocus: true,
            onEditingComplete: () => _addTask(_input.text),
            style: const TextStyle(color: textColor, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Escribe y presiona Enter',
              hintStyle: TextStyle(color: textColorDone),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const Divider(height: 1, color: dividerColor),
        ],
        const SizedBox(height: 10),
        Expanded(
          child: TaskList(
            tasks: tasks,
            onToggle: (task, done) => setState(() => task.done = done),
            emptyTitle: _section == AppSection.completadas
                ? 'Nada completado aún'
                : 'Sin tareas',
            emptyHint: _section == AppSection.completadas
                ? 'Marca una tarea para verla aquí.'
                : 'Escribe arriba para agregar la primera.',
          ),
        ),
      ],
    );
  }
}