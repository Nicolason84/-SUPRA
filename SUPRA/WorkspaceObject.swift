import Foundation
import CommonCrypto

actor WorkspaceObjectFactory {

    static let shared = WorkspaceObjectFactory()

    private init() {}

    func createObject(at url: URL, type: WorkspaceObjectType? = nil) -> WorkspaceObject? {
        let resourceKeys: Set<URLResourceKey> = [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .isDirectoryKey]
        guard let resourceValues = try? url.resourceValues(forKeys: resourceKeys),
              let fileSize = resourceValues.fileSize
        else { return nil }

        let isDir = resourceValues.isDirectory ?? false
        let resolvedType = type ?? inferType(from: url, isDirectory: isDir)
        let lang = language(for: url.pathExtension)
        let hash = computeHash(url: url, size: fileSize, modDate: resourceValues.contentModificationDate)
        let name = url.lastPathComponent
        let path = url.path
        let importance = calculateImportance(type: resolvedType, isDir: isDir, name: name, size: fileSize)

        return WorkspaceObject(
            id: hash,
            name: name,
            path: path,
            type: resolvedType,
            language: lang,
            dateCreated: resourceValues.creationDate,
            dateModified: resourceValues.contentModificationDate,
            sizeBytes: Int64(fileSize),
            hash: hash,
            relations: [],
            tags: inferTags(from: name, type: resolvedType, lang: lang),
            importance: importance,
            projectName: nil,
            moduleName: nil,
            lineCount: nil
        )
    }

    private func inferType(from url: URL, isDirectory: Bool) -> WorkspaceObjectType {
        let ext = url.pathExtension.lowercased()
        let name = url.lastPathComponent

        if isDirectory {
            if url.lastPathComponent == ".git" { return .gitRepository }
            if ext == "xcodeproj" || ext == "xcworkspace" { return .xcodeProject }
            if ext == "playground" { return .xcodeProject }
            if ext == "bundle" || ext == "framework" { return .module }
            return .directory
        }

        switch ext {
        case "swift", "py", "js", "ts", "jsx", "tsx", "rb", "go", "rs", "kt", "java":
            return .script
        case "md", "txt", "rtf":
            return .document
        case "pdf":
            return .pdf
        case "png", "jpg", "jpeg", "gif", "svg", "webp", "bmp":
            return .image
        case "sqlite", "db", "sqlite3":
            return .database
        case "log", "out":
            return .log
        case "zip", "tar", "gz", "bz2", "7z", "rar":
            return .archive
        case "json", "yaml", "yml", "toml", "xml", "plist":
            if name.contains("mission") { return .mission }
            if name.contains("decision") { return .decision }
            if name.contains("evidence") || name.contains("proof") { return .evidence }
            return .file
        case "sh", "bash", "zsh", "fish":
            return .script
        default:
            return .file
        }
    }

    private func language(for ext: String) -> String? {
        switch ext.lowercased() {
        case "swift": "Swift"
        case "py": "Python"
        case "js": "JavaScript"
        case "ts": "TypeScript"
        case "jsx", "tsx": "React"
        case "rb": "Ruby"
        case "go": "Go"
        case "rs": "Rust"
        case "kt": "Kotlin"
        case "java": "Java"
        case "sh", "bash", "zsh", "fish": "Shell"
        case "md", "txt", "rtf": "Text"
        case "json": "JSON"
        case "yaml", "yml": "YAML"
        case "xml": "XML"
        case "sql": "SQL"
        case "sqlite", "db": "SQLite"
        case "plist": "Plist"
        case "html": "HTML"
        case "css": "CSS"
        default: nil
        }
    }

    private func computeHash(url: URL, size: Int, modDate: Date?) -> String {
        let dateStr = modDate?.timeIntervalSince1970.description ?? "0"
        let components = "\(url.path):\(size):\(dateStr)"
        return String(components.hashValue.description)
    }

    private func calculateImportance(type: WorkspaceObjectType, isDir: Bool, name: String, size: Int) -> Double {
        var score: Double = 0.5
        switch type {
        case .project, .gitRepository: score = 1.0
        case .xcodeProject: score = 0.95
        case .script: score = 0.8
        case .pdf, .document: score = 0.7
        case .mission, .decision, .evidence, .conversation: score = 1.0
        case .database: score = 0.75
        case .archive: score = 0.3
        case .log: score = 0.2
        case .directory: score = 0.4
        case .file: score = 0.5
        case .image: score = 0.3
        default: score = 0.3
        }
        if name.contains("SUPRA") || name.contains("supra") { score = min(score + 0.2, 1.0) }
        if size > 1_000_000 { score = max(score - 0.1, 0.1) }
        return score
    }

    private func inferTags(from name: String, type: WorkspaceObjectType, lang: String?) -> [String] {
        var tags: [String] = [type.rawValue]
        if let lang = lang { tags.append(lang) }
        if name.contains("SUPRA") || name.contains("supra") { tags.append("SUPRA") }
        if name.contains("test") || name.contains("Test") || name.contains("spec") { tags.append("test") }
        if name.contains("README") || name.contains("readme") { tags.append("readme") }
        if name.contains("config") || name.contains("Config") { tags.append("config") }
        if name.hasSuffix(".swift") { tags.append("swift-source") }
        if name.contains("report") || name.contains("REPORT") || name.contains("Report") { tags.append("report") }
        return tags
    }

    func updateProjectNames(_ objects: inout [WorkspaceObject], rootURL: URL) {
        let projectName = rootURL.lastPathComponent
        for i in objects.indices {
            objects[i].projectName = projectName
        }
    }
}
