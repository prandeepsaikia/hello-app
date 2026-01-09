
import com.github.spotbugs.snom.Confidence
import com.github.spotbugs.snom.Effort
import com.github.spotbugs.snom.SpotBugsTask


plugins {
    java
    application
    checkstyle
    id("com.github.spotbugs") version "6.4.8"

}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(25))
    }
}


application {
    mainClass = "org.hawk.HelloApp"
}


group = "org.hawk.hello-app"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.13.4")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}

tasks.jar {
    archiveFileName.set("hello-app.jar")
    manifest {
        attributes(
            "Main-Class" to application.mainClass.get()
        )
    }
}

tasks.withType<Checkstyle>().configureEach {
    reports {
        xml.required.set(false)
        html.required.set(true)
    }
}

tasks.withType<SpotBugsTask>().configureEach {
    val taskName = name  // safe: this is the SpotBugsTask

    reports.all { required.set(false) }

    if (!reports.names.contains("html")) {
        reports.create("html")
    }

    reports.matching { it.name == "html" }.configureEach {
        required.set(true)
        outputLocation.set(layout.buildDirectory.file("reports/spotbugs/spotbugs-$taskName.html"))
    }
}


checkstyle {
    toolVersion = "10.3.3"
    isIgnoreFailures = false
    configFile = file("config/checkstyle/checkstyle.xml")
    isShowViolations = true
}

spotbugs {
    effort.set(Effort.MAX)
    reportLevel.set(Confidence.LOW)
    ignoreFailures.set(false)
    showProgress.set(true)
}
