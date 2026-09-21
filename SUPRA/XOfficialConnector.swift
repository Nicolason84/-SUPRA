import Foundation
import Security

enum ConnectorCredentialVault {
    static func readString(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8),
              !value.isEmpty else {
            return nil
        }
        return value
    }
}

struct XAPIEnvelope<T: Decodable>: Decodable {
    let data: T
}

struct XAPIUser: Decodable, Identifiable {
    let id: String
    let name: String
    let username: String
}

struct XAPIPost: Decodable, Identifiable {
    let id: String
    let text: String
}

enum XOfficialConnectorError: LocalizedError {
    case missingCredential
    case invalidURL
    case requestFailed(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingCredential:
            return "X credential missing. Add the token to Keychain or runtime secret injection."
        case .invalidURL:
            return "Invalid X API URL."
        case .requestFailed(let code):
            return "X API request failed with HTTP \(code)."
        case .invalidResponse:
            return "X API returned an invalid response."
        }
    }
}

actor XOfficialConnector {
    static let keychainService = "com.nicolasalonso.SUPRA.external"
    static let bearerTokenAccount = "x.bearerToken"

    private let session: URLSession
    private let baseURL = URL(string: "https://api.x.com/2")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    var credentialConfigured: Bool {
        bearerToken() != nil
    }

    func lookupUser(username: String) async throws -> XAPIUser {
        let clean = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty,
              let encoded = clean.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "users/by/username/\(encoded)?user.fields=id,name,username", relativeTo: baseURL) else {
            throw XOfficialConnectorError.invalidURL
        }

        let data = try await request(url: url)
        return try JSONDecoder().decode(XAPIEnvelope<XAPIUser>.self, from: data).data
    }

    func recentSearch(query: String, maxResults: Int = 10) async throws -> [XAPIPost] {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent("tweets/search/recent"),
            resolvingAgainstBaseURL: true
        ) else {
            throw XOfficialConnectorError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "max_results", value: String(min(max(maxResults, 10), 100))),
            URLQueryItem(name: "tweet.fields", value: "created_at,author_id,public_metrics")
        ]

        guard let url = components.url else {
            throw XOfficialConnectorError.invalidURL
        }

        let data = try await request(url: url)
        return try JSONDecoder().decode(XAPIEnvelope<[XAPIPost]>.self, from: data).data
    }

    private func request(url: URL) async throws -> Data {
        guard let token = bearerToken() else {
            throw XOfficialConnectorError.missingCredential
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw XOfficialConnectorError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw XOfficialConnectorError.requestFailed(http.statusCode)
        }
        return data
    }

    private func bearerToken() -> String? {
        ConnectorCredentialVault.readString(
            service: Self.keychainService,
            account: Self.bearerTokenAccount
        ) ?? ProcessInfo.processInfo.environment["SUPRA_X_BEARER_TOKEN"]
    }
}
