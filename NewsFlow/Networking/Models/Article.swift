//
//  Article.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import Foundation

struct NewsResponse: Decodable {
    let status: String
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Codable, Hashable, Sendable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    var imageURL: URL? {
        guard let raw = urlToImage else { return nil }
        return URL(string: raw)
    }

    var articleURL: URL? { URL(string: url) }

    var timeAgo: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = iso.date(from: publishedAt) else { return "" }
        let diff = Int(Date().timeIntervalSince(date))
        switch diff {
        case 0..<60: return "Just now"
        case 60..<3600: return "\(diff / 60)m ago"
        case 3600..<86400: return "\(diff / 3600)h ago"
        default: return "\(diff / 86400)d ago"
        }
    }

    var formattedDate: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = iso.date(from: publishedAt) else { return publishedAt }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(url) }
    static func == (lhs: Article, rhs: Article) -> Bool { lhs.url == rhs.url }
}

struct Source: Codable, Hashable, Sendable {
    let id: String?
    let name: String
}


extension Article {

    private static let bookmarkKey = "newsflow.bookmarks"

    static func savedArticles() -> [Article] {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey),
              let articles = try? JSONDecoder().decode([Article].self, from: data)
        else { return [] }
        return articles
    }

    func isSaved() -> Bool { Article.savedArticles().contains(self) }

    func save() {
        var saved = Article.savedArticles()
        guard !saved.contains(self) else { return }
        saved.insert(self, at: 0)
        persist(saved)
    }

    func unsave() {
        let saved = Article.savedArticles().filter { $0 != self }
        persist(saved)
    }

    private func persist(_ articles: [Article]) {
        if let data = try? JSONEncoder().encode(articles) {
            UserDefaults.standard.set(data, forKey: Article.bookmarkKey)
        }
    }
}
