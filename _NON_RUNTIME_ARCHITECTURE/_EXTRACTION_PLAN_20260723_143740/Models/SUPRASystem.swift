import Foundation
import SwiftUI

struct SUPRASystem: Codable {
    let name: String
    let subtitle: String
    let status: String
    let canonicalSource: String?
    let runtimeSource: String?
    let atlasSource: String?

    enum CodingKeys: String, CodingKey {
        case name
        case subtitle
        case status
        case canonicalSource = "canonical_source"
        case runtimeSource = "runtime_source"
        case atlasSource = "atlas_source"
    }
}
