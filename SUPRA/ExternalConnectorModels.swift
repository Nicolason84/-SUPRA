import SwiftUI

enum ExternalConnectionStatus: String, CaseIterable {
    case connected = "CONNECTED"
    case available = "AVAILABLE"
    case authRequired = "AUTH REQUIRED"
    case approvalRequired = "APPROVAL REQUIRED"
    case providerRequired = "PROVIDER REQUIRED"
    case planned = "PLANNED"
    case blocked = "BLOCKED"

    var tint: Color {
        switch self {
        case .connected: return .green
        case .available: return .mint
        case .authRequired: return .orange
        case .approvalRequired: return .yellow
        case .providerRequired: return .blue
        case .planned: return .secondary
        case .blocked: return .red
        }
    }
}

struct ExternalConnectorDescriptor: Identifiable {
    let id: String
    let provider: String
    let family: String
    let authorityClass: String
    let status: ExternalConnectionStatus
    let detail: String
    let systemImage: String
    let humanGate: String
    let officialRoute: String
    let priority: String
}

enum ExternalConnectorCatalog {
    static func descriptor(id: String) -> ExternalConnectorDescriptor? {
        all.first { $0.id == id }
    }

    static var connectedCount: Int {
        all.filter { $0.status == .connected }.count
    }

    static var attentionCount: Int {
        all.filter {
            $0.status == .authRequired
                || $0.status == .approvalRequired
                || $0.status == .providerRequired
                || $0.status == .blocked
        }.count
    }

    static let all: [ExternalConnectorDescriptor] = [
        .init(
            id: "gmail",
            provider: "Gmail",
            family: "Communications",
            authorityClass: "C1/C2/C3",
            status: .connected,
            detail: "Search, read, attachments, drafts, labels, archive and send.",
            systemImage: "envelope.fill",
            humanGate: "External send by default",
            officialRoute: "Google connector",
            priority: "P0"
        ),
        .init(
            id: "gcal",
            provider: "Google Calendar",
            family: "Communications",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Events, availability, create/update/delete and invitation response.",
            systemImage: "calendar",
            humanGate: "Material external invitations",
            officialRoute: "Google connector",
            priority: "P0"
        ),
        .init(
            id: "gcontacts",
            provider: "Google Contacts",
            family: "Identity",
            authorityClass: "C1",
            status: .connected,
            detail: "Search and read contact identity data.",
            systemImage: "person.crop.circle.fill",
            humanGate: "None for authorized read",
            officialRoute: "Google connector",
            priority: "P0"
        ),
        .init(
            id: "gdrive",
            provider: "Google Drive",
            family: "Documents",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Drive, Docs, Sheets and Slides with source-preserving operations.",
            systemImage: "folder.fill",
            humanGate: "Sensitive share/delete",
            officialRoute: "Google connector",
            priority: "P0"
        ),
        .init(
            id: "github",
            provider: "GitHub",
            family: "Engineering",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Code, branches, pull requests, CI evidence and canonical promotion.",
            systemImage: "chevron.left.forwardslash.chevron.right",
            humanGate: "High-impact release / destructive action",
            officialRoute: "GitHub connector",
            priority: "P0"
        ),
        .init(
            id: "inpi-rne",
            provider: "INPI · RNE / Entreprises",
            family: "Institutional / Legal",
            authorityClass: "C1/C6",
            status: .authRequired,
            detail: "RNE, creations/modifications/cessations, accounts and corporate acts.",
            systemImage: "building.columns.fill",
            humanGate: "Any filing, legal modification or fee",
            officialRoute: "Data INPI official API / SFTP",
            priority: "P0"
        ),
        .init(
            id: "inpi-ip",
            provider: "INPI · Propriété industrielle",
            family: "Institutional / IP",
            authorityClass: "C1/C6",
            status: .authRequired,
            detail: "Trademarks, patents, designs/models, notices and watchlists.",
            systemImage: "seal.fill",
            humanGate: "Any trademark/patent/design filing",
            officialRoute: "Data INPI official PI APIs",
            priority: "P0"
        ),
        .init(
            id: "x",
            provider: "X",
            family: "Public Presence",
            authorityClass: "C1/C3",
            status: .authRequired,
            detail: "Official X API v2 read connector prepared; write stays gated.",
            systemImage: "bubble.left.and.text.bubble.right.fill",
            humanGate: "Publish/reply by default",
            officialRoute: "X API v2",
            priority: "P1"
        ),
        .init(
            id: "linkedin",
            provider: "LinkedIn",
            family: "Public Presence",
            authorityClass: "C1/C3",
            status: .connected,
            detail: "LinkedIn organic company data is connected through the existing provider path; publishing and material comments remain gated.",
            systemImage: "person.text.rectangle.fill",
            humanGate: "Publish/comment by default",
            officialRoute: "LinkedIn official API / approved provider",
            priority: "P1"
        ),
        .init(
            id: "instagram",
            provider: "Instagram / Meta",
            family: "Public Presence",
            authorityClass: "C1/C3",
            status: .authRequired,
            detail: "Professional media, comments, audience signals and business publishing.",
            systemImage: "camera.fill",
            humanGate: "Publish/reply by default",
            officialRoute: "Meta / Instagram Business APIs",
            priority: "P1"
        ),
        .init(
            id: "whatsapp",
            provider: "WhatsApp Business",
            family: "Communications",
            authorityClass: "C1/C3",
            status: .authRequired,
            detail: "Business messaging, templates, delivery/read events and media.",
            systemImage: "message.fill",
            humanGate: "Sensitive/binding/first-contact messages",
            officialRoute: "WhatsApp Business Platform",
            priority: "P1"
        ),
        .init(
            id: "youtube",
            provider: "YouTube",
            family: "Public Presence",
            authorityClass: "C1/C3",
            status: .authRequired,
            detail: "Channels, videos, playlists, comments and publishing workflows.",
            systemImage: "play.rectangle.fill",
            humanGate: "Publish/delete",
            officialRoute: "YouTube Data API v3",
            priority: "P1"
        ),
        .init(
            id: "gbp",
            provider: "Google Business Profile",
            family: "Public Presence",
            authorityClass: "C1/C3",
            status: .approvalRequired,
            detail: "Locations, reviews, posts, business information and engagement.",
            systemImage: "mappin.and.ellipse",
            humanGate: "Public write / listing changes",
            officialRoute: "Google Business Profile APIs",
            priority: "P1"
        ),
        .init(
            id: "stripe",
            provider: "Stripe",
            family: "Finance / Payments",
            authorityClass: "C1/C4/C5",
            status: .authRequired,
            detail: "DEFERRED HUMAN AUTH — provider route is ready, but Stripe authentication is intentionally parked so it cannot block the current SUPRA mission. Resume later with least-privilege read access; money movement stays human-gated.",
            systemImage: "creditcard.fill",
            humanGate: "Deferred auth; charge/refund/payout/money movement always gated",
            officialRoute: "Stripe API / Windsor.ai",
            priority: "P2"
        ),
        .init(
            id: "bank",
            provider: "Bank / Open Banking",
            family: "Finance",
            authorityClass: "C1/C4/C5",
            status: .providerRequired,
            detail: "Accounts, balances and transactions read-first; execution separately gated.",
            systemImage: "banknote.fill",
            humanGate: "All money movement",
            officialRoute: "Bank API or regulated PSD2 provider",
            priority: "P1"
        ),
        .init(
            id: "docusign",
            provider: "Docusign",
            family: "Legal / Agreements",
            authorityClass: "C1/C2/C6",
            status: .available,
            detail: "Agreement metadata, envelopes, templates and signature workflows.",
            systemImage: "signature",
            humanGate: "Send/sign/binding agreement",
            officialRoute: "Docusign connector / eSignature API",
            priority: "P1"
        ),
        .init(
            id: "crm",
            provider: "CRM · HubSpot / Close",
            family: "Commercial",
            authorityClass: "C1/C2/C3",
            status: .authRequired,
            detail: "HubSpot and Close connector routes are available, but no CRM account is authenticated yet.",
            systemImage: "person.3.sequence.fill",
            humanGate: "External communication / material record change policy",
            officialRoute: "Provider connector",
            priority: "P1"
        ),
        .init(
            id: "dgfip",
            provider: "DGFiP / impôts",
            family: "Administration / Tax",
            authorityClass: "C1/C6",
            status: .approvalRequired,
            detail: "Official API access is habilitation/DataPass based for eligible use cases.",
            systemImage: "eurosign.bank.building",
            humanGate: "Submission/payment/legal declaration",
            officialRoute: "DGFiP official APIs / approved portal workflow",
            priority: "P0"
        ),
        .init(
            id: "urssaf",
            provider: "URSSAF",
            family: "Administration / Social",
            authorityClass: "C0/C1/C6",
            status: .approvalRequired,
            detail: "Public simulation remains available; certified URSSAF data and attestations require eligible API Entreprise access. Declarations and payments stay gated.",
            systemImage: "person.crop.rectangle.stack.fill",
            humanGate: "Declaration/payment/private-account action",
            officialRoute: "URSSAF / API Entreprise official interfaces",
            priority: "P0"
        ),
        .init(
            id: "windsor",
            provider: "Windsor.ai",
            family: "Partner Fabric",
            authorityClass: "C1/C2/C3",
            status: .connected,
            detail: "Provider fabric is authenticated. LinkedIn organic is live; other provider accounts remain independently gated.",
            systemImage: "link.circle.fill",
            humanGate: "Provider write actions follow each connector policy",
            officialRoute: "Windsor.ai connector",
            priority: "P1"
        ),
        .init(
            id: "figma",
            provider: "Figma",
            family: "Design / Product",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Authenticated design workspace observed. Design reads and supported design workflows are available.",
            systemImage: "square.3.layers.3d",
            humanGate: "Material shared-design writes",
            officialRoute: "Figma connector",
            priority: "P1"
        ),
        .init(
            id: "canva",
            provider: "Canva",
            family: "Design / Media",
            authorityClass: "C1/C2/C3",
            status: .connected,
            detail: "Authenticated Canva workspace and existing designs observed.",
            systemImage: "paintpalette.fill",
            humanGate: "External publication / material shared-design changes",
            officialRoute: "Canva connector",
            priority: "P1"
        ),
        .init(
            id: "notion",
            provider: "Notion",
            family: "Knowledge / Operations",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Authenticated workspace search and page reads are operational.",
            systemImage: "doc.text.fill",
            humanGate: "Material workspace writes follow mission authority",
            officialRoute: "Notion connector",
            priority: "P1"
        ),
        .init(
            id: "linear",
            provider: "Linear",
            family: "Product / Operations",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Authenticated workspace search is operational.",
            systemImage: "checklist",
            humanGate: "Material issue/project mutations follow mission authority",
            officialRoute: "Linear connector",
            priority: "P1"
        ),
        .init(
            id: "posthog",
            provider: "PostHog",
            family: "Analytics / Product",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "A live project is accessible. Core project tools respond; some advanced scopes are not granted.",
            systemImage: "chart.line.uptrend.xyaxis",
            humanGate: "Production flags/experiments and destructive writes",
            officialRoute: "PostHog connector",
            priority: "P1"
        ),
        .init(
            id: "supabase",
            provider: "Supabase",
            family: "Data / Backend",
            authorityClass: "C1/C2",
            status: .available,
            detail: "Authenticated organization is visible, but no Supabase project is currently accessible to operate on.",
            systemImage: "cylinder.fill",
            humanGate: "Schema/auth/production mutations follow change policy",
            officialRoute: "Supabase connector",
            priority: "P1"
        ),
        .init(
            id: "apollo",
            provider: "Apollo.io",
            family: "Commercial Intelligence",
            authorityClass: "C1/C2/C3",
            status: .connected,
            detail: "Authenticated Apollo workspace profile is readable.",
            systemImage: "scope",
            humanGate: "Outbound sends and material CRM mutations",
            officialRoute: "Apollo.io connector",
            priority: "P1"
        ),
        .init(
            id: "atlassian",
            provider: "Atlassian Rovo",
            family: "Engineering / Knowledge",
            authorityClass: "C1/C2",
            status: .connected,
            detail: "Authenticated Atlassian account and an accessible Jira resource are observed.",
            systemImage: "shippingbox.fill",
            humanGate: "Issue/page writes follow mission authority",
            officialRoute: "Atlassian Rovo connector",
            priority: "P1"
        ),
        .init(
            id: "tamarind",
            provider: "Tamarind Bio",
            family: "Life Sciences",
            authorityClass: "C1/C2",
            status: .authRequired,
            detail: "Tool route is present, but the current credential is rejected and must be re-authenticated.",
            systemImage: "atom",
            humanGate: "Paid compute submission and publication",
            officialRoute: "Tamarind Bio connector",
            priority: "P2"
        ),
        .init(
            id: "adaptyv",
            provider: "Adaptyv Bio",
            family: "Life Sciences",
            authorityClass: "C1/C2",
            status: .providerRequired,
            detail: "No live Adaptyv tool route is available in this session; do not present it as connected.",
            systemImage: "testtube.2",
            humanGate: "Experiment submission / spend",
            officialRoute: "Adaptyv Bio eligible connector",
            priority: "P2"
        )
    ]
}


enum ExternalConnectorRuntimeReadiness {
    static var xReadCredentialConfigured: Bool {
        ConnectorCredentialVault.readString(
            service: XOfficialConnector.keychainService,
            account: XOfficialConnector.bearerTokenAccount
        ) != nil || !(ProcessInfo.processInfo.environment["SUPRA_X_BEARER_TOKEN"] ?? "").isEmpty
    }

    static var inpiRuntimeConfigured: Bool {
        INPIOfficialConnectorConfiguration.fromRuntime() != nil
    }
}
