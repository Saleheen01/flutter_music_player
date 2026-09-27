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
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.methods.firstOrNull { it.name == "getNamespace" }
                val setNamespace = android.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 }
                if (getNamespace != null && setNamespace != null) {
                    val currentNamespace = getNamespace.invoke(android)
                    if (currentNamespace == null) {
                        val fallbackNamespace = "com.example.${project.name.replace("-", "_").replace(":", "_")}"
                        setNamespace.invoke(android, fallbackNamespace)
                    }
                }
            } catch (_: Exception) {}

            try {
                val compileOptions = android.javaClass.methods.firstOrNull { it.name == "getCompileOptions" }?.invoke(android)
                if (compileOptions != null) {
                    val setSource = compileOptions.javaClass.methods.firstOrNull { it.name == "setSourceCompatibility" }
                    val setTarget = compileOptions.javaClass.methods.firstOrNull { it.name == "setTargetCompatibility" }
                    setSource?.invoke(compileOptions, JavaVersion.VERSION_17)
                    setTarget?.invoke(compileOptions, JavaVersion.VERSION_17)
                }
            } catch (_: Exception) {}
        }

        tasks.matching { it.name.startsWith("process") && it.name.endsWith("Manifest") }.configureEach {
            doFirst {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    if (content.contains("package=")) {
                        val cleanedContent = content.replace(Regex("""\s*package="[^"]*""""), "")
                        manifestFile.writeText(cleanedContent)
                    }
                }
            }
        }
    }

    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
    tasks.withType(JavaCompile::class.java).configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
