import SwiftUI
import UniformTypeIdentifiers

struct ConversationTwinView: View {
    @StateObject private var store = ConversationMemoryStore.shared
    @State private var showFilePicker = false
    @State private var selectedConversationId: String?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                    header
                    searchBar
                    filterChips
                    if store.isImporting {
                        importProgress
                    }
                    if let status = store.importStatus {
                        importStatusBanner(status)
                    }
                    if store.visibleConversations.isEmpty {
                        emptyState
                    } else {
                        conversationTimeline
                    }
                }
                .padding(SUPRAOSDesignSystem.padding)
            }
        }
        .background(Color.supraBackground)
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                store.importConversations(from: url)
            case .failure:
                break
            }
        }
        .onAppear {
            store.startAutoRefresh()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.supraTeal)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("CONVERSATIONS TWIN")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.supraTeal)
                        .tracking(2)
                    Text("Mémoire des conversations")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.supraText)
                }
                Spacer()
                HStack(spacing: 6) {
                    statsBadge("\(store.conversations.count)", "total", .supraTeal)
                    statsBadge("\(store.conversations.reduce(0) { $0 + $1.messageCount })", "messages", .supraAccent)
                }
            }

            HStack(spacing: 8) {
                Button {
                    showFilePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 10))
                        Text("IMPORT CHATGPT EXPORT")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.supraTeal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.supraTeal.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(store.isImporting)

                Button {
                    store.generateAllSummaries()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "text.redaction")
                            .font(.system(size: 10))
                        Text("GÉNÉRER RÉSUMÉS")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.supraPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.supraPurple.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()

                if let lastRefresh = store.lastRefresh {
                    HStack(spacing: 3) {
                        Circle().fill(Color.supraTeal).frame(width: 3, height: 3)
                        Text("Indexé: \(lastRefresh.formatted(date: .omitted, time: .standard))")
                            .font(.system(size: 8))
                            .foregroundColor(.supraTextTertiary)
                    }
                }
            }

            Divider().background(Color.supraBorder)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(.supraTextTertiary)
            TextField("Rechercher dans les conversations...", text: $store.query)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.supraText)
            if !store.query.isEmpty {
                Button {
                    store.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.supraTextTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(ConversationMemoryStore.allTags, id: \.self) { tag in
                    Button {
                        if store.activeTags.contains(tag) {
                            store.activeTags.remove(tag)
                        } else {
                            store.activeTags.insert(tag)
                        }
                    } label: {
                        Text(tag)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(store.activeTags.contains(tag) ? .white : tagColor(tag))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(store.activeTags.contains(tag) ? tagColor(tag) : tagColor(tag).opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                if !store.activeTags.isEmpty {
                    Button {
                        store.activeTags = []
                    } label: {
                        Text("Effacer")
                            .font(.system(size: 8))
                            .foregroundColor(.supraTextTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var importProgress: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(0.6)
            Text("Import en cours...")
                .font(.system(size: 10))
                .foregroundColor(.supraTextSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func importStatusBanner(_ status: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: status.contains("Erreur") ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.system(size: 10))
                .foregroundColor(status.contains("Erreur") ? .supraRed : .supraGreen)
            Text(status)
                .font(.system(size: 10))
                .foregroundColor(status.contains("Erreur") ? .supraRed : .supraGreen)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((status.contains("Erreur") ? Color.supraRed : Color.supraGreen).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Image(systemName: "text.bubble")
                .font(.system(size: 40))
                .foregroundColor(.supraTextTertiary)
            Text("Aucune conversation")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.supraTextSecondary)
            Text("Importez un export ChatGPT (conversations.json)\npour commencer à explorer votre mémoire de conversations")
                .font(.system(size: 11))
                .foregroundColor(.supraTextTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            Button {
                showFilePicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Importer conversations.json")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.supraTeal)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.supraTeal.opacity(0.12))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            Spacer().frame(height: 60)
        }
        .frame(maxWidth: .infinity)
    }

    private var conversationTimeline: some View {
        LazyVStack(spacing: 8) {
            ForEach(store.visibleConversations) { conv in
                conversationCard(conv)
                    .onTapGesture {
                        if selectedConversationId == conv.id {
                            selectedConversationId = nil
                        } else {
                            selectedConversationId = conv.id
                            if conv.summary == nil {
                                store.generateSummary(for: conv.id)
                            }
                        }
                    }
            }
        }
    }

    private func conversationCard(_ conv: ConversationRecord) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(conv.summary != nil ? Color.supraTeal : Color.supraTextTertiary)
                            .frame(width: 6, height: 6)
                        Text(conv.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.supraText)
                            .lineLimit(1)
                    }
                    HStack(spacing: 8) {
                        Text(conv.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 9))
                            .foregroundColor(.supraTextTertiary)
                        Text("\(conv.messageCount) messages")
                            .font(.system(size: 9))
                            .foregroundColor(.supraTextTertiary)
                        if conv.duration > 0 {
                            Text(formattedDuration(conv.duration))
                                .font(.system(size: 9))
                                .foregroundColor(.supraTextTertiary)
                        }
                    }
                }
                Spacer()
                if !conv.tags.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(conv.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 7, weight: .medium))
                                .foregroundColor(tagColor(tag))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(tagColor(tag).opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                Image(systemName: selectedConversationId == conv.id ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9))
                    .foregroundColor(.supraTextTertiary)
            }
            .padding(SUPRAOSDesignSystem.paddingSmall)

            if selectedConversationId == conv.id {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().background(Color.supraBorder)

                    if let summary = conv.summary {
                        summarySection(summary)
                    } else {
                        HStack(spacing: 6) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.5)
                            Text("Génération du résumé...")
                                .font(.system(size: 9))
                                .foregroundColor(.supraTextTertiary)
                        }
                        .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
                        .padding(.bottom, 8)
                    }

                    messagesPreview(conv)
                }
                .transition(.opacity)
            }
        }
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
        .contentShape(Rectangle())
    }

    private func summarySection(_ summary: ConversationSummary) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if !summary.context.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.supraTeal)
                        .frame(width: 12, height: 12)
                    Text(summary.context)
                        .font(.system(size: 10))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(3)
                }
            }
            if !summary.decisions.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.supraOrange)
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(summary.decisions, id: \.self) { decision in
                            Text(decision)
                                .font(.system(size: 9))
                                .foregroundColor(.supraOrange)
                                .lineLimit(2)
                        }
                    }
                }
            }
            if !summary.nextActions.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.supraAccent)
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(summary.nextActions, id: \.self) { action in
                            Text(action)
                                .font(.system(size: 9))
                                .foregroundColor(.supraAccent)
                                .lineLimit(2)
                        }
                    }
                }
            }
            if !summary.relatedFiles.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.supraBlue)
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(summary.relatedFiles.prefix(5), id: \.self) { file in
                            Text(file)
                                .font(.system(size: 8))
                                .foregroundColor(.supraBlue)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
    }

    private func messagesPreview(_ conv: ConversationRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            let previews = conv.messages.suffix(3)
            ForEach(previews) { msg in
                HStack(alignment: .top, spacing: 6) {
                    Text(msg.role == "user" ? "Vous" : "Assistant")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(msg.role == "user" ? .supraAccent : .supraGreen)
                        .frame(width: 50, alignment: .leading)
                    Text(msg.content.replacingOccurrences(of: "\n", with: " "))
                        .font(.system(size: 9))
                        .foregroundColor(.supraTextSecondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraGlass)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .padding(SUPRAOSDesignSystem.paddingSmall)
    }

    private func statsBadge(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .tracking(1)
        }
    }

    private func formattedDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)min" }
        return "\(minutes)min"
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag {
        case "SUPRA": .supraAccent
        case "NOVA ERA": .supraPurple
        case "CAnnoNico": .supraRed
        case "Runtime": .supraTeal
        case "Business": .supraGreen
        case "Legal": .supraOrange
        case "Décisions": .supraBlue
        default: .supraTextSecondary
        }
    }
}
