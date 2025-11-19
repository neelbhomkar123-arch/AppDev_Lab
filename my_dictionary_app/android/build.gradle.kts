// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    // Remove explicit versions for plugins already managed by Flutter/Gradle settings
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false // Version removed here to fix conflict
    
    // Keep Google Services version explicit as it is an external addition
    id("com.google.gms.google-services") version "4.4.2" apply false
    
    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")  apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}