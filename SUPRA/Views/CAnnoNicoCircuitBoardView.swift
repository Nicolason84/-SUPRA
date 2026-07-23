import SwiftUI

extension ContentView {
    var cannonicoCircuitBoard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CAnnoNico Closed Circuit").font(.title2.bold())
                    Text("Entrées filtrées · circulation fermée · sorties tracées · purge contrôlée.").foregroundStyle(.secondary)
                }
                Spacer()
                Label("CIRCUIT CLOSED", systemImage: "lock.shield.fill").font(.caption.weight(.black)).foregroundStyle(.green)
            }
            ZStack {
                Circle().stroke(.secondary.opacity(0.20), lineWidth: 26).frame(width: 350, height: 350)
                Circle().trim(from: 0.04, to: 0.92).stroke(.primary.opacity(0.55), style: StrokeStyle(lineWidth: 7, lineCap: .round)).rotationEffect(.degrees(-90)).frame(width: 350, height: 350)
                VStack(spacing: 8) {
                    Image(systemName: "atom").font(.system(size: 40, weight: .semibold))
                    Text("SUPRA CORE").font(.title3.bold())
                    Text("CAnnoNico contracts").font(.caption).foregroundStyle(.secondary)
                }
                .padding(22)
                .background(.ultraThinMaterial, in: Circle())
                circuitNode("Universal Inputs", subtitle: filteredInputStatus, symbol: "line.3.horizontal.decrease.circle.fill").offset(y: -195)
                circuitNode("Gabriel", subtitle: "CONDUCTOR", symbol: "circle.hexagongrid.fill").offset(x: 195)
                circuitNode("Outputs", subtitle: "TRACEABLE", symbol: "arrow.up.right.circle.fill").offset(y: 195)
                circuitNode("Purge Valve", subtitle: "\(circuitPurgeCount)", symbol: "drop.triangle.fill").offset(x: -195)
            }
            .frame(maxWidth: .infinity, minHeight: 450)
            HStack(spacing: 9) {
                circuitChip("Text", symbol: "text.alignleft")
                circuitChip("Files", symbol: "doc.fill")
                circuitChip("Events", symbol: "bolt.fill")
                circuitChip("Evidence", symbol: "checkmark.seal.fill")
                circuitChip("Media", symbol: "play.rectangle.fill")
                circuitChip("Human", symbol: "person.fill")
                Spacer()
            }
            HStack(spacing: 10) {
                Button {
                    circuitPurgeCount += 1
                    chatDraft = "CANNONICO PURGE VALVE. Purge uniquement les buffers temporaires, entrées non validées, doublons et sorties non promues. Ne touche à aucune source canonique, preuve, freeze, registre ou mémoire validée."
                    selection = "chat"
                } label: {
                    Label("Purge transient flow", systemImage: "drop.triangle.fill")
                }
                .buttonStyle(.bordered)
                Button {
                    filteredInputStatus = "REVALIDATING"
                    Task {
                        await store.sendChat("CANNONICO INPUT FILTER. Accepte uniquement les entrées avec type, source, autorité, lineage et contrat I/O. Rejette toute entrée ambiguë, dupliquée, non prouvée ou non autorisée.")
                        filteredInputStatus = "FILTERED"
                    }
                } label: {
                    Label("Revalidate inputs", systemImage: "line.3.horizontal.decrease.circle")
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.chatBusy)
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Label(
                        "Megabus \(terminalMegabusStatus)",
                        systemImage: terminalMegabusStatus == "CONNECTED"
                            ? "point.3.connected.trianglepath.dotted"
                            : "exclamationmark.triangle.fill"
                    )
                    .font(.caption.weight(.bold))
                    .foregroundStyle(
                        terminalMegabusStatus == "CONNECTED"
                            ? .green
                            : .orange
                    )

                    Label(
                        "No canonical source mutation",
                        systemImage: "lock.shield.fill"
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
    }

    private func circuitNode(_ title: String, subtitle: String, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol).font(.title2)
            Text(title).font(.caption.weight(.bold))
            Text(subtitle).font(.caption2.weight(.black)).foregroundStyle(.secondary)
        }
        .frame(width: 126, height: 84)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func circuitChip(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 7).background(.quaternary, in: Capsule())
    }
}
