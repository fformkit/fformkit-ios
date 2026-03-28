import Foundation

enum FFormkitError: LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case serverError(String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: return "Invalid API key. Please check your FFormkit API key."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .serverError(let msg): return "Server error: \(msg)"
        case .decodingError(let e): return "Failed to decode response: \(e.localizedDescription)"
        }
    }
}

final class FFormkitAPI {
    static let baseURL = "https://api.fformkit.com"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchConfig(apiKey: String) async throws -> FormConfig {
        guard !apiKey.isEmpty else { throw FFormkitError.invalidAPIKey }
        let urlString = "\(Self.baseURL)/api/v1/config/\(apiKey)"
        guard let url = URL(string: urlString) else { throw FFormkitError.invalidAPIKey }

        let (data, response) = try await fetch(url: url)
        try validateResponse(response)

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(FormConfig.self, from: data)
        } catch {
            throw FFormkitError.decodingError(error)
        }
    }

    func submit(_ submission: FFormkitSubmission) async throws -> String {
        guard let url = URL(string: "\(Self.baseURL)/api/v1/submit") else {
            throw FFormkitError.serverError("Invalid submit URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(submission)

        let (data, response) = try await fetch(request: request)
        try validateResponse(response)

        let result = try JSONDecoder().decode(SubmitResponse.self, from: data)
        if result.success, let id = result.id {
            return id
        }
        throw FFormkitError.serverError(result.error ?? "Submission failed")
    }

    // MARK: - Private

    private func fetch(url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch {
            throw FFormkitError.networkError(error)
        }
    }

    private func fetch(request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw FFormkitError.networkError(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299: return
        case 401, 403: throw FFormkitError.invalidAPIKey
        case 429: throw FFormkitError.serverError("Rate limit exceeded. Please try again later.")
        default: throw FFormkitError.serverError("HTTP \(http.statusCode)")
        }
    }
}
