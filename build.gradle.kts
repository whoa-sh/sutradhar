plugins {
    base
    java
    `maven-publish`
}

group = "sh.whoa.sutradhar"
version = "0.1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

sourceSets {
    named("main") {
        java.srcDir("src/main/java")
        java.srcDir("examples/jvm/src/main/java")
    }
    named("test") {
        java.srcDir("packages/jvm/src/test/java")
        resources.srcDir("contracts/fixtures")
    }
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher:1.10.2")
}

tasks.test {
    useJUnitPlatform()
}

tasks.register<JavaExec>("runM11JvmExample") {
    group = "application"
    description = "Runs the M11 JVM consumer example."
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("sh.whoa.sutradhar.examples.M11ConsumerExample")
}

tasks.register<Exec>("protoLint") {
    group = "verification"
    description = "Runs buf lint for protobuf contracts."
    commandLine("buf", "lint")
}

tasks.register<Exec>("protoGenerate") {
    group = "build"
    description = "Runs buf generate for protobuf outputs."
    commandLine("buf", "generate")
}

tasks.register<Exec>("protoCheckFreshness") {
    group = "verification"
    description = "Fails if generated outputs are stale after buf generate."
    dependsOn("protoGenerate")
    commandLine("git", "diff", "--exit-code", "--", "packages/go", "packages/typescript/src/generated")
}

tasks.register("verifyRepositoryFiles") {
    group = "verification"
    description = "Checks that required repository files exist."

    val requiredFiles = listOf(
        "README.md",
        "LICENSE.txt",
        "NOTICE",
        "Makefile",
        "Makefile.windows",
        "scripts/README.md",
        "buf.yaml",
        "buf.gen.yaml",
        "contracts/topics.yaml",
        "contracts/headers.yaml",
        "contracts/validation.yaml",
        "contracts/metadata-prefixes.yaml",
        "proto/sh/whoa/sutradhar/common/v1/common_enums.proto",
        "proto/sh/whoa/sutradhar/common/v1/trace_context.proto",
        "proto/sh/whoa/sutradhar/common/v1/tenant_context.proto",
        "proto/sh/whoa/sutradhar/common/v1/metadata.proto",
        "proto/sh/whoa/sutradhar/common/v1/idempotency_context.proto",
        "proto/sh/whoa/sutradhar/common/v1/failure_context.proto",
        "proto/sh/whoa/sutradhar/notification/v1/notification_enums.proto",
        "proto/sh/whoa/sutradhar/notification/v1/recipient_ref.proto",
        "proto/sh/whoa/sutradhar/notification/v1/notification_target.proto",
        "proto/sh/whoa/sutradhar/notification/v1/notification_request.proto",
        "proto/sh/whoa/sutradhar/notification/v1/lifecycle_event.proto",
        "proto/sh/whoa/sutradhar/template/v1/template_enums.proto",
        "proto/sh/whoa/sutradhar/template/v1/template_ref.proto",
        "proto/sh/whoa/sutradhar/template/v1/render_command.proto",
        "proto/sh/whoa/sutradhar/template/v1/render_result.proto",
        "proto/sh/whoa/sutradhar/provider/v1/provider_enums.proto",
        "proto/sh/whoa/sutradhar/provider/v1/delivery_command.proto",
        "proto/sh/whoa/sutradhar/provider/v1/delivery_event.proto",
        "proto/sh/whoa/sutradhar/preference/v1/preference_enums.proto",
        "proto/sh/whoa/sutradhar/preference/v1/preference_event.proto",
        "proto/sh/whoa/sutradhar/preference/v1/preference_decision.proto",
    )

    inputs.files(requiredFiles.map { layout.projectDirectory.file(it) })

    doLast {
        requiredFiles.forEach { path ->
            val file = layout.projectDirectory.file(path).asFile
            require(file.isFile) { "Missing required repository file: $path" }
        }
    }
}

tasks.named("check") {
    dependsOn("protoLint")
    dependsOn("verifyRepositoryFiles")
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
            groupId = project.group.toString()
            artifactId = "sutradhar-proto-jvm"
            version = project.version.toString()
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/whoa-sh/sutradhar")
            credentials {
                username = providers.environmentVariable("GITHUB_ACTOR").orNull
                    ?: providers.environmentVariable("MAVEN_USERNAME").orNull
                password = providers.environmentVariable("GITHUB_TOKEN").orNull
                    ?: providers.environmentVariable("MAVEN_PASSWORD").orNull
            }
        }
    }
}
