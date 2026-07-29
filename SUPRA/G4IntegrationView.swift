import SwiftUI

struct G4IntegrationView: View {
    @StateObject private var service = G4IntegrationService()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                overallHealthSection
                servicesSection
                footerSection
            }
            .padding(20)
        }
        .background(Color.supraBackground)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Integration Dashboard")
                    .font(.title2.bold())
                    .foregroundColor(.supraText)
                Text("System-wide service health")
                    .font(.caption)
                    .foregroundColor(.supraTextSecondary)
            }
            Spacer()
            Circle()
                .fill(snapshot.allConnected ? Color.supraGreen : Color.supraRed)
                .frame(width: 12, height: 12)
        }
    }

    // MARK: - Overall Health

    private var overallHealthSection: some View {
        HStack(spacing: 16) {
            HealthPill(
                icon: "heart.fill",
                label: "Health",
                value: snapshot.overallHealth,
                color: snapshot.allConnected ? .supraGreen : .supraOrange
            )
            HealthPill(
                icon: "clock",
                label: "Updated",
                value: timeAgo(snapshot.lastUpdated),
                color: .supraTextSecondary
            )
            Spacer()
        }
    }

    // MARK: - Services Grid

    private var servicesSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260))], spacing: 12) {
            ForEach(snapshot.services) { service in
                ServiceCard(status: service)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Text("Auto-refreshing")
                .font(.caption2)
                .foregroundColor(.supraTextTertiary)
            Spacer()
        }
    }

    // MARK: - Helpers

    private var snapshot: IntegrationDashboardSnapshot {
        service.snapshot ?? IntegrationDashboardSnapshot(
            services: [],
            lastUpdated: Date()
        )
    }

    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "\(Int(interval))s ago" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        return "\(Int(interval / 3600))h ago"
    }
}

// MARK: - HealthPill

private struct HealthPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.supraTextTertiary)
                Text(value)
                    .font(.caption.bold())
                    .foregroundColor(.supraText)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.supraSurface)
        .cornerRadius(8)
    }
}

// MARK: - ServiceCard

private struct ServiceCard: View {
    let status: IntegrationServiceStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: status.type.icon)
                    .foregroundColor(.supraAccent)
                    .font(.title3)
                Spacer()
                Image(systemName: status.connectionStatus.icon)
                    .foregroundColor(status.connectionStatus.color)
                    .font(.caption)
            }
            Text(status.type.title)
                .font(.subheadline.bold())
                .foregroundColor(.supraText)
            Text(status.statusText)
                .font(.caption)
                .foregroundColor(.supraTextSecondary)
            if let detail = status.detailText {
                Text(detail)
                    .font(.caption2)
                    .foregroundColor(.supraTextTertiary)
            }
        }
        .padding(12)
        .background(Color.supraSurface)
        .cornerRadius(10)
    }
}
