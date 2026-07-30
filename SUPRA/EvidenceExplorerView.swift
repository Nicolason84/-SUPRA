import SwiftUI

struct EvidenceExplorerView: View {
    @State private var selectedFile: String?
    @State private var fileContents: String?
    @State private var isLoading = false

    private let evidenceFiles = [
        "runtime_trace.json", "delegation_trace.json", "runtime_metrics.json",
        "agent_execution.json", "consensus_report.json", "execution_graph.json",
        "provider_metrics.json", "mission_graph_metrics.json", "dashboard_snapshot.json"
    ]

    var body: some View {
        HSplitView {
            fileList
            contentView
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var fileList: some View {
        List(evidenceFiles, id: \.self, selection: $selectedFile) { file in
            Label(file, systemImage: iconFor(file))
                .tag(file)
                .onTapGesture { loadFile(file) }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200, idealWidth: 250)
        .navigationTitle("Evidence Explorer")
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            ProgressView("Loading…").frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let contents = fileContents, let file = selectedFile {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(file).font(.headline)
                    Spacer()
                    Button("Copy") { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(contents, forType: .string) }
                }
                .padding(.horizontal).padding(.top)
                ScrollView {
                    Text(contents)
                        .font(.body.monospaced())
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ContentUnavailableView("Select a file", systemImage: "doc.text.magnifyingglass",
                                   description: Text("Choose an evidence file from the sidebar."))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func loadFile(_ filename: String) {
        isLoading = true
        selectedFile = filename
        let base = UserDefaults.standard.string(forKey: "runtimePath") ?? FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: base).appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url), let text = String(data: data, encoding: .utf8) {
            fileContents = text
        } else {
            fileContents = "// File not found: \(filename)"
        }
        isLoading = false
    }

    private func iconFor(_ file: String) -> String {
        if file.contains("trace") { return "point.connected" }
        if file.contains("metric") { return "chart.bar" }
        if file.contains("report") { return "doc.text" }
        if file.contains("graph") { return "arrow.triangle.branch" }
        if file.contains("dashboard") { return "gauge.with.dots.needle.33percent" }
        if file.contains("consensus") { return "person.3" }
        return "doc"
    }
}
