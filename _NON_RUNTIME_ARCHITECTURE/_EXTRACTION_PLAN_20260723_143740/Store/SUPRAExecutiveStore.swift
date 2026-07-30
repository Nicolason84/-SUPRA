import Foundation
import SwiftUI

final class SUPRAExecutiveStore: ObservableObject {
    @Published private(set) var model: SUPRAExecutiveModel = .fallback
    @Published private(set) var monetizableOpportunities: [SUPRARecord] = []
    @Published private(set) var actions: [SUPRAActionDefinition] = []
    @Published private(set) var actionOutput = ""
    @Published private(set) var actionBusy = false

    @Published private(set) var chatMessages: [SUPRAChatMessage] = []
    @Published private(set) var chatBusy = false
    @Published private(set) var chatConnected = false

    private let chatURL = URL(string: "http://127.0.0.1:18765/v1/chat")!

    func sendChat(_ text: String) async {
        chatMessages.append(SUPRAChatMessage(role: "user", text: text))
        chatBusy = true
        defer { chatBusy = false }

        do {
            var request = URLRequest(url: chatURL)
            request.timeoutInterval = 600
            request.httpMethod = "POST"
            request.timeoutInterval = 180
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("SUPRA.app", forHTTPHeaderField: "X-SUPRA-Client")
            request.httpBody = try JSONEncoder().encode(SUPRAChatRequest(message: text))

            // SUPRA_MISSION_EVIDENCE_INJECTION_V1_BEGIN

            guard let originalRequestBody = request.httpBody,
                  var localBridgePayload = try JSONSerialization.jsonObject(
                      with: originalRequestBody
                  ) as? [String: Any]
            else {
                throw URLError(.cannotParseResponse)
            }

            let missionEvidence =
                SUPRAMissionEvidenceLoader.loadRequiredEvidence()

            let requiredMissionEvidence = Set([
                "GRAPH_SCHEMA_PROBE",
                "STATUS"
            ])

            let loadedMissionEvidence = Set(
                missionEvidence.map(\.evidenceId)
            )

            guard requiredMissionEvidence.isSubset(
                of: loadedMissionEvidence
            ) else {
                let missingEvidence = requiredMissionEvidence
                    .subtracting(loadedMissionEvidence)
                    .sorted()
                    .joined(separator: ", ")

                throw NSError(
                    domain: "SUPRA.MissionContextLoader",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Mission evidence missing: \(missingEvidence)"
                    ]
                )
            }

            SUPRAMissionEvidenceLoader
                .removePlaceholderMissionEvidence(
                    from: &localBridgePayload
                )

            localBridgePayload["mission_evidence"] =
                missionEvidence.map { evidence in
                    [
                        "evidence_id": evidence.evidenceId,
                        "source_path": evidence.sourcePath,
                        "content_type": evidence.contentType,
                        "content": evidence.content
                    ]
                }

            request.httpBody = try JSONSerialization.data(
                withJSONObject: localBridgePayload,
                options: []
            )

            // SUPRA_MISSION_EVIDENCE_INJECTION_V1_END

            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 600
            configuration.timeoutIntervalForResource = 900
            configuration.waitsForConnectivity = true
            let session = URLSession(configuration: configuration)
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            let payload = try JSONDecoder().decode(SUPRAChatResponse.self, from: data)
            guard (200..<300).contains(http.statusCode), payload.status == "PASS", let reply = payload.reply else {
                throw NSError(
                    domain: "SUPRABridge",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: payload.error ?? "Réponse invalide du bridge"]
                )
            }
            chatConnected = true
            chatMessages.append(SUPRAChatMessage(role: "assistant", text: reply))
        } catch {
            chatConnected = false
            chatMessages.append(
                SUPRAChatMessage(role: "assistant", text: "Bridge indisponible : \(error.localizedDescription)")
            )
        }
    }


    private var modelURL: URL? {
        Bundle.main.url(
            forResource: "SUPRA_EXECUTIVE_UI_MODEL",
            withExtension: "json"
        )
    }

    func load() {
        loadActions()

        guard let modelURL else {
            model = .fallback.withAlert(
                title: "UI model missing from application bundle",
                detail: "SUPRA_EXECUTIVE_UI_MODEL.json n’est pas inclus dans le bundle."
            )
            monetizableOpportunities = []
            return
        }

        do {
            let data = try Data(contentsOf: modelURL)
            let decoder = JSONDecoder()
            let baseModel = try decoder.decode(
                SUPRAExecutiveModel.self,
                from: data
            )

            do {
                let connection = try baseModel.connectingSemanticProductFeeds()
                model = connection.model
                monetizableOpportunities = connection.opportunities
            } catch {
                model = baseModel.withAlert(
                    title: "Semantic product feed unavailable",
                    detail: error.localizedDescription
                )
                monetizableOpportunities = []
            }
        } catch {
            model = .fallback.withAlert(
                title: "UI model decoding failed",
                detail: error.localizedDescription
            )
            monetizableOpportunities = []
        }
    }


    func loadActions() {
        do {
            actions = try SUPRAActionRuntime.loadManifest().actions
            actionOutput = "Allowlist chargée : \(actions.count) action(s)."
        } catch {
            actions = []
            actionOutput = "Allowlist indisponible : \(error.localizedDescription)"
        }
    }

    func verify(_ action: SUPRAActionDefinition) {
        do {
            try SUPRAActionRuntime.verify(action)
            actionOutput = "VERIFY=PASS\nID=\(action.id)\nSHA256=\(action.sha256)\nMODE=\(action.mode)"
        } catch {
            actionOutput = "VERIFY=FAILED\nID=\(action.id)\nERROR=\(error.localizedDescription)"
        }
    }

    func execute(_ action: SUPRAActionDefinition) async {
        actionBusy = true
        actionOutput = "EXECUTION=START\nID=\(action.id)"
        do {
            let output = try await Task.detached(priority: .userInitiated) {
                try SUPRAActionRuntime.execute(action)
            }.value
            actionOutput = output
        } catch {
            actionOutput = "EXECUTION=FAILED\nID=\(action.id)\nERROR=\(error.localizedDescription)"
        }
        actionBusy = false
    }

    func revealModel() {
        guard let modelURL else {
            return
        }

        NSWorkspace.shared.activateFileViewerSelecting([modelURL])
    }
}
