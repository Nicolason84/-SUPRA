import SwiftUI
import Combine
import AppKit
import Foundation
import CryptoKit
import CAnnoNicoContracts

struct SUPRARecord: Codable, Identifiable {
    let id: String
    let name: String
    let status: String
    let path: String?
    let score: Double?
    let detail: String?

    enum CodingKeys: String, CodingKey {
        case id, name, status, path, score, detail
    }

    init(id: String, name: String, status: String, path: String?, score: Double?, detail: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.path = path
        self.score = score
        self.detail = detail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        status = try container.decode(String.self, forKey: .status)
        path = try container.decodeIfPresent(String.self, forKey: .path)
        score = try container.decodeIfPresent(Double.self, forKey: .score)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
    }
}
