import Foundation

struct INPIOfficialConnectorConfiguration {
    let apiBaseURL: URL
    let authorizationHeaderValue: String?

    static func fromRuntime() -> INPIOfficialConnectorConfiguration? {
        let rawBase =
            ProcessInfo.processInfo.environment["SUPRA_INPI_API_BASE_URL"]
            ?? UserDefaults.standard.string(forKey: "SUPRA_INPI_API_BASE_URL")

        guard let raw = rawBase,
              let base = URL(string: raw) else {
            return nil
        }

        let auth = ConnectorCredentialVault.readString(
            service: "com.nicolasalonso.SUPRA.external",
            account: "inpi.authorizationHeader"
        ) ?? ProcessInfo.processInfo.environment["SUPRA_INPI_AUTHORIZATION"]

        return INPIOfficialConnectorConfiguration(
            apiBaseURL: base,
            authorizationHeaderValue: auth
        )
    }
}

enum INPIOfficialDataset: String, CaseIterable, Identifiable {
    case rne = "RNE / entreprises"
    case annualAccounts = "Comptes annuels"
    case corporateActs = "Actes et statuts"
    case trademarks = "Marques"
    case patents = "Brevets"
    case designs = "Dessins et modèles"

    var id: String { rawValue }
}

enum INPIOfficialConnectorError: LocalizedError {
    case configurationMissing
    case invalidPath
    case requestFailed(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .configurationMissing:
            return "INPI API configuration missing. Official technical credentials and endpoint configuration are required."
        case .invalidPath:
            return "Invalid INPI API path."
        case .requestFailed(let code):
            return "INPI API request failed with HTTP \(code)."
        case .invalidResponse:
            return "INPI API returned an invalid response."
        }
    }
}

actor INPIOfficialConnector {
    static let officialPortalURL = URL(string: "https://data.inpi.fr")!

    private let session: URLSession
    private let configuration: INPIOfficialConnectorConfiguration?

    init(
        configuration: INPIOfficialConnectorConfiguration? = .fromRuntime(),
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }

    var isConfigured: Bool {
        configuration != nil
    }

    /// Raw official API fetch. Endpoint paths come from the INPI technical documentation
    /// associated with the user's approved API/SFTP access. SUPRA intentionally does not
    /// guess private endpoint paths.
    func fetch(relativePath: String) async throws -> Data {
        guard let configuration else {
            throw INPIOfficialConnectorError.configurationMissing
        }

        let clean = relativePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !clean.isEmpty else {
            throw INPIOfficialConnectorError.invalidPath
        }

        let url = configuration.apiBaseURL.appendingPathComponent(clean)
        var request = URLRequest(url: url)
        request.timeoutInterval = 20

        if let auth = configuration.authorizationHeaderValue, !auth.isEmpty {
            request.setValue(auth, forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw INPIOfficialConnectorError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw INPIOfficialConnectorError.requestFailed(http.statusCode)
        }
        return data
    }
}
