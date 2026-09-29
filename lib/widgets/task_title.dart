import 'package:flutter/material.dart';
import 'package:student_productivity_tracker/models/task_model.dart';
import 'package:student_productivity_tracker/themes/app_theme.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
  });

  Color _priorityColor() {
    switch (task.priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return AppTheme.primary;
    }
  }

  String _formatTime() {
    final hour = task.date.hour;
    final minute = task.date.minute;

    final period = hour >= 12 ? "PM" : "AM";

    final displayHour =
    hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    final displayMinute =
    minute.toString().padLeft(2, '0');

    return "$displayHour:$displayMinute $period";
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
        ),

        child: Row(
          children: [
            // ======================================================
            // COMPLETE BUTTON
            // ======================================================

            GestureDetector(
              onTap: onComplete,

              child: Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,

                color: task.isCompleted
                    ? Colors.green
                    : Colors.white54,

                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // ======================================================
            // TASK DETAILS
            // ======================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    task.title,

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,

                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (task.description.isNotEmpty)
                    Text(
                      task.description,

                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // ==================================================
                      // TIME
                      // ==================================================

                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.white60,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        _formatTime(),

                        style:
                        const TextStyle(
                          color: Colors.white60,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ==================================================
                      // PRIORITY
                      // ==================================================

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),

                        decoration:
                        BoxDecoration(
                          color: priorityColor
                              .withOpacity(.15),

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Text(
                          task.priority,

                          style: TextStyle(
                            color:
                            priorityColor,

                            fontWeight:
                            FontWeight.bold,

                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}