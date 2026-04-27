//
//  BookmarksViewModel.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 27.04.2026.
//

import Foundation

final class BookmarksViewModel {

    var onUpdate: (() -> Void)?

    private(set) var articles: [Article] = []

    func load() {
        articles = Article.savedArticles()
        onUpdate?()
    }

    func remove(article: Article) {
        article.unsave()
        articles = Article.savedArticles()
        onUpdate?()
    }
}
