import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseListView extends StatelessWidget {
  final List<Course> courses;
  final bool isDark;
  final Function(Course) onEdit;
  final Function(Course) onGrade;

  const CourseListView({
    super.key,
    required this.courses,
    required this.isDark,
    required this.onEdit,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("No courses found for this semester.")),
      );
    }

    return Column(
      children: courses.map((course) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onLongPress: () => onEdit(course),
          onTap: () => onGrade(course),
          title: Text(course.code, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.name),
              if (course.examDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 12, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text("Exam Set", style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: course.grade != null 
                  ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              course.grade ?? '-',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: course.grade != null ? (isDark ? Colors.white : Colors.green.shade800) : Colors.grey,
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}