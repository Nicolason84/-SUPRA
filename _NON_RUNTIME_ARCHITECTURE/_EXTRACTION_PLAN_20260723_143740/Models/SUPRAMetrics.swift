import Foundation
import SwiftUI

struct SUPRAMetrics: Codable {
    let projects: Int
    let capabilities: Int
    let products: Int
    let uiModules: Int
    let memoryObjects: Int
    let resources: Int
    let sourcesFound: Int
    let sourcesMissing: Int

    enum CodingKeys: String, CodingKey {
        case projects
        case capabilities
        case products
        case uiModules = "ui_modules"
        case memoryObjects = "memory_objects"
        case resources
        case sourcesFound = "sources_found"
        case sourcesMissing = "sources_missing"
    }
}
