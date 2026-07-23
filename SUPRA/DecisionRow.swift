import SwiftUI

struct DecisionRow: View {
    let decision: Decision

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(decision.title)
                    .font(.headline)
                    .lineLimit(2)
                Spacer(minLength: 8)
                Text(decision.status.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            HStack(spacing: 8) {
                Label(decision.priority.rawValue, systemImage: "flag.fill")
                Text(decision.category)
                Spacer()
                Text(decision.date, format: .dateTime.day().month(.abbreviated).year())
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(decision.humanGate.rawValue, systemImage: "person.badge.shield.checkmark")
                Spacer()
                Label(confidenceText, systemImage: "gauge.with.dots.needle.33percent")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var confidenceText: String {
        guard let confidence = decision.confidence else { return "Not available" }
        return confidence.formatted(.percent.precision(.fractionLength(0)))
    }
}
