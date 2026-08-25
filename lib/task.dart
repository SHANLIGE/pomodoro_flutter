class Task {
  Task({required this.id, required this.text, this.projectId});

  final int id;
  final String text;
  final int? projectId;
  bool done = false;
}