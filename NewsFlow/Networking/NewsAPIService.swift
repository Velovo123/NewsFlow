//
//  NewsAPIService.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import Foundation

final class NewsAPIService {
    
    static let shared = NewsAPIService()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    func fetchTopHeadlines(category: NewsCategory = .all, page: Int = 1) async throws -> [Article] {
        try await fetch(endpoint: .topHeadlines(category: category, page: page))
    }
    
    func search(query: String, page: Int = 1) async throws -> [Article] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return try await fetch(endpoint: .search(query: query, page: page))
    }
    
    private func fetch(endpoint: APIEndpoint) async throws -> [Article] {
        guard APIEndpoint.apiKey != "YOUR_API_KEY_HERE" else { throw APIError.noAPIKey }
        guard let url = endpoint.url else { throw APIError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: -1)
        }
        
        switch http.statusCode {
        case 200: break
        case 429: throw APIError.rateLimited
        default: throw APIError.invalidResponse(statusCode: http.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(NewsResponse.self, from: data).articles
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }
    }
}
