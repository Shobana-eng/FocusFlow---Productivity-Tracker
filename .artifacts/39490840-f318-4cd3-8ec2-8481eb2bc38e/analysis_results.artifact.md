# Project Review: Student Productivity Tracker (FocusFlow)

I have performed a comprehensive review of the `student_productivity_tracker` project, covering both the Flutter frontend and the Flask backend.

## 1. Project Architecture Overview

### Flutter Frontend (`lib/`)
The project follows a standard Flutter feature-based or layer-based architecture:
- **`models/`**: Data classes like `TaskModel` and `UserModel` with Firestore serialization.
- **`services/`**: logic for Auth, Firestore, Notifications, and API communication.
- **`screens/`**: UI components categorized by features (Auth, Dashboard, AI, Analytics, etc.).
- **`widgets/`**: Reusable UI components (cards, buttons, navbar).
- **`themes/`**: Centralized styling using Material 3.

### Flask Backend (`backend/`)
A lightweight backend serving as a utility for AI-powered features:
- **`routes/`**: Handles authentication and productivity predictions.
- **`database.py`**: Manages a local SQLite database (`focusflow.db`).
- **`app.py`**: Entry point for the Flask server.

---

## 2. Key Findings & Issues

### A. Redundant Screens (Multiple Home Screens)
There are three different implementations of the Home screen, which leads to confusion and potential bugs:
1. [home_screen.dart](file:///C:/Users/shoba/StudioProjects/student_productivity_tracker/lib/screens/dashboard/home_screen.dart): **Primary.** Features AI prediction integration, Firestore task tracking, and modern UI.
2. [home-screen.dart](file:///C:/Users/shoba/StudioProjects/student_productivity_tracker/lib/screens/home/home-screen.dart): **Secondary.** Includes notification handling but uses a slightly older UI style.
3. [home_screen.dart](file:///C:/Users/shoba/StudioProjects/student_productivity_tracker/lib/screens/home_screen.dart): **Basic.** Likely a leftover prototype with hardcoded data.

### B. Dual Authentication Systems
The project currently implements two separate authentication mechanisms:
- **Firebase Auth**: Used by the primary UI (`AuthService`, `LoginScreen`). This is the industry standard for Flutter apps.
- **Flask/SQLite Auth**: Defined in `backend/routes/auth.py` and `ApiService.dart`.
> [!WARNING]
> Maintaining two auth systems causes data desync. A user registered via Firebase will not exist in the local SQLite database used by the backend.

### C. AI Integration Inconsistency
- **`AIScreen`**: The logic in `lib/screens/ai/ai_screen.dart` is **hardcoded**. It calculates scores using simple slider math in `setState` and does not call the backend.
- **`HomeScreen`**: The logic in `lib/screens/dashboard/home_screen.dart` correctly calls the Flask API via `ApiService` and saves results to Firestore.

### D. Under-utilized State Management
The `provider` package is included in `pubspec.yaml` but is not being used to manage global state in `main.dart`. Most screens rely on local `setState` and direct service singletons.

---

## 3. Recommendations for Improvement

### 1. Consolidate and Clean Up
- **Action**: Delete `lib/screens/home/home-screen.dart` and `lib/screens/home_screen.dart`.
- **Action**: Merge any unique logic (like notification cancellation) from the deleted files into the primary `lib/screens/dashboard/home_screen.dart`.

### 2. Unify Authentication
- **Action**: Remove the `/login` and `/register` routes from the Flask backend and the corresponding methods in `ApiService`.
- **Action**: Stick to **Firebase Auth** for all user management.

### 3. Fix AI Service Integration
- **Action**: Update `AIScreen` to use `ApiService.predict()` or `AIService` instead of hardcoded calculations.
- **Action**: Standardize the `baseUrl` in a central `AppConstants` file to avoid discrepancies between `10.0.2.2` (emulator) and `127.0.0.1`.

### 4. Implement Global State
- **Action**: Use `ChangeNotifierProvider` in `main.dart` to manage user data and task lists globally. This will make the app more responsive and reduce redundant Firestore reads.

### 5. Enhance the "AI" Backend
- **Action**: Replace the heuristic `if-else` scoring in `backend/routes/prediction.py` with a machine learning model (e.g., a simple Linear Regression or Random Forest model using `scikit-learn`) trained on student productivity data.

---

## 4. Next Steps
I can help you implement these improvements one by one. Which area would you like to focus on first?
- [ ] **Cleaning up redundant files**
- [ ] **Integrating AI Screen with the Backend**
- [ ] **Implementing State Management with Provider**
