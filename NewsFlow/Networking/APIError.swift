//
//  APIError.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingFailed(underlying: Error)
    case noAPIKey
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Could not build the request URL."
        case .noAPIKey: return "Add your NewsAPI key in APIEndpoint.swift."
        case .rateLimited: return "Too many requests. Try again in a moment."
        case let .invalidResponse(code): return "Server returned status \(code)."
        case let .decodingFailed(error): return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}
