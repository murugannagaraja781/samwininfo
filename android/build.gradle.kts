allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    val fixCompileSdk = {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                val method = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(androidExt, 36)
            } catch (_: Exception) {
                try {
                    androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType).invoke(androidExt, 36)
                } catch (_: Exception) {}
            }
        }
    }

    if (state.executed) {
        fixCompileSdk()
    } else {
        afterEvaluate {
            fixCompileSdk()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
