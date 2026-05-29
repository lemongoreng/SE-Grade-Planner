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

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'creditHours': creditHours,
      'year': year,
      'semester': semester,
      'grade': grade,
      'examDate': examDate?.toIso8601String(),
      'examTime': examTime != null ? "${examTime!.hour}:${examTime!.minute}" : null,
      'examVenue': examVenue,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedTime;
    if (json['examTime'] != null) {
      final parts = json['examTime'].toString().split(':');
      if (parts.length == 2) {
        parsedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    return Course(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      creditHours: json['creditHours'] ?? 0,
      year: json['year'] ?? 1,
      semester: json['semester'] ?? 1,
      grade: json['grade'],
      examDate: json['examDate'] != null ? DateTime.tryParse(json['examDate']) : null,
      examTime: parsedTime,
      examVenue: json['examVenue'],
    );
  }
}