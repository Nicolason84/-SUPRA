import SwiftUI

// MARK: - ExportSection

struct ExportSection: View {
    @State private var showExportSheet = false

    var body: some View {
        Button {
            showExportSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.supraAccent)
                    .frame(width: 32, height: 32)
                    .background(Color.supraAccent.opacity(0.15), in: RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusTiny))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Export Dashboard")
                        .font(SUPRAOSDesignSystem.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.supraText)
                    Text("CSV, JSON, Markdown")
                        .font(SUPRAOSDesignSystem.Fonts.bodySmall)
                        .foregroundColor(.supraTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.supraTextTertiary)
            }
            .padding(SUPRAOSDesignSystem.paddingSmall)
            .supraCardStyle()
            .contentShape(Rectangle())
            .cardHoverEffect()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showExportSheet) {
            ExportView()
                .environmentObject(SUPRACommandCenterState.shared)
                .frame(minWidth: 320, minHeight: 400)
                .padding()
                .background(Color.supraBackground)
        }
    }
}
