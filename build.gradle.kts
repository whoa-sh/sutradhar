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
