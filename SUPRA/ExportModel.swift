import Foundation
import SwiftUI

// MARK: - ExportFormat

enum ExportFormat: String, CaseIterable, Identifiable {
    case csv
    case json
    case markdown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .csv:      return "CSV"
        case .json:     return "JSON"
        case .markdown: return "Markdown"
        }
    }

    var fileExtension: String {
        switch self {
        case .csv:      return "csv"
        case .json:     return "json"
        case .markdown: return "md"
        }
    }

    var contentType: String {
        switch self {
        case .csv:      return "text/csv"
        case .json:     return "application/json"
        case .markdown: return "text/markdown"
        }
    }
}

// MARK: - ExportScope

enum ExportScope: String, CaseIterable, Identifiable {
    case all
    case health
    case runtime
    case missions
    case intelligence
    case resources

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:          return "All Sections"
        case .health:       return "System Health"
        case .runtime:      return "Runtime"
        case .missions:     return "Missions"
        case .intelligence: return "Intelligence"
        case .resources:    return "Resources"
        }
    }

    var icon: String {
        switch self {
        case .all:          return "square.grid.2x2"
        case .health:       return "heart.fill"
        case .runtime:      return "cpu"
        case .missions:     return "flag.fill"
        case .intelligence: return "brain.head.profile"
        case .resources:    return "gauge.with.dots.needle.67percent"
        }
    }
}

// MARK: - ExportOptions

struct ExportOptions {
    var includeTimestamps: Bool
    var includeDetails: Bool
    var compactFormat: Bool

    init(
        includeTimestamps: Bool = true,
        includeDetails: Bool = true,
        compactFormat: Bool = false
    ) {
        self.includeTimestamps = includeTimestamps
        self.includeDetails = includeDetails
        self.compactFormat = compactFormat
    }
}

// MARK: - ExportConfiguration

struct ExportConfiguration {
    var format: ExportFormat
    var scope: ExportScope
    var options: ExportOptions

    init(
        format: ExportFormat = .json,
        scope: ExportScope = .all,
        options: ExportOptions = ExportOptions()
    ) {
        self.format = format
        self.scope = scope
        self.options = options
    }
}
