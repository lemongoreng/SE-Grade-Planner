import 'package:flutter/material.dart';
import '../models/course.dart';

class SemesterCard extends StatelessWidget {
  final String title;
  final List<Course> courses;
  final bool isDark;
  final Function(Course) onEdit;
  final Function(Course) onGrade;

  const SemesterCard({
    super.key,
    required this.title,
    required this.courses,
    required this.isDark,
    required this.onEdit,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: courses.map((course) => ListTile(
          onLongPress: () => onEdit(course),
          onTap: () => onGrade(course),
          title: Text(course.code, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Container(
            width: 80, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (course.examDate != null)
                   const Padding(
                     padding: EdgeInsets.only(right: 8.0),
                     child: Icon(Icons.event_available, size: 16, color: Colors.blue),
                   ),
                Container(
                  width: 35,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: course.grade != null 
                        ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.grade ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: course.grade != null ? (isDark ? Colors.white : Colors.green.shade800) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}