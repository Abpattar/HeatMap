# Project Memory (Aura Frontend)

This document preserves the context, design decisions, and critical environment fixes for this project to ensure seamless continuity in future sessions.

## 🎨 Design Language
- **Aesthetic**: Premium Glassmorphism / Modern Mint.
- **Colors**:
  - Primary Background: `#F1FDF5` (Mint White)
  - Alert Card: Dark Red Linear Gradient
  - Standard Card: White with 5% alpha shadow.
- **Typography**:
  - `GoogleFonts.poppins`: Used for headers and primary UI titles.
  - `GoogleFonts.inter`: Used for body text and task details.
- **Shapes**: High border-radius (24px - 30px) for a soft, premium feel.

## 🔧 Critical Environment Fixes
To avoid a broken build, these configurations **must not** be reverted:
1. **Gradle Java Home**: Forced to `C:\Program Files\Android\Android Studio\jbr` in `gradle.properties` to ensure Java 21 compatibility.
2. **NDK Override**: Forced `ndkVersion = "30.0.14904198"` in `app/build.gradle.kts` to bypass the corrupted NDK 28 installation on the local machine.
3. **IDE Module Fix**: `aura_frontend.iml` is set to `type="FLUTTER_MODULE_TYPE"`.

## [x] Integrate Animation with Slide Button <!-- id: 7 -->
    - [x] Update `SlideToAcceptButton` or its parent to trigger the animation <!-- id: 8 -->
    - [x] Implement the transition logic from image to center to pulsating to tick <!-- id: 9 -->
- [/] Verification <!-- id: 10 -->
## 📍 Navigation & State
- **Home Screen**: A `SlidingUpPanel` overlaying a `GoogleMap`.
  - **Gesture Shield**: Wrapped in `PointerInterceptor` to prevent gestures from leaking to the Google Map on Web.
  - **Interactive Stack**: Uses `StackedKpiCards` widget for a swipeable, depth-aware card layout ("send to back" style).
- **Bottom Navigation**: Uses the `curved_labeled_navigation_bar` package.
  - **Animation**: Optimized for smoothness (400ms duration, `Curves.easeInOutCubic`).

## 🔑 Infrastructure
- **SDK Path**: `C:\src\flutter`
- **Main Entry**: `lib/main.dart` -> `AuraApp` (Stateless)
- **Primary Screen**: `HomeScreen` (Stateful)
- **New Dependency**: `pointer_interceptor: ^0.10.1+1` for Web gesture management.
