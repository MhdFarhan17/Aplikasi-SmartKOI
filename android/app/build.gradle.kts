import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

fun localProperties(key: String, file: String = "local.properties"): String {
    val properties = Properties()
    val localPropertiesFile = rootProject.file(file)
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { properties.load(it) }
    }
    return properties.getProperty(key) ?: ""
}

android {
    namespace = "com.example.smartkoi"
    compileSdk = flutter.compileSdkVersion.toInt()
    // ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.smartkoi"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = localProperties("flutter.versionCode").toIntOrNull() ?: 1
        versionName = localProperties("flutter.versionName") ?: "1.0"
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Import the BoM for the Firebase platform
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))

    // Add the dependency for the Performance Monitoring library
    // When using the BoM, you don't specify versions in Firebase library dependencies
    implementation("com.google.firebase:firebase-perf")
}
