import SwiftUI

private struct GrandeMissionDecisionOption: Identifiable {
    let key: String
    let value: String
    var id: String { key }
}

struct GrandeMissionHumanGateView: View {
    @ObservedObject private var runner = SUPRAGrandeMissionRunner.shared

    @State private var packet = ""
    @State private var fields: [String: String] = [:]
    @State private var decisionDraft = ""
    @State private var isLoading = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var submissionMessage: String?

    private let runtime = SUPRAChatRuntimeAdapter()

    var body: some View {
        if let phase = runner.blockedPhase,
           let receipt = runner.receipt(for: phase.id) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("NICOLAS DECISION REQUIRED", systemImage: "person.crop.circle.badge.exclamationmark")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(.orange)

                        Text(phase.title)
                            .font(.title2.bold())

                        Text("The mission is waiting here. It will not retry in a loop until you answer.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("AWAITING NICOLAS")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.10), in: Capsule())
                }

                blockerSummary(receipt: receipt)

                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Resolving missing decision details…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !options.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Choose")
                                .font(.headline)

                            ForEach(options) { option in
                                Button {
                                    decisionDraft = "\(option.key) — \(option.value)"
                                } label: {
                                    HStack(alignment: .top, spacing: 10) {
                                        Text(option.key)
                                            .font(.caption.weight(.heavy))
                                            .foregroundStyle(.orange)
                                            .frame(width: 72, alignment: .leading)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(option.value)
                                                .font(.callout.weight(.semibold))
                                                .foregroundStyle(.primary)

                                            if let consequence = consequence(for: option.key) {
                                                Text(consequence)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        Spacer()

                                        Image(systemName: decisionDraft.hasPrefix(option.key) ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(decisionDraft.hasPrefix(option.key) ? .green : .secondary)
                                    }
                                    .padding(12)
                                    .background(
                                        decisionDraft.hasPrefix(option.key)
                                            ? Color.green.opacity(0.07)
                                            : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if let safeDefault = fields["SAFE_DEFAULT"],
                       !safeDefault.isEmpty {
                        Label("Safe default: \(safeDefault)", systemImage: "shield.checkered")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your answer")
                            .font(.headline)

                        TextEditor(text: $decisionDraft)
                            .font(.callout.monospaced())
                            .frame(minHeight: 95)
                            .padding(8)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

                        Text("You can choose one option above or write a precise instruction in your own words.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Button {
                            Task { await loadDecisionPacket(force: true) }
                        } label: {
                            Label("Clarify / refresh options", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading || isSubmitting)

                        Spacer()

                        Button {
                            Task { await submit(phaseID: phase.id) }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Label("Submit decision & resume", systemImage: "play.circle.fill")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(
                            decisionDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            || isLoading
                            || isSubmitting
                        )
                    }

                    if let submissionMessage {
                        Label(submissionMessage, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }
            .padding(18)
            .background(Color.orange.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.orange.opacity(0.32))
            )
            .task(id: phase.id) {
                await loadDecisionPacket(force: false)
            }
        }
    }

    @ViewBuilder
    private func blockerSummary(
        receipt: SUPRAGrandeMissionRunner.PhaseReceipt
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let why = fields["BLOCKERS"] ?? fields["WHY_BLOCKED"] {
                labeled("Why blocked", why, symbol: "exclamationmark.octagon.fill")
            } else {
                labeled(
                    "Why blocked",
                    compactFallback(from: receipt.response),
                    symbol: "exclamationmark.octagon.fill"
                )
            }

            if let question = fields["DECISION_QUESTION"],
               !question.isEmpty {
                labeled("Decision", question, symbol: "questionmark.circle.fill")
            } else {
                labeled(
                    "Decision",
                    "SUPRA is preparing the exact decision question from the current blocker.",
                    symbol: "questionmark.circle.fill"
                )
            }

            if let evidence = fields["EVIDENCE_REFS"],
               !evidence.isEmpty {
                labeled("Evidence", evidence, symbol: "doc.text.magnifyingglass")
            }
        }
    }

    private func labeled(
        _ title: String,
        _ value: String,
        symbol: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.orange)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.callout)
                    .textSelection(.enabled)
            }
        }
    }

    private var options: [GrandeMissionDecisionOption] {
        ["OPTION_A", "OPTION_B", "OPTION_C"].compactMap { key in
            guard let value = fields[key],
                  !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                return nil
            }

            return GrandeMissionDecisionOption(
                key: key,
                value: value
            )
        }
    }

    private func consequence(
        for optionKey: String
    ) -> String? {
        let suffix = optionKey.replacingOccurrences(of: "OPTION_", with: "")
        return fields["CONSEQUENCE_\(suffix)"]
    }

    @MainActor
    private func loadDecisionPacket(
        force: Bool
    ) async {
        guard let phase = runner.blockedPhase,
              let receipt = runner.receipt(for: phase.id)
        else {
            return
        }

        errorMessage = nil

        // 1. Fastest path: the blocked receipt may already contain a complete
        // decision packet. Parse it locally; no runtime call required.
        let receiptFields = parse(receipt.response)

        if !force,
           hasUsableDecisionPacket(receiptFields) {
            packet = receipt.response
            fields = receiptFields
            return
        }

        // 2. Reuse the last packet for this exact blocked receipt.
        if !force,
           let cached = runner.humanGatePacket(
               for: phase.id,
               receiptFinishedAt: receipt.finishedAt
           ) {
            let cachedFields = parse(cached)

            if hasUsableDecisionPacket(cachedFields) {
                packet = cached
                fields = cachedFields
                return
            }
        }

        // 3. Never blank the UI while enriching missing options.
        // Keep all blocker/evidence fields we already have on screen.
        if fields.isEmpty {
            fields = receiptFields
        }

        isLoading = true

        do {
            try await runtime.checkHealth()

            let originConversationID = SUPRAConversationLineage.canonicalID()
            let prompt = """
            GRANDE_MISSION_HUMAN_GATE_PACKET
            AUTHORITY=NICOLAS
            READ_ONLY=YES
            MISSION_ID=\(runner.missionID)
            ORIGIN_CONVERSATION_ID=\(originConversationID)
            ORIGIN_CHAT=\(originConversationID)
            ORIGIN_CHAT_EXACT_REQUIRED=YES
            PHASE_ID=\(phase.id)
            PHASE_TITLE=\(phase.title)
            PHASE_OBJECTIVE=\(phase.objective)

            CURRENT_BLOCKED_RECEIPT:
            \(receipt.response)

            Convert this blocker into one concrete human decision packet.
            Reuse the supplied evidence; do not re-investigate the mission.
            Do not invent missing facts.
            If evidence is insufficient, one option must preserve the ambiguity and collect only the missing evidence.
            Keep options materially distinct and concise.

            RETURN EXACTLY:
            WHY_BLOCKED=
            DECISION_QUESTION=
            OPTION_A=
            OPTION_B=
            OPTION_C=
            SAFE_DEFAULT=
            CONSEQUENCE_A=
            CONSEQUENCE_B=
            CONSEQUENCE_C=
            EVIDENCE_REFS=
            """

            let resolved = try await runtime.execute(
                prompt: prompt,
                mode: .ask
            )

            let resolvedFields = parse(resolved)

            packet = resolved

            // Merge instead of replacing so existing evidence never disappears.
            fields.merge(resolvedFields) { _, new in new }

            if hasUsableDecisionPacket(resolvedFields) {
                try? runner.saveHumanGatePacket(
                    phaseID: phase.id,
                    receiptFinishedAt: receipt.finishedAt,
                    packet: resolved
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func hasUsableDecisionPacket(
        _ candidate: [String: String]
    ) -> Bool {
        let question = candidate["DECISION_QUESTION"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let optionCount = ["OPTION_A", "OPTION_B", "OPTION_C"]
            .compactMap { candidate[$0] }
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
            .count

        return !(question ?? "").isEmpty && optionCount >= 2
    }

    @MainActor
    private func submit(
        phaseID: String
    ) async {
        let answer = decisionDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }

        isSubmitting = true
        errorMessage = nil
        submissionMessage = nil

        do {
            let originConversationID = SUPRAConversationLineage.canonicalID()
            try await runner.submitHumanDecision(
                phaseID: phaseID,
                decision: answer
            )

            SUPRAConversationLineage.append(
                role: .user,
                mode: .ask,
                content: "HUMAN_GATE_DECISION PHASE_ID=\(phaseID)\n\(answer)",
                originConversationID: originConversationID
            )

            let resumedStatus = runner.receiptStatus(for: phaseID) ?? "UNPROVEN"
            SUPRAConversationLineage.append(
                role: .runtime,
                mode: .ask,
                content: "HUMAN_GATE_RESUME PHASE_ID=\(phaseID) ORIGIN_CONVERSATION_ID=\(originConversationID) STATUS=\(resumedStatus)",
                originConversationID: originConversationID
            )

            if resumedStatus == "PASS" {
                submissionMessage = "Decision accepted. Mission resumed and this phase passed."
                runner.clearHumanGatePacket(phaseID: phaseID)
                decisionDraft = ""
                fields = [:]
                packet = ""
            } else {
                submissionMessage = nil
                decisionDraft = ""
                await loadDecisionPacket(force: true)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    private func parse(
        _ text: String
    ) -> [String: String] {
        var result: [String: String] = [:]

        for rawLine in text.split(whereSeparator: { $0.isNewline }) {
            let line = String(rawLine)
            guard let separator = line.firstIndex(of: "=") else { continue }

            let key = String(line[..<separator])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let value = String(line[line.index(after: separator)...])
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !key.isEmpty else { continue }
            result[key] = value
        }

        return result
    }

    private func compactFallback(
        from text: String
    ) -> String {
        let compact = text
            .split(whereSeparator: { $0.isNewline })
            .prefix(8)
            .joined(separator: " · ")

        return compact.isEmpty
            ? "The phase returned BLOCKED without a usable explanation."
            : compact
    }
}
