plugins {
    base
}

group = "sh.whoa.sutradhar"
version = "0.1.0-SNAPSHOT"

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
    dependsOn("verifyRepositoryFiles")
}
