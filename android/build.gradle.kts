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

// 🚀 الكود المحدث: إجبار الحزم على إصدار 36 مباشرة وبدون أي تعارض مع حالة السيرفر
subprojects {
    if (project.hasProperty("android")) {
        val androidExtensions = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
        androidExtensions.compileSdkVersion(36)
    }
}
