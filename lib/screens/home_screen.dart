import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../data/unimas_curriculum.dart';
import '../utils/calculator_logic.dart'; 
import '../utils/pdf_generator.dart';
import '../main.dart'; 
import '../widgets/exam_card.dart';
import '../widgets/cgpa_card.dart';
import '../widgets/dashboard_button.dart'; 
import '../widgets/course_list_view.dart'; 
import '../utils/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _allCourses = [];
  SharedPreferences? _prefs;
  
  double _cgpa = 0.00;
  int _totalCreditsEarned = 0;
  Timer? _countdownTimer;
  Course? _nextExamCourse;

  // NAVIGATION STATE
  int? _selectedYear;     
  int? _selectedSemester;
  Map<String, dynamic>? _userProfile;

  // SIMULATION MODE STATE
  bool _isSimulationMode = false;
  List<Course> _simulatedCourses = [];

  void _loadProfile() {
    if (_prefs == null) return;
    final name = _prefs!.getString('profile_name') ?? "Student";
    final matrix = _prefs!.getString('profile_matrix') ?? "85732";
    final targetCgpa = _prefs!.getString('profile_target_cgpa') ?? "3.50";
    
    setState(() {
      _userProfile = {
        'name': name,
        'matrix_number': matrix,
        'target_cgpa': targetCgpa,
      };
    });
  }

  void _saveProfile(String name, String matrix, String targetCgpa) {
    if (_prefs == null) return;
    _prefs!.setString('profile_name', name);
    _prefs!.setString('profile_matrix', matrix);
    _prefs!.setString('profile_target_cgpa', targetCgpa);
    
    setState(() {
      _userProfile = {
        'name': name,
        'matrix_number': matrix,
        'target_cgpa': targetCgpa,
      };
    });
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?['name'] ?? "Student");
    final matrixController = TextEditingController(text: _userProfile?['matrix_number'] ?? "85732");
    final targetController = TextEditingController(text: _userProfile?['target_cgpa'] ?? "3.50");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Student Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: matrixController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Matrix Number',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target CGPA',
                    prefixIcon: Icon(Icons.track_changes),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveProfile(
                  nameController.text.trim().isEmpty ? "Student" : nameController.text.trim(),
                  matrixController.text.trim().isEmpty ? "85732" : matrixController.text.trim(),
                  targetController.text.trim().isEmpty ? "3.50" : targetController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSimulationMode(bool enabled) {
    setState(() {
      _isSimulationMode = enabled;
      if (enabled) {
        _simulatedCourses = _allCourses.map((c) => Course(
          code: c.code,
          name: c.name,
          creditHours: c.creditHours,
          year: c.year,
          semester: c.semester,
          grade: c.grade,
          examDate: c.examDate,
          examTime: c.examTime,
          examVenue: c.examVenue,
        )).toList();
      } else {
        _simulatedCourses = [];
      }
      _recalculateCGPA();
    });
  }

  void _showGradingScaleGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final grades = [
          {'grade': 'A', 'point': '4.00', 'range': '80 - 100', 'desc': 'Excellent'},
          {'grade': 'A-', 'point': '3.67', 'range': '75 - 79', 'desc': 'Very Good'},
          {'grade': 'B+', 'point': '3.33', 'range': '70 - 74', 'desc': 'Good'},
          {'grade': 'B', 'point': '3.00', 'range': '65 - 69', 'desc': 'Good'},
          {'grade': 'B-', 'point': '2.67', 'range': '60 - 64', 'desc': 'Satisfactory'},
          {'grade': 'C+', 'point': '2.33', 'range': '55 - 59', 'desc': 'Satisfactory'},
          {'grade': 'C', 'point': '2.00', 'range': '50 - 54', 'desc': 'Pass'},
          {'grade': 'C-', 'point': '1.50', 'range': '45 - 49', 'desc': 'Conditional Pass'},
          {'grade': 'D', 'point': '1.00', 'range': '40 - 44', 'desc': 'Conditional Pass'},
          {'grade': 'F', 'point': '0.00', 'range': '0 - 39', 'desc': 'Fail'},
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "UNIMAS Grading Scale",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final g = grades[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF02569B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              g['grade']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF02569B)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g['desc']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text("Marks: ${g['range']}%", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            g['point']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBackupRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Local Backup & Restore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Since your data is saved offline on this device, use these tools to transfer or backup your academic records.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportBackup();
                },
                icon: const Icon(Icons.copy),
                label: const Text('Export Backup Code'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  backgroundColor: const Color(0xFF02569B),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showImportDialog();
                },
                icon: const Icon(Icons.paste),
                label: const Text('Import Backup Code'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportBackup() {
    if (_prefs == null) return;
    
    final backupData = {
      'profile_name': _prefs!.getString('profile_name') ?? 'Student',
      'profile_matrix': _prefs!.getString('profile_matrix') ?? '85732',
      'profile_target_cgpa': _prefs!.getString('profile_target_cgpa') ?? '3.50',
      'saved_grades': jsonDecode(_prefs!.getString('saved_grades') ?? '{}'),
      'saved_course_edits': jsonDecode(_prefs!.getString('saved_course_edits') ?? '{}'),
      'saved_custom_courses': jsonDecode(_prefs!.getString('saved_custom_courses') ?? '[]'),
    };
    
    final jsonString = jsonEncode(backupData);
    Clipboard.setData(ClipboardData(text: jsonString));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Backup Code Copied!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The backup code has been copied to your clipboard. Paste it in a notes app or save it securely.'),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonString,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import Backup Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste the backup code string below to overwrite your current local records:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: '{"profile_name": ...}',
                  hintStyle: const TextStyle(fontSize: 12),
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
                final input = controller.text.trim();
                if (input.isEmpty) return;
                
                try {
                  final data = jsonDecode(input);
                  if (data is Map<String, dynamic>) {
                    _importBackup(data);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup imported successfully!'), backgroundColor: Colors.green),
                    );
                  } else {
                    throw const FormatException('Invalid backup structure');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to import backup: Invalid code format. $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  void _importBackup(Map<String, dynamic> data) {
    if (_prefs == null) return;
    
    if (data.containsKey('profile_name')) _prefs!.setString('profile_name', data['profile_name']);
    if (data.containsKey('profile_matrix')) _prefs!.setString('profile_matrix', data['profile_matrix']);
    if (data.containsKey('profile_target_cgpa')) _prefs!.setString('profile_target_cgpa', data['profile_target_cgpa']);
    if (data.containsKey('saved_grades')) _prefs!.setString('saved_grades', jsonEncode(data['saved_grades']));
    if (data.containsKey('saved_course_edits')) _prefs!.setString('saved_course_edits', jsonEncode(data['saved_course_edits']));
    if (data.containsKey('saved_custom_courses')) _prefs!.setString('saved_custom_courses', jsonEncode(data['saved_custom_courses']));
    
    _initializeData();
  }

  void _saveCustomCourse(Course course) {
    if (_prefs == null) return;
    setState(() {
      _allCourses.add(course);
    });
    
    final standardCodes = UnimasCurriculum.allCourses.map((c) => c.code).toSet();
    final customList = _allCourses.where((c) => !standardCodes.contains(c.code)).toList();
    
    String jsonString = jsonEncode(customList.map((c) => c.toJson()).toList());
    _prefs!.setString('saved_custom_courses', jsonString);
    
    _recalculateCGPA();
    _updateNextExam();
  }

  bool _isCustomCourse(Course course) {
    final standardCodes = UnimasCurriculum.allCourses.map((c) => c.code).toSet();
    return !standardCodes.contains(course.code);
  }

  void _showAddCourseDialog(int year, int semester) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final creditController = TextEditingController(text: "3");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Custom Course (Y$year S$semester)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Course Code (e.g., TMX3113)',
                    prefixIcon: Icon(Icons.code),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Credit Hours',
                    prefixIcon: Icon(Icons.hourglass_empty),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim().toUpperCase();
                final name = nameController.text.trim();
                final credits = int.tryParse(creditController.text.trim()) ?? 3;

                if (code.isEmpty || name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
                  );
                  return;
                }

                if (_allCourses.any((c) => c.code.toUpperCase() == code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Course code $code already exists!'), backgroundColor: Colors.red),
                  );
                  return;
                }

                final newCourse = Course(
                  code: code,
                  name: name,
                  creditHours: credits,
                  year: year,
                  semester: semester,
                );

                _saveCustomCourse(newCourse);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Custom course $code added!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

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
    
    // Load custom courses
    String? customJson = _prefs!.getString('saved_custom_courses');
    List<Course> custom = [];
    if (customJson != null) {
      try {
        List<dynamic> list = jsonDecode(customJson);
        custom = list.map((item) => Course.fromJson(item)).toList();
      } catch (e) {
        debugPrint("Error loading custom courses: $e");
      }
    }
    
    _allCourses = [
      ...UnimasCurriculum.allCourses,
      ...custom,
    ];

    _loadCourseEdits(); 
    _loadGrades();
    _loadProfile();
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
    final courses = _isSimulationMode ? _simulatedCourses : _allCourses;
    for (var course in courses) {
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

  List<double> _getSemesterGPAs() {
    List<double> semesterGpas = [];
    final activeCourses = _isSimulationMode ? _simulatedCourses : _allCourses;
    
    for (int y = 1; y <= 4; y++) {
      for (int s = 1; s <= 2; s++) {
        double semPoints = 0;
        int semCredits = 0;
        for (var course in activeCourses) {
          if (course.year == y && course.semester == s && course.grade != null) {
            semPoints += course.totalQualityPoints;
            semCredits += course.creditHours;
          }
        }
        if (semCredits > 0) {
          semesterGpas.add(semPoints / semCredits);
        }
      }
    }
    return semesterGpas;
  }

  // --- DIALOGS (Kept same logic) ---
  void _showEditCourseDialog(Course course) {
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
            if (_isCustomCourse(course))
              TextButton(
                onPressed: () {
                  setState(() {
                    _allCourses.removeWhere((c) => c.code == course.code);
                    
                    final standardCodes = UnimasCurriculum.allCourses.map((c) => c.code).toSet();
                    final customList = _allCourses.where((c) => !standardCodes.contains(c.code)).toList();
                    _prefs?.setString('saved_custom_courses', jsonEncode(customList.map((c) => c.toJson()).toList()));
                    
                    _recalculateCGPA();
                    _updateNextExam();
                  });
                  Navigator.pop(context);
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            if(tempDate != null) 
              TextButton(
                onPressed: () { 
                  setState((){ 
                    course.examDate = null; 
                    course.examVenue = null; 
                    course.examTime = null; 
                    _persistSingleEdit(course); 
                    _recalculateCGPA(); // Keeps UI in sync
                  }); 
                  
                  // --- ALARM: CANCEL ---
                  NotificationService.cancelNotification(course.code.hashCode);
                  
                  Navigator.pop(context); 
                }, 
                child: const Text("Clear Exam", style: TextStyle(color:Colors.red))
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  course.name = nameController.text;
                  course.creditHours = int.tryParse(creditController.text) ?? course.creditHours;
                  course.examVenue = venueController.text;
                  course.examDate = tempDate;
                  course.examTime = tempTime;
                  
                  if (!_isSimulationMode) {
                    _persistSingleEdit(course);
                  } else {
                    final masterCourse = _allCourses.firstWhere((c) => c.code == course.code, orElse: () => course);
                    masterCourse.name = nameController.text;
                    masterCourse.creditHours = int.tryParse(creditController.text) ?? masterCourse.creditHours;
                    masterCourse.examVenue = venueController.text;
                    masterCourse.examDate = tempDate;
                    masterCourse.examTime = tempTime;
                    _persistSingleEdit(masterCourse);
                  }
                  
                  _recalculateCGPA();
                });

                // --- ALARM: SCHEDULE OR CANCEL ---
                if (tempDate != null && tempTime != null) {
                  // 1. Combine Date and Time
                  DateTime fullExamTime = DateTime(
                    tempDate!.year, tempDate!.month, tempDate!.day,
                    tempTime!.hour, tempTime!.minute,
                  );
                  
                  // 2. Set alarm for 30 mins before
                  DateTime alarmTime = fullExamTime.subtract(const Duration(minutes: 30));

                  // 3. Schedule it
                  NotificationService.scheduleNotification(
                    id: course.code.hashCode, // Unique ID per course
                    title: "⏰ EXAM ALARM: ${course.code}",
                    body: "Your exam for ${course.name} starts in 30 mins at ${venueController.text.isEmpty ? 'TBA' : venueController.text}!",
                    scheduledDate: alarmTime,
                  );
                } else {
                  // If user didn't set a time, ensure no rogue alarm exists
                  NotificationService.cancelNotification(course.code.hashCode);
                }

                Navigator.pop(context);
              }, 
              child: const Text('Save')
            ),
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
          SimpleDialogOption(
            child: Text(g), 
            onPressed: () {
              setState(() {
                course.grade = g;
                _recalculateCGPA();
                if (!_isSimulationMode) {
                  _saveGrades();
                }
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSimulationMode 
                      ? 'Simulated grade updated to $g for ${course.code}'
                      : 'Grade updated to $g for ${course.code}'),
                  backgroundColor: _isSimulationMode ? Colors.orange.shade800 : Colors.green,
                  duration: const Duration(seconds: 1),
                )
              );
            }
          )
        ),
        const Divider(),
        SimpleDialogOption(
          child: const Text('Reset', style: TextStyle(color: Colors.red)), 
          onPressed: () {
            setState(() {
              course.grade = null;
              _recalculateCGPA();
              if (!_isSimulationMode) {
                _saveGrades();
              }
            });
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isSimulationMode 
                    ? 'Simulated grade reset for ${course.code}'
                    : 'Grade reset for ${course.code}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 1),
              )
            );
          }
        ),
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

  Widget _buildAnalyticsSection(bool isDarkMode) {
    int countA = 0;
    int countB = 0;
    int countC = 0;
    int countDF = 0;
    int totalGrades = 0;
    
    final activeCourses = _isSimulationMode ? _simulatedCourses : _allCourses;

    for (var course in activeCourses) {
      if (course.grade != null) {
        totalGrades++;
        if (course.grade == 'A' || course.grade == 'A-') {
          countA++;
        } else if (course.grade == 'B+' || course.grade == 'B' || course.grade == 'B-') {
          countB++;
        } else if (course.grade == 'C+' || course.grade == 'C' || course.grade == 'C-') {
          countC++;
        } else {
          countDF++;
        }
      }
    }

    final semGpas = _getSemesterGPAs();

    if (totalGrades == 0) {
      return const SizedBox.shrink(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("ANALYTICS & INSIGHTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
              onPressed: _showGradingScaleGuide,
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.blue.withValues(alpha: 0.1)),
          ),
          color: isDarkMode ? Colors.blueGrey.shade900.withValues(alpha: 0.2) : Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Grade Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGradeBar("A/A-", countA, totalGrades, Colors.green),
                    _buildGradeBar("B Range", countB, totalGrades, Colors.blue),
                    _buildGradeBar("C Range", countC, totalGrades, Colors.orange),
                    _buildGradeBar("D/F", countDF, totalGrades, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        if (semGpas.isNotEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.blue.withValues(alpha: 0.1)),
            ),
            color: isDarkMode ? Colors.blueGrey.shade900.withValues(alpha: 0.2) : Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("GPA Trend", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    "Average Semester GPA: ${(semGpas.reduce((a, b) => a + b) / semGpas.length).toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: GPATrendPainter(semGpas, isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(semGpas.length, (index) => Text("Sem ${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.grey))),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGradeBar(String label, int count, int total, Color color) {
    double percentage = total > 0 ? count / total : 0.0;
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        Container(
          height: 70,
          width: 14,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 70 * percentage,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _selectedYear == null, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; 
        _goBack(); 
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedYear == null ? 'UNIMAS SE Dashboard' : _selectedSemester == null ? 'Year $_selectedYear' : 'Y$_selectedYear Sem $_selectedSemester'),
          leading: _selectedYear != null 
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack)
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_backup_restore), 
              tooltip: "Backup & Restore",
              onPressed: _showBackupRestoreDialog,
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf), 
              tooltip: "Print PDF Report",
              onPressed: () => PdfGenerator.generateAndPrint(_isSimulationMode ? _simulatedCourses : _allCourses, _cgpa, _totalCreditsEarned),
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode), 
              tooltip: "Toggle Theme",
              onPressed: () => MyApp.of(context)?.toggleTheme(!isDarkMode),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedYear == null) ...[
                if (_nextExamCourse != null) ...[
                  const Text("UPCOMING EXAM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ExamCard(course: _nextExamCourse!, isDark: isDarkMode),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ACADEMIC OVERVIEW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.science, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text("Simulator", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Switch(
                          value: _isSimulationMode,
                          activeThumbColor: Colors.orange.shade800,
                          onChanged: _toggleSimulationMode,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_userProfile != null)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.blue.withValues(alpha: 0.2), 
                        width: 1
                      ),
                    ),
                    color: isDarkMode ? Colors.blueGrey.shade900.withValues(alpha: 0.4) : Colors.blue.shade50.withValues(alpha: 0.5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showEditProfileDialog,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: isDarkMode ? const Color(0xFF02569B) : Colors.blue.shade100,
                              child: Text(
                                _userProfile!['name'].toString().isNotEmpty 
                                    ? _userProfile!['name'].toString().substring(0, 1).toUpperCase()
                                    : "S",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF02569B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Hi, ${_userProfile!['name']}!",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Tooltip(
                                        message: "Saved Offline to Local Storage",
                                        child: Icon(Icons.offline_pin, size: 16, color: Colors.green),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.edit, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "ID: ${_userProfile!['matrix_number']}",
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "🎯 Target CGPA: ${_userProfile!['target_cgpa']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.blue.shade200 : const Color(0xFF02569B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_isSimulationMode) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.science, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "SIMULATION MODE ACTIVE (Grades not saved)",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                CgpaCard(
                  cgpa: _cgpa, 
                  totalCredits: _totalCreditsEarned, 
                  isDark: isDarkMode
                ),
                const SizedBox(height: 16),

                _buildAnalyticsSection(isDarkMode),

                const SizedBox(height: 8),
                const Text("SELECT YEAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                const SizedBox(height: 8),
                DashboardButton(label: "Year 1", subLabel: "Freshman", icon: Icons.looks_one, color: Colors.orange, onTap: () => _selectYear(1)),
                DashboardButton(label: "Year 2", subLabel: "Sophomore", icon: Icons.looks_two, color: Colors.blue, onTap: () => _selectYear(2)),
                DashboardButton(label: "Year 3", subLabel: "Junior", icon: Icons.looks_3, color: Colors.purple, onTap: () => _selectYear(3)),
                DashboardButton(label: "Year 4", subLabel: "Senior", icon: Icons.looks_4, color: Colors.teal, onTap: () => _selectYear(4)),
              ],

              if (_selectedYear != null && _selectedSemester == null) ...[
                 DashboardButton(label: "Semester 1", subLabel: "Start of Year", icon: Icons.wb_sunny, color: Colors.amber.shade700, onTap: () => _selectSemester(1)),
                 DashboardButton(label: "Semester 2", subLabel: "End of Year", icon: Icons.nightlight_round, color: Colors.indigo, onTap: () => _selectSemester(2)),
              ],

              if (_selectedYear != null && _selectedSemester != null) ...[
                 CourseListView(
                   courses: (_isSimulationMode ? _simulatedCourses : _allCourses).where((c) => c.year == _selectedYear && c.semester == _selectedSemester).toList(),
                   isDark: isDarkMode,
                   onEdit: _showEditCourseDialog,
                   onGrade: _showGradeDialog,
                 ),
                 if (!_isSimulationMode) ...[
                   const SizedBox(height: 16),
                   Center(
                     child: TextButton.icon(
                       onPressed: () => _showAddCourseDialog(_selectedYear!, _selectedSemester!),
                       icon: const Icon(Icons.add, color: Color(0xFF02569B)),
                       label: const Text("Add Custom Course", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF02569B))),
                       style: TextButton.styleFrom(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                         backgroundColor: const Color(0xFF02569B).withValues(alpha: 0.1),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                     ),
                   ),
                 ],
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

class GPATrendPainter extends CustomPainter {
  final List<double> gpas;
  final bool isDark;

  GPATrendPainter(this.gpas, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (gpas.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF02569B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF02569B)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    double widthStep = size.width / (gpas.length > 1 ? gpas.length - 1 : 1);

    double mapGpaToY(double gpa) {
      double normalized = (gpa - 0.0) / 4.0;
      return size.height - (normalized * (size.height - 20) + 10);
    }

    for (int i = 0; i < gpas.length; i++) {
      double x = i * widthStep;
      double y = mapGpaToY(gpas[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == gpas.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF02569B).withValues(alpha: 0.3),
        const Color(0xFF02569B).withValues(alpha: 0.0),
      ],
    );
    fillPaint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    if (gpas.length > 1) {
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);
    }

    for (int i = 0; i < gpas.length; i++) {
      double x = i * widthStep;
      double y = mapGpaToY(gpas[i]);
      canvas.drawCircle(Offset(x, y), 5.5, paint);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GPATrendPainter oldDelegate) {
    return oldDelegate.gpas != gpas || oldDelegate.isDark != oldDelegate.isDark;
  }
}