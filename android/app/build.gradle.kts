import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.samwininfo.app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    val isAdminBuild = project.hasProperty("adminApp") || 
                       (project.findProperty("target")?.toString()?.contains("admin_main") == true)

    defaultConfig {
        if (isAdminBuild) {
            applicationId = "com.samwininfo.admin"
            manifestPlaceholders["appName"] = "SamWin Admin"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_admin"
        } else {
            applicationId = "com.samwininfo.app"
            manifestPlaceholders["appName"] = "SamWin"
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    signingConfigs {
        create("release") {
            val keyFile = keystoreProperties.getProperty("storeFile") ?: "upload-keystore.jks"
            storeFile = file(keyFile)
            storePassword = keystoreProperties.getProperty("storePassword") ?: "TenkasiDreams@2026"
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "upload"
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: "TenkasiDreams@2026"
        }
    }

    buildTypes {
        release {
            ndk {
                debugSymbolLevel = "none"
            }
            signingConfig = signingConfigs.getByName("release")
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
