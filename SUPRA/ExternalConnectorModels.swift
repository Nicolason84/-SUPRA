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
            status: .authRequired,
            detail: "Founder/company identity, company posts, analytics and prospect signals.",
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
            status: .available,
            detail: "Payments, invoices, customers, refunds, payouts and webhook events.",
            systemImage: "creditcard.fill",
            humanGate: "Charge/refund/payout/money movement",
            officialRoute: "Stripe API / existing aggregator where useful",
            priority: "P1"
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
            status: .available,
            detail: "Contacts, companies, deals, activities, follow-up and sales evidence.",
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
            status: .available,
            detail: "Open Mon-entreprise simulation API now; private-account actions remain gated.",
            systemImage: "person.crop.rectangle.stack.fill",
            humanGate: "Declaration/payment/private-account action",
            officialRoute: "URSSAF official interfaces",
            priority: "P0"
        )
    ]
}
