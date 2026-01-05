plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

layout.buildDirectory.set(File(rootProject.projectDir.parentFile, "build/app"))

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
        minSdk = 24  // Firebase nécessite minimum 21, mais 24+ recommandé
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
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

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM pour gérer toutes les versions Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // Firebase Analytics (version gérée par BOM)
    implementation("com.google.firebase:firebase-analytics")

    // MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
}