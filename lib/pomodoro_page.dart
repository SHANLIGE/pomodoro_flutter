import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'task.dart';
import 'theme.dart';
import 'widgets/task_row.dart';
import 'widgets/title_bar.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final _tasks = <Task>[];
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  int _nextId = 0;

  final _minCtrl = FixedExtentScrollController(initialItem: 25);
  final _secCtrl = FixedExtentScrollController(initialItem: 0);

  int _totalSeconds = 25 * 60;
  int _remaining = 25 * 60;
  Timer? _ticker;

  bool get _running => _ticker != null;
  bool get _idle => !_running && _remaining == _totalSeconds;

  // Pendientes primero, completadas al final: tu move_task, declarativo.
  List<Task> get _ordered => [
    ..._tasks.where((t) => !t.done),
    ..._tasks.where((t) => t.done),
  ];

  @override
  void dispose() {
    _ticker?.cancel();
    _input.dispose();
    _inputFocus.dispose();
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  void _addTask(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    setState(() => _tasks.add(Task(id: _nextId++, text: text)));
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inputFocus.requestFocus();
    });
  }

  void _syncDuration() {
    setState(() {
      _totalSeconds = _minCtrl.selectedItem * 60 + _secCtrl.selectedItem;
      _remaining = _totalSeconds;
    });
  }

  void _toggleTimer() {
    if (_running) {
      _ticker!.cancel();
      setState(() => _ticker = null);
      return;
    }
    if (_remaining == 0) return;
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

  String _format(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tareas',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _input,
                    onEditingComplete: () =>
                        _addTask(_input.text), // ~ returnPressed
                    style: const TextStyle(color: textColor, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '¿En qué vas a trabajar?',
                      hintStyle: TextStyle(color: textColorTertiary),

                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildTaskList()),
                  const SizedBox(height: 12),
                  _buildTimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final ordered = _ordered;
    return SingleChildScrollView(
      child: SizedBox(
        height: ordered.length * taskRowHeight,
        child: Stack(
          children: [
            for (var i = 0; i < ordered.length; i++)
              AnimatedPositioned(
                key: ValueKey(ordered[i].id),
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                top: i * taskRowHeight,
                left: 0,
                right: 0,
                height: taskRowHeight,
                child: TaskRow(
                  task: ordered[i],
                  onToggle: (v) => setState(() => ordered[i].done = v),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: _idle ? _buildPickers() : _buildCountdown(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AppButton(
                label: _running ? 'Pausar' : 'Iniciar',
                onTap: _toggleTimer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AppButton(label: 'Reiniciar', onTap: _reset),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountdown() => Center(
    child: Text(
      _format(_remaining),
      style: const TextStyle(
        color: textColorTertiary,
        fontSize: 64,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildPickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _wheel(_minCtrl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            ':',
            style: TextStyle(fontSize: 28, color: textColorTertiary),
          ),
        ),
        _wheel(_secCtrl),
      ],
    );
  }

  // Esto es todo tu WheelPicker de 60 líneas.
  Widget _wheel(FixedExtentScrollController controller) {
    return SizedBox(
      width: 90,
      child: CupertinoPicker(
        itemExtent: 40,
        scrollController: controller,
        squeeze: 1.1,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: Color(0x1AFF85BE),
        ),
        onSelectedItemChanged: (_) => _syncDuration(),
        children: List.generate(
          60,
          (i) => Center(
            child: Text(
              i.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 24, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppButton extends StatelessWidget {
  const _AppButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ).copyWith(overlayColor: WidgetStateProperty.all(primaryColor)),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
