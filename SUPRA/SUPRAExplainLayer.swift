import SwiftUI

struct ExplainContext {
    let title: String
    let why: String
    let evidence: String
    let impact: String
    let risk: String
    let rollback: String
    let confidence: Double
    let source: String
}

struct SUPRAExplainLayer: ViewModifier {
    let context: ExplainContext
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .popover(isPresented: $isPresented) {
                explainContent
                    .frame(width: 320).frame(minHeight: 400)
                    .background(Color.supraBackground)
            }
    }

    private var explainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.supraAccent)
                    Text("EXPLICATION").font(.caption.weight(.bold)).tracking(2).foregroundColor(.supraAccent)
                    Spacer()
                    SUPRAOSBadge(text: "Φ \(Int(context.confidence * 100))%", color: .supraAccent)
                }
                .padding(.bottom, 4)

                Divider().background(Color.supraBorder)

                explainRow("POURQUOI ?", context.why, .supraText)
                explainRow("PREUVE", context.evidence, .supraAccent)
                explainRow("IMPACT", context.impact, .supraOrange)
                explainRow("RISQUE", context.risk, .supraRed)
                explainRow("ROLLBACK", context.rollback, .supraGreen)
                explainRow("SOURCE", context.source, .supraTextTertiary)
                explainRow("CONFIANCE", "\(Int(context.confidence * 100))%", .supraAccent)
            }
            .padding(SUPRAOSDesignSystem.padding)
        }
    }

    private func explainRow(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(color).tracking(1)
            Text(value).font(.system(size: 11)).foregroundColor(.supraTextSecondary)
        }
    }
}

extension View {
    func explainLayer(context: ExplainContext, isPresented: Binding<Bool>) -> some View {
        modifier(SUPRAExplainLayer(context: context, isPresented: isPresented))
    }
}

struct SUPRAExplainButton: View {
    let context: ExplainContext
    @State private var showExplain = false

    var body: some View {
        Button {
            showExplain.toggle()
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "questionmark.circle.fill").font(.system(size: 10))
                Text("Expliquer").font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(.supraAccent)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Color.supraAccent.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .explainLayer(context: context, isPresented: $showExplain)
    }
}
