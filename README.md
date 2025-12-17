# 🎓 UNIMAS SE Grade Planner
[![Download for Android](https://img.shields.io/badge/Download%20for-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/lemongoreng/SE-Grade-Planner/releases/latest)

A professional Flutter mobile application designed specifically for **Software Engineering students at Universiti Malaysia Sarawak (UNIMAS)**. 

This tool helps students track their academic performance, forecast required grades to hit CGPA targets, and manage their 4-year curriculum roadmap.

## 🚀 Key Features

### 📚 Pre-loaded Curriculum
* **Complete Roadmap:** Contains the full list of subjects (Code, Name, Credit Hours) from Year 1 to Year 4 based on the official UNIMAS Software Engineering Guidebook.
* **Semester Organization:** Courses are automatically grouped by Year and Semester (e.g., "Year 2 Semester 1") for easy navigation.

### 📊 Advanced Calculation
* **Real-time CGPA:** Instantly updates your pointer as you input grades.
* **Target GPA Calculator:** A forecasting tool that answers: *"What GPA do I need this semester to reach a CGPA of 3.50?"*

### 💾 Smart Persistence
* **Auto-Save:** Grades are saved locally using `SharedPreferences`. You never lose your data, even if you close the app.
* **Dark Mode:** Fully supported dark theme that respects your system settings or can be toggled manually.

---

## 🛠️ Tech Stack
* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Architecture:** MVC (Model-View-Controller)
* **State Management:** `setState` with optimized Memoization
* **Local Storage:** `shared_preferences`
* **IDE:** VS Code

---

## 📂 Project Structure
The codebase follows industry-standard engineering practices:

```text
lib/
├── data/
│   └── unimas_curriculum.dart   # Hardcoded subject list & credit hours
├── models/
│   ├── course.dart              # Data model for Course object
│   └── unimas_grade.dart        # Logic for converting Grades to Points (A = 4.0)
├── screens/
│   └── home_screen.dart         # Main UI (Optimized with Memoization)
├── utils/
│   └── calculator_logic.dart    # Pure logic for Target GPA calculations
│   └── pdf_generator.dart       # Service to generate & print PDF reports
├── main.dart                    # Application Entry Point & Theme Logic

🏁 Getting Started
Prerequisites
1. Flutter SDK installed.
2. VS Code or Android Studio.

Installation
1. Clone the repository
git clone [https://github.com/lemongoreng/SE-Grade-Planner.git](https://github.com/lemongoreng/SE-Grade-Planner.git)

2. Navigate to the project folder
cd SE-Grade-Planner

3. Install dependencies
This command downloads all required packages (PDF, Printing, Shared Preferences, etc.):
flutter pub get

4. Run the app
flutter run

⚙️ Development Notes
Changing the App Icon: If you replace `assets/icon.png`, run this command to regenerate the launcher icons for Android and iOS:
dart run flutter_launcher_icons

🗺️ Roadmap
[x] Implement Core Curriculum (Year 1-4)

[x] Add Data Persistence (Save/Load Grades)

[x] Add Target GPA Calculator

[x] Add Dark Mode Support

[x] Add "Edit Course" feature (for electives)

[x] Export Data to PDF

🤝 Contributing
Contributions are welcome! If you notice a change in the UNIMAS curriculum (e.g., a credit hour update), please open an issue or submit a pull request.
