import 'unimas_grade.dart';

class Course {
  final String code;        // e.g., "TMF1414"
  final String name;        // e.g., "Introduction to Programming"
  final int creditHours;    // e.g., 4
  final int year;           // e.g., 1
  final int semester;       // e.g., 1 or 2
  String? grade;            // Nullable because you might not have taken it yet

  Course({
    required this.code,
    required this.name,
    required this.creditHours,
    required this.year,
    required this.semester,
    this.grade, // Optional
  });

  // Returns 0.00 if no grade is assigned yet
  double get point => grade != null ? UnimasGrade.convertGradeToPoint(grade!) : 0.00;

  double get totalQualityPoints => point * creditHours;
}