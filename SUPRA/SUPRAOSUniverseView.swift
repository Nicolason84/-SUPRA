import SwiftUI

struct SUPRAOSUniverseView: View {
    @EnvironmentObject var universe: TwinUniverse
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            header
            graphCanvas
        }
        .background(Color.supraBackground)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Univers")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.supraText)
                Text("\(universe.state?.objectCount ?? 0) objets · \(universe.state?.twinCount ?? 0) twins")
                    .font(.system(size: 13))
                    .foregroundColor(.supraTextSecondary)
            }
            Spacer()
            HStack(spacing: 8) {
                filterButton("Tout", active: true)
                filterButton("Objets", active: false)
                filterButton("Twins", active: false)
            }
        }
        .padding(SUPRAOSDesignSystem.padding)
    }

    private var graphCanvas: some View {
        GeometryReader { geometry in
            let clusters: [(String, String, Color, CGFloat)] = [
                ("workspace", "cube", .supraAccent, 0),
                ("git", "arrow.triangle.branch", .supraOrange, 1),
                ("report", "doc.text", .supraGreen, 2),
                ("decision", "checkmark.shield", .supraRed, 3),
                ("freeze", "snowflake", .supraTeal, 4),
                ("artifact", "gearshape", .supraPurple, 5),
            ]
            ZStack {
                gridLines(size: geometry.size)
                connectionWeb(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                ForEach(clusters, id: \.0) { cluster in
                    clusterNode(
                        name: cluster.0,
                        icon: cluster.1,
                        color: cluster.2,
                        index: cluster.3,
                        total: CGFloat(clusters.count),
                        size: geometry.size
                    )
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(MagnificationGesture().onChanged { scale = max(min($0, 3), 0.5) })
            .gesture(DragGesture().onChanged { offset = $0.translation })
        }
        .background(Color.supraBackground)
    }

    private func gridLines(size: CGSize) -> some View {
        Canvas { context, _ in
            context.stroke(
                Path { path in
                    for x in stride(from: 0, to: size.width, by: 60) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    for y in stride(from: 0, to: size.height, by: 60) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                },
                with: .color(Color.supraBorder.opacity(0.2)),
                lineWidth: 0.5
            )
        }
    }

    private func connectionWeb(center: CGPoint) -> some View {
        Canvas { context, _ in
            var path = Path()
            for i in 0..<12 {
                let angle = Angle.degrees(Double(i) * 30)
                let point = CGPoint(
                    x: center.x + cos(angle.radians) * 100,
                    y: center.y + sin(angle.radians) * 100
                )
                path.move(to: center)
                path.addLine(to: point)
            }
            context.stroke(path, with: .color(Color.supraBorder.opacity(0.3)), lineWidth: 0.5)
        }
    }

    private func clusterNode(name: String, icon: String, color: Color, index: CGFloat, total: CGFloat, size: CGSize) -> some View {
        let angle = Angle.degrees(Double(index / total) * 360 - 90)
        let radius: CGFloat = min(size.width, size.height) * 0.28
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let position = CGPoint(
            x: center.x + cos(angle.radians) * radius,
            y: center.y + sin(angle.radians) * radius
        )
        return Circle()
            .fill(color.opacity(0.12))
            .frame(width: 110, height: 110)
            .overlay(
                VStack(spacing: 6) {
                    Image(systemName: icon).font(.title3).foregroundColor(color)
                    Text(name.capitalized).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                }
            )
            .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))
            .position(position)
    }

    private func filterButton(_ label: String, active: Bool) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(active ? .white : .supraTextSecondary)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(active ? Color.supraAccent : Color.supraSurface)
            .clipShape(Capsule())
    }
}
