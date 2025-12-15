//
//  SportmonksClient.swift
//  FlashGoal
//
//  Created by Josias Pérez on 4/12/25.
//

import Foundation

/// Represents the various errors that can occur during network operations.
enum APIError: LocalizedError {
    /// The URL constructed for the request was malformed.
    case invalidURL
    
    /// The server responded with a status code outside the 200-299 success range.
    ///
    /// - Parameters:
    ///   - status: The HTTP status code returned by the server.
    ///   - body: The raw response body, if available, which may contain error details.
    case httpError(status: Int, body: String?)
    
    /// The response data could not be decoded into the expected type.
    ///
    /// - Parameter error: The underlying `DecodingError` thrown by `JSONDecoder`.
    case decodingError(Error)
    
    /// An unexpected error occurred that does not fit into other categories.
    case unknown

    /// A localized message describing the error.
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL configuration."
        case .httpError(let status, let body): return "HTTP \(status): \(body ?? "Unknown error")"
        case .decodingError(let error): return "Decoding Failed: \(error.localizedDescription)"
        case .unknown: return "An unknown error occurred."
        }
    }
}

/// A singleton networking client responsible for communicating with the Sportmonks API.
///
/// This client handles the low-level details of URL construction, authentication via API tokens,
/// HTTP header management (e.g., Timezone), and JSON decoding.
final class SportmonksClient {
    /// The shared singleton instance of the client.
    static let shared = SportmonksClient()
    
    private init() {}

    /// Performs an asynchronous generic network request to the Sportmonks API.
    ///
    /// This method constructs a full URL by appending the endpoint to the `AppConfig.baseURL`,
    /// injects the API token, applies any specified include parameters or filters, and decodes
    /// the response into the specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - endpoint: The specific API endpoint path (e.g., `"fixtures/date/..."`).
    ///   - includes: A list of related resources to include in the response (e.g., `["participants", "scores"]`).
    ///               These are joined by semicolons in the URL query.
    ///   - filters: A dictionary of additional query parameters to filter the request (e.g., `["season_id": "123"]`).
    ///
    /// - Returns: The decoded object of type `T`.
    ///
    /// - Throws: `APIError.invalidURL` if the URL cannot be formed.
    /// - Throws: `APIError.httpError` if the server returns a non-2xx status code.
    /// - Throws: `APIError.decodingError` if the response data does not match the `T` structure.
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
        // Enforce European timezone to match league schedules
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
