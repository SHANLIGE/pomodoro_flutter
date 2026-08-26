import 'package:flutter/material.dart';

import '../task.dart';
import '../theme.dart';
import 'app_icon.dart';
import 'task_row.dart';

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.emptyTitle,
    required this.emptyHint,
    required this.onDelete,
  });

  final List<Task> tasks;
  final void Function(Task task, bool done) onToggle;
  final void Function(Task task) onDelete;
  final String emptyTitle;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon('play-solid', size: 78),
            const SizedBox(height: 18),
            Text(emptyTitle, style: display(32, color: green)),
            const SizedBox(height: 6),
            Text(emptyHint, style: mono(14, color: inkMuted)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: SizedBox(
        height: tasks.length * taskRowHeight,
        child: Stack(
          children: [
            // La key por id le dice a Flutter que es el mismo widget
            // cambiando de sitio, no uno nuevo. Sin ella no hay animación.
            for (var i = 0; i < tasks.length; i++)
              AnimatedPositioned(
                key: ValueKey(tasks[i].id),
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                top: i * taskRowHeight,
                left: 0,
                right: 0,
                height: taskRowHeight,
                child: TaskRow(
                  task: tasks[i],
                  onToggle: (v) => onToggle(tasks[i], v),
                  onDelete: () => onDelete(tasks[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
