import 'package:flutter/material.dart';
import '../models/course.dart';

class ExamCard extends StatelessWidget {
  final Course course;
  final bool isDark;

  const ExamCard({super.key, required this.course, required this.isDark});

  String _getTimeRemaining() {
    DateTime examDateTime = DateTime(
      course.examDate!.year, course.examDate!.month, course.examDate!.day, 
      course.examTime?.hour ?? 8, course.examTime?.minute ?? 0 
    );
    
    Duration diff = examDateTime.difference(DateTime.now());
    
    if (diff.isNegative) return "In Progress / Done";
    
    if (diff.inDays > 0) {
      return "${diff.inDays} Days, ${diff.inHours % 24} Hours left";
    } else {
      return "${diff.inHours}h ${diff.inMinutes % 60}m remaining";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[800] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // FIXED: Updated to .withValues(alpha: ...)
                color: Colors.redAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.code, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    _getTimeRemaining(),
                    style: TextStyle(
                      color: isDark ? Colors.redAccent[100] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        course.examVenue ?? "Venue TBD", 
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        course.examTime?.format(context) ?? "Time TBD", 
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}