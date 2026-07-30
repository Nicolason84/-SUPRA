import SwiftUI

struct SUPRAOSCommandCenterView: View {
    @State private var commandText = ""
    @State private var selectedIndex = 0

    let commands: [(String, String, String)] = [
        ("Lancer une mission", "flag", "Démarrer une mission depuis le Mission Center"),
        ("Créer un Twin", "person.2", "Générer un nouveau Twin"),
        ("Recherche universelle", "magnifyingglass", "Rechercher dans tout l'Univers et le workspace"),
        ("Lancer le runtime", "play", "Démarrer le Runtime OpenCode"),
        ("Freeze l'Univers", "snowflake", "Geler l'état courant de l'Univers"),
        ("Générer un rapport", "doc.text", "Produire un rapport d'audit"),
        ("Aide SUPRA OS", "questionmark.circle", "Documentation et raccourcis"),
    ]

    var filtered: [(String, String, String)] {
        if commandText.isEmpty { return commands }
        return commands.filter { $0.0.localizedCaseInsensitiveContains(commandText) || $0.2.localizedCaseInsensitiveContains(commandText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchField
            if !filtered.isEmpty {
                resultsList
            } else {
                emptyState
            }
        }
        .background(Color.supraBackground)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "command").foregroundColor(.supraAccent).font(.system(size: 14))
            TextField("Commander...", text: $commandText)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(.supraText)
                .onSubmit { /* execute */ }
            if !commandText.isEmpty {
                Button { commandText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.supraTextTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraAccent.opacity(0.4), lineWidth: 1))
        .padding(SUPRAOSDesignSystem.padding)
    }

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 2) {
                ForEach(filtered.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Image(systemName: filtered[i].1)
                            .font(.system(size: 14))
                            .foregroundColor(.supraAccent)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(filtered[i].0)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.supraText)
                            Text(filtered[i].2)
                                .font(.system(size: 11))
                                .foregroundColor(.supraTextSecondary)
                        }
                        Spacer()
                        Text("↵")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.supraTextTertiary)
                    }
                    .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
                    .padding(.vertical, 8)
                    .background(selectedIndex == i ? Color.supraAccent.opacity(0.1) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .contentShape(Rectangle())
                    .onTapGesture { selectedIndex = i }
                }
            }
            .padding(.horizontal, SUPRAOSDesignSystem.padding)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Aucune commande trouvée")
                .font(.system(size: 15))
                .foregroundColor(.supraTextSecondary)
            Spacer()
        }
    }
}
