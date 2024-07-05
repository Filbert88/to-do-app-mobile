import 'package:flutter/material.dart';
import 'task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onUncomplete;
  final VoidCallback onDelete;

  // Passing `key` directly to the super constructor
  const TaskCard({
    super.key, // Using the super parameter feature
    required this.task,
    required this.onComplete,
    required this.onUncomplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Removing `const` from Padding as it depends on non-constant properties
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // `const` can still be used here
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: const BorderSide(color: Colors.grey), // `const` is appropriate here
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Due: ${task.duedate != null ? DateFormat.yMMMd().format(task.duedate!) : 'No Due Date'}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isDone ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: task.isDone ? onUncomplete : onComplete,
                    child: Text(task.isDone ? 'Mark as Undone' : 'Mark as Done'),
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
