import 'dart:async';
import 'package:flutter/material.dart';

import 'task.dart';
import 'theme.dart';
import 'widgets/app_icon.dart';
import 'widgets/calendar_view.dart';
import 'widgets/dialogs.dart';
import 'widgets/pixel_box.dart';
import 'widgets/settings_view.dart';
import 'widgets/sidebar.dart';
import 'widgets/task_list.dart';
import 'widgets/timer_bar.dart';
import 'widgets/title_bar.dart';
import 'widgets/pixel_ui.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _tasks = <Task>[];
  final _projects = <Project>[];
  final _input = TextEditingController();

  int _nextId = 0;
  int _nextProjectId = 0;

  AppSection _section = AppSection.hoy;
  int? _currentProject;
  bool _settingsOpen = false;

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

  // ------------------------------------------------------------ tareas

  /// Primero filtra por proyecto, luego la sección decide qué subconjunto.
  List<Task> get _scoped => _currentProject == null
      ? _tasks
      : _tasks.where((t) => t.projectId == _currentProject).toList();

  List<Task> get _visible {
    final base = _scoped;
    return switch (_section) {
      AppSection.hoy => base.where((t) => !t.done).toList(),
      AppSection.completadas => base.where((t) => t.done).toList(),
      _ => [
          ...base.where((t) => !t.done),
          ...base.where((t) => t.done),
        ],
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

    Future<bool> _editTask(Task task) async {
    final result = await showTaskDialog(
      context,
      task,
      projects: _projects,
      onCreateProject: _createProjectInline,
    );
    if (result == null) return false;

    setState(() {
      if (result.deleted) {
        _tasks.remove(task);
      } else {
        task.text = result.text;
        task.start = result.start;
        task.end = result.end;
        task.projectId = result.projectId;
      }
    });
    return true;
  }
    Future<void> _clearCompleted() async {
    final count = _visible.length;
    if (count == 0) return;

    final ok = await showConfirmDialog(
      context,
      title: 'Limpiar completadas',
      message: 'Se eliminarán $count tarea${count == 1 ? '' : 's'} '
          'completada${count == 1 ? '' : 's'}. Esta acción no se puede deshacer.',
      confirmLabel: 'Limpiar',
    );
    if (!ok) return;

    setState(() {
      // Respeta el filtro de proyecto activo: solo borra lo que se ve.
      _tasks.removeWhere(
        (t) =>
            t.done &&
            (_currentProject == null || t.projectId == _currentProject),
      );
    });
  }
  Future<Project?> _createProjectInline() async {
    final name = await showNameDialog(
      context,
      title: 'Nuevo proyecto',
      hint: 'Nombre del proyecto',
    );
    if (name == null) return null;

    final id = _nextProjectId++;
    final project = Project(
      id,
      name,
      projectPalette[id % projectPalette.length],
    );
    setState(() => _projects.add(project));
    return project;
  }
    /// Crea una tarea vacía en ese día y abre el editor de una vez.
    /// Crea una tarea vacía en ese día y abre el editor de una vez.
  Future<void> _addTaskOnDate(DateTime day) async {
    final task = Task(
      id: _nextId++,
      text: 'Nueva tarea',
      projectId: _currentProject,
      start: day,
    );
    setState(() => _tasks.add(task));

    final saved = await _editTask(task);
    // Si se canceló, no dejamos la tarea provisional.
    if (!saved && mounted) {
      setState(() => _tasks.remove(task));
    }
  }

  // --------------------------------------------------------- proyectos

    Future<void> _addProject() async {
    final project = await _createProjectInline();
    if (project == null) return;
    setState(() {
      _currentProject = project.id;
      _section = AppSection.todas;
      _settingsOpen = false;
    });
  }

  Future<void> _handleProjectAction(Project p, ProjectAction action) async {
    switch (action) {
      case ProjectAction.pin:
        setState(() => p.pinned = !p.pinned);

      case ProjectAction.rename:
        final name = await showNameDialog(
          context,
          title: 'Renombrar proyecto',
          initial: p.name,
          hint: 'Nombre del proyecto',
        );
        if (name != null) setState(() => p.name = name);

      case ProjectAction.delete:
        final count = _tasks.where((t) => t.projectId == p.id).length;
        if (count > 0) {
          final ok = await showConfirmDialog(
            context,
            title: 'Eliminar proyecto',
            message: '"${p.name}" contiene $count '
                'tarea${count == 1 ? '' : 's'}. '
                'Si continúas se eliminarán también.',
            confirmLabel: 'Eliminar todo',
          );
          if (!ok) return;
        }
        setState(() {
          _tasks.removeWhere((t) => t.projectId == p.id);
          _projects.remove(p);
          if (_currentProject == p.id) _currentProject = null;
        });
    }
  }

  // ------------------------------------------------------------- timer

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

  // ---------------------------------------------------------------- UI

  String get _headerTitle {
    if (_settingsOpen) return 'Ajustes';
    if (_currentProject != null) {
      // where en vez de firstWhere: no revienta si el proyecto ya no existe.
      final match = _projects.where((p) => p.id == _currentProject);
      if (match.isNotEmpty) return match.first.name;
    }
    return _section.label;
  }
  Color _colorOf(Task task) {
    final match = _projects.where((p) => p.id == task.projectId);
    return match.isEmpty ? green : match.first.color;
  }
  
  bool get _showInput =>
      !_settingsOpen &&
      _section != AppSection.completadas &&
      _section != AppSection.calendario;

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
                    _settingsOpen = false;
                  }),
                  projects: _projects,
                  currentProject: _settingsOpen ? null : _currentProject,
                  onSelectProject: (id) => setState(() {
                    _currentProject = id;
                    _section = AppSection.todas;
                    _settingsOpen = false;
                  }),
                  onAddProject: _addProject,
                  onProjectAction: _handleProjectAction,
                  onOpenSettings: () =>
                      setState(() => _settingsOpen = !_settingsOpen),
                  settingsOpen: _settingsOpen,
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
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              _headerTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: display(42),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('✦', style: mono(12, color: green)),
                        ],
                      ),
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
              if (_showInput) ...[
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
              child: Center(child: AppIcon('mic', size: 18)),
            ),
          ),
        ],
      ),
    );
  }

      Widget _buildSection() {
    if (_settingsOpen) return const SettingsView();

        if (_section == AppSection.calendario && _currentProject == null) {
      return CalendarView(
        // Las completadas no ensucian el calendario: viven en su sección.
        tasks: _tasks.where((t) => t.hasSchedule && !t.done).toList(),
        colorOf: _colorOf,
        onEdit: _editTask,
        onAddOnDate: _addTaskOnDate,
      );
    }

        final completed = _section == AppSection.completadas;
    final list = TaskList(
      tasks: _visible,
      onToggle: (task, done) => setState(() => task.done = done),
      onEdit: _editTask,
      emptyTitle: completed ? 'Nada completado' : 'Sin tareas',
      emptyHint: completed
          ? 'Marca una tarea para verla aquí.'
          : 'Escribe arriba para agregar la primera.',
    );

    if (!completed) return list;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_visible.isNotEmpty) ...[
          Row(
            children: [
              const Spacer(),
              PixelButton(
                label: 'Limpiar (${_visible.length})',
                danger: true,
                onTap: _clearCompleted,
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Expanded(child: list),
      ],
    );
  }
}