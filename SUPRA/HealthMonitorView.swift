import SwiftUI

struct HealthMonitorView: View {
    @StateObject private var detector = HealthAnomalyDetector()
    @EnvironmentObject var state: SUPRACommandCenterState

    var body: some View {
        VStack(spacing: 0) {
            if !detector.alerts.isEmpty {
                alertHeader
                alertBanners
            }
        }
        .onAppear { monitorHealth() }
        .onChange(of: state.isReady) { _, ready in
            if ready { monitorHealth() }
        }
    }

    private var alertHeader: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundColor(.supraAccent)
            Text("Health Alerts")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.supraTextSecondary)
            Spacer()
            Text("\(detector.alerts.filter { !$0.acknowledged }.count) active")
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
            Button("Dismiss All") {
                detector.acknowledgeAll()
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.supraAccent)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.supraSurfaceLight.opacity(0.5))
    }

    private var alertBanners: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(detector.alerts.prefix(5)) { alert in
                    alertBanner(alert)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func alertBanner(_ alert: AlertModel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: alert.severity.icon)
                .foregroundColor(
                    alert.severity == .critical ? .red
                    : alert.severity == .warning ? .orange
                    : .blue
                )
                .font(.system(size: 14, weight: .bold))

            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.supraText)
                    .lineLimit(1)
                Text(alert.message)
                    .font(.system(size: 10))
                    .foregroundColor(.supraTextSecondary)
                    .lineLimit(2)
            }

            if !alert.acknowledged {
                Button("Dismiss") {
                    detector.acknowledge(alert.id)
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.supraTextSecondary)
                .buttonStyle(.plain)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.supraGreen)
                    .font(.system(size: 10))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            alert.severity == .critical
                ? Color.red.opacity(0.08)
                : alert.severity == .warning
                    ? Color.orange.opacity(0.08)
                    : Color.blue.opacity(0.06)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: 320)
    }

    private func monitorHealth() {
        _ = detector.analyze(RuntimeHealth.initial)
    }
}
