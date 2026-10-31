import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

layout.buildDirectory.set(File(rootProject.projectDir.parentFile, "build/app"))

android {
    namespace = "com.tintinos.stoki"
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
        applicationId = "com.tintinos.stoki"
        minSdk = 24  // Firebase nécessite minimum 21, mais 24+ recommandé
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            // Configuration debug par défaut
        }
        release {
            // Clé de publication si android/key.properties existe, sinon clé debug
            signingConfig = if (keystorePropertiesFile.exists())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
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