allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Simplified build directory configuration for CI/CD stability
// rootProject.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir("../../build"))

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
