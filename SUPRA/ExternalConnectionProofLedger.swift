import SwiftUI

enum ExternalConnectionFreshness: String, CaseIterable {
    case live = "LIVE"
    case stale = "STALE"
    case unproven = "UNPROVEN"

    var tint: Color {
        switch self {
        case .live: return .green
        case .stale: return .orange
        case .unproven: return .secondary
        }
    }
}

struct ExternalConnectionProof: Identifiable {
    let id: String
    let observedAt: Date
    let evidence: String
    let source: String
}

enum ExternalConnectionProofLedger {
    private static let auditObservedAt = ISO8601DateFormatter().date(
        from: "2026-09-22T08:12:00Z"
    )!

    private static func audit(_ id: String, _ evidence: String) -> ExternalConnectionProof {
        ExternalConnectionProof(
            id: id,
            observedAt: auditObservedAt,
            evidence: evidence,
            source: "NOVA_ERA_EXTERNAL_CONNECTION_LIVE_STATE_20260922"
        )
    }

    static let all: [String: ExternalConnectionProof] = [
        "gdrive": audit("gdrive", "Live Drive read/write + private mailbox roundtrip PASS"),
        "gmail": audit("gmail", "Live Gmail search/read surface PASS"),
        "gcal": audit("gcal", "Authenticated Google Calendar profile read PASS"),
        "gcontacts": audit("gcontacts", "Authenticated Google Contacts profile read PASS"),
        "github": audit("github", "Repository read/write + canonical CI PASS"),
        "figma": audit("figma", "Authenticated Figma workspace observed"),
        "canva": audit("canva", "Authenticated Canva root workspace observed"),
        "notion": audit("notion", "Authenticated Notion workspace search/read observed"),
        "linear": audit("linear", "Authenticated Linear workspace search observed"),
        "windsor": audit("windsor", "Windsor provider fabric responsive"),
        "linkedin": audit("linkedin", "Live LinkedIn organic account observed via approved provider"),
        "apollo": audit("apollo", "Authenticated Apollo profile read PASS"),
        "atlassian": audit("atlassian", "Authenticated Atlassian user + Jira resource observed"),
        "posthog": audit("posthog", "Project listing PASS; advanced scopes remain limited"),
        "supabase": audit("supabase", "Account linked; no accessible operational project returned")
    ]

    private static func projectedProofs() -> [String: ExternalConnectionProof] {
        let fm = FileManager.default
        guard let appSupport = fm.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return [:]
        }

        let url = appSupport
            .appendingPathComponent("SUPRA", isDirectory: true)
            .appendingPathComponent("Projection", isDirectory: true)
            .appendingPathComponent("EXTERNAL_CONNECTION_LIVE_PROOFS_V1.json")

        guard let data = try? Data(contentsOf: url, options: [.mappedIfSafe]),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              root["schema"] as? String == "EXTERNAL_CONNECTION_LIVE_PROOFS_V1",
              let observedRaw = root["observed_at"] as? String,
              let observedAt = ISO8601DateFormatter().date(from: observedRaw),
              let rows = root["proofs"] as? [[String: Any]]
        else {
            return [:]
        }

        let source = root["source"] as? String ?? "LIVE_CONNECTOR_READ_PROBES"
        var result: [String: ExternalConnectionProof] = [:]

        for row in rows {
            guard let id = row["id"] as? String,
                  let evidence = row["evidence"] as? String,
                  !id.isEmpty,
                  !evidence.isEmpty
            else {
                continue
            }

            result[id] = ExternalConnectionProof(
                id: id,
                observedAt: observedAt,
                evidence: evidence,
                source: source
            )
        }

        return result
    }

    static func proof(for id: String) -> ExternalConnectionProof? {
        projectedProofs()[id] ?? all[id]
    }

    static func freshness(
        for connector: ExternalConnectorDescriptor,
        now: Date = .now
    ) -> ExternalConnectionFreshness {
        guard connector.status == .connected else {
            return .unproven
        }
        guard let proof = proof(for: connector.id) else {
            return .unproven
        }
        let age = now.timeIntervalSince(proof.observedAt)
        return age <= 48 * 60 * 60 ? .live : .stale
    }

    static func ageLabel(for id: String, now: Date = .now) -> String? {
        guard let proof = proof(for: id) else { return nil }
        let seconds = max(0, now.timeIntervalSince(proof.observedAt))
        if seconds < 60 * 60 {
            return "\(max(1, Int(seconds / 60)))m"
        }
        if seconds < 48 * 60 * 60 {
            return "\(Int(seconds / 3600))h"
        }
        return "\(Int(seconds / 86400))d"
    }

    static var liveCount: Int {
        ExternalConnectorCatalog.all.filter {
            freshness(for: $0) == .live
        }.count
    }

    static var staleCount: Int {
        ExternalConnectorCatalog.all.filter {
            freshness(for: $0) == .stale
        }.count
    }
}
