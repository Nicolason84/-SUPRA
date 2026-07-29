import SwiftUI

// MARK: - ExportView

struct ExportView: View {
    @EnvironmentObject private var state: SUPRACommandCenterState
    @StateObject private var service = ExportService()
    @State private var configuration = ExportConfiguration()
    @State private var showSuccess = false
    @State private var showFailure = false

    var body: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            header
            Divider().background(Color.supraBorder)
            formatPicker
            scopePicker
            optionsSection
            Divider().background(Color.supraBorder)
            exportButton
            statusSection
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .alert("Export Complete", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Dashboard data exported successfully.")
        }
        .alert("Export Failed", isPresented: $showFailure) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to export dashboard data. Please try again.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.supraAccent)
            Text("Export Dashboard")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.supraText)
        }
    }

    // MARK: - Format Picker

    private var formatPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Format")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.supraTextSecondary)
            HStack(spacing: 8) {
                ForEach(ExportFormat.allCases) { format in
                    formatChip(format)
                }
            }
        }
    }

    private func formatChip(_ format: ExportFormat) -> some View {
        Button {
            withAnimation(SUPRAOSDesignSystem.Motion.feedback) {
                configuration.format = format
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: format == .csv ? "tablecells" : format == .json ? "curlybraces" : "doc.text")
                    .font(.system(size: 10))
                Text(format.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(configuration.format == format ? Color.supraAccent.opacity(0.2) : Color.supraSurface)
            .foregroundColor(configuration.format == format ? .supraAccent : .supraTextSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(configuration.format == format ? Color.supraAccent.opacity(0.4) : Color.supraBorder)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Scope Picker

    private var scopePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Scope")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.supraTextSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(ExportScope.allCases) { scope in
                        scopeChip(scope)
                    }
                }
            }
        }
    }

    private func scopeChip(_ scope: ExportScope) -> some View {
        Button {
            withAnimation(SUPRAOSDesignSystem.Motion.feedback) {
                configuration.scope = scope
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: scope.icon)
                    .font(.system(size: 9))
                Text(scope.title)
                    .font(.system(size: 9, weight: .medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(configuration.scope == scope ? Color.supraAccent.opacity(0.2) : Color.supraSurface)
            .foregroundColor(configuration.scope == scope ? .supraAccent : .supraTextSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(configuration.scope == scope ? Color.supraAccent.opacity(0.4) : Color.supraBorder)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Options Section

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Options")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.supraTextSecondary)
            toggleRow("Include Timestamps", isOn: $configuration.options.includeTimestamps)
            toggleRow("Include Details", isOn: $configuration.options.includeDetails)
            toggleRow("Compact Format", isOn: $configuration.options.compactFormat)
        }
    }

    private func toggleRow(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.supraText)
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
        }
    }

    // MARK: - Export Button

    private var exportButton: some View {
        Button {
            Task {
                let success = await service.export(configuration: configuration)
                if success {
                    showSuccess = true
                } else {
                    showFailure = true
                }
            }
        } label: {
            HStack(spacing: 6) {
                if service.isExporting {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(service.isExporting ? "Exporting..." : "Export")
                    .font(.system(size: 11, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(service.isExporting ? Color.supraAccent.opacity(0.5) : Color.supraAccent)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .disabled(service.isExporting)
    }

    // MARK: - Status Section

    private var statusSection: some View {
        Group {
            if let date = service.lastExportDate {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.supraGreen)
                    Text("Last export: \(date.formatted(date: .omitted, time: .shortened))")
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                }
            }
        }
    }
}
