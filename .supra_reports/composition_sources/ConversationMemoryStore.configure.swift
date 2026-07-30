    func configure(knowledgeGraph: KnowledgeGraph, decisionStore: DecisionStore, missionStore: MissionStore) {
        self.knowledgeGraph = knowledgeGraph
        self.decisionStore = decisionStore
        self.missionStore = missionStore
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        timer = Timer.scheduledTimer(withTimeInterval: 90, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkForNewFiles()
            }
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    func checkForNewFiles() {
        let conversationsDir = saveURL.deletingLastPathComponent()
        guard FileManager.default.fileExists(atPath: conversationsDir.path) else { return }
        let discovered = findConversationFiles(in: conversationsDir)
        let existingIds = Set(conversations.map { $0.id })
        let newFiles = discovered.filter { !existingIds.contains(lastPathComponentWithoutExtension($0)) }
        guard !newFiles.isEmpty else {
            lastRefresh = Date()
            return
        }
        for url in newFiles {
            importSingleFile(url, version: importVersion + 1)
        }
        importVersion += 1
        saveIndex()
        connectToKnowledgeGraph()
        lastRefresh = Date()
        applyFilters()
    }

    func importConversations(from url: URL) {
        isImporting = true
        importStatus = nil
        importVersion += 1
        do {
            let data = try Data(contentsOf: url)
            let parsed = try parseChatGPTExport(data, sourceFile: url.lastPathComponent, version: importVersion)
            let existingIds = Set(conversations.map { $0.id })
            let newRecords = parsed.filter { !existingIds.contains($0.id) }
            guard !newRecords.isEmpty else {
                importStatus = "Aucune nouvelle conversation détectée"
                dismissImportStatus()
                isImporting = false
                return
            }
            conversations.append(contentsOf: newRecords)
            conversations.sort { $0.date > $1.date }
            saveIndex()
            connectToKnowledgeGraph()
            applyFilters()
            importStatus = "\(newRecords.count) conversations importées"
        } catch {
            importStatus = "Erreur d'import : \(error.localizedDescription)"
        }
        dismissImportStatus()
        isImporting = false
    }

    func generateSummary(for conversationId: String) {
        guard let idx = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        var conv = conversations[idx]
        let allText = conv.messages.map { "[\($0.role)] \($0.content)" }.joined(separator: "\n")
        conv.summary = ConversationSummary(
            context: extractContext(from: allText),
            decisions: extractDecisions(from: allText),
            nextActions: extractNextActions(from: allText),
            relatedFiles: extractRelatedFiles(from: allText)
        )
        conversations[idx] = conv
        saveIndex()
        applyFilters()
    }

    func generateAllSummaries() {
        for idx in conversations.indices where conversations[idx].summary == nil {
            var conv = conversations[idx]
            let allText = conv.messages.map { "[\($0.role)] \($0.content)" }.joined(separator: "\n")
            conv.summary = ConversationSummary(
                context: extractContext(from: allText),
                decisions: extractDecisions(from: allText),
                nextActions: extractNextActions(from: allText),
                relatedFiles: extractRelatedFiles(from: allText)
            )
            conversations[idx] = conv
        }
        saveIndex()
    }

    func refresh() {
        checkForNewFiles()
    }

    private func applyFilters() {
        var result = conversations
        if !query.isEmpty {
            result = result.filter { conv in
                conv.title.localizedStandardContains(query) ||
                conv.messages.contains { $0.content.localizedStandardContains(query) } ||
                conv.tags.contains { $0.localizedStandardContains(query) }
            }
        }
        if !activeTags.isEmpty {
            result = result.filter { conv in
                !activeTags.isDisjoint(with: conv.tags)
            }
        }
        visibleConversations = result
    }

    private func loadIndex() {
        guard FileManager.default.fileExists(atPath: saveURL.path),
              let data = try? Data(contentsOf: saveURL),
              let decoded = try? decoder.decode([ConversationRecord].self, from: data) else { return }
        conversations = decoded
        conversations.sort { $0.date > $1.date }
        applyFilters()
    }

    private func saveIndex() {
        try? FileManager.default.createDirectory(at: saveURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? encoder.encode(conversations) {
            try? data.write(to: saveURL)
        }
    }

    private func parseChatGPTExport(_ data: Data, sourceFile: String, version: Int) throws -> [ConversationRecord] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return root.compactMap { entry in
            guard let title = entry["title"] as? String,
                  let createTime = entry["create_time"] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: createTime)
            var messages: [ConversationMessage] = []
            if let mapping = entry["mapping"] as? [String: [String: Any]] {
                let sorted = mapping.values
                    .compactMap { node -> ConversationMessage? in
                        guard let msg = node["message"] as? [String: Any],
                              let author = msg["author"] as? [String: Any],
                              let role = author["role"] as? String,
                              let content = msg["content"] as? [String: Any],
                              let parts = content["parts"] as? [Any] else { return nil }
                        let text = parts.compactMap { $0 as? String }.joined(separator: "\n")
                        let msgId = (msg["id"] as? String) ?? UUID().uuidString
                        let ts = (msg["create_time"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
                        return ConversationMessage(id: msgId, role: role, content: text, timestamp: ts)
                    }
                    .sorted { ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast) }
                messages = sorted
            }
            let tags = inferTags(from: title, messages: messages)
            let id = "conv_\(sourceFile)_\(Int(createTime))"
            return ConversationRecord(
                id: id,
                title: title,
                date: date,
                messages: messages,
                tags: tags,
                projects: [],
                decisions: [],
                missions: [],
                freezes: [],
                evidence: [],
                summary: nil,
                sourceFile: sourceFile,
                importVersion: version
            )
        }
    }

    private func importSingleFile(_ url: URL, version: Int) {
        guard let data = try? Data(contentsOf: url),
              let records = try? parseChatGPTExport(data, sourceFile: url.lastPathComponent, version: version) else { return }
        let existingIds = Set(conversations.map { $0.id })
        let newRecords = records.filter { !existingIds.contains($0.id) }
        conversations.append(contentsOf: newRecords)
    }

    private func findConversationFiles(in directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey]) else { return [] }
        var results: [URL] = []
        for case let url as URL in enumerator {
            if url.lastPathComponent == "conversations.json" || url.pathExtension == "json" {
                results.append(url)
            }
        }
        return results
    }

    private func lastPathComponentWithoutExtension(_ url: URL) -> String {
        url.deletingPathExtension().lastPathComponent
    }

    private func connectToKnowledgeGraph() {
        guard let graph = knowledgeGraph else { return }
        let existingIds = Set(graph.objects.map { $0.id })
        for conv in conversations {
            let objId = "conversation:\(conv.id)"
            guard !existingIds.contains(objId) else { continue }
            let obj = KnowledgeObject(
                id: objId,
                source: "conversation",
                type: .conversation,
                title: conv.title,
                summary: conv.summary?.context ?? "\(conv.messages.count) messages",
                path: conv.sourceFile,
                project: nil,
                module: nil,
                created: conv.date,
                updated: conv.date,
                tags: conv.tags,
                relations: [],
                authority: 0.8,
                confidence: 0.85,
                status: nil,
                metadata: ["messageCount": "\(conv.messages.count)", "importVersion": "\(conv.importVersion)"]
            )
            graph.objects.append(obj)
        }
    }

    private func inferTags(from title: String, messages: [ConversationMessage]) -> [String] {
        let allText = (title + " " + messages.map { $0.content }.joined(separator: " ")).lowercased()
        var tags: [String] = []
        if allText.contains("supra") { tags.append("SUPRA") }
        if allText.contains("nova") || allText.contains("era") { tags.append("NOVA ERA") }
        if allText.contains("cannonico") || allText.contains("canno") { tags.append("CAnnoNico") }
        if allText.contains("runtime") || allText.contains("process") || allText.contains("cpu") { tags.append("Runtime") }
        if allText.contains("business") || allText.contains("revenue") || allText.contains("market") { tags.append("Business") }
        if allText.contains("legal") || allText.contains("license") || allText.contains("compliance") { tags.append("Legal") }
        if allText.contains("decision") || allText.contains("verdict") || allText.contains("approve") || allText.contains("gate") { tags.append("Décisions") }
        return tags
    }

    private func extractContext(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let assistantLines = lines.filter { $0.hasPrefix("[assistant]") }
        guard let firstResponse = assistantLines.first else { return "Aucun contexte extrait" }
        let cleaned = firstResponse
            .replacingOccurrences(of: "[assistant]", with: "")
            .trimmingCharacters(in: .whitespaces)
        return String(cleaned.prefix(200))
    }

    private func extractDecisions(from text: String) -> [String] {
        let lower = text.lowercased()
        var results: [String] = []
        if let range = lower.range(of: "décision") {
            let snippet = text[range.lowerBound...].prefix(100)
            results.append(String(snippet))
        }
        if let range = lower.range(of: "decision") {
            let snippet = text[range.lowerBound...].prefix(100)
            results.append(String(snippet))
        }
        return results
    }

    private func extractNextActions(from text: String) -> [String] {
        let lower = text.lowercased()
        var results: [String] = []
        let markers = ["prochaine action", "next action", "à faire", "todo", "étape suivante"]
        for marker in markers {
            if let range = lower.range(of: marker) {
                let snippet = text[range.lowerBound...].prefix(100)
                results.append(String(snippet))
            }
        }
        return results
    }

    private func extractRelatedFiles(from text: String) -> [String] {
        let pattern = try! NSRegularExpression(pattern: #"(/[^\s]+\.\w+)"#)
        let nsRange = NSRange(text.startIndex..., in: text)
        let matches = pattern.matches(in: text, range: nsRange)
        return matches.prefix(10).compactMap { match in
            guard let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }
    }

    private func dismissImportStatus() {
        importStatusDismissTask?.cancel()
        importStatusDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled else { return }
            self.importStatus = nil
        }
    }
}
