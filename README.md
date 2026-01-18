# Employee Management App

A Small Flutter MVVM application for managing employee records with full CRUD functionality and Optimistic UI.
API: https://dummy.restapiexample.com/

<img src="screenshots/home.jpg" alt="App Screenshot" width="300">

## Features

- **Employee List** - View all employees with refresh button
- **Employee Details** - View detailed information
- **Create** - Add a new employee
- **Update** - Edit existing employee information
- **Delete** - Remove an existing employee with confirmation
- **Optimistic UI** - Instant feedback, rollback on failure
- **Error Management** - Proper error handling for CRUD operations - snackbar style non blocking the main UI with retry and close actions
- **Success messages** clear feedback in case of success

## Architecture

```
lib/
├── models/
│   └── employee.dart          # Data model
├── services/
│   └── api_service.dart       # API communication
├── viewmodels/
│   └── employee_view_model.dart  # Business logic & state
└── views/
    ├── employee_list_screen.dart
    ├── employee_detail_screen.dart
    ├── employee_form_screen.dart
    └── widgets/
        └── error_view.dart    # Reusable error component
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.10+ |
| State Management | Provider + ChangeNotifier |
| Architecture | MVVM |
| HTTP Client | http package |

## Getting Started

### Prerequisites

- VSCode: 1.108.0
- Flutter SDK 3.10.7+
- cupertino_icons: ^1.0.8
- http: ^1.6.0
- provider: ^6.1.5

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd flutter_employee
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Optimistic UI

All CRUD operations use Optimistic UI for instant feedback:

1. **Create**: Add immediately with temp ID → Replace with real ID on success
2. **Update**: Apply changes instantly → Rollback on failure
3. **Delete**: Remove instantly → Restore on failure
