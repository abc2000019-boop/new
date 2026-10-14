plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart1"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.smart1"
        minSdk = 21
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// 🚀 الكود السحري: إجبار جميع الحزم الخارجية (مثل file_picker) على التجميع بإصدار 36
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExtensions = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            androidExtensions.compileSdkVersion(36)
        }
    }
}
