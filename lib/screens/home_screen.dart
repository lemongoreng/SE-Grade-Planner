import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../data/unimas_curriculum.dart';
import '../utils/calculator_logic.dart'; 
import '../main.dart'; // This allows us to access MyApp

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Course> _allCourses = UnimasCurriculum.allCourses;
  final Map<String, List<Course>> _semesterGroups = {};
  SharedPreferences? _prefs;

  double _cgpa = 0.00;
  int _totalCreditsEarned = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _groupCoursesBySemester();
    _prefs = await SharedPreferences.getInstance();
    _loadGrades();
  }

  void _groupCoursesBySemester() {
    for (int y = 1; y <= 4; y++) {
      for (int s = 1; s <= 2; s++) {
        String key = "Y${y}S$s";
        _semesterGroups[key] = _allCourses
            .where((c) => c.year == y && c.semester == s)
            .toList();
      }
    }
  }

  void _loadGrades() {
    if (_prefs == null) return;
    String? jsonString = _prefs!.getString('saved_grades');
    if (jsonString != null) {
      Map<String, dynamic> savedData = jsonDecode(jsonString);
      for (var course in _allCourses) {
        if (savedData.containsKey(course.code)) {
          course.grade = savedData[course.code];
        }
      }
      _recalculateCGPA();
    }
  }

  void _saveGrades() {
    if (_prefs == null) return;
    Map<String, String> dataToSave = {
      for (var c in _allCourses) 
        if (c.grade != null) c.code: c.grade!
    };
    _prefs!.setString('saved_grades', jsonEncode(dataToSave));
  }

  void _recalculateCGPA() {
    double totalPoints = 0;
    int credits = 0;
    for (var course in _allCourses) {
      if (course.grade != null) {
        totalPoints += course.totalQualityPoints;
        credits += course.creditHours;
      }
    }
    if (mounted) {
      setState(() {
        _totalCreditsEarned = credits;
        _cgpa = credits > 0 ? totalPoints / credits : 0.00;
      });
    }
  }

  void _showGradeDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Grade for ${course.code}'),
        children: [
          ...['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F'].map((g) => 
            SimpleDialogOption(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Text(g, style: const TextStyle(fontSize: 16)),
              onPressed: () {
                course.grade = g;
                _recalculateCGPA();
                _saveGrades();
                Navigator.pop(context);
              },
            )
          ),
          const Divider(),
          SimpleDialogOption(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: const Text('Reset Grade', style: TextStyle(color: Colors.red)),
            onPressed: () {
              course.grade = null;
              _recalculateCGPA();
              _saveGrades();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() {
    TextEditingController targetController = TextEditingController();
    int creditsThisSem = 0;
    for (var course in _allCourses) {
      if (course.grade == null) {
        creditsThisSem += course.creditHours;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Target CGPA Calculator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current CGPA: ${_cgpa.toStringAsFixed(2)}'),
              Text('Remaining Credits: $creditsThisSem'),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target CGPA (e.g. 3.50)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? target = double.tryParse(targetController.text);
                if (target != null && creditsThisSem > 0) {
                  double required = CalculatorLogic.calculateRequiredGPA(
                    currentCGPA: _cgpa,
                    currentCreditsEarned: _totalCreditsEarned,
                    targetCGPA: target,
                    creditsThisSem: creditsThisSem,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Required GPA: ${required.toStringAsFixed(2)}'),
                      backgroundColor: required > 4.0 ? Colors.red : Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Calculate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UNIMAS Grade Planner'),
        backgroundColor: isDarkMode ? null : const Color(0xFF02569B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // This should work now because MyAppState is public
              MyApp.of(context)?.toggleTheme(!isDarkMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(isDarkMode),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                int year = (index ~/ 2) + 1;
                int sem = (index % 2) + 1;
                String key = "Y${year}S$sem";
                List<Course>? coursesInSem = _semesterGroups[key];

                if (coursesInSem == null || coursesInSem.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ExpansionTile(
                  initiallyExpanded: year == 1 && sem == 1,
                  title: Text('Year $year Semester $sem', 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  children: coursesInSem.map((course) => _buildCourseTile(course, isDarkMode)).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTargetDialog,
        label: const Text('Target Calculator'),
        icon: const Icon(Icons.track_changes),
        backgroundColor: const Color(0xFF02569B),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      color: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade50,
      child: Column(
        children: [
          const Text('Current CGPA', style: TextStyle(color: Colors.grey)),
          Text(
            _cgpa.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.bold,
              color: _cgpa >= 3.0 
                  ? (isDarkMode ? Colors.lightGreenAccent : Colors.green) 
                  : Colors.orange,
            ),
          ),
          Text('Credits Earned: $_totalCreditsEarned',
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTile(Course course, bool isDarkMode) {
    return ListTile(
      title: Text(course.code, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(course.name),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: course.grade != null 
              ? (isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100) 
              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          course.grade ?? '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: (isDarkMode && course.grade != null) ? Colors.white : Colors.black,
          ),
        ),
      ),
      onTap: () => _showGradeDialog(course),
    );
  }
}