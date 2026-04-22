# Aura Frontend

A stunning Flutter-based mobile and web application featuring high-fidelity UI, Google Maps integration, and a glassmorphic sliding interface.

## 🚀 Key Features
- **Interactive Map**: Background Google Maps layer with custom markers.
- **Draggable Drawer**: A premium sliding up panel for task management and alerts.
- **Modern UI**: Custom navigation bar with a centered action notch, using Poppins and Inter typography.
- **Multi-Platform**: Fully compatible with Android (Mobile) and Web Browsers.

## 🛠 Tools & Dependencies
- **Flutter SDK**: `3.41.5`
- **Google Maps**: `google_maps_flutter`
- **Animation/UI**: `sliding_up_panel`, `google_fonts`, `flutter_svg`
- **Typography**: Poppins (Headers), Inter (Body)

## 🏗 Setup & Installation

### 1. Prerequisites
- **Flutter SDK**: Installed at `C:\src\flutter`
- **Android Studio**: With Flutter and Dart plugins installed.
- **Java**: Forced to use Android Studio's **JBR (Java 21)** for Gradle stability.

### 2. Running the App
- **From Terminal**: 
  ```powershell
  C:\src\flutter\bin\flutter.bat run
  ```
- **From Android Studio**: Select your phone/emulator and click the green **Play** button.

### 3. Native Build (Android)
The project is configured to use **NDK 30.0.14904198** to ensure stable CMake compilation of the map components.

---

## 🎨 How to Add New Features

### Adding a New Screen
1. Create a new file in `lib/screens/`.
2. Import `package:flutter/material.dart`.
3. Link it to the `CustomBottomNavBar` in `lib/widgets/bottom_nav_bar.dart` by updating the index logic in `home_screen.dart`.

### Changing API Keys
- **Android**: `android/app/src/main/AndroidManifest.xml`
- **Web**: `web/index.html`

### Customizing Styles
Update the constants in `lib/screens/home_screen.dart` or create a dedicated `lib/theme/` if expanding the design system.
