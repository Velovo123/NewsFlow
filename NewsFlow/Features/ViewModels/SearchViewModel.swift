//
//  SearchViewModel.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 27.04.2026.
//


import Foundation

final class SearchViewModel {

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    private(set) var articles: [Article] = []
    private var debounceTask: Task<Void, Never>?

    func search(query: String) {
        debounceTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            articles = []
            onUpdate?()
            return
        }

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s debounce
            guard !Task.isCancelled else { return }

            do {
                let results = try await NewsAPIService.shared.search(query: trimmed)
                await MainActor.run {
                    self.articles = results
                    self.onUpdate?()
                }
            } catch is CancellationError {
                // ignore — this is just debounce doing its job
            } catch let error as APIError {
                await MainActor.run {
                    if case .rateLimited = error {
                        self.onError?("Too many requests. Wait a moment before searching again.")
                    } else {
                        self.onError?(error.localizedDescription)
                    }
                }
            } catch {
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    func clear() {
        debounceTask?.cancel()
        articles = []
        onUpdate?()
    }
}
