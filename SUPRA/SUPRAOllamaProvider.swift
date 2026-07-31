import Foundation

struct OllamaGenerateRequest: Codable {
    let model: String
    let prompt: String
    let system: String?
    let stream: Bool
    let options: [String: Double]?
}

struct OllamaGenerateResponse: Codable {
    let model: String
    let response: String
    let done: Bool
    let totalDuration: Int?
    let promptEvalCount: Int?
    let evalCount: Int?

    enum CodingKeys: String, CodingKey {
        case model, response, done
        case totalDuration = "total_duration"
        case promptEvalCount = "prompt_eval_count"
        case evalCount = "eval_count"
    }
}

@MainActor
final class SUPRAOllamaProvider: SUPRAProviderPlugin {
    let pluginID: String = "ollama"
    let pluginVersion: String = "1.0.0"
    let pluginCapabilities: [String] = ["provider", "llm", "local"]

    let declaration: SUPRAProviderPluginDeclaration
    let models: [SUPRAProviderModelDeclaration]

    private let session: URLSession
    private var healthCheckTask: Task<Void, Never>?
    private var _isHealthy: Bool = false

    init(baseURL: String = "http://localhost:11434") {
        let decl = SUPRAProviderPluginDeclaration(
            pluginID: "ollama",
            providerID: "ollama",
            providerName: "Ollama",
            providerVersion: "1.0.0",
            capabilities: ["reasoning", "conversation", "analysis", "coding", "planning"],
            supportsVision: false,
            supportsTools: false,
            supportsStreaming: true,
            supportsJSON: false,
            supportsEmbeddings: true,
            contextWindow: 8192,
            maxTokens: 4096,
            isLocal: true,
            costPer1KTokens: 0.0,
            priority: 0,
            healthEndpoint: "\(baseURL)/api/tags"
        )
        self.declaration = decl

        self.models = [
            SUPRAProviderModelDeclaration(
                modelID: "deepseek-r1", modelName: "DeepSeek R1",
                providerID: "ollama",
                capabilities: ["reasoning", "conversation", "analysis"],
                contextWindow: 8192, maxTokens: 4096,
                isLocal: true, speed: 40
            ),
            SUPRAProviderModelDeclaration(
                modelID: "qwen2.5", modelName: "Qwen 2.5",
                providerID: "ollama",
                capabilities: ["reasoning", "coding", "conversation"],
                contextWindow: 8192, maxTokens: 4096,
                isLocal: true, speed: 50
            ),
            SUPRAProviderModelDeclaration(
                modelID: "llama3.2", modelName: "Llama 3.2",
                providerID: "ollama",
                capabilities: ["conversation", "analysis"],
                contextWindow: 4096, maxTokens: 2048,
                isLocal: true, speed: 60
            ),
            SUPRAProviderModelDeclaration(
                modelID: "gemma3", modelName: "Gemma 3",
                providerID: "ollama",
                capabilities: ["reasoning", "conversation"],
                contextWindow: 8192, maxTokens: 4096,
                isLocal: true, speed: 45
            ),
            SUPRAProviderModelDeclaration(
                modelID: "mistral", modelName: "Mistral",
                providerID: "ollama",
                capabilities: ["reasoning", "conversation", "analysis"],
                contextWindow: 8192, maxTokens: 4096,
                isLocal: true, speed: 55
            ),
        ]

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 70
        self.session = URLSession(configuration: config)
    }

    func execute(prompt: String, systemPrompt: String, modelID: String,
                 maxTokens: Int, temperature: Double) async throws -> String {
        guard let url = URL(string: "\(declaration.healthEndpoint?.replacingOccurrences(of: "/api/tags", with: "") ?? "http://localhost:11434")/api/generate") else {
            throw NSError(domain: "Ollama", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL invalide"])
        }

        var options: [String: Double] = [:]
        options["num_predict"] = Double(maxTokens)
        options["temperature"] = temperature

        let ollamaRequest = OllamaGenerateRequest(
            model: modelID,
            prompt: prompt,
            system: systemPrompt.isEmpty ? nil : systemPrompt,
            stream: false,
            options: options
        )

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(ollamaRequest)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Ollama", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pas de réponse HTTP"])
        }
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "Ollama", code: httpResponse.statusCode,
                         userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
        }

        let ollamaResponse = try JSONDecoder().decode(OllamaGenerateResponse.self, from: data)
        return ollamaResponse.response
    }

    func healthCheck() async -> Bool {
        guard let urlString = declaration.healthEndpoint,
              let url = URL(string: urlString) else { return false }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 5

        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                _isHealthy = false
                return false
            }
            _isHealthy = httpResponse.statusCode == 200
            return _isHealthy
        } catch {
            _isHealthy = false
            return false
        }
    }

    func onRegister() async {
        _ = await healthCheck()
        startPeriodicHealthCheck()
    }

    func onUnregister() async {
        stopHealthCheck()
    }

    private func startPeriodicHealthCheck(intervalSeconds: Int = 30) {
        healthCheckTask = Task { [weak self] in
            while !Task.isCancelled {
                _ = await self?.healthCheck()
                try? await Task.sleep(nanoseconds: UInt64(intervalSeconds) * 1_000_000_000)
            }
        }
    }

    private func stopHealthCheck() {
        healthCheckTask?.cancel()
        healthCheckTask = nil
    }

    deinit {
        healthCheckTask?.cancel()
    }
}
