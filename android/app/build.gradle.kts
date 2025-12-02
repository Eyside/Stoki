plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← AJOUT FIREBASE
}

android {
    namespace = "com.example.stoki"
    compileSdk = 36
    ndkVersion = "27.1.12297006"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.stoki"
        minSdk = flutter.minSdkVersion  // Firebase nécessite minimum 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true  // ← AJOUT pour Firebase
    }

    buildTypes {
        debug {
            // Configuration debug par défaut
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ✅ FIX PERMANENT pour le chemin de l'APK
tasks.whenTaskAdded {
    if (name == "assembleDebug" || name == "assembleRelease") {
        doLast {
            val flutterApkDir = File(rootProject.projectDir.parent, "build/app/outputs/flutter-apk")
            flutterApkDir.mkdirs()

            val sourceApk = File(project.layout.buildDirectory.get().asFile, "outputs/apk/debug/app-debug.apk")
            val destApk = File(flutterApkDir, "app-debug.apk")

            if (sourceApk.exists()) {
                sourceApk.copyTo(destApk, overwrite = true)
                println("✅ APK copié automatiquement vers: ${destApk.absolutePath}")
            }

            // Copie aussi pour release
            val sourceApkRelease = File(project.layout.buildDirectory.get().asFile, "outputs/apk/release/app-release.apk")
            val destApkRelease = File(flutterApkDir, "app-release.apk")

            if (sourceApkRelease.exists()) {
                sourceApkRelease.copyTo(destApkRelease, overwrite = true)
                println("✅ APK release copié automatiquement")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase dépendances (si nécessaires directement)
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("androidx.multidex:multidex:2.0.1")  // Pour MultiDex
}
