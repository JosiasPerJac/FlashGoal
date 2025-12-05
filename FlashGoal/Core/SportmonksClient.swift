//
//  SportmonksClient.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case httpError(status: Int, body: String?)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL configuration."
        case .httpError(let status, let body): return "HTTP \(status): \(body ?? "Unknown error")"
        case .decodingError(let error): return "Decoding Failed: \(error.localizedDescription)"
        case .unknown: return "An unknown error occurred."
        }
    }
}

final class SportmonksClient {
    static let shared = SportmonksClient()
    private init() {}

    func request<T: Decodable>(
        endpoint: String,
        includes: [String] = [],
        filters: [String: String] = [:]
    ) async throws -> T {
        var components = URLComponents(
            url: AppConfig.baseURL.appendingPathComponent(endpoint),
            resolvingAgainstBaseURL: false
        )

        var queryItems = [URLQueryItem(name: "api_token", value: AppConfig.apiKey)]
        
        if !includes.isEmpty {
            let includesString = includes.joined(separator: ";")
            queryItems.append(URLQueryItem(name: "include", value: includesString))
        }

        for (key, value) in filters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Europe/Copenhagen", forHTTPHeaderField: "X-Timezone")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw APIError.httpError(status: http.statusCode, body: body)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error for \(endpoint): \(error)")
            throw APIError.decodingError(error)
        }
    }
}
