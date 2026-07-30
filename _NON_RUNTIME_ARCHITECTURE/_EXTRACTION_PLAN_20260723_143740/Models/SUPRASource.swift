import Foundation
import SwiftUI

struct SUPRASource: Codable, Identifiable {
    var id: String { name }

    let name: String
    let path: String?
    let status: String
    let authority: String?
    let priority: Int?
}
