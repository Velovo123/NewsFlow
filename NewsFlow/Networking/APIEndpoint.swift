//
//  APIEndpoint.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import Foundation
import UIKit

enum NewsCategory: String, CaseIterable {
    case all = ""
    case technology = "technology"
    case business = "business"
    case sports = "sports"
    case science = "science"
    case health = "health"
    case entertainment = "entertainment"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .technology: return "Tech"
        case .business: return "Business"
        case .sports: return "Sports"
        case .science: return "Science"
        case .health: return "Health"
        case .entertainment: return "Entertainment"
        }
    }
}

enum APIEndpoint {
    case topHeadlines(category: NewsCategory, page: Int)
    case search(query: String, page: Int)
    
    private static let baseURL = "https://newsapi.org/v2"
    static let apiKey: String = {
        guard let key = ProcessInfo.processInfo.environment["NEWS_API_KEY"] else {
            fatalError("NEWS_API_KEY not set in environment")
        }
        return key
    }()
    
    var url: URL? {
        var components = URLComponents(string: APIEndpoint.baseURL)
        
        switch self {
        case let .topHeadlines(category, page):
            components?.path = "/v2/top-headlines"
            var items: [URLQueryItem] = [
                .init(name: "country", value: "us"),
                .init(name: "pageSize", value: "20"),
                .init(name: "page", value: "\(page)"),
                .init(name: "apiKey", value: APIEndpoint.apiKey)
            ]
            if !category.rawValue.isEmpty {
                items.append(.init(name: "category", value: category.rawValue))
            }
            components?.queryItems = items
            
        case let .search(query, page):
            components?.path = "/v2/everything"
            components?.queryItems = [
                .init(name: "q", value: query),
                .init(name: "language", value: "en"),
                .init(name: "sortBy", value: "publishedAt"),
                .init(name: "pageSize", value: "20"),
                .init(name: "page", value: "\(page)"),
                .init(name: "apiKey", value: APIEndpoint.apiKey)
            ]
        }
        
        return components?.url
    }
}

