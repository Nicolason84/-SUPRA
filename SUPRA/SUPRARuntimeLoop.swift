import Foundation

enum SUPRAExecutivePriorityKind: String, Codable, Equatable {
    case restoreBuildHealth = "RESTORE_BUILD_HEALTH"
    case restoreTestHealth = "RESTORE_TEST_HEALTH"
    case restoreProviderAvailability = "RESTORE_PROVIDER_AVAILABILITY"
    case closeEvidenceGap = "CLOSE_EVIDENCE_GAP"
    case reduceDuplicateResponsibilities = "REDUCE_DUPLICATE_RESPONSIBILITIES"
    case activateInactiveServices = "ACTIVATE_INACTIVE_SERVICES"
    case executeBacklog = "EXECUTE_BACKLOG"
    case stabilizeRuntime = "STABILIZE_RUNTIME"
}

enum SUPRAExecutiveLoopState: String, Codable, Equatable {
    case boot = "BOOT"
    case observe = "OBSERVE"
    case understand = "UNDERSTAND"
    case decide = "DECIDE"
    case prepare = "PREPARE"
    case execute = "EXECUTE"
    case validate = "VALIDATE"
    case learn = "LEARN"
    case freeze = "FREEZE"
    case ready = "READY"
    case failed = "FAILED"
}

enum SUPRARecoveryStrategyKind: String, Codable, Equatable {
    case retry = "RETRY"
    case replay = "REPLAY"
    case fallback = "FALLBACK"
    case skip = "SKIP"
    case abort = "ABORT"
    case humanIntervention = "HUMAN_INTERVENTION"
}

struct SUPRAExecutiveStateRule: Codable, Equatable {
    let preconditions: [String]
    let entryConditions: [String]
    let exitConditions: [String]
    let successCriteria: [String]
    let failureCriteria: [String]
    let recoveryStrategy: SUPRARecoveryStrategyKind
    let timeoutSeconds: Double
    let producedEvidence: [String]
    let confidenceScore: Double
    let allowedSuccessorStates: [SUPRAExecutiveLoopState]
}

struct SUPRARootCauseReport: Codable, Equatable {
    let currentSituation: String
    let rootCause: String
    let causalChain: [String]
    let riskLevel: String
    let technicalImpact: String
    let confidence: Double
    let recoveryStrategy: String
    let recoveryClassification: SUPRARecoveryStrategyKind
    let proof: [String]
}

struct SUPRAExecutionTransition: Codable, Equatable, Identifiable {
    let id: UUID
    let state: SUPRAExecutiveLoopState
    let entryTimestamp: Date
    let exitTimestamp: Date
    let durationMs: Int
    let currentAction: String
    let expectedResult: String
    let producedEvidence: [String]
    let failureCause: String?
    let recoveryStrategy: String?
    let confidence: Double
    let nextState: SUPRAExecutiveLoopState?
    let currentMission: String?
    let currentProvider: String?
    let currentModel: String?
    let tokenConsumption: Int
    let cpu: Double
    let memory: Double
    let gitState: String
    let repositoryState: String

    init(
        state: SUPRAExecutiveLoopState,
        entryTimestamp: Date,
        exitTimestamp: Date,
        currentAction: String,
        expectedResult: String,
        producedEvidence: [String],
        failureCause: String? = nil,
        recoveryStrategy: String? = nil,
        confidence: Double,
        nextState: SUPRAExecutiveLoopState?,
        currentMission: String? = nil,
        currentProvider: String? = nil,
        currentModel: String? = nil,
        tokenConsumption: Int = 0,
        cpu: Double = 0,
        memory: Double = 0,
        gitState: String,
        repositoryState: String
    ) {
        self.id = UUID()
        self.state = state
        self.entryTimestamp = entryTimestamp
        self.exitTimestamp = exitTimestamp
        self.durationMs = Int(exitTimestamp.timeIntervalSince(entryTimestamp) * 1000)
        self.currentAction = currentAction
        self.expectedResult = expectedResult
        self.producedEvidence = producedEvidence
        self.failureCause = failureCause
        self.recoveryStrategy = recoveryStrategy
        self.confidence = confidence
        self.nextState = nextState
        self.currentMission = currentMission
        self.currentProvider = currentProvider
        self.currentModel = currentModel
        self.tokenConsumption = tokenConsumption
        self.cpu = cpu
        self.memory = memory
        self.gitState = gitState
        self.repositoryState = repositoryState
    }
}

struct SUPRARepositoryStatus: Codable, Equatable {
    let branch: String
    let modifiedFiles: [String]
    let untrackedFiles: [String]
    let hasRepositoryChanges: Bool
}

struct SUPRAExecutiveObservation: Codable, Equatable {
    let workspace: SUPRAWorkspaceAnalysis
    let repository: SUPRARepositoryStatus
    let runtimeStatus: RuntimeStatus
    let providerCount: Int
    let providerAvailable: Bool
    let memoryEntryCount: Int
    let recentMemoryChanges: [String]
    let duplicateResponsibilities: [String]
    let inactiveServices: [String]
    let missingEvidence: [String]
    let missionBacklogCount: Int
    let blockedMissionCount: Int
    let priorBuildStatus: String
    let priorTestStatus: String
    let observedAt: Date
}

struct SUPRAExecutiveDecision: Codable, Equatable {
    let priority: SUPRAExecutivePriorityKind
    let rationale: String
    let confidence: Double
    let evidence: [String]
    let recommendedAction: String
}

struct SUPRAExecutiveMissionDraft: Codable, Equatable {
    let objective: String
    let scope: [String]
    let constraints: [String]
    let expectedDeliverables: [String]
    let validationCriteria: [String]
    let stopConditions: [String]
    let estimatedImpact: String
    let confidence: Double
    let evidenceRequirements: [String]

    func intentPayload() -> String {
        [
            objective,
            "Scope: " + scope.joined(separator: "; "),
            "Constraints: " + constraints.joined(separator: "; "),
            "Expected Deliverables: " + expectedDeliverables.joined(separator: "; "),
            "Validation Criteria: " + validationCriteria.joined(separator: "; "),
            "Stop Conditions: " + stopConditions.joined(separator: "; "),
            "Estimated Impact: \(estimatedImpact)",
            "Confidence: \(Int(confidence * 100))%",
            "Evidence Requirements: " + evidenceRequirements.joined(separator: "; ")
        ].joined(separator: "\n")
    }
}

struct SUPRAExecutiveLearning: Codable, Equatable {
    let lessonsLearned: [String]
    let repositoryEvolution: String
    let evidence: [String]
    let recordedAt: Date
}

struct SUPRAExecutiveRuntimeState: Codable, Equatable {
    let observation: SUPRAExecutiveObservation
    let decision: SUPRAExecutiveDecision
    let mission: SUPRAExecutiveMissionDraft
    let validation: SUPRAValidationSummary
    let currentMission: SUPRAMissionLoopSummary
    let learning: SUPRAExecutiveLearning
    let recommendedNextAction: String
    let nextIterationPrepared: Bool
    let generatedAt: Date
}

struct SUPRAWorkspaceAnalysis: Codable, Equatable {
    let rootPath: String
    let fileCount: Int
    let swiftFileCount: Int
    let markdownFileCount: Int
    let jsonFileCount: Int
    let analyzedAt: Date
}

struct SUPRAValidationSummary: Codable, Equatable {
    let buildSucceeded: Bool
    let testSucceeded: Bool
    let buildOutput: String
    let testOutput: String
    let validatedAt: Date
}

struct SUPRAMissionLoopSummary: Codable, Equatable {
    let missionID: String
    let title: String
    let state: String
    let report: String?
    let error: String?
}

struct SUPRARuntimeIterationResult: Codable, Equatable {
    let startedAt: Date
    let completedAt: Date
    let finalState: SUPRAExecutiveLoopState
    let workspace: SUPRAWorkspaceAnalysis
    let runtimeStatus: RuntimeStatus
    let executiveState: SUPRAExecutiveRuntimeState
    let generatedMission: SUPRAMissionLoopSummary
    let validation: SUPRAValidationSummary
    let memoryUpdated: Bool
    let nextExecutiveMission: String
    let transitions: [SUPRAExecutionTransition]
    let rootCause: SUPRARootCauseReport?
}

protocol SUPRABuildValidationRunning {
    func run(projectRoot: URL) async -> SUPRAValidationSummary
}

struct SUPRAXcodeValidationRunner: SUPRABuildValidationRunning {
    func run(projectRoot: URL) async -> SUPRAValidationSummary {
        let derivedData = FileManager.default.temporaryDirectory
            .appendingPathComponent("SUPRA_RUNTIME_LOOP_DERIVED", isDirectory: true)
        let buildResult = execute(
            arguments: [
                "-project", projectRoot.appendingPathComponent("SUPRA.xcodeproj").path,
                "-scheme", "SUPRA",
                "-configuration", "Debug",
                "-sdk", "macosx",
                "-derivedDataPath", derivedData.path,
                "build"
            ]
        )
        let testResult = execute(
            arguments: [
                "-project", projectRoot.appendingPathComponent("SUPRA.xcodeproj").path,
                "-scheme", "SUPRA",
                "-configuration", "Debug",
                "-sdk", "macosx",
                "-derivedDataPath", derivedData.path,
                "test"
            ]
        )

        return SUPRAValidationSummary(
            buildSucceeded: buildResult.success,
            testSucceeded: testResult.success,
            buildOutput: buildResult.output,
            testOutput: testResult.output,
            validatedAt: Date()
        )
    }

    private func execute(arguments: [String]) -> (success: Bool, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        process.arguments = arguments

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        do {
            try process.run()
            let completion = DispatchSemaphore(value: 0)
            DispatchQueue.global(qos: .utility).async {
                process.waitUntilExit()
                completion.signal()
            }
            if completion.wait(timeout: .now() + 120) == .timedOut {
                process.terminate()
                _ = completion.wait(timeout: .now() + 5)
                return (false, "xcodebuild timed out after 120s")
            }

            let data = stdout.fileHandleForReading.readDataToEndOfFile()
                + stderr.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?
                .split(separator: "\n")
                .suffix(40)
                .joined(separator: "\n") ?? ""
            return (process.terminationStatus == 0, output)
        } catch {
            return (false, "xcodebuild failed to start: \(error.localizedDescription)")
        }
    }
}

@MainActor
final class SUPRARuntimeLoop {
    private let missionStore: MissionStore
    private let runtimeMonitor: RuntimeMonitor
    private let workspaceMemoryStore: WorkspaceMemoryStore
    private let validationRunner: any SUPRABuildValidationRunning
    private let projectRootURL: URL

    init(
        missionStore: MissionStore? = nil,
        runtimeMonitor: RuntimeMonitor? = nil,
        workspaceMemoryStore: WorkspaceMemoryStore? = nil,
        validationRunner: (any SUPRABuildValidationRunning)? = nil,
        projectRootURL: URL? = nil
    ) {
        let compositionRoot = SUPRACompositionRoot.shared
        self.missionStore = missionStore ?? compositionRoot.missionStore
        self.runtimeMonitor = runtimeMonitor ?? compositionRoot.runtimeMonitor
        self.workspaceMemoryStore = workspaceMemoryStore ?? WorkspaceMemoryStore()
        self.validationRunner = validationRunner ?? SUPRAXcodeValidationRunner()
        self.projectRootURL = projectRootURL ?? Self.defaultProjectRootURL()
    }

    func runIteration() async -> SUPRARuntimeIterationResult? {
        let startedAt = Date()
        let logger = SUPRARuntimeLogger.shared
        var transitions: [SUPRAExecutionTransition] = []
        var rootCause: SUPRARootCauseReport?
        var activeState: SUPRAExecutiveLoopState?
        var currentMissionTitle: String?
        var currentProvider: String?
        var currentModel: String?
        var tokenConsumption = 0

        func authorizeTransition(
            from previous: SUPRAExecutiveLoopState?,
            to next: SUPRAExecutiveLoopState
        ) -> (allowed: Bool, proof: String) {
            guard let previous else {
                let allowed = next == .boot
                return (allowed, allowed ? "initial->\(next.rawValue)" : "illegal initial->\(next.rawValue)")
            }
            let allowed = Self.isTransitionAllowed(from: previous, to: next)
            return (
                allowed,
                allowed
                    ? "\(previous.rawValue)->\(next.rawValue) authorized"
                    : "\(previous.rawValue)->\(next.rawValue) rejected"
            )
        }

        func repositoryEvidence() -> String {
            let status = repositoryStatus(at: projectRootURL)
            return status.hasRepositoryChanges
                ? "modified=\(status.modifiedFiles.count),untracked=\(status.untrackedFiles.count)"
                : "clean"
        }

        func record(
            state: SUPRAExecutiveLoopState,
            entry: Date,
            action: String,
            expected: String,
            evidence: [String],
            failure: String? = nil,
            recovery: String? = nil,
            confidence: Double,
            next: SUPRAExecutiveLoopState?
        ) {
            let authorization = authorizeTransition(from: activeState, to: state)
            transitions.append(
                SUPRAExecutionTransition(
                    state: state,
                    entryTimestamp: entry,
                    exitTimestamp: Date(),
                    currentAction: action,
                    expectedResult: expected,
                    producedEvidence: evidence + [authorization.proof],
                    failureCause: failure ?? (authorization.allowed ? nil : "Illegal state transition"),
                    recoveryStrategy: recovery,
                    confidence: confidence,
                    nextState: next,
                    currentMission: currentMissionTitle,
                    currentProvider: currentProvider,
                    currentModel: currentModel,
                    tokenConsumption: tokenConsumption,
                    cpu: 0,
                    memory: 0,
                    gitState: runShell(executable: "/usr/bin/git", arguments: ["-C", projectRootURL.path, "rev-parse", "--abbrev-ref", "HEAD"]).trimmingCharacters(in: .whitespacesAndNewlines),
                    repositoryState: repositoryEvidence()
                )
            )
            activeState = authorization.allowed ? state : .failed
        }

        func failResult(
            workspace: SUPRAWorkspaceAnalysis,
            observation: SUPRAExecutiveObservation,
            decision: SUPRAExecutiveDecision,
            missionDraft: SUPRAExecutiveMissionDraft,
            mission: SUPRAMissionLoopSummary,
            validation: SUPRAValidationSummary,
            failureState: SUPRAExecutiveLoopState,
            failureAction: String,
            failureCause: String,
            recovery: String,
            proof: [String]
        ) -> SUPRARuntimeIterationResult {
            rootCause = SUPRARootCauseReport(
                currentSituation: failureAction,
                rootCause: failureCause,
                causalChain: [failureAction, failureCause],
                riskLevel: "HIGH",
                technicalImpact: "Executive iteration terminated before READY",
                confidence: 0.9,
                recoveryStrategy: recovery,
                recoveryClassification: Self.classifyRecoveryStrategy(recovery),
                proof: proof
            )
            let learning = SUPRAExecutiveLearning(
                lessonsLearned: ["Iteration failed in \(failureState.rawValue)", failureCause],
                repositoryEvolution: observation.repository.hasRepositoryChanges ? "Repository changed during observation." : "Repository stable during observation.",
                evidence: proof,
                recordedAt: Date()
            )
            let executiveState = SUPRAExecutiveRuntimeState(
                observation: observation,
                decision: decision,
                mission: missionDraft,
                validation: validation,
                currentMission: mission,
                learning: learning,
                recommendedNextAction: recovery,
                nextIterationPrepared: false,
                generatedAt: Date()
            )
            return SUPRARuntimeIterationResult(
                startedAt: startedAt,
                completedAt: Date(),
                finalState: .failed,
                workspace: workspace,
                runtimeStatus: runtimeMonitor.runtimeStatus,
                executiveState: executiveState,
                generatedMission: mission,
                validation: validation,
                memoryUpdated: workspaceMemoryStore.lastEntry != nil,
                nextExecutiveMission: recovery,
                transitions: transitions,
                rootCause: rootCause
            )
        }

        let bootEntry = Date()
        let bootAuthorization = authorizeTransition(from: activeState, to: .boot)
        guard bootAuthorization.allowed else {
            return nil
        }
        logger.log(.boot, "Runtime loop boot")
        SUPRAEnvironmentResolver.shared.resolve()
        _ = await SUPRAPluginDiscovery.shared.discoverAll()
        await SUPRARuntimeRegistry.shared.initialize()
        SUPRARuntimeRegistry.shared.refresh()
        record(
            state: .boot,
            entry: bootEntry,
            action: "Initialize environment, plugins and runtime registry",
            expected: "Runtime dependencies available",
            evidence: ["providers=\(SUPRAProviderRegistry.shared.providers.count)", "models=\(SUPRAModelRegistry.shared.models.count)"],
            confidence: 0.95,
            next: .observe
        )

        let observeEntry = Date()
        guard authorizeTransition(from: activeState, to: .observe).allowed else {
            let failedWorkspace = analyzeWorkspace(at: projectRootURL)
            return failResult(
                workspace: failedWorkspace,
                observation: buildObservation(workspace: failedWorkspace),
                decision: SUPRAExecutiveDecision(priority: .stabilizeRuntime, rationale: "Illegal transition detected before observation.", confidence: 1.0, evidence: ["BOOT->OBSERVE"], recommendedAction: "Repair state sequencing"),
                missionDraft: SUPRAExecutiveMissionDraft(objective: "Illegal transition", scope: [], constraints: [], expectedDeliverables: [], validationCriteria: [], stopConditions: [], estimatedImpact: "Transition blocked", confidence: 1.0, evidenceRequirements: []),
                mission: SUPRAMissionLoopSummary(missionID: "unknown", title: "Illegal transition", state: "FAILED", report: nil, error: "BOOT->OBSERVE rejected"),
                validation: SUPRAValidationSummary(buildSucceeded: false, testSucceeded: false, buildOutput: "SKIPPED", testOutput: "SKIPPED", validatedAt: Date()),
                failureState: .observe,
                failureAction: "Transition authorization",
                failureCause: "BOOT->OBSERVE rejected by governance rules",
                recovery: "Repair state sequencing and replay iteration",
                proof: ["BOOT->OBSERVE rejected"]
            )
        }
        let workspace = analyzeWorkspace(at: projectRootURL)
        updateRuntimeStatus(for: workspace)
        CAnnoNicoSnapshotStore.shared.refresh()
        missionStore.refresh()
        MultiMemoryStore.shared.refresh()
        SUPRAMissionProposalEngine.shared.clear()
        SUPRAMissionProposalEngine.shared.refresh()
        record(
            state: .observe,
            entry: observeEntry,
            action: "Observe repository, memory and runtime surfaces",
            expected: "Workspace and runtime state captured",
            evidence: ["files=\(workspace.fileCount)", "swift=\(workspace.swiftFileCount)", "missions=\(missionStore.missions.count)"],
            confidence: 0.9,
            next: .understand
        )

        let understandEntry = Date()
        guard authorizeTransition(from: activeState, to: .understand).allowed else {
            return nil
        }
        let observation = buildObservation(workspace: workspace)
        record(
            state: .understand,
            entry: understandEntry,
            action: "Build executive observation",
            expected: "Repository condition and runtime risks understood",
            evidence: ["providers=\(observation.providerCount)", "missingEvidence=\(observation.missingEvidence.count)", "duplicates=\(observation.duplicateResponsibilities.count)"],
            confidence: 0.88,
            next: .decide
        )

        let decideEntry = Date()
        guard authorizeTransition(from: activeState, to: .decide).allowed else {
            return nil
        }
        let decision = selectExecutiveDecision(from: observation)
        record(
            state: .decide,
            entry: decideEntry,
            action: "Select one executive priority",
            expected: "One bounded executive decision",
            evidence: [decision.priority.rawValue, decision.recommendedAction],
            confidence: decision.confidence,
            next: .prepare
        )

        let prepareEntry = Date()
        guard authorizeTransition(from: activeState, to: .prepare).allowed else {
            return nil
        }
        let missionDraft = generateMissionDraft(from: observation, decision: decision)
        let missionIntent = missionDraft.intentPayload()
        currentMissionTitle = missionDraft.objective
        runtimeMonitor.addEvent(.missionCreated, title: "Mission generated", detail: missionIntent)
        guard let missionID = await missionStore.createMission(intent: missionIntent) else {
            record(
                state: .prepare,
                entry: prepareEntry,
                action: "Persist generated mission",
                expected: "Mission queued in canonical MissionStore",
                evidence: ["missionStore=\(missionStore.missions.count)"],
                failure: "Mission persistence failed",
                recovery: "Repair MissionStore write path and retry iteration",
                confidence: 0.2,
                next: .failed
            )
            return failResult(
                workspace: workspace,
                observation: observation,
                decision: decision,
                missionDraft: missionDraft,
                mission: SUPRAMissionLoopSummary(missionID: "unknown", title: missionDraft.objective, state: "FAILED", report: nil, error: "Mission persistence failed"),
                validation: SUPRAValidationSummary(buildSucceeded: false, testSucceeded: false, buildOutput: "SKIPPED", testOutput: "SKIPPED", validatedAt: Date()),
                failureState: .prepare,
                failureAction: "Mission persistence",
                failureCause: missionStore.errorMessage ?? "MissionStore failed to persist mission",
                recovery: "Repair MissionStore write path and retry iteration",
                proof: ["missionStore.error=\(missionStore.errorMessage ?? "nil")"]
            )
        }
        record(
            state: .prepare,
            entry: prepareEntry,
            action: "Persist generated mission",
            expected: "Mission queued in canonical MissionStore",
            evidence: ["missionID=\(missionID.uuidString)"],
            confidence: 0.92,
            next: .execute
        )

        let executeEntry = Date()
        guard authorizeTransition(from: activeState, to: .execute).allowed else {
            return nil
        }
        let executed = await runWithTimeout(seconds: 20) {
            await self.missionStore.executeMission(id: missionID)
            return true
        } ?? false
        missionStore.refresh()

        guard let mission = missionStore.missions.first(where: { $0.id == missionID }) else {
            record(
                state: .execute,
                entry: executeEntry,
                action: "Execute mission through canonical pipeline",
                expected: "Mission result persisted",
                evidence: ["missionID=\(missionID.uuidString)"],
                failure: "Mission lookup failed after execution",
                recovery: "Repair MissionStore refresh consistency and retry iteration",
                confidence: 0.2,
                next: .failed
            )
            return failResult(
                workspace: workspace,
                observation: observation,
                decision: decision,
                missionDraft: missionDraft,
                mission: SUPRAMissionLoopSummary(missionID: missionID.uuidString, title: missionDraft.objective, state: "FAILED", report: nil, error: "Mission lookup failed"),
                validation: SUPRAValidationSummary(buildSucceeded: false, testSucceeded: false, buildOutput: "SKIPPED", testOutput: "SKIPPED", validatedAt: Date()),
                failureState: .execute,
                failureAction: "Mission lookup after execution",
                failureCause: "MissionStore.refresh did not surface the executed mission",
                recovery: "Repair MissionStore refresh consistency and retry iteration",
                proof: ["missionID=\(missionID.uuidString)"]
            )
        }

        currentProvider = InferenceSovereigntyRuntime.shared.lastResponse?.provider.rawValue
        currentModel = InferenceSovereigntyRuntime.shared.lastResponse?.model
        tokenConsumption = (InferenceSovereigntyRuntime.shared.lastMetric?.tokensIn ?? 0) + (InferenceSovereigntyRuntime.shared.lastMetric?.tokensOut ?? 0)

        if mission.status == .completed {
            runtimeMonitor.addEvent(.executionCompleted, title: mission.title, detail: mission.report ?? "", missionId: missionID.uuidString)
        } else {
            runtimeMonitor.addEvent(.error, title: mission.title, detail: mission.executionError ?? "Unknown execution error", missionId: missionID.uuidString)
        }
        record(
            state: .execute,
            entry: executeEntry,
            action: "Execute mission through canonical pipeline",
            expected: "Mission completes or fails with proof",
            evidence: ["missionState=\(mission.currentStatus)", "provider=\(currentProvider ?? "none")", "model=\(currentModel ?? "none")"],
            failure: executed ? nil : "Mission execution timed out",
            recovery: executed ? nil : "Bound mission execution timed out after 20s; inspect mission pipeline and provider path",
            confidence: executed && mission.status == .completed ? 0.9 : 0.4,
            next: mission.status == .completed ? .validate : .failed
        )

        if !executed || mission.status != .completed {
            return failResult(
                workspace: workspace,
                observation: observation,
                decision: decision,
                missionDraft: missionDraft,
                mission: SUPRAMissionLoopSummary(
                    missionID: mission.id.uuidString,
                    title: mission.title,
                    state: mission.currentStatus,
                    report: mission.report,
                    error: mission.executionError ?? (executed ? "Mission did not complete" : "Mission execution timed out")
                ),
                validation: SUPRAValidationSummary(buildSucceeded: false, testSucceeded: false, buildOutput: "SKIPPED", testOutput: "SKIPPED", validatedAt: Date()),
                failureState: .execute,
                failureAction: "Mission execution",
                failureCause: mission.executionError ?? (executed ? "Mission ended in \(mission.currentStatus)" : "Mission execution exceeded 20s"),
                recovery: "Inspect canonical execution pipeline and replay with runtime transitions",
                proof: transitions.last?.producedEvidence ?? []
            )
        }

        let validateEntry = Date()
        guard authorizeTransition(from: activeState, to: .validate).allowed else {
            return nil
        }
        let validation = await runWithTimeout(seconds: 30) {
            await self.validationRunner.run(projectRoot: self.projectRootURL)
        } ?? SUPRAValidationSummary(
            buildSucceeded: false,
            testSucceeded: false,
            buildOutput: "Validation timed out after 30s",
            testOutput: "Validation timed out after 30s",
            validatedAt: Date()
        )
        if validation.buildSucceeded && validation.testSucceeded {
            runtimeMonitor.addEvent(.validationPassed, title: "Build and tests passed")
        } else {
            runtimeMonitor.addEvent(.validationFailed, title: "Build/test validation failed")
        }
        record(
            state: .validate,
            entry: validateEntry,
            action: "Validate build and test state",
            expected: "Build and test evidence produced",
            evidence: ["build=\(validation.buildSucceeded)", "tests=\(validation.testSucceeded)"],
            confidence: validation.buildSucceeded && validation.testSucceeded ? 0.9 : 0.5,
            next: .learn
        )

        let learnEntry = Date()
        guard authorizeTransition(from: activeState, to: .learn).allowed else {
            return nil
        }
        workspaceMemoryStore.recordEvent(
            type: "runtime_iteration",
            object: nil,
            change: "Mission \(mission.title) -> \(mission.currentStatus)"
        )
        let learning = recordLearning(
            mission: mission,
            validation: validation,
            observation: observation,
            decision: decision
        )
        record(
            state: .learn,
            entry: learnEntry,
            action: "Record runtime learning and memory",
            expected: "Memory updated with mission outcome",
            evidence: ["memoryUpdated=\(workspaceMemoryStore.lastEntry != nil)", "lessons=\(learning.lessonsLearned.count)"],
            confidence: workspaceMemoryStore.lastEntry != nil ? 0.88 : 0.5,
            next: .freeze
        )

        let freezeEntry = Date()
        guard authorizeTransition(from: activeState, to: .freeze).allowed else {
            return nil
        }
        let nextExecutiveMission = recommendedNextMission(
            for: mission,
            validation: validation,
            status: runtimeMonitor.runtimeStatus
        )
        let executiveState = SUPRAExecutiveRuntimeState(
            observation: observation,
            decision: decision,
            mission: missionDraft,
            validation: validation,
            currentMission: SUPRAMissionLoopSummary(
                missionID: mission.id.uuidString,
                title: mission.title,
                state: mission.currentStatus,
                report: mission.report,
                error: mission.executionError
            ),
            learning: learning,
            recommendedNextAction: nextExecutiveMission,
            nextIterationPrepared: true,
            generatedAt: Date()
        )
        record(
            state: .freeze,
            entry: freezeEntry,
            action: "Publish next executive mission and freeze iteration evidence",
            expected: "One next action published",
            evidence: [nextExecutiveMission],
            confidence: 0.86,
            next: .ready
        )
        let readyEntry = Date()
        guard authorizeTransition(from: activeState, to: .ready).allowed else {
            return nil
        }
        record(
            state: .ready,
            entry: readyEntry,
            action: "Return runtime to ready state",
            expected: "Executive loop terminates deterministically",
            evidence: ["nextIterationPrepared=true", "missionState=\(mission.currentStatus)"],
            confidence: 0.95,
            next: nil
        )

        return SUPRARuntimeIterationResult(
            startedAt: startedAt,
            completedAt: Date(),
            finalState: .ready,
            workspace: workspace,
            runtimeStatus: runtimeMonitor.runtimeStatus,
            executiveState: executiveState,
            generatedMission: SUPRAMissionLoopSummary(
                missionID: mission.id.uuidString,
                title: mission.title,
                state: mission.currentStatus,
                report: mission.report,
                error: mission.executionError
            ),
            validation: validation,
            memoryUpdated: workspaceMemoryStore.lastEntry != nil,
            nextExecutiveMission: nextExecutiveMission,
            transitions: transitions,
            rootCause: rootCause
        )
    }

    private func analyzeWorkspace(at rootURL: URL) -> SUPRAWorkspaceAnalysis {
        let enumerator = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var fileCount = 0
        var swiftFiles = 0
        var markdownFiles = 0
        var jsonFiles = 0

        while let fileURL = enumerator?.nextObject() as? URL {
            guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  values.isRegularFile == true else { continue }
            fileCount += 1
            switch fileURL.pathExtension.lowercased() {
            case "swift": swiftFiles += 1
            case "md": markdownFiles += 1
            case "json": jsonFiles += 1
            default: break
            }
        }

        return SUPRAWorkspaceAnalysis(
            rootPath: rootURL.path,
            fileCount: fileCount,
            swiftFileCount: swiftFiles,
            markdownFileCount: markdownFiles,
            jsonFileCount: jsonFiles,
            analyzedAt: Date()
        )
    }

    private func updateRuntimeStatus(for workspace: SUPRAWorkspaceAnalysis) {
        let providerCount = SUPRAProviderRegistry.shared.providers.count
        var health = runtimeMonitor.health
        health.isConnected = providerCount > 0
        health.connectionState = providerCount > 0 ? .connected : .degraded
        health.agentCount = 1
        health.activeProviderCount = providerCount
        health.totalProviderCount = providerCount
        health.activeMissionCount = missionStore.missions.count
        health.lastSyncDate = Date()
        health.lastSyncDurationMs = 1
        health.fileCount = workspace.fileCount
        runtimeMonitor.health = health
        runtimeMonitor.addEvent(.info, title: "Workspace analyzed", detail: "\(workspace.fileCount) files")
        if providerCount > 0 {
            runtimeMonitor.addEvent(.providerAssigned, title: "Execution providers connected", detail: "\(providerCount) provider(s)")
        }
    }

    private func buildObservation(workspace: SUPRAWorkspaceAnalysis) -> SUPRAExecutiveObservation {
        let repository = repositoryStatus(at: projectRootURL)
        let providerCount = SUPRAProviderRegistry.shared.providers.count
        let memoryEntries = workspaceMemoryStore.recentEvents(limit: 10)
        let duplicateResponsibilities = detectDuplicateResponsibilities()
        let inactiveServices = inactiveServices()
        let missingEvidence = detectMissingEvidence()
        let priorValidation = readPriorValidationStatus()

        return SUPRAExecutiveObservation(
            workspace: workspace,
            repository: repository,
            runtimeStatus: runtimeMonitor.runtimeStatus,
            providerCount: providerCount,
            providerAvailable: providerCount > 0,
            memoryEntryCount: workspaceMemoryStore.memory.entries.count,
            recentMemoryChanges: memoryEntries.map(\.changeDescription),
            duplicateResponsibilities: duplicateResponsibilities,
            inactiveServices: inactiveServices,
            missingEvidence: missingEvidence,
            missionBacklogCount: missionStore.missions.filter { $0.status != .completed }.count,
            blockedMissionCount: missionStore.missions.filter { $0.status == .blocked }.count,
            priorBuildStatus: priorValidation.build,
            priorTestStatus: priorValidation.test,
            observedAt: Date()
        )
    }

    private func selectExecutiveDecision(from observation: SUPRAExecutiveObservation) -> SUPRAExecutiveDecision {
        if observation.priorBuildStatus == "FAILED" {
            return SUPRAExecutiveDecision(
                priority: .restoreBuildHealth,
                rationale: "The last known build state is failed, which blocks safe repository progress.",
                confidence: 0.96,
                evidence: ["prior build status: FAILED"],
                recommendedAction: "Restore a passing build before any new functional work."
            )
        }

        if observation.priorTestStatus == "FAILED" {
            return SUPRAExecutiveDecision(
                priority: .restoreTestHealth,
                rationale: "The last known test state is failed, reducing reliability of repository evolution.",
                confidence: 0.94,
                evidence: ["prior test status: FAILED"],
                recommendedAction: "Stabilize failing tests and re-establish the validated baseline."
            )
        }

        if !observation.providerAvailable {
            return SUPRAExecutiveDecision(
                priority: .restoreProviderAvailability,
                rationale: "Canonical mission execution depends on at least one registered execution provider.",
                confidence: 0.93,
                evidence: ["provider count: 0"],
                recommendedAction: "Restore provider availability through the canonical provider bridge."
            )
        }

        if !observation.missingEvidence.isEmpty {
            return SUPRAExecutiveDecision(
                priority: .closeEvidenceGap,
                rationale: "Missing evidence weakens autonomous decision quality and traceability.",
                confidence: 0.9,
                evidence: observation.missingEvidence,
                recommendedAction: "Generate or restore the missing evidence needed for reliable autonomy."
            )
        }

        if !observation.duplicateResponsibilities.isEmpty {
            return SUPRAExecutiveDecision(
                priority: .reduceDuplicateResponsibilities,
                rationale: "Repository duplication increases ambiguity and makes runtime decisions less predictable.",
                confidence: 0.84,
                evidence: observation.duplicateResponsibilities,
                recommendedAction: "Consolidate the highest-risk duplicate responsibility without deleting unproven code."
            )
        }

        if !observation.inactiveServices.isEmpty {
            return SUPRAExecutiveDecision(
                priority: .activateInactiveServices,
                rationale: "Inactive canonical services reduce available runtime capability and observability.",
                confidence: 0.82,
                evidence: observation.inactiveServices,
                recommendedAction: "Investigate and reactivate the most important inactive canonical service."
            )
        }

        if observation.runtimeStatus.level != .healthy {
            return SUPRAExecutiveDecision(
                priority: .stabilizeRuntime,
                rationale: "Runtime health is below healthy and should be stabilized before expanding work.",
                confidence: 0.8,
                evidence: [observation.runtimeStatus.summary],
                recommendedAction: "Stabilize runtime health and preserve continuity."
            )
        }

        return SUPRAExecutiveDecision(
            priority: .executeBacklog,
            rationale: "The runtime is healthy enough to advance the highest-value executable backlog item.",
            confidence: 0.78,
            evidence: ["backlog count: \(observation.missionBacklogCount)", "repository changes: \(observation.repository.modifiedFiles.count)"],
            recommendedAction: "Execute one backlog item that improves repository reliability."
        )
    }

    private func generateMissionDraft(
        from observation: SUPRAExecutiveObservation,
        decision: SUPRAExecutiveDecision
    ) -> SUPRAExecutiveMissionDraft {
        let objective = "Executive Priority: \(decision.priority.rawValue)"
        let scope = [
            "Repository root: \(observation.workspace.rootPath)",
            "Runtime health: \(observation.runtimeStatus.summary)",
            "Backlog count: \(observation.missionBacklogCount)"
        ]
        let constraints = [
            "Reuse existing RuntimeMonitor, MetricsCollector, HealthMonitor, WorkspaceMemoryStore",
            "Execute only through MissionStore and SUPRAExecutionPipeline",
            "Do not introduce a parallel execution path",
            "Preserve validated build and test baseline"
        ]
        let expectedDeliverables = [
            "Mission result in canonical MissionStore",
            "Updated workspace memory",
            "Validated build output",
            "Validated test output",
            "Recommended next action"
        ]
        let validationCriteria = [
            "One executive priority selected",
            "One mission generated",
            "Mission executed through canonical pipeline",
            "Build completed",
            "Tests completed",
            "Memory updated",
            "Next iteration prepared"
        ]
        let stopConditions = [
            "Mission execution result stored",
            "Validation completed",
            "Learning recorded",
            "Recommendation published"
        ]

        return SUPRAExecutiveMissionDraft(
            objective: objective,
            scope: scope,
            constraints: constraints,
            expectedDeliverables: expectedDeliverables,
            validationCriteria: validationCriteria,
            stopConditions: stopConditions,
            estimatedImpact: decision.recommendedAction,
            confidence: decision.confidence,
            evidenceRequirements: decision.evidence.isEmpty ? ["Runtime status", "Mission outcome"] : decision.evidence
        )
    }

    private func recordLearning(
        mission: Mission,
        validation: SUPRAValidationSummary,
        observation: SUPRAExecutiveObservation,
        decision: SUPRAExecutiveDecision
    ) -> SUPRAExecutiveLearning {
        let lessons = [
            "Priority selected: \(decision.priority.rawValue)",
            "Mission state: \(mission.currentStatus)",
            "Build result: \(validation.buildSucceeded ? "PASSED" : "FAILED")",
            "Test result: \(validation.testSucceeded ? "PASSED" : "FAILED")"
        ]
        let repositoryEvolution = observation.repository.hasRepositoryChanges
            ? "Repository has \(observation.repository.modifiedFiles.count) modified file(s) and \(observation.repository.untrackedFiles.count) untracked file(s)."
            : "Repository clean at observation time."

        workspaceMemoryStore.recordEvent(
            type: "executive_learning",
            object: nil,
            change: "Priority \(decision.priority.rawValue) with mission \(mission.currentStatus)"
        )

        return SUPRAExecutiveLearning(
            lessonsLearned: lessons,
            repositoryEvolution: repositoryEvolution,
            evidence: decision.evidence,
            recordedAt: Date()
        )
    }

    private func repositoryStatus(at rootURL: URL) -> SUPRARepositoryStatus {
        let branch = runShell(
            executable: "/usr/bin/git",
            arguments: ["-C", rootURL.path, "rev-parse", "--abbrev-ref", "HEAD"]
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        let statusOutput = runShell(
            executable: "/usr/bin/git",
            arguments: ["-C", rootURL.path, "status", "--short"]
        )
        let lines = statusOutput.split(separator: "\n").map(String.init)
        let modified = lines.compactMap { line -> String? in
            guard line.count > 3 else { return nil }
            let prefix = line.prefix(2)
            if prefix.contains("M") || prefix.contains("A") || prefix.contains("D") || prefix.contains("R") {
                return String(line.dropFirst(3))
            }
            return nil
        }
        let untracked = lines.compactMap { line -> String? in
            line.hasPrefix("?? ") ? String(line.dropFirst(3)) : nil
        }

        return SUPRARepositoryStatus(
            branch: branch.isEmpty ? "unknown" : branch,
            modifiedFiles: modified,
            untrackedFiles: untracked,
            hasRepositoryChanges: !modified.isEmpty || !untracked.isEmpty
        )
    }

    private func inactiveServices() -> [String] {
        guard let state = SUPRACompositionRoot.shared.runtimeKernel.state else { return [] }
        return state.components.values
            .filter { $0.health == .inactive }
            .map { $0.component.id }
            .sorted()
    }

    private func detectDuplicateResponsibilities() -> [String] {
        let knownPairs = [
            ["RuntimeEvent.swift", "SUPRARuntimeEvents.swift"],
            ["MissionProposalEngine.swift", "SUPRAMissionProposalEngine.swift"],
            ["KnowledgeGraph.swift", "WorkspaceKnowledgeGraph.swift"],
            ["KnowledgeGraph.swift", "NOVAKnowledgeKernel.swift"]
        ]

        let available = Set(runShell(
            executable: "/usr/bin/find",
            arguments: [projectRootURL.path, "-name", "*.swift"]
        ).split(separator: "\n").map { URL(fileURLWithPath: String($0)).lastPathComponent })

        return knownPairs.compactMap { pair in
            pair.allSatisfy { available.contains($0) } ? pair.joined(separator: " ↔ ") : nil
        }
    }

    private func detectMissingEvidence() -> [String] {
        var missing: [String] = []
        if workspaceMemoryStore.memory.entries.isEmpty {
            missing.append("workspace_memory.json has no recorded entries")
        }
        if SUPRACompositionRoot.shared.runtimeKernel.state == nil {
            missing.append("Runtime kernel state not loaded")
        }
        if CAnnoNicoSnapshotStore.shared.state == nil {
            missing.append("CAnnoNico snapshot unavailable")
        }
        return missing
    }

    private func readPriorValidationStatus() -> (build: String, test: String) {
        let statusURL = projectRootURL.appendingPathComponent("STATUS.json")
        guard let data = try? Data(contentsOf: statusURL),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return ("UNKNOWN", "UNKNOWN")
        }

        let build = ((object["build"] as? [String: Any])?["status"] as? String) ?? "UNKNOWN"
        let test = ((object["tests"] as? [String: Any])?["status"] as? String) ?? "UNKNOWN"
        return (build, test)
    }

    private func runShell(executable: String, arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()
        do {
            try process.run()
            let completion = DispatchSemaphore(value: 0)
            DispatchQueue.global(qos: .utility).async {
                process.waitUntilExit()
                completion.signal()
            }
            if completion.wait(timeout: .now() + 5) == .timedOut {
                process.terminate()
                _ = completion.wait(timeout: .now() + 1)
                return ""
            }
            let data = output.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private func recommendedNextMission(
        for mission: Mission,
        validation: SUPRAValidationSummary,
        status: RuntimeStatus
    ) -> String {
        if !validation.buildSucceeded || !validation.testSucceeded {
            return """
            # NEXT EXECUTIVE MISSION

            Fix the build or test regression detected during the runtime iteration.
            Evidence: validation failed while mission \(mission.title) ended in \(mission.currentStatus).
            """
        }

        if mission.status != .completed {
            return """
            # NEXT EXECUTIVE MISSION

            Restore provider execution reliability for queued runtime missions.
            Evidence: mission \(mission.title) did not complete successfully.
            """
        }

        return """
        # NEXT EXECUTIVE MISSION

        Advance the next highest-confidence runtime proposal while preserving the validated build and test baseline.
        Evidence: runtime status \(status.level.rawValue), build passed, tests passed, memory updated.
        """
    }

    private static func defaultProjectRootURL() -> URL {
        let root = SUPRAEnvironmentResolver.shared.projectRoot
        return URL(fileURLWithPath: root.isEmpty ? FileManager.default.currentDirectoryPath : root)
    }

    nonisolated static func stateRule(for state: SUPRAExecutiveLoopState) -> SUPRAExecutiveStateRule {
        switch state {
        case .boot:
            return SUPRAExecutiveStateRule(preconditions: ["Iteration requested"], entryConditions: ["No active state"], exitConditions: ["Environment resolved"], successCriteria: ["Registry initialized"], failureCriteria: ["Environment unresolved"], recoveryStrategy: .replay, timeoutSeconds: 10, producedEvidence: ["providers", "models"], confidenceScore: 0.95, allowedSuccessorStates: [.observe, .failed])
        case .observe:
            return SUPRAExecutiveStateRule(preconditions: ["BOOT completed"], entryConditions: ["Workspace reachable"], exitConditions: ["Workspace analyzed"], successCriteria: ["Runtime status updated"], failureCriteria: ["Workspace unavailable"], recoveryStrategy: .fallback, timeoutSeconds: 10, producedEvidence: ["files", "missions"], confidenceScore: 0.9, allowedSuccessorStates: [.understand, .failed])
        case .understand:
            return SUPRAExecutiveStateRule(preconditions: ["OBSERVE completed"], entryConditions: ["Observation inputs present"], exitConditions: ["Observation built"], successCriteria: ["Risks identified"], failureCriteria: ["Observation incomplete"], recoveryStrategy: .retry, timeoutSeconds: 10, producedEvidence: ["providers", "missingEvidence", "duplicates"], confidenceScore: 0.88, allowedSuccessorStates: [.decide, .failed])
        case .decide:
            return SUPRAExecutiveStateRule(preconditions: ["UNDERSTAND completed"], entryConditions: ["Observation available"], exitConditions: ["Single priority selected"], successCriteria: ["One decision published"], failureCriteria: ["Ambiguous priority"], recoveryStrategy: .retry, timeoutSeconds: 10, producedEvidence: ["priority", "recommendedAction"], confidenceScore: 0.9, allowedSuccessorStates: [.prepare, .failed])
        case .prepare:
            return SUPRAExecutiveStateRule(preconditions: ["DECIDE completed"], entryConditions: ["Decision available"], exitConditions: ["Mission persisted"], successCriteria: ["Mission ID created"], failureCriteria: ["Mission persistence failed"], recoveryStrategy: .retry, timeoutSeconds: 10, producedEvidence: ["missionID"], confidenceScore: 0.92, allowedSuccessorStates: [.execute, .failed])
        case .execute:
            return SUPRAExecutiveStateRule(preconditions: ["PREPARE completed"], entryConditions: ["Mission ID available"], exitConditions: ["Mission ended"], successCriteria: ["Mission completed or failed with proof"], failureCriteria: ["Mission timed out", "Mission missing"], recoveryStrategy: .fallback, timeoutSeconds: 20, producedEvidence: ["missionState", "provider", "model"], confidenceScore: 0.9, allowedSuccessorStates: [.validate, .failed])
        case .validate:
            return SUPRAExecutiveStateRule(preconditions: ["EXECUTE completed"], entryConditions: ["Mission result available"], exitConditions: ["Validation complete"], successCriteria: ["Build/test evidence recorded"], failureCriteria: ["Validation timed out"], recoveryStrategy: .skip, timeoutSeconds: 30, producedEvidence: ["build", "tests"], confidenceScore: 0.9, allowedSuccessorStates: [.learn, .failed])
        case .learn:
            return SUPRAExecutiveStateRule(preconditions: ["VALIDATE completed"], entryConditions: ["Validation available"], exitConditions: ["Memory updated"], successCriteria: ["Learning recorded"], failureCriteria: ["Memory write failed"], recoveryStrategy: .retry, timeoutSeconds: 10, producedEvidence: ["memoryUpdated", "lessons"], confidenceScore: 0.88, allowedSuccessorStates: [.freeze, .failed])
        case .freeze:
            return SUPRAExecutiveStateRule(preconditions: ["LEARN completed"], entryConditions: ["Learning available"], exitConditions: ["Next mission published"], successCriteria: ["One recommendation prepared"], failureCriteria: ["Recommendation missing"], recoveryStrategy: .abort, timeoutSeconds: 10, producedEvidence: ["nextExecutiveMission"], confidenceScore: 0.86, allowedSuccessorStates: [.ready, .failed])
        case .ready:
            return SUPRAExecutiveStateRule(preconditions: ["FREEZE completed"], entryConditions: ["Next mission available"], exitConditions: ["Iteration terminated"], successCriteria: ["Runtime ready"], failureCriteria: ["Multiple active states"], recoveryStrategy: .abort, timeoutSeconds: 5, producedEvidence: ["nextIterationPrepared", "missionState"], confidenceScore: 0.95, allowedSuccessorStates: [])
        case .failed:
            return SUPRAExecutiveStateRule(preconditions: ["Failure detected"], entryConditions: ["Proof available"], exitConditions: ["Recovery published"], successCriteria: ["Failure classified"], failureCriteria: ["Missing root cause"], recoveryStrategy: .humanIntervention, timeoutSeconds: 5, producedEvidence: ["rootCause", "proof"], confidenceScore: 0.9, allowedSuccessorStates: [])
        }
    }

    nonisolated static func isTransitionAllowed(
        from previous: SUPRAExecutiveLoopState,
        to next: SUPRAExecutiveLoopState
    ) -> Bool {
        stateRule(for: previous).allowedSuccessorStates.contains(next)
    }

    nonisolated static func classifyRecoveryStrategy(_ strategy: String) -> SUPRARecoveryStrategyKind {
        let normalized = strategy.lowercased()
        if normalized.contains("retry") {
            return .retry
        }
        if normalized.contains("replay") {
            return .replay
        }
        if normalized.contains("fallback") || normalized.contains("provider") {
            return .fallback
        }
        if normalized.contains("skip") {
            return .skip
        }
        if normalized.contains("human") {
            return .humanIntervention
        }
        return .abort
    }

    private func runWithTimeout<T: Sendable>(
        seconds: Double,
        operation: @escaping @MainActor () async -> T
    ) async -> T? {
        let task = Task { @MainActor in
            await operation()
        }

        return await withTaskGroup(of: T?.self) { group in
            group.addTask {
                await task.value
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                task.cancel()
                return nil
            }

            let result = await group.next() ?? nil
            group.cancelAll()
            return result
        }
    }
}
