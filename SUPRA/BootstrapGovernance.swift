import Foundation

enum BootstrapActivationState: String, Codable, CaseIterable {
    case creatingServices = "CREATE_SERVICES"
    case bindingDependencies = "BIND_DEPENDENCIES"
    case publishingReferences = "PUBLISH_REFERENCES"
    case activatingRuntime = "ACTIVATE_RUNTIME"
    case runtimeReady = "RUNTIME_READY"
}

struct BootstrapActivationEvent: Codable, Hashable {
    let state: BootstrapActivationState
    let timestamp: Date
    let detail: String
}

struct BootstrapDependencyEdge: Codable, Hashable {
    let from: String
    let to: String
    let kind: String
}

struct BootstrapServiceNode: Codable, Hashable {
    let name: String
    let filePath: String
    let initDependencies: [String]
    let lateBindings: [String]
    let forbiddenSharedDependenciesInInit: [String]
    let accessesCompositionRoot: Bool
    let activatesRuntimeInInit: Bool
}

struct BootstrapDependencyGraph: Codable {
    let root: String
    let generatedAt: Date
    let nodes: [BootstrapServiceNode]
    let edges: [BootstrapDependencyEdge]
    let initializationOrder: [String]
    let bindingOrder: [String]
    let activationSequence: [String]
    let cycles: [[String]]
    let missingDependencies: [String]
    let orphanServices: [String]
    let duplicateBindings: [String]
    let maxDepth: Int
}

struct BootstrapValidationReport: Codable {
    let generatedAt: Date
    let noCompositionRootBackEdges: Bool
    let noForbiddenSharedAccessInsideInitializers: Bool
    let noDependencyCycle: Bool
    let validInitializationOrder: Bool
    let noMissingDependencies: Bool
    let noOrphanServices: Bool
    let noDuplicateBindings: Bool
    let activationSequenceValid: Bool
    let violations: [String]
    let status: String
}

struct BootstrapProofReport: Codable {
    let generatedAt: Date
    let totalServices: Int
    let initializationOrder: [String]
    let dependencyDepth: Int
    let detectedCycles: [[String]]
    let bootstrapDurationMs: Int
    let servicesRequiringLateBinding: [String]
    let validationResult: String
    let activationSequence: [BootstrapActivationEvent]
}

struct ArchitectureHealthReport: Codable {
    let generatedAt: Date
    let status: String
    let healthScore: Double
    let governedServices: Int
    let violations: [String]
}

struct BootstrapExecutiveSummary {
    let graph: BootstrapDependencyGraph
    let validation: BootstrapValidationReport
    let proof: BootstrapProofReport
    let health: ArchitectureHealthReport
}

struct BootstrapAnalysis {
    let graph: BootstrapDependencyGraph
    let governedServiceNames: Set<String>
}

@MainActor
struct DependencyGraphGenerator {
    func generate(sourceRoot: URL, activationEvents: [BootstrapActivationEvent]) throws -> BootstrapAnalysis {
        try BootstrapAnalyzer(sourceRoot: sourceRoot).analyze(activationEvents: activationEvents)
    }
}

struct BootstrapValidator {
    func validate(graph: BootstrapDependencyGraph) -> BootstrapValidationReport {
        let noCompositionRootBackEdges = graph.nodes.allSatisfy { !$0.accessesCompositionRoot }
        let noForbiddenSharedAccessInsideInitializers = graph.nodes.allSatisfy { $0.forbiddenSharedDependenciesInInit.isEmpty }
        let noDependencyCycle = graph.cycles.isEmpty
        let validInitializationOrder = !graph.initializationOrder.isEmpty
            && graph.bindingOrder.count >= 4
            && graph.activationSequence == BootstrapActivationState.allCases.map(\.rawValue)
        let noMissingDependencies = graph.missingDependencies.isEmpty
        let noOrphanServices = graph.orphanServices.isEmpty
        let noDuplicateBindings = graph.duplicateBindings.isEmpty
        let activationSequenceValid = graph.activationSequence == BootstrapActivationState.allCases.map(\.rawValue)

        var violations: [String] = []
        if !noCompositionRootBackEdges { violations.append("One or more bootstrap services still access SUPRACompositionRoot.shared.") }
        if !noForbiddenSharedAccessInsideInitializers { violations.append("A governed bootstrap service still resolves a governed peer through .shared inside init().") }
        if !noDependencyCycle { violations.append("Bootstrap dependency cycle detected.") }
        if !validInitializationOrder { violations.append("Initialization, binding, and activation order is invalid.") }
        if !noMissingDependencies { violations.append("One or more bootstrap dependencies are unresolved.") }
        if !noOrphanServices { violations.append("One or more bootstrap services are orphaned from the composition root.") }
        if !noDuplicateBindings { violations.append("Duplicate bootstrap bindings detected.") }
        if !activationSequenceValid { violations.append("Runtime activation sequence is invalid.") }

        return BootstrapValidationReport(
            generatedAt: Date(),
            noCompositionRootBackEdges: noCompositionRootBackEdges,
            noForbiddenSharedAccessInsideInitializers: noForbiddenSharedAccessInsideInitializers,
            noDependencyCycle: noDependencyCycle,
            validInitializationOrder: validInitializationOrder,
            noMissingDependencies: noMissingDependencies,
            noOrphanServices: noOrphanServices,
            noDuplicateBindings: noDuplicateBindings,
            activationSequenceValid: activationSequenceValid,
            violations: violations,
            status: violations.isEmpty ? "PASS" : "FAIL"
        )
    }
}

@MainActor
struct ArchitectureGuard {
    func validateAndPublish(
        sourceRoot: URL,
        compositionRoot: SUPRACompositionRoot,
        outputDirectory: URL
    ) throws -> BootstrapExecutiveSummary {
        compositionRoot.loadRuntime()

        let analysis = try DependencyGraphGenerator().generate(sourceRoot: sourceRoot, activationEvents: compositionRoot.bootstrapEvents)
        let validation = BootstrapValidator().validate(graph: analysis.graph)
        let proof = buildProof(from: analysis.graph, activationEvents: compositionRoot.bootstrapEvents, validation: validation)
        let health = buildHealth(graph: analysis.graph, validation: validation)
        let summary = BootstrapExecutiveSummary(graph: analysis.graph, validation: validation, proof: proof, health: health)

        try publish(summary, to: outputDirectory)
        return summary
    }

    private func buildProof(
        from graph: BootstrapDependencyGraph,
        activationEvents: [BootstrapActivationEvent],
        validation: BootstrapValidationReport
    ) -> BootstrapProofReport {
        let bootstrapDurationMs: Int
        if let first = activationEvents.first?.timestamp, let last = activationEvents.last?.timestamp {
            bootstrapDurationMs = Int(last.timeIntervalSince(first) * 1000)
        } else {
            bootstrapDurationMs = 0
        }

        let servicesRequiringLateBinding = graph.nodes
            .filter { !$0.lateBindings.isEmpty }
            .map(\.name)
            .sorted()

        return BootstrapProofReport(
            generatedAt: Date(),
            totalServices: graph.nodes.count,
            initializationOrder: graph.initializationOrder,
            dependencyDepth: graph.maxDepth,
            detectedCycles: graph.cycles,
            bootstrapDurationMs: bootstrapDurationMs,
            servicesRequiringLateBinding: servicesRequiringLateBinding,
            validationResult: validation.status,
            activationSequence: activationEvents
        )
    }

    private func buildHealth(
        graph: BootstrapDependencyGraph,
        validation: BootstrapValidationReport
    ) -> ArchitectureHealthReport {
        let checks = [
            validation.noCompositionRootBackEdges,
            validation.noForbiddenSharedAccessInsideInitializers,
            validation.noDependencyCycle,
            validation.validInitializationOrder,
            validation.noMissingDependencies,
            validation.noOrphanServices,
            validation.noDuplicateBindings,
            validation.activationSequenceValid
        ]
        let passed = checks.filter { $0 }.count
        let score = Double(passed) / Double(checks.count)

        return ArchitectureHealthReport(
            generatedAt: Date(),
            status: validation.status,
            healthScore: score,
            governedServices: graph.nodes.count,
            violations: validation.violations
        )
    }

    private func publish(_ summary: BootstrapExecutiveSummary, to outputDirectory: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        try write(encoder.encode(summary.validation), to: outputDirectory.appendingPathComponent("BOOTSTRAP_VALIDATION.json"))
        try write(encoder.encode(summary.proof), to: outputDirectory.appendingPathComponent("BOOTSTRAP_PROOF.json"))
        try write(encoder.encode(summary.graph), to: outputDirectory.appendingPathComponent("DEPENDENCY_GRAPH.json"))
        try write(encoder.encode(summary.health), to: outputDirectory.appendingPathComponent("ARCHITECTURE_HEALTH.json"))
        try write(renderGraphMarkdown(summary.graph).data(using: .utf8)!, to: outputDirectory.appendingPathComponent("DEPENDENCY_GRAPH.md"))
        try write(renderBootstrapPolicy().data(using: .utf8)!, to: outputDirectory.appendingPathComponent("BOOTSTRAP_POLICY.md"))
        try write(renderExecutiveReport(summary).data(using: .utf8)!, to: outputDirectory.appendingPathComponent("BOOTSTRAP_EXECUTIVE_REPORT.md"))
    }

    private func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: [.atomic])
    }

    private func renderGraphMarkdown(_ graph: BootstrapDependencyGraph) -> String {
        let nodeLines = graph.nodes.map { "- `\($0.name)` → init: [\($0.initDependencies.joined(separator: ", "))] bind: [\($0.lateBindings.joined(separator: ", "))]" }
        let edgeLines = graph.edges.map { "- `\($0.from)` -> `\($0.to)` (\($0.kind))" }
        return """
        # Dependency Graph

        Generated: \(ISO8601DateFormatter().string(from: graph.generatedAt))

        ## Initialization Order

        \(graph.initializationOrder.map { "- `\($0)`" }.joined(separator: "\n"))

        ## Binding Order

        \(graph.bindingOrder.map { "- `\($0)`" }.joined(separator: "\n"))

        ## Services

        \(nodeLines.joined(separator: "\n"))

        ## Edges

        \(edgeLines.joined(separator: "\n"))

        ## Cycles

        \(graph.cycles.isEmpty ? "- None" : graph.cycles.map { "- `" + $0.joined(separator: " -> ") + "`" }.joined(separator: "\n"))
        """
    }

    private func renderBootstrapPolicy() -> String {
        """
        # Bootstrap Policy

        Date: July 29, 2026

        - `SUPRACompositionRoot` is the unique bootstrap creator and binder of governed services.
        - No governed service may access `SUPRACompositionRoot.shared`.
        - No governed peer may be resolved through `.shared` inside `init()`.
        - No business logic is allowed inside `init()`.
        - Runtime activation is forbidden during construction.
        - Observers depending on late-bound services must start only after explicit binding.
        - Every governed dependency must be injected or explicitly bound.
        - The bootstrap dependency graph must remain acyclic.
        - The runtime activation sequence must remain deterministic:
          `CREATE_SERVICES -> BIND_DEPENDENCIES -> PUBLISH_REFERENCES -> ACTIVATE_RUNTIME -> RUNTIME_READY`
        """
    }

    private func renderExecutiveReport(_ summary: BootstrapExecutiveSummary) -> String {
        """
        # Bootstrap Executive Report

        Date: July 29, 2026
        Status: \(summary.validation.status)

        ## Architecture Summary

        - Governed services: \(summary.graph.nodes.count)
        - Dependency depth: \(summary.graph.maxDepth)
        - Bootstrap duration: \(summary.proof.bootstrapDurationMs) ms

        ## Initialization

        \(summary.graph.initializationOrder.map { "- `\($0)`" }.joined(separator: "\n"))

        ## Bindings

        \(summary.graph.bindingOrder.map { "- `\($0)`" }.joined(separator: "\n"))

        ## Activation

        \(summary.graph.activationSequence.map { "- `\($0)`" }.joined(separator: "\n"))

        ## Violations

        \(summary.validation.violations.isEmpty ? "- None" : summary.validation.violations.map { "- \($0)" }.joined(separator: "\n"))

        ## Result

        - PASS / FAIL: \(summary.validation.status)
        """
    }
}

private struct BootstrapAnalyzer {
    private let sourceRoot: URL
    private let fileManager = FileManager.default

    init(sourceRoot: URL) {
        self.sourceRoot = sourceRoot
    }

    func analyze(activationEvents: [BootstrapActivationEvent]) throws -> BootstrapAnalysis {
        let swiftFiles = try swiftSourceFiles()
        let fileByType = try buildFileByTypeIndex(swiftFiles: swiftFiles)
        let rootURL = sourceRoot.appendingPathComponent("SUPRA/SUPRACompositionRoot.swift")
        let rootSource = try String(contentsOf: rootURL, encoding: .utf8)

        let rootProperties = parseRootPropertyTypes(from: rootSource)
        let initDetails = parseRootInitialization(from: rootSource)
        let governedServices = Set(rootProperties + initDetails.initializationOrder + ["SUPRACompositionRoot"])

        let nodes = try governedServices
            .filter { $0 != "SUPRACompositionRoot" }
            .sorted()
            .map { serviceName -> BootstrapServiceNode in
                guard let fileURL = fileByType[serviceName] else {
                    return BootstrapServiceNode(
                        name: serviceName,
                        filePath: serviceName,
                        initDependencies: [],
                        lateBindings: [],
                        forbiddenSharedDependenciesInInit: [],
                        accessesCompositionRoot: false,
                        activatesRuntimeInInit: false
                    )
                }
                let source = try String(contentsOf: fileURL, encoding: .utf8)
                let initBlocks = extractInitializerBlocks(from: source)
                let initDependencies = unique(parseDependencies(from: source))
                let lateBindings = unique(parseLateBindings(from: source))
                let forbiddenSharedInInit = unique(parseSharedDependencies(in: initBlocks).filter { governedServices.contains($0) })
                return BootstrapServiceNode(
                    name: serviceName,
                    filePath: fileURL.path.replacingOccurrences(of: sourceRoot.path + "/", with: ""),
                    initDependencies: initDependencies.filter { $0 != serviceName },
                    lateBindings: lateBindings.filter { $0 != serviceName },
                    forbiddenSharedDependenciesInInit: forbiddenSharedInInit.filter { $0 != serviceName },
                    accessesCompositionRoot: source.contains("SUPRACompositionRoot.shared"),
                    activatesRuntimeInInit: initBlocks.contains(where: {
                        $0.contains("loadRuntime(") || $0.contains(".start(") || $0.contains("startMonitoring(")
                    })
                )
            }

        let rootCreatedServices = governedServices
            .filter { $0 != "SUPRACompositionRoot" }
            .sorted()
        let rootEdges = rootCreatedServices.map {
            BootstrapDependencyEdge(from: "SUPRACompositionRoot", to: $0, kind: "create")
        }
        let nodeEdges = nodes.flatMap { node in
            node.initDependencies.map { BootstrapDependencyEdge(from: node.name, to: $0, kind: "init") }
            + node.lateBindings.map { BootstrapDependencyEdge(from: node.name, to: $0, kind: "bind") }
        }
        let allEdges = uniqueEdges(rootEdges + nodeEdges)
        let bootstrapEdges = uniqueEdges(
            rootEdges + nodes.flatMap { node in
                node.initDependencies.map { BootstrapDependencyEdge(from: node.name, to: $0, kind: "init") }
            }
        )
        let cycles = findCycles(edges: bootstrapEdges)
        let missingDependencies = unique(
            nodes.flatMap { $0.initDependencies + $0.lateBindings }
                .filter { isGovernedType($0) && !governedServices.contains($0) }
        )
        let reachable = reachableNodes(from: "SUPRACompositionRoot", edges: rootEdges)
        let orphanServices = governedServices
            .filter { $0 != "SUPRACompositionRoot" && !reachable.contains($0) }
            .sorted()
        let duplicateBindings = initDetails.bindingOrder
            .reduce(into: [String: Int]()) { counts, binding in counts[binding, default: 0] += 1 }
            .filter { $0.value > 1 }
            .map(\.key)
            .sorted()

        let graph = BootstrapDependencyGraph(
            root: "SUPRACompositionRoot",
            generatedAt: Date(),
            nodes: nodes,
            edges: allEdges.sorted { lhs, rhs in
                lhs.from == rhs.from ? lhs.to < rhs.to : lhs.from < rhs.from
            },
            initializationOrder: initDetails.initializationOrder,
            bindingOrder: initDetails.bindingOrder,
            activationSequence: activationEvents.map { $0.state.rawValue },
            cycles: cycles,
            missingDependencies: missingDependencies,
            orphanServices: orphanServices,
            duplicateBindings: duplicateBindings,
            maxDepth: maximumDepth(from: "SUPRACompositionRoot", edges: bootstrapEdges)
        )

        return BootstrapAnalysis(graph: graph, governedServiceNames: governedServices)
    }

    private func swiftSourceFiles() throws -> [URL] {
        let sourceDirectory = sourceRoot.appendingPathComponent("SUPRA", isDirectory: true)
        guard let enumerator = fileManager.enumerator(at: sourceDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        var files: [URL] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            files.append(url)
        }
        return files
    }

    private func buildFileByTypeIndex(swiftFiles: [URL]) throws -> [String: URL] {
        var index: [String: URL] = [:]
        let pattern = try NSRegularExpression(pattern: #"(?:final\s+class|class|struct|actor)\s+([A-Z][A-Za-z0-9_]*)"#)
        for file in swiftFiles {
            let source = try String(contentsOf: file, encoding: .utf8)
            let ns = source as NSString
            for match in pattern.matches(in: source, range: NSRange(location: 0, length: ns.length)) {
                let type = ns.substring(with: match.range(at: 1))
                index[type] = file
            }
        }
        return index
    }

    private func parseRootPropertyTypes(from source: String) -> [String] {
        guard let range = source.range(of: "private init()") else { return [] }
        let propertySection = String(source[..<range.lowerBound])
        let lines = propertySection.split(separator: "\n").map(String.init)
        return unique(lines.compactMap { line in
            guard line.contains("let "), line.contains(":") else { return nil }
            let parts = line.split(separator: ":")
            guard parts.count >= 2 else { return nil }
            let type = parts[1]
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "@Published private(set) var ", with: "")
                .split(separator: " ")
                .first
                .map(String.init)
            return type
        }).filter { isGovernedType($0) }
    }

    private func parseRootInitialization(from source: String) -> (initializationOrder: [String], bindingOrder: [String]) {
        let initBlock = extractBlock(containing: "private init()", from: source)
        let lines = initBlock.split(separator: "\n").map(String.init)
        let createPattern = try? NSRegularExpression(pattern: #"let\s+([a-zA-Z_][A-Za-z0-9_]*)\s*=\s*([A-Z][A-Za-z0-9_]*)"#)
        let bindPattern = try? NSRegularExpression(pattern: #"([a-zA-Z_][A-Za-z0-9_]*)\.bind\((.*)\)"#)

        var variableToType: [String: String] = [:]
        var initializationOrder: [String] = []
        var bindingOrder: [String] = []

        for line in lines {
            let ns = line as NSString
            if let createPattern,
               let match = createPattern.firstMatch(in: line, range: NSRange(location: 0, length: ns.length)) {
                let variable = ns.substring(with: match.range(at: 1))
                let type = ns.substring(with: match.range(at: 2))
                variableToType[variable] = type
                if isGovernedType(type) {
                    initializationOrder.append(type)
                }
            }
        }

        for line in lines {
            let ns = line as NSString
            guard let bindPattern,
                  let match = bindPattern.firstMatch(in: line, range: NSRange(location: 0, length: ns.length))
            else { continue }
            let sourceVariable = ns.substring(with: match.range(at: 1))
            let arguments = ns.substring(with: match.range(at: 2))
            guard let sourceType = variableToType[sourceVariable] else { continue }
            let argumentTypes = parseArgumentVariables(from: arguments)
                .compactMap { variableToType[$0] }
                .filter(isGovernedType)
            for dependency in argumentTypes {
                bindingOrder.append("\(sourceType)->\(dependency)")
            }
        }

        return (unique(initializationOrder), bindingOrder)
    }

    private func parseArgumentVariables(from argumentList: String) -> [String] {
        argumentList
            .split(separator: ",")
            .map(String.init)
            .compactMap { argument in
                let parts = argument.split(separator: ":")
                guard parts.count == 2 else { return nil }
                return parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
    }

    private func parseDependencies(from source: String) -> [String] {
        let initBlocks = extractInitializerBlocks(from: source)
        let dependencyPatterns = [
            try? NSRegularExpression(pattern: #"=\s*([A-Z][A-Za-z0-9_]*)\.shared"#),
            try? NSRegularExpression(pattern: #"=\s*([A-Z][A-Za-z0-9_]*)\("#)
        ].compactMap { $0 }

        var results: [String] = []
        let fullText = initBlocks.joined(separator: "\n")
        let ns = fullText as NSString
        for pattern in dependencyPatterns {
            for match in pattern.matches(in: fullText, range: NSRange(location: 0, length: ns.length)) {
                results.append(ns.substring(with: match.range(at: 1)))
            }
        }
        return unique(results.filter(isGovernedType))
    }

    private func parseLateBindings(from source: String) -> [String] {
        let pattern = try? NSRegularExpression(pattern: #"func\s+bind\(([^)]*)\)"#)
        guard let pattern else { return [] }
        let ns = source as NSString
        var results: [String] = []
        for match in pattern.matches(in: source, range: NSRange(location: 0, length: ns.length)) {
            let args = ns.substring(with: match.range(at: 1))
            for part in args.split(separator: ",") {
                let sections = part.split(separator: ":")
                guard sections.count == 2 else { continue }
                let type = sections[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "?", with: "")
                if isGovernedType(type) {
                    results.append(type)
                }
            }
        }
        return unique(results)
    }

    private func parseSharedDependencies(in blocks: [String]) -> [String] {
        let pattern = try? NSRegularExpression(pattern: #"([A-Z][A-Za-z0-9_]*)\.shared"#)
        guard let pattern else { return [] }
        var results: [String] = []
        for block in blocks {
            let ns = block as NSString
            for match in pattern.matches(in: block, range: NSRange(location: 0, length: ns.length)) {
                results.append(ns.substring(with: match.range(at: 1)))
            }
        }
        return unique(results)
    }

    private func extractInitializerBlocks(from source: String) -> [String] {
        source
            .split(separator: "\n")
            .map(String.init)
            .enumerated()
            .compactMap { index, line in
                guard line.contains("init(") || line.contains("private init(") else { return nil }
                return extractBlock(startingAt: index, in: source.split(separator: "\n").map(String.init))
            }
    }

    private func extractBlock(containing marker: String, from source: String) -> String {
        let lines = source.split(separator: "\n").map(String.init)
        guard let start = lines.firstIndex(where: { $0.contains(marker) }) else { return "" }
        return extractBlock(startingAt: start, in: lines)
    }

    private func extractBlock(startingAt start: Int, in lines: [String]) -> String {
        var braceDepth = 0
        var hasOpened = false
        var collected: [String] = []

        for line in lines[start...] {
            collected.append(line)
            for character in line {
                if character == "{" {
                    braceDepth += 1
                    hasOpened = true
                } else if character == "}" {
                    braceDepth -= 1
                    if hasOpened && braceDepth == 0 {
                        return collected.joined(separator: "\n")
                    }
                }
            }
        }
        return collected.joined(separator: "\n")
    }

    private func reachableNodes(from root: String, edges: [BootstrapDependencyEdge]) -> Set<String> {
        var adjacency: [String: [String]] = [:]
        for edge in edges {
            adjacency[edge.from, default: []].append(edge.to)
        }

        var visited: Set<String> = [root]
        var queue: [String] = [root]
        while let next = queue.first {
            queue.removeFirst()
            for neighbor in adjacency[next, default: []] where !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.append(neighbor)
            }
        }
        return visited
    }

    private func maximumDepth(from root: String, edges: [BootstrapDependencyEdge]) -> Int {
        var adjacency: [String: [String]] = [:]
        for edge in edges {
            adjacency[edge.from, default: []].append(edge.to)
        }

        func depth(_ node: String, _ visiting: inout Set<String>) -> Int {
            guard !visiting.contains(node) else { return 0 }
            visiting.insert(node)
            let childDepth = adjacency[node, default: []].map { depth($0, &visiting) }.max() ?? 0
            visiting.remove(node)
            return childDepth + (node == root ? 0 : 1)
        }

        var visiting: Set<String> = []
        return depth(root, &visiting)
    }

    private func findCycles(edges: [BootstrapDependencyEdge]) -> [[String]] {
        var adjacency: [String: [String]] = [:]
        for edge in edges {
            adjacency[edge.from, default: []].append(edge.to)
        }

        var visited = Set<String>()
        var stack = [String]()
        var stackSet = Set<String>()
        var cycles = [[String]]()

        func dfs(_ node: String) {
            visited.insert(node)
            stack.append(node)
            stackSet.insert(node)

            for neighbor in adjacency[node, default: []] {
                if !visited.contains(neighbor) {
                    dfs(neighbor)
                } else if stackSet.contains(neighbor),
                          let index = stack.firstIndex(of: neighbor) {
                    cycles.append(Array(stack[index...]) + [neighbor])
                }
            }

            _ = stack.popLast()
            stackSet.remove(node)
        }

        for node in adjacency.keys.sorted() where !visited.contains(node) {
            dfs(node)
        }

        return uniqueCycles(cycles)
    }

    private func uniqueCycles(_ cycles: [[String]]) -> [[String]] {
        var seen = Set<String>()
        var uniqueValues: [[String]] = []
        for cycle in cycles {
            let key = cycle.joined(separator: "->")
            if seen.insert(key).inserted {
                uniqueValues.append(cycle)
            }
        }
        return uniqueValues
    }

    private func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    private func uniqueEdges(_ values: [BootstrapDependencyEdge]) -> [BootstrapDependencyEdge] {
        var seen = Set<String>()
        return values.filter { edge in
            let key = "\(edge.from)->\(edge.to):\(edge.kind)"
            return seen.insert(key).inserted
        }
    }

    private func isGovernedType(_ type: String) -> Bool {
        type == "RuntimeDataService"
            || type == "MissionStore"
            || type == "DecisionStore"
            || type == "RuntimeMonitor"
            || type == "SUPRARuntimeEvents"
            || type == "ControlTowerState"
            || type == "SUPRARuntimeKernel"
            || type == "MultiMemoryStore"
            || type == "SUPRAIntelligenceEngine"
            || type == "SUPRAMissionObserver"
            || type == "MissionOpportunityEngine"
            || type == "MissionEvolutionEngine"
            || type == "SUPRACompositionRoot"
    }
}
