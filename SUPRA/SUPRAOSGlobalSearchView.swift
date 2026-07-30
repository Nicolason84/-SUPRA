import SwiftUI

struct SUPRAOSGlobalSearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedScope = "all"

    let scopes = ["all", "objects", "twins", "projects", "missions"]

    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            if !searchText.isEmpty {
                resultsList
            } else {
                emptyState
            }
        }
        .background(Color.supraBackground)
    }

    private var searchHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(Color.supraAccent)
                TextField("Rechercher dans l'Univers...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20))
                    .foregroundColor(.supraText)
                    .onSubmit { isSearching = true }
                if !searchText.isEmpty {
                    Button { searchText = ""; isSearching = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.supraTextTertiary).font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(SUPRAOSDesignSystem.paddingSmall)
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
            .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
            HStack(spacing: 8) {
                ForEach(scopes, id: \.self) { scope in
                    scopeButton(scope)
                }
                Spacer()
                if isSearching {
                    ProgressView().scaleEffect(0.7)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.padding)
    }

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                ForEach(0..<12, id: \.self) { i in
                    resultRow(index: i)
                }
            }
            .padding(.horizontal, SUPRAOSDesignSystem.padding)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.supraTextTertiary)
            Text("Recherchez dans tout l'Univers")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.supraTextSecondary)
            Text("Twins · Objets · Projets · Commits · Décisions · Rapports · PDF")
                .font(.system(size: 13))
                .foregroundColor(.supraTextTertiary)
            Spacer()
        }
    }

    private func resultRow(index: Int) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.supraAccent.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: ["cube", "person.2", "folder", "doc.text", "flag"][index % 5])
                    .foregroundColor(Color.supraAccent).font(.system(size: 14)))
            VStack(alignment: .leading, spacing: 2) {
                Text("Résultat \(index + 1)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.supraText)
                Text("Type: objet · Source: workspace")
                    .font(.system(size: 11))
                    .foregroundColor(.supraTextTertiary)
            }
            Spacer()
            Text("Score: \(Double.random(in: 0.7...1.0), specifier: "%.2f")")
                .font(.system(size: 11))
                .foregroundColor(.supraGreen)
        }
        .padding(12)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func scopeButton(_ scope: String) -> some View {
        Text(scope.capitalized)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(selectedScope == scope ? .white : .supraTextSecondary)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(selectedScope == scope ? Color.supraAccent : Color.supraSurface)
            .clipShape(Capsule())
            .onTapGesture { selectedScope = scope }
    }
}
