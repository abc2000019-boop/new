allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

// 🚀 الكود الحاسم لإجبار حزمة file_picker وكافة الحزم على التجميع بإصدار 36 رغماً عن الكاش
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExtensions = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            androidExtensions.compileSdkVersion(36)
        }
    }
}
