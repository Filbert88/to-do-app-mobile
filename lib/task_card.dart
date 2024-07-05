import 'package:flutter/material.dart';
import 'task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onUncomplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onUncomplete,
    required this.onDelete,
  });

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPastDue = task.duedate != null &&
        task.duedate!.isBefore(DateTime.now()) &&
        !task.isDone;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: isPastDue
              ? const BorderSide(color: Colors.red, width: 3.0)
              : BorderSide.none,
        ),
        color: isPastDue ? const Color(0xFF1D2029) : const Color(0xFF3A3C48),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitalize(task.title),
                style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Due: ${task.duedate != null ? DateFormat.yMMMd().format(task.duedate!) : 'No Due Date'}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (isPastDue)
                const Text(
                  'Past due already',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isDone
                          ? const Color(0xFFFF7350)
                          : const Color.fromARGB(221, 87, 195, 166),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: task.isDone ? onUncomplete : onComplete,
                    child:
                        Text(task.isDone ? 'Mark as Undone' : 'Mark as Done'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
