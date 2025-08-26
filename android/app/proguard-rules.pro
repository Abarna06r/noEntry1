# ✅ Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.view.** { *; }

# ✅ Keep Supabase + Coroutines
-keep class io.supabase.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ✅ Keep Firebase Auth + Firestore
-keep class com.google.firebase.** { *; }
-keep class com.google.auth.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ✅ Keep Play Core classes (fixes R8 missing class errors)
-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# ✅ Keep JSON (used by Supabase + Firebase)
-keep class org.json.** { *; }
-dontwarn org.json.**

# ✅ Keep Kotlin reflection
-keepclassmembers class kotlin.Metadata { *; }
-dontwarn kotlin.**

# ✅ Keep your app package
-keep class com.example.doorapp.** { *; }

# ✅ Prevent warnings from lambda/metainf
-dontwarn javax.annotation.**
-dontwarn sun.misc.**

# ✅ Optional: Kotlin serialization (if used)
-keep class kotlinx.serialization.** { *; }

# ✅ Optional: Jetpack Compose (if used)
-keep class androidx.compose.** { *; }
-dontwarn androidx.compose.**
