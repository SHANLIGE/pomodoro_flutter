import 'dart:async';

import 'package:flutter/material.dart';

import 'task.dart';
import 'theme.dart';
import 'widgets/app_icon.dart';
import 'widgets/pixel_box.dart';
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
  int? _currentProject;

  final _proyectos = [
    Project(0, 'Project 1', projectPink),
    Project(1, 'Project 2', projectBlue),
    Project(2, 'Project 3', projectRed),
  ];

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

  /// Primero filtra por proyecto, luego la sección decide qué subconjunto.
  List<Task> get _scoped => _currentProject == null
      ? _tasks
      : _tasks.where((t) => t.projectId == _currentProject).toList();

  List<Task> get _visible {
    final base = _scoped;
    return switch (_section) {
      AppSection.hoy => base.where((t) => !t.done).toList(),
      AppSection.completadas => base.where((t) => t.done).toList(),
      _ => [...base.where((t) => !t.done), ...base.where((t) => t.done)],
    };
  }

  void _addTask(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(Task(id: _nextId++, text: text, projectId: _currentProject));
    });
    _input.clear();
  }

  void _deleteTask(Task task) {
    setState(() => _tasks.remove(task));
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

  String get _headerTitle {
    if (_currentProject != null) {
      return _proyectos.firstWhere((p) => p.id == _currentProject).name;
    }
    return _section.label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Sidebar(
                  current: _section,
                  onSelect: (s) => setState(() {
                    _section = s;
                    _currentProject = null;
                  }),
                  projects: _proyectos,
                  currentProject: _currentProject,
                  onSelectProject: (id) => setState(() {
                    _currentProject = id;
                    _section = AppSection.todas;
                  }),
                  onAddProject: () {},
                  onOpenSettings: () {},
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera: título a la izquierda, timer a la derecha.
              // El timer vive aquí, así que sigue corriendo al cambiar
              // de sección o de proyecto.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(_headerTitle, style: display(42)),
                        const SizedBox(width: 8),
                        Text('✦', style: mono(12, color: green)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 20),
                    child: Text('☰', style: mono(20, color: inkMuted)),
                  ),
                  SizedBox(
                    width: 655,
                    child: TimerBar(
                      remaining: _remaining,
                      total: _totalSeconds,
                      running: _running,
                      pickerOpen: _pickerOpen,
                      minCtrl: _minCtrl,
                      secCtrl: _secCtrl,
                      onToggleRun: _toggleRun,
                      onReset: _reset,
                      onTapTime: () =>
                          setState(() => _pickerOpen = !_pickerOpen),
                      onDurationChanged: _syncDuration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_section != AppSection.completadas) ...[
                _inputBox(),
                const SizedBox(height: 26),
              ],
              Expanded(child: _buildSection()),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PixelScene('grass'),
        ),
      ],
    );
  }

  //icono microfono
  Widget _inputBox() {
    return PixelBox(
      fill: cream,
      border: line,
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              autofocus: true,
              onEditingComplete: () => _addTask(_input.text),
              style: mono(15, color: ink),
              decoration: InputDecoration(
                hintText: 'Escribe y presiona Enter',
                hintStyle: mono(15, color: inkFaint),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          PixelBox(
            fill: cream,
            border: line,
            borderWidth: 1.5,
            unit: 2,
            child: const SizedBox(
              width: 36,
              height: 32,
              child: Center(child: Iconblock('trash')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection() {
    if (_section == AppSection.calendario && _currentProject == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon('calendar', size: 72),
            const SizedBox(height: 18),
            Text('Calendario', style: display(32, color: green)),
            const SizedBox(height: 6),
            Text('Próximamente.', style: mono(14, color: inkMuted)),
          ],
        ),
      );
    }

    final completed = _section == AppSection.completadas;
    return TaskList(
      tasks: _visible,
      onToggle: (task, done) => setState(() => task.done = done),
      onDelete: _deleteTask,
      emptyTitle: completed ? 'Nada completado' : 'Sin tareas',
      emptyHint: completed
          ? 'Marca una tarea para verla aquí.'
          : 'Escribe arriba para agregar la primera.',
    );
  }
}
