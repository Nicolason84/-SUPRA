struct SUPRASection: Codable, Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let subtitle: String
    let count: Int
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case systemImage = "system_image"
        case subtitle
        case count
        case status
    }
}
