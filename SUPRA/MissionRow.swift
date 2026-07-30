import SwiftUI

struct MissionRow: View {
    let mission: Mission

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(mission.title)
                    .font(.headline)
                    .lineLimit(2)
                Spacer(minLength: 8)
                Text(mission.status.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            HStack(spacing: 8) {
                Label(mission.priority.rawValue, systemImage: "flag.fill")
                Text(mission.lifecycle.rawValue)
                Spacer()
                Label(mission.authority.rawValue, systemImage: "person.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(mission.currentStep)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 10) {
                Label(mission.health.rawValue, systemImage: "heart.text.square")
                Spacer()
                ProgressView(value: mission.progress)
                    .frame(maxWidth: 100)
                Text(mission.progress, format: .percent.precision(.fractionLength(0)))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
