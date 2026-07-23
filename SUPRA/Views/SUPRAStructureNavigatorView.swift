import SwiftUI
import CAnnoNicoContracts

extension ContentView {
    // SUPRA_MULTI_STRUCTURE_CLOSED_CIRCUIT_V1_BEGIN
    var structureNavigator: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Label(structureMode.rawValue, systemImage: structureMode.symbol).font(.title2.bold())
                Text(structureMode.subtitle).font(.callout).foregroundStyle(.secondary)
            }
            Picker("Human journey", selection: $humanStage) {
                ForEach(SUPRAHumanStage.allCases) { stage in
                    Label(stage.rawValue, systemImage: stage.symbol).tag(stage)
                }
            }
            .pickerStyle(.radioGroup)
            Divider()
            structureContext
            Spacer()
            Label("SUPRA agit · Nicolas décide", systemImage: "bolt.shield.fill")
                .font(.caption.weight(.bold))
        }
        .padding(20)
        .background(.thinMaterial)
    }

    @ViewBuilder
    private var structureContext: some View {
        switch structureMode {
        case .hydrogen:
            structureSummary("Intention", value: humanIntent)
            structureSummary("Prochaine action", value: humanNextAction)
        case .atomium:
            structureMetric("Modules liés", value: cannonicoIntegrationSnapshot.references.count)
            structureMetric("Gabriel workers", value: gabrielSnapshot.workers.count)
            structureMetric("Décisions", value: operationalDecisionCandidates.count)
        case .arbo:
            structureMetric("Projects", value: store.model.projects.count)
            structureMetric("Capabilities", value: store.model.capabilities.count)
            structureMetric("Products", value: store.model.products.count)
        case .orbital:
            structureMetric("Mission slots", value: gabrielSnapshot.missionSlots)
            structureMetric("Workers", value: gabrielSnapshot.workerProcesses)
            structureMetric("Recovered modules", value: cannonicoRecoveredReferences.count)
        }
    }

    private func structureSummary(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(value).font(.callout).foregroundStyle(.secondary)
        }
    }

    private func structureMetric(_ title: String, value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value.formatted()).font(.caption.monospacedDigit().weight(.semibold)).foregroundStyle(.secondary)
        }
    }

    var humanIntent: String {
        switch humanStage {
        case .observe: return "Voir ce qui change réellement."
        case .understand: return "Relier les preuves et comprendre."
        case .decide: return "Présenter une décision importante et explicable."
        case .act: return "Exécuter le sûr et le réversible."
        case .learn: return "Mémoriser et améliorer le prochain cycle."
        }
    }

    var humanNextAction: String {
        if gabrielBusy { return "Gabriel conduit trois missions en parallèle." }
        if store.chatBusy { return "SUPRA analyse les preuves." }
        if !operationalDecisionCandidates.isEmpty { return "Examiner la première décision prioritaire." }
        return "Laisser SUPRA poursuivre l’autopilot."
    }
    // SUPRA_MULTI_STRUCTURE_CLOSED_CIRCUIT_V1_END
}
