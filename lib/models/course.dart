import 'unimas_grade.dart';

class Course {
  final String code;
  String name;           // CHANGED: Removed 'final' so it can be edited
  int creditHours;       // CHANGED: Removed 'final' so it can be edited
  final int year;
  final int semester;
  String? grade;

  Course({
    required this.code,
    required this.name,
    required this.creditHours,
    required this.year,
    required this.semester,
    this.grade,
  });

  double get point => grade != null ? UnimasGrade.convertGradeToPoint(grade!) : 0.00;

  double get totalQualityPoints => point * creditHours;
}