// Reemplaza TODO el contenido de tu archivo con esto

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    // AÑADE ESTO para Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.avivamiento_app" // Coincide con tu nombre de proyecto
    compileSdk = 36 // Actualizado para cumplir dependencias (plugins requieren 35/36)

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.avivamiento_app"
        // Tus plugins (Jitsi, audio_service) requieren un SDK alto. 26 es un mínimo seguro.
        minSdk = 26
        targetSdk = 34 // O la versión que 'flutter doctor' recomiende
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"

        // ¡AQUÍ ESTÁ LA CORRECCIÓN DE MULTIDEX!
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(kotlin("stdlib-jdk7"))
    
    // ¡AQUÍ ESTÁ LA DEPENDENCIA DE MULTIDEX!
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Dependencias de Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-analytics")
}