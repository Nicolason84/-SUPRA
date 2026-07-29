import SwiftUI

struct G4IntegrationView: View {
    @StateObject private var service = G4IntegrationService()

    var body: some View {
        SUPRAOSCard(
            title: "Integrations",
            subtitle: snapshot.overallHealth,
            icon: "point.3.connected.trianglepath.dotted",
            color: snapshot.allConnected ? .supraGreen : .supraOrange
        ) {
            VStack(spacing: 8) {
                ForEach(snapshot.services) { svc in
                    HStack(spacing: 8) {
                        Image(systemName: svc.type.icon)
                            .font(.system(size: 10))
                            .foregroundColor(svc.connectionStatus.color)
                            .frame(width: 16)
                        Text(svc.type.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.supraText)
                            .frame(width: 60, alignment: .leading)
                        Text(svc.statusText)
                            .font(.system(size: 10))
                            .foregroundColor(.supraTextSecondary)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: svc.connectionStatus.icon)
                            .font(.system(size: 8))
                            .foregroundColor(svc.connectionStatus.color)
                    }
                    if svc.id != snapshot.services.last?.id {
                        Divider().background(Color.supraBorder)
                    }
                }
            }
        }
    }

    private var snapshot: IntegrationDashboardSnapshot {
        service.snapshot ?? IntegrationDashboardSnapshot(
            services: [],
            lastUpdated: Date()
        )
    }
}
