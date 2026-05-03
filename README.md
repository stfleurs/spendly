# Spendly

A modern, cross-platform personal finance tracker built with Flutter and Firebase.

## Getting Started

This project is structured using a feature-based Riverpod architecture.

### 1. Install Dependencies
Make sure you have Flutter installed. Then run:
```bash
flutter pub get
```

### 2. Set up Firebase
Firebase dependencies are already installed (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`), but you need to connect your Firebase project.

1. Ensure you have the Firebase CLI installed and logged in:
   ```bash
   firebase login
   ```
2. Activate the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Configure your project:
   ```bash
   flutterfire configure
   ```
   *Select your Spendly Firebase project and the platforms you want to support (Android/iOS).*

4. Once `firebase_options.dart` is generated in the `lib` folder, open `lib/main.dart` and uncomment the Firebase initialization code:
   ```dart
   import 'firebase_options.dart';

   // Inside void main()
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

### 3. Run the App
```bash
flutter run
```

## Architecture

- **State Management**: Riverpod (`flutter_riverpod`)
- **Models**: Freezed (`freezed_annotation`, `json_annotation`)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Folder Structure**: Feature-based (`lib/features/...`), adhering to `Repository -> Provider -> UI`.
