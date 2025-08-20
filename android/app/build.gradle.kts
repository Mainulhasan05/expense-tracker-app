plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← ADD THIS LINE
}

android {
    namespace = "com.example.expense_tracker"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Updated
        targetCompatibility = JavaVersion.VERSION_17  // Updated
    }

    kotlinOptions {
        jvmTarget = "17"  // Updated
    }

    defaultConfig {
        applicationId = "com.example.expense_tracker"
        minSdk = 23
        targetSdk = 35  // Match compileSdk
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidx:2.0.1")
}