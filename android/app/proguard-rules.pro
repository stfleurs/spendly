# Flutter-specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Freezed / JSON serializable models
-keep class receet.pro.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Suppress warnings for missing classes during R8 shrinking
-dontwarn com.google.android.play.core.**
-dontwarn com.google.mlkit.vision.text.**
