plugins {
    base
}

group = "sh.whoa.sutradhar"
version = "0.1.0-SNAPSHOT"

tasks.register("verifyPlanningFiles") {
    group = "verification"
    description = "Checks that required planning and tracker files exist."

    val requiredFiles = listOf(
        ".agents/plans/sutradhar-grill-decision-log.md",
        ".agents/plans/sutradhar-comprehensive-implementation-plan.md",
        ".agents/plans/sutradhar-technology-and-tooling-matrix.md",
        ".agents/tracker.md",
        "AGENTS.md",
    )

    inputs.files(requiredFiles.map { layout.projectDirectory.file(it) })

    doLast {
        requiredFiles.forEach { path ->
            val file = layout.projectDirectory.file(path).asFile
            require(file.isFile) { "Missing required planning file: $path" }
        }
    }
}

tasks.named("check") {
    dependsOn("verifyPlanningFiles")
}
