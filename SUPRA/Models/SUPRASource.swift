import SwiftUI
import Combine
import AppKit
import Foundation
import CryptoKit
import CAnnoNicoContracts

struct SUPRASource: Codable, Identifiable {
    var id: String { name }

    let name: String
    let path: String?
    let status: String
    let authority: String?
    let priority: Int?
}
