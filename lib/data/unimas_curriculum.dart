import '../models/course.dart';

class UnimasCurriculum {
  static List<Course> get allCourses => [
    // --- YEAR 1 SEMESTER 1 ---
    Course(code: 'TMF1414', name: 'Introduction to Programming', creditHours: 4, year: 1, semester: 1),
    Course(code: 'TMF1814', name: 'Discrete Mathematics', creditHours: 4, year: 1, semester: 1),
    Course(code: 'TMF1913', name: 'System Analysis and Design', creditHours: 3, year: 1, semester: 1),
    Course(code: 'PBI1112', name: 'Preparatory English 1', creditHours: 2, year: 1, semester: 1),
    Course(code: 'MPU3222', name: 'Foundation of Entrepreneurship Inculturation', creditHours: 2, year: 1, semester: 1),

    // --- YEAR 1 SEMESTER 2 ---
    Course(code: 'TMF1434', name: 'Data Structure and Algorithm', creditHours: 4, year: 1, semester: 2),
    Course(code: 'TMF1214', name: 'Computer Architecture', creditHours: 4, year: 1, semester: 2),
    Course(code: 'TMF1883', name: 'Automata Theory', creditHours: 3, year: 1, semester: 2),
    Course(code: 'TMF1254', name: 'Communication and Computer Network', creditHours: 4, year: 1, semester: 2),
    Course(code: 'PBI1122', name: 'Preparatory English 2', creditHours: 2, year: 1, semester: 2),
    Course(code: 'MPUXXX2', name: 'Credited Co-curricular', creditHours: 2, year: 1, semester: 2),

    // --- YEAR 2 SEMESTER 1 ---
    Course(code: 'TMF2034', name: 'Database Concept & Design', creditHours: 4, year: 2, semester: 1),
    Course(code: 'TMF2234', name: 'Operating System', creditHours: 4, year: 2, semester: 1),
    Course(code: 'TMF2243', name: 'Object Oriented Software Engineering', creditHours: 3, year: 2, semester: 1),
    Course(code: 'PBIXXX2', name: 'English Course 1', creditHours: 2, year: 2, semester: 1),
    Course(code: 'ABCXXX3', name: 'Elective from another faculty', creditHours: 3, year: 2, semester: 1),

    // --- YEAR 2 SEMESTER 2 ---
    Course(code: 'TMF2954', name: 'Java Programming', creditHours: 4, year: 2, semester: 2),
    Course(code: 'TMF2263', name: 'Human Computer Interaction', creditHours: 3, year: 2, semester: 2),
    Course(code: 'TMF2964', name: 'Software Economics', creditHours: 4, year: 2, semester: 2),
    Course(code: 'TMF2973', name: 'Software Requirement Engineering', creditHours: 3, year: 2, semester: 2),
    Course(code: 'PBIXXX2', name: 'English Course 2', creditHours: 2, year: 2, semester: 2),
    Course(code: 'MPU3182', name: 'Philosophy and Current Issues', creditHours: 2, year: 2, semester: 2),

    // --- YEAR 3 SEMESTER 1 ---
    Course(code: 'TMF3973', name: 'Web Application Development', creditHours: 3, year: 3, semester: 1),
    Course(code: 'TMA3093', name: 'Formal Method', creditHours: 3, year: 3, semester: 1),
    Course(code: 'TMA3084', name: 'Software Engineering Laboratory', creditHours: 4, year: 3, semester: 1),
    Course(code: 'TMF3963', name: 'Ethics and Professionalism', creditHours: 2, year: 3, semester: 1),
    Course(code: 'TMF3113', name: 'Project Management', creditHours: 3, year: 3, semester: 1),

    // --- YEAR 3 SEMESTER 2 (INTERNSHIP) ---
    Course(code: 'TMF39412', name: 'Industrial Training', creditHours: 12, year: 3, semester: 2),

    // --- YEAR 4 SEMESTER 1 ---
    Course(code: 'TMA4093', name: 'Software Maintenance and Configuration', creditHours: 3, year: 4, semester: 1),
    Course(code: 'TMF4913', name: 'Final Year Project 1', creditHours: 3, year: 4, semester: 1),
    Course(code: 'TMF4034', name: 'Technopreneurship', creditHours: 4, year: 4, semester: 1),
    Course(code: 'ABCXXX3', name: 'Elective from another faculty', creditHours: 3, year: 4, semester: 1),

    // --- YEAR 4 SEMESTER 2 ---
    Course(code: 'TMA4103', name: 'Software Testing', creditHours: 3, year: 4, semester: 2),
    Course(code: 'TMA4113', name: 'Software Security Engineering', creditHours: 3, year: 4, semester: 2),
    Course(code: 'TMF4935', name: 'Final Year Project 2', creditHours: 5, year: 4, semester: 2),
    Course(code: 'ABCXXX3', name: 'Elective from another faculty', creditHours: 3, year: 4, semester: 2),
  ];
}