import SwiftUI

struct ExecutiveWorkflowListView: View {
    @StateObject private var registry = ExecutiveWorkflowRegistry.shared
    @State private var selectedWorkflowID: String?
    @State private var expandedReport: UUID?
    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                    header
                    if showHistory {
                        executionHistorySection
                    } else {
                        workflowCards
                    }
                    if let report = registry.lastReport {
                        reportSection(report)
                    }
                }
                .padding(SUPRAOSDesignSystem.padding)
                .frame(maxWidth: 1280, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Color.supraBackground)
            .toolbar {
                ToolbarItemGroup {
                    Button(showHistory ? "Workflows" : "History") {
                        withAnimation { showHistory.toggle() }
                    }
                    .foregroundColor(.supraAccent)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.supraAccent)
                VStack(alignment: .leading, spacing: 1) {
                    Text("EXECUTIVE WORKFLOWS")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundColor(.supraAccent)
                    Text(showHistory ? "Historique des exécutions" : "\(registry.workflows.filter { $0.status == .ready }.count)/\(registry.workflows.count) workflows disponibles")
                        .font(.system(size: 12))
                        .foregroundColor(.supraTextSecondary)
                }
                Spacer()
                if registry.isExecuting {
                    HStack(spacing: 6) {
                        ProgressView().scaleEffect(0.7)
                        Text("Exécution…")
                            .font(.system(size: 10))
                            .foregroundColor(.supraAccent)
                    }
                }
            }
        }
    }

    private var workflowCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(registry.workflows) { workflow in
                workflowCard(workflow)
            }
        }
    }

    private func workflowCard(_ workflow: ExecutiveWorkflow) -> some View {
        let isSelected = selectedWorkflowID == workflow.id
        let statusColor: Color = switch workflow.status {
        case .ready: .supraGreen
        case .partial: .supraOrange
        case .blocked: .supraRed
        }
        let lastExecution = registry.executionHistory.last(where: { $0.workflowID == workflow.id })

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(workflow.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.supraText)
                        SUPRAOSBadge(text: workflow.status.rawValue, color: statusColor)
                    }
                    Text(workflow.description)
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(2)
                }
                Spacer()

                if !registry.isExecuting && workflow.status == .ready {
                    SUPRAOSButton(title: "Lancer", icon: "play.fill", color: .supraGreen) {
                        selectedWorkflowID = workflow.id
                        Task {
                            let _ = await registry.executeWorkflow(id: workflow.id)
                        }
                    }
                }
            }

            if isSelected && registry.isExecuting {
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7)
                    Text("Exécution du workflow…")
                        .font(.system(size: 10))
                        .foregroundColor(.supraAccent)
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Entrées")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.supraTextTertiary)
                    Text(workflow.inputs.joined(separator: ", "))
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sorties")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.supraTextTertiary)
                    Text(workflow.outputs.joined(separator: ", "))
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Artefacts")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.supraTextTertiary)
                    Text(workflow.artifacts.joined(separator: ", "))
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(1)
                }
            }

            if let last = lastExecution {
                Divider().background(Color.supraBorder)
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.supraTextTertiary)
                    Text("Dernière exécution: \(last.startDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextTertiary)
                    Text("• \(Int(last.duration * 1000))ms")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextTertiary)
                    Text("• \(Int(last.confidence * 100))% confiance")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(last.confidence > 0.7 ? .supraGreen : .supraOrange)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(isSelected ? Color.supraAccent.opacity(0.3) : Color.supraBorder, lineWidth: 1))
    }

    private var executionHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("HISTORIQUE DES EXÉCUTIONS (\(registry.executionHistory.count))")

            if registry.executionHistory.isEmpty {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.supraTextTertiary)
                    Text("Aucune exécution — lancez un workflow")
                        .font(.system(size: 11))
                        .foregroundColor(.supraTextTertiary)
                    Spacer()
                }
                .padding(12)
                .background(Color.supraGlass)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 0) {
                    historyTableHeader
                    Divider().background(Color.supraBorder)
                    ForEach(Array(registry.executionHistory.reversed())) { record in
                        historyRow(record)
                        if record.id != registry.executionHistory.last?.id {
                            Divider().background(Color.supraBorder.opacity(0.5))
                        }
                    }
                }
                .background(Color.supraSurfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
            }
        }
    }

    private var historyTableHeader: some View {
        HStack(spacing: 0) {
            Text("Date").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 70, alignment: .leading)
            Text("Workflow").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 140, alignment: .leading)
            Text("Durée").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 50, alignment: .trailing)
            Text("Confiance").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 60, alignment: .trailing)
            Text("Résultat").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(maxWidth: .infinity, alignment: .leading)
            Text("Décision").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraTextTertiary).frame(width: 100, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private func historyRow(_ record: WorkflowExecutionRecord) -> some View {
        let isExpanded = expandedReport == record.id
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation { expandedReport = isExpanded ? nil : record.id }
            }) {
                HStack(spacing: 0) {
                    Text(record.startDate.formatted(date: .numeric, time: .shortened))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextSecondary)
                        .frame(width: 70, alignment: .leading)
                    Text(record.workflowName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.supraText)
                        .frame(width: 140, alignment: .leading)
                    Text("\(Int(record.duration * 1000))ms")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.supraTextTertiary)
                        .frame(width: 50, alignment: .trailing)
                    Text("\(Int(record.confidence * 100))%")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(record.confidence > 0.7 ? .supraGreen : .supraOrange)
                        .frame(width: 60, alignment: .trailing)
                    Text(record.result.prefix(60))
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(record.decision.prefix(40))
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextTertiary)
                        .lineLimit(1)
                        .frame(width: 100, alignment: .leading)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 7))
                        .foregroundColor(.supraTextTertiary)
                        .frame(width: 10)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Artefacts: \(record.artifacts.joined(separator: ", "))")
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                    if let path = record.reportPath {
                        Text("Rapport: \(path)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.supraTextTertiary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .padding(.leading, 16)
                .background(Color.supraGlass)
                .transition(.opacity)
            }
        }
    }

    private func reportSection(_ report: ExecutiveReport) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("DERNIER RAPPORT — \(report.reportID)")

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.supraAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.workflowName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.supraText)
                        Text(report.date.formatted(date: .long, time: .standard))
                            .font(.system(size: 10))
                            .foregroundColor(.supraTextSecondary)
                    }
                    Spacer()
                    SUPRAOSBadge(text: "Φ \(Int(report.confidence * 100))%", color: report.confidence > 0.7 ? .supraGreen : .supraOrange)
                }

                Divider().background(Color.supraBorder)

                reportField("Executive Summary", report.summary)
                reportField("Contexte", report.context)
                reportField("Analyse", report.analysis)

                if !report.evidence.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Preuves")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraTextTertiary)
                        ForEach(report.evidence, id: \.self) { item in
                            HStack(spacing: 6) {
                                Circle().fill(Color.supraGreen).frame(width: 4, height: 4)
                                Text(item)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.supraTextSecondary)
                            }
                        }
                    }
                }

                if !report.risks.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Risques")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraRed)
                        ForEach(report.risks, id: \.self) { risk in
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.supraRed)
                                Text(risk)
                                    .font(.system(size: 10))
                                    .foregroundColor(.supraTextSecondary)
                            }
                        }
                    }
                }

                if !report.opportunities.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Opportunités")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraGreen)
                        ForEach(report.opportunities, id: \.self) { opp in
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 8))
                                    .foregroundColor(.supraGreen)
                                Text(opp)
                                    .font(.system(size: 10))
                                    .foregroundColor(.supraTextSecondary)
                            }
                        }
                    }
                }

                reportField("Décision", report.decision)

                if !report.recommendedActions.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Actions recommandées")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.supraAccent)
                        ForEach(Array(report.recommendedActions.enumerated()), id: \.offset) { idx, action in
                            HStack(spacing: 6) {
                                Text("\(idx + 1).")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.supraAccent)
                                Text(action)
                                    .font(.system(size: 10))
                                    .foregroundColor(.supraTextSecondary)
                            }
                        }
                    }
                }

                if !report.artifacts.isEmpty {
                    Divider().background(Color.supraBorder)
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.supraTextTertiary)
                        Text("Artefacts: \(report.artifacts.joined(separator: ", "))")
                            .font(.system(size: 9))
                            .foregroundColor(.supraTextTertiary)
                    }
                }
            }
            .padding(SUPRAOSDesignSystem.paddingSmall)
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
            .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
        }
    }

    private func reportField(_ label: String, _ value: String) -> some View {
        guard !value.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.supraTextTertiary)
                Text(value)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.supraTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.supraTextTertiary)
            .tracking(1)
    }
}
