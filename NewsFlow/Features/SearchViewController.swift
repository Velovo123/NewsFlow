//
//  SearchViewController.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit

final class SearchViewController: UIViewController {

    private let viewModel = SearchViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var collectionView: UICollectionView!
    private let emptyStateLabel = UILabel()
    private let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSearchBar()
        setupCollectionView()
        setupDataSource()
        setupEmptyState()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupSearchBar() {
        searchBar.placeholder = "Search articles…"
        searchBar.tintColor = Theme.Color.accent
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = Theme.Color.background
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.reuseID)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)),
            subitems: [item]
        )
        return UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group))
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            guard case let .article(article) = item else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCell.reuseID, for: indexPath) as! ArticleCell
            cell.configure(with: article)
            return cell
        }
    }

    private func setupEmptyState() {
        emptyStateLabel.text = "Search for articles"
        emptyStateLabel.font = Theme.Font.medium(17)
        emptyStateLabel.textColor = Theme.Color.textTertiary
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateEmptyState(query: String) {
        let isEmpty = viewModel.articles.isEmpty
        emptyStateLabel.isHidden = !isEmpty

        if query.trimmingCharacters(in: .whitespaces).count < 2 {
            emptyStateLabel.text = "Search for articles"
        } else {
            emptyStateLabel.text = "No results for \"\(query)\""
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.applySnapshot()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.articles])
        snapshot.appendItems(viewModel.articles.map { .article($0) }, toSection: .articles)
        dataSource.apply(snapshot, animatingDifferences: true)
        updateEmptyState(query: searchBar.text ?? "")
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.clear()
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard case let .article(article) = dataSource.itemIdentifier(for: indexPath) else { return }
        let detail = DetailViewController(article: article)
        navigationController?.pushViewController(detail, animated: true)
    }
}
