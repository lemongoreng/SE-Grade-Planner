# 🎓 UNIMAS SE Grade Planner (v2.0)
[![Download for Android](https://img.shields.io/badge/Download%20for-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/lemongoreng/SE-Grade-Planner/releases/latest)

A professional Flutter mobile application designed specifically for **Software Engineering students at Universiti Malaysia Sarawak (UNIMAS)**. 

This tool has been upgraded to a full **Student Dashboard** that helps students track academic performance, manage exam schedules, and forecast required grades to hit CGPA targets.

## 🚀 Key Features

### 📊 Student Dashboard (New in v2.0)
* **Exam Countdown:** Automatically tracks your nearest upcoming exam and displays a live countdown timer (Days/Hours).
* **Smart Navigation:** Courses are organized into Year/Semester folders to reduce clutter.
* **Quick Stats:** At-a-glance view of your current CGPA and total credits earned.

### 🔔 Exam Management & Alerts
* **Exam Scheduling:** Set dates, times, and venues for every course.
* **Automated Reminders:** The app schedules local notifications to alert you before an exam starts.
* **Conflict Detection:** Visual indicators for courses that are "In Progress" or completed.

### 📚 Curriculum & Grades
* **Pre-loaded Roadmap:** Contains the full list of subjects from Year 1 to Year 4 based on the UNIMAS Software Engineering Guidebook.
* **Target GPA Calculator:** A forecasting tool that answers: *"What GPA do I need this semester to reach a CGPA of 3.50?"*

### 📄 Utilities
* **PDF Transcript Export:** Generate a professional "Unofficial Transcript" PDF grouped by semester and share it directly (WhatsApp, Email, Drive).
* **Smart Persistence:** Auto-saves all data (Grades, Dates, Venues) locally.
* **Dark Mode:** Fully supported dark theme for late-night study sessions.

---

## 🛠️ Tech Stack
* **Framework:** [Flutter](https://flutter.dev/) (Dart 3.0+)
* **Architecture:** Modular MVC (Widgets, Screens, Models, Utils)
* **Local Storage:** `shared_preferences`
* **Notifications:** `flutter_local_notifications` + `timezone`
* **PDF Generation:** `pdf` + `printing`
* **IDE:** VS Code

---

## 📂 Project Structure
The codebase has been refactored in v2.0 to follow clean architecture principles:

```text
lib/
├── data/
│   └── unimas_curriculum.dart   # Hardcoded subject list & credit hours
├── models/
│   ├── course.dart              # Data model for Course object
│   └── unimas_grade.dart        # Logic for converting Grades to Points (A = 4.0)
├── screens/
│   └── home_screen.dart         # Main Dashboard Controller
├── widgets/                     # Reusable UI Components
│   ├── cgpa_card.dart           # The top card showing CGPA stats
│   ├── dashboard_button.dart    # Navigation buttons (Year 1, Year 2...)
│   ├── exam_card.dart           # Countdown timer widget
│   └── semester_card.dart       # List view for specific semesters
├── utils/
│   ├── calculator_logic.dart    # Pure logic for Target GPA calculations
│   ├── notification_service.dart# Background service for scheduling alerts
│   └── pdf_generator.dart       # Service to generate & print PDF reports
└── main.dart                    # Application Entry Point & Theme Logic
```
🏁 Getting Started
Prerequisites
1. Flutter SDK installed.
2. VS Code or Android Studio.

Installation
1. Clone the repository
```text
   git clone [https://github.com/lemongoreng/SE-Grade-Planner.git](https://github.com/lemongoreng/SE-Grade-Planner.git)
```

2. Navigate to the project folder
```text
cd SE-Grade-Planner
```

3. Install dependencies
This command downloads all required packages (PDF, Printing, Shared Preferences, etc.):
```text
flutter pub get
```

4. Run the app
```text
flutter run
```

⚙️ Development Notes
* Notifications: This app uses flutter_local_notifications. If testing on Android 13+, ensure you grant notification permissions when prompted.
* Timezones: The app initializes the timezone database (tz.initializeTimeZones()) in main.dart to ensure exam alerts trigger correctly across different regions.

🗺️ Roadmap
[x] Implement Core Curriculum (Year 1-4)

[x] Add Data Persistence (Save/Load Grades)

[x] Add Target GPA Calculator

[x] Add Dark Mode Support

[x] Add "Edit Course" feature (for electives)

[x] Export Data to PDF

[x] Add Exam Countdown & Reminders (v2.0)

🤝 Contributing
Contributions are welcome! If you notice a change in the UNIMAS curriculum (e.g., a credit hour update), please open an issue or submit a pull request.
