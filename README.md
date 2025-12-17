# 📝 TodoList App (Flutter + Supabase)

A modern, cloud-synced **Todo List mobile application** built using **Flutter**.  
This project leverages **Supabase** for backend services (Auth & Database) and **GetX** for state management, offering a seamless and responsive user experience.

---

## ✨ Features

- **🔐 Authentication**: Secure Email/Password and Google Sign-In via Supabase.
- **☁️ Cloud Sync**: Real-time data synchronization across devices using Supabase Database.
- **📅 Task Management**: Organize tasks by categories:
  - **Inbox**: General tasks.
  - **Today**: Tasks due today.
  - **Upcoming**: Future tasks.
- **🎨 Modern UI/UX**:
  - Clean, minimalist design.
  - **Dark/Light Mode** support (System or User defined).
  - Smooth animations and transitions.
- **🔗 Deep Linking**: Handle external links (e.g., Password Reset) using `app_links`.
- **⚡ Performance**: Efficient state management with GetX.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Backend**: [Supabase](https://supabase.com/) (Auth, Database)
- **Local Storage**: [GetStorage](https://pub.dev/packages/get_storage) / [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Navigation**: GetX Configuration
- **Deep Linking**: [App Links](https://pub.dev/packages/app_links)
- **UI Components**:
  - [Google Nav Bar](https://pub.dev/packages/google_nav_bar) for bottom navigation.
  - [Card Loading](https://pub.dev/packages/card_loading) for skeletal loading states.

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

- Flutter SDK installed (Version 3.0.0 or higher recommended).
- A Supabase project set up.

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Abduldinata/project_flutter_todolist.git
   cd project_flutter_todolist
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   > [!IMPORTANT]
   > You must provide your own Supabase credentials for the app to function correctly.

   Open `lib/utils/constants.dart` and update the following values with your project's URL and Anon Key:

   ```dart
   // lib/utils/constants.dart
   const String supabaseUrl = 'YOUR_SUPABASE_URL';
   const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── controllers/      # State management (GetX Controllers)
├── models/           # Data models
├── screens/          # UI Screens (Auth, Home, Settings)
├── services/         # External services (Supabase, Connectivity)
├── theme/            # App theming and styles
├── utils/            # Constants, Routes, Helpers
├── widgets/          # Reusable UI widgets
└── main.dart         # Entry point
```

---

## 📄 License

This project is licensed under the MIT License – free to use, modify, and distribute.
