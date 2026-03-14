plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    // Gson for JSON parsing
    implementation("com.google.code.gson:gson:2.10.1")

    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

android {
    namespace = "com.simpurrapps.quran_jarr"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.simpurrapps.quran_jarr"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 64-bit only architectures for smaller APK
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    signingConfigs {
        create("release") {
            // Read from keystore.properties if it exists
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            if (keystorePropertiesFile.exists()) {
                val lines = keystorePropertiesFile.readLines()
                val props = lines.associate {
                    val parts = it.split("=")
                    parts[0] to parts[1]
                }
                storeFile = file(props["storeFile"]!!)
                storePassword = props["storePassword"]!!
                keyAlias = props["keyAlias"]!!
                keyPassword = props["keyPassword"]!!
            }
        }
    }

    buildTypes {
        release {
            // Use release signing config if keystore exists
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // Enable code shrinking and obfuscation
            isMinifyEnabled = true
            isShrinkResources = true

            // ProGuard rules for Flutter
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Enable bundle optimization for smaller AAB size
    bundle {
        language {
            // Enable language splitting for smaller downloads
            enableSplit = false
        }
        density {
            // Enable density splitting
            enableSplit = true
        }
        abi {
            // Enable ABI splitting
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}
