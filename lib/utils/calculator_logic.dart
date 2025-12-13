class CalculatorLogic {
  /// Calculates what GPA you need this semester to hit a Target CGPA.
  /// 
  /// Formula: 
  /// (Target CGPA * Total Credits) - (Current Points) / Semester Credits
  static double calculateRequiredGPA({
    required double currentCGPA,
    required int currentCreditsEarned,
    required double targetCGPA, 
    required int creditsThisSem,
  }) {
    // 1. Total credits you will have AFTER this semester
    int totalCredits = currentCreditsEarned + creditsThisSem;

    // 2. The total quality points you need to have by the end
    double totalPointsNeeded = targetCGPA * totalCredits;

    // 3. The quality points you ALREADY have
    double currentPoints = currentCGPA * currentCreditsEarned;

    // 4. The points you need to earn just in this semester
    double pointsNeededThisSem = totalPointsNeeded - currentPoints;

    // 5. The GPA required for this semester
    double requiredGPA = pointsNeededThisSem / creditsThisSem;

    // Safety: Cap the result (You can't get more than 4.00 or less than 0.00)
    if (requiredGPA > 4.00) return requiredGPA; // We return the high number so UI can show red warning
    if (requiredGPA < 0.00) return 0.00;

    return requiredGPA;
  }
}