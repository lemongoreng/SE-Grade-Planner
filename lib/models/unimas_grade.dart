class UnimasGrade {
  static double convertGradeToPoint(String grade) {
    switch (grade) {
      case 'A':  return 4.00;
      case 'A-': return 3.67;
      case 'B+': return 3.33;
      case 'B':  return 3.00;
      case 'B-': return 2.67;
      case 'C+': return 2.33;
      case 'C':  return 2.00;
      case 'C-': return 1.67; // Depends on faculty, sometimes fail
      case 'D':  return 1.00;
      case 'F':  return 0.00;
      default:   return 0.00;
    }
  }
}