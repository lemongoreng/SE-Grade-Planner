import 'package:flutter/material.dart';

class Course {
  final String code;
  String name;
  int creditHours;
  final int year;
  final int semester;
  String? grade;
  
  // New Fields for Dashboard
  DateTime? examDate;
  TimeOfDay? examTime;
  String? examVenue;

  Course({
    required this.code,
    required this.name,
    required this.creditHours,
    required this.year,
    required this.semester,
    this.grade,
    this.examDate,
    this.examTime,
    this.examVenue,
  });

  // Calculate Quality Points (A = 4.0, A- = 3.67, etc.)
  double get pointValue {
    switch (grade) {
      case 'A': return 4.00;
      case 'A-': return 3.67;
      case 'B+': return 3.33;
      case 'B': return 3.00;
      case 'B-': return 2.67;
      case 'C+': return 2.33;
      case 'C': return 2.00;
      case 'C-': return 1.50; 
      case 'D': return 1.00;  
      case 'F': return 0.00;
      default: return 0.00;
    }
  }

  double get totalQualityPoints => pointValue * creditHours;
}