import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../data/unimas_curriculum.dart';
import '../utils/calculator_logic.dart'; 
import '../utils/pdf_generator.dart';
import '../main.dart'; 

// IMPORT WIDGETS
import '../widgets/exam_card.dart';
import '../widgets/cgpa_card.dart';
import '../widgets/dashboard_button.dart'; // NEW
import '../widgets/course_list_view.dart'; // NEW

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Course> _allCourses = UnimasCurriculum.allCourses;
  SharedPreferences? _prefs;
  
  double _cgpa = 0.00;
  int _totalCreditsEarned = 0;
  Timer? _countdownTimer;
  Course? _nextExamCourse;

  // NAVIGATION STATE
  int? _selectedYear;     // Level 1 Selection
  int? _selectedSemester; // Level 2 Selection

  @override
  void initState() {
    super.initState();
    _initializeData();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateNextExam();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCourseEdits(); 
    _loadGrades();
    _updateNextExam(); 
  }

  // --- NAVIGATION HELPERS ---
  void _selectYear(int year) {
    setState(() => _selectedYear = year);
  }

  void _selectSemester(int semester) {
    setState(() => _selectedSemester = semester);
  }

  void _goBack() {
    setState(() {
      if (_selectedSemester != null) {
        _selectedSemester = null; // Go back to Year view
      } else if (_selectedYear != null) {
        _selectedYear = null; // Go back to Dashboard
      }
    });
  }

  // --- DATA LOGIC (Same as before) ---
  void _updateNextExam() {
    final now = DateTime.now();
    List<Course> upcoming = _allCourses.where((c) {
      if (c.examDate == null) return false;
      DateTime examEnd = DateTime(
        c.examDate!.year, c.examDate!.month, c.examDate!.day, 
        c.examTime?.hour ?? 23, c.examTime?.minute ?? 59
      );
      return examEnd.isAfter(now); 
    }).toList();

    if (upcoming.isNotEmpty) {
      upcoming.sort((a, b) => a.examDate!.compareTo(b.examDate!));
      setState(() => _nextExamCourse = upcoming.first);
    } else {
      setState(() => _nextExamCourse = null);
    }
  }

  void _loadGrades() {
    if (_prefs == null) return;
    String? jsonString = _prefs!.getString('saved_grades');
    if (jsonString != null) {
      Map<String, dynamic> savedData = jsonDecode(jsonString);
      for (var course in _allCourses) {
        if (savedData.containsKey(course.code)) course.grade = savedData[course.code];
      }
      _recalculateCGPA();
    }
  }

  void _saveGrades() {
    if (_prefs == null) return;
    Map<String, String> dataToSave = {
      for (var c in _allCourses) if (c.grade != null) c.code: c.grade!
    };
    _prefs!.setString('saved_grades', jsonEncode(dataToSave));
  }

  void _loadCourseEdits() {
    if (_prefs == null) return;
    String? jsonString = _prefs!.getString('saved_course_edits');
    if (jsonString != null) {
      Map<String, dynamic> savedEdits = jsonDecode(jsonString);
      for (var course in _allCourses) {
        if (savedEdits.containsKey(course.code)) {
          final editData = savedEdits[course.code];
          course.name = editData['name'];
          course.creditHours = editData['credits'];
          course.examVenue = editData['venue'];
          if (editData['examDate'] != null) course.examDate = DateTime.parse(editData['examDate']);
          if (editData['examTime'] != null) {
            List<String> parts = editData['examTime'].split(':');
            course.examTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        }
      }
      _updateNextExam();
    }
  }

  void _persistSingleEdit(Course course) {
    if (_prefs == null) return;
    String? jsonString = _prefs!.getString('saved_course_edits');
    Map<String, dynamic> savedEdits = jsonString != null ? jsonDecode(jsonString) : {};
    savedEdits[course.code] = {
      'name': course.name,
      'credits': course.creditHours,
      'venue': course.examVenue,
      'examDate': course.examDate?.toIso8601String(),
      'examTime': course.examTime != null ? "${course.examTime!.hour}:${course.examTime!.minute}" : null,
    };
    _prefs!.setString('saved_course_edits', jsonEncode(savedEdits));
    _updateNextExam();
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

  // --- DIALOGS (Kept same logic) ---
  void _showEditCourseDialog(Course course) {
    /* ... Same as previous version ... */
    TextEditingController nameController = TextEditingController(text: course.name);
    TextEditingController creditController = TextEditingController(text: course.creditHours.toString());
    TextEditingController venueController = TextEditingController(text: course.examVenue ?? "");
    DateTime? tempDate = course.examDate;
    TimeOfDay? tempTime = course.examTime;

    showDialog(context: context, builder: (context) {
      return StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text('Edit ${course.code}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: creditController, decoration: const InputDecoration(labelText: 'Credits'), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                TextField(controller: venueController, decoration: const InputDecoration(labelText: 'Venue')),
                const SizedBox(height: 10),
                Row(children: [
                   Expanded(child: OutlinedButton(onPressed: () async {
                     final picked = await showDatePicker(context: context, initialDate: tempDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                     if(picked != null) setStateDialog(()=>tempDate=picked);
                   }, child: Text(tempDate == null ? "Date" : "${tempDate!.day}/${tempDate!.month}"))),
                   const SizedBox(width: 5),
                   Expanded(child: OutlinedButton(onPressed: () async {
                     final picked = await showTimePicker(context: context, initialTime: tempTime ?? TimeOfDay.now());
                     if(picked != null) setStateDialog(()=>tempTime=picked);
                   }, child: Text(tempTime == null ? "Time" : tempTime!.format(context)))),
                ]),
              ],
            ),
          ),
          actions: [
            if(tempDate!=null) TextButton(onPressed: (){ 
              setState((){ course.examDate=null; course.examVenue=null; course.examTime=null; _persistSingleEdit(course); }); 
              Navigator.pop(context); 
            }, child: const Text("Clear Exam", style: TextStyle(color:Colors.red))),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              setState(() {
                course.name = nameController.text;
                course.creditHours = int.tryParse(creditController.text) ?? course.creditHours;
                course.examVenue = venueController.text;
                course.examDate = tempDate;
                course.examTime = tempTime;
                _persistSingleEdit(course);
                _recalculateCGPA();
              });
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        );
      });
    });
  }

  void _showGradeDialog(Course course) {
    showDialog(context: context, builder: (context) => SimpleDialog(
      title: Text('Grade for ${course.code}'),
      children: [
        ...['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F'].map((g) => 
          SimpleDialogOption(child: Text(g), onPressed: () {
            course.grade = g; _recalculateCGPA(); _saveGrades(); Navigator.pop(context);
          })
        ),
        const Divider(),
        SimpleDialogOption(child: const Text('Reset', style: TextStyle(color: Colors.red)), onPressed: () {
          course.grade = null; _recalculateCGPA(); _saveGrades(); Navigator.pop(context);
        }),
      ],
    ));
  }
  
  void _showTargetDialog() {
    TextEditingController targetController = TextEditingController();
    int creditsThisSem = 0;
    for (var course in _allCourses) { if (course.grade == null) creditsThisSem += course.creditHours; }
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Target CGPA'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Remaining Credits: $creditsThisSem'),
          TextField(controller: targetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target (e.g. 3.50)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {
            double? target = double.tryParse(targetController.text);
            if (target != null && creditsThisSem > 0) {
              double required = CalculatorLogic.calculateRequiredGPA(currentCGPA: _cgpa, currentCreditsEarned: _totalCreditsEarned, targetCGPA: target, creditsThisSem: creditsThisSem);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Required GPA: ${required.toStringAsFixed(2)}'), backgroundColor: required > 4.0 ? Colors.red : Colors.green));
            }
          }, child: const Text('Calc')),
        ],
      );
    });
  }

  // --- UI BUILDING BLOCKS ---

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedYear != null) {
          _goBack(); // Handle back button to go up a level
          return false;
        }
        return true; // Exit app if at root
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedYear == null ? 'UNIMAS SE Dashboard' : _selectedSemester == null ? 'Year $_selectedYear' : 'Y$_selectedYear Sem $_selectedSemester'),
          leading: _selectedYear != null 
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack)
              : null,
          actions: [
            IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () => PdfGenerator.generateAndPrint(_allCourses, _cgpa, _totalCreditsEarned)),
            IconButton(icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode), onPressed: () => MyApp.of(context)?.toggleTheme(!isDarkMode)),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SHOW STATS ON ROOT ONLY (Optional, but looks cleaner)
              if (_selectedYear == null) ...[
                if (_nextExamCourse != null) ...[
                  const Text("UPCOMING EXAM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ExamCard(course: _nextExamCourse!, isDark: isDarkMode),
                  const SizedBox(height: 24),
                ],
                const Text("ACADEMIC OVERVIEW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                const SizedBox(height: 8),
                CgpaCard(cgpa: _cgpa, totalCredits: _totalCreditsEarned, isDark: isDarkMode),
                const SizedBox(height: 24),
                const Text("SELECT YEAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                const SizedBox(height: 8),
                // LEVEL 1: YEAR BUTTONS
                DashboardButton(label: "Year 1", subLabel: "Freshman", icon: Icons.looks_one, color: Colors.orange, onTap: () => _selectYear(1)),
                DashboardButton(label: "Year 2", subLabel: "Sophomore", icon: Icons.looks_two, color: Colors.blue, onTap: () => _selectYear(2)),
                DashboardButton(label: "Year 3", subLabel: "Junior", icon: Icons.looks_3, color: Colors.purple, onTap: () => _selectYear(3)),
                DashboardButton(label: "Year 4", subLabel: "Senior", icon: Icons.looks_4, color: Colors.teal, onTap: () => _selectYear(4)),
              ],

              // LEVEL 2: SEMESTER BUTTONS
              if (_selectedYear != null && _selectedSemester == null) ...[
                 DashboardButton(label: "Semester 1", subLabel: "Start of Year", icon: Icons.wb_sunny, color: Colors.amber.shade700, onTap: () => _selectSemester(1)),
                 DashboardButton(label: "Semester 2", subLabel: "End of Year", icon: Icons.nightlight_round, color: Colors.indigo, onTap: () => _selectSemester(2)),
              ],

              // LEVEL 3: COURSE LIST
              if (_selectedYear != null && _selectedSemester != null) ...[
                 CourseListView(
                   courses: _allCourses.where((c) => c.year == _selectedYear && c.semester == _selectedSemester).toList(),
                   isDark: isDarkMode,
                   onEdit: _showEditCourseDialog,
                   onGrade: _showGradeDialog,
                 )
              ]
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showTargetDialog,
          label: const Text('Target Calc'),
          icon: const Icon(Icons.calculate),
          backgroundColor: const Color(0xFF02569B),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}