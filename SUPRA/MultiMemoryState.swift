import Foundation

struct MemorySourceInfo: Identifiable {
    let id: String
    let name: String
    let icon: String
    let objectCount: Int
    let lastSync: Date?
    let confidence: Double
    let anomalies: [String]
    let isConnected: Bool
}

struct MultiMemorySnapshot {
    let memories: [MemorySourceInfo]
    let globalHealth: String
    let lastUpdated: Date
}
