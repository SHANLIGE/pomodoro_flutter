import 'package:flutter/material.dart';
import '../task.dart';
import '../theme.dart';
import 'task_row.dart';

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.emptyTitle,
    required this.emptyHint,
  });

  final List<Task> tasks;
  final void Function(Task task, bool done) onToggle;
  final String emptyTitle;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 15,
                color: textColorTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emptyHint,
              style: const TextStyle(fontSize: 13, color: textColorDone),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: SizedBox(
        height: tasks.length * taskRowHeight,
        child: Stack(
          children: [
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}