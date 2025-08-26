plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") version "2.1.0"
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.doorapp"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.doorapp"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs = listOf("-Xjvm-default=all")
    }

    kotlin {
        jvmToolchain(17)
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug") // ⚠️ Replace with release keystore before publishing
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // 🔥 Global exclusion to prevent duplicate class errors from core-common
    configurations.all {
        exclude(group = "com.google.android.play", module = "core-common")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation(platform("com.google.firebase:firebase-bom:33.2.1"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")

    implementation("androidx.multidex:multidex:2.0.1")

    implementation("com.google.android.play:core:1.10.3") {
        exclude(group = "com.google.android.play", module = "core-common")
    }
    implementation("com.google.android.play:core-ktx:1.8.1") {
        exclude(group = "com.google.android.play", module = "core-common")
    }

    // Supabase SDK (commented out for now)
    // implementation("com.github.supabase-community:supabase-kt:0.8.3")
}
flutter {
    source = "../.."
}
