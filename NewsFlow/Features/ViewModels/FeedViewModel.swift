//
//  FeedViewModel.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import Foundation

final class FeedViewModel {

    var articles: [Article] = []
    var selectedCategory: NewsCategory = .all
    var isLoading = false
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    func fetchArticles() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let fetched = try await NewsAPIService.shared.fetchTopHeadlines(category: selectedCategory)
                await MainActor.run {
                    self.articles = fetched
                    self.isLoading = false
                    self.onUpdate?()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    func selectCategory(_ category: NewsCategory) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        articles = []
        onUpdate?()
        fetchArticles()
    }
}
