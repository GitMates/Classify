buildscript {
    // Stable Kotlin version compatible with Flutter 3.x
    val kotlin_version by extra("1.9.22")
    
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // FIX: Use stable AGP version 7.4.2, compatible with Gradle 7.6
        classpath("com.android.tools.build:gradle:7.4.2") 
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // Standard Google services version for Firebase
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}