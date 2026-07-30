import XCTest
@testable import SUPRA

@MainActor
final class BootstrapArchitectureTests: XCTestCase {
    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private var artifactOutputDirectory: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA_BOOTSTRAP_ARCHITECTURE_ARTIFACTS", isDirectory: true)
    }

    func testArchitectureGuardPublishesBootstrapArtifacts() throws {
        try prepareArtifactOutputDirectory()

        let summary = try ArchitectureGuard().validateAndPublish(
            sourceRoot: repositoryRoot,
            compositionRoot: SUPRACompositionRoot.shared,
            outputDirectory: artifactOutputDirectory
        )

        XCTAssertEqual(summary.validation.status, "PASS", summary.validation.violations.joined(separator: "\n"))
        XCTAssertTrue(summary.validation.noCompositionRootBackEdges)
        XCTAssertTrue(summary.validation.noForbiddenSharedAccessInsideInitializers)
        XCTAssertTrue(summary.validation.noDependencyCycle)
        XCTAssertTrue(summary.validation.activationSequenceValid)
        XCTAssertTrue(summary.graph.cycles.isEmpty)

        let expectedFiles = [
            "BOOTSTRAP_VALIDATION.json",
            "BOOTSTRAP_PROOF.json",
            "DEPENDENCY_GRAPH.json",
            "DEPENDENCY_GRAPH.md",
            "BOOTSTRAP_POLICY.md",
            "ARCHITECTURE_HEALTH.json",
            "BOOTSTRAP_EXECUTIVE_REPORT.md"
        ]

        for file in expectedFiles {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: artifactOutputDirectory.appendingPathComponent(file).path),
                "Missing generated artifact: \(file)"
            )
        }
    }

    func testBootstrapActivationSequenceIsDeterministic() {
        let root = SUPRACompositionRoot.shared
        root.loadRuntime()

        XCTAssertEqual(
            root.bootstrapEvents.map(\.state),
            [.creatingServices, .bindingDependencies, .publishingReferences, .activatingRuntime, .runtimeReady]
        )
    }

    private func prepareArtifactOutputDirectory() throws {
        if FileManager.default.fileExists(atPath: artifactOutputDirectory.path) {
            try FileManager.default.removeItem(at: artifactOutputDirectory)
        }
        try FileManager.default.createDirectory(at: artifactOutputDirectory, withIntermediateDirectories: true)
    }
}
