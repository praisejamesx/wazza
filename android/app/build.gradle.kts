plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.wazza"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.wazza"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // CRITICAL: Add packaging options to include native libraries
    packagingOptions {
        pickFirst("**/*.so")
        pickFirst("**/libc++_shared.so")
    }

    buildTypes {
        release {
            // TODO: Change to your own signing config later
            signingConfig = signingConfigs.getByName("debug")
            
            // CRITICAL: Disable code shrinking for now
            isMinifyEnabled = false
            isShrinkResources = false
            
            // OPTIONAL: Add ProGuard rules file if you have one
            // proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.21")
}