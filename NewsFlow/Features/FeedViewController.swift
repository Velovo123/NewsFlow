//
//  FeedViewController.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit

enum Section: Hashable { case hero, articles }
enum Item: Hashable {
    case hero(Article)
    case article(Article)
}

final class FeedViewController: UIViewController, UICollectionViewDelegate {

    private let viewModel = FeedViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var collectionView: UICollectionView!
    private let categoryScrollView = UIScrollView()
    private let categoryStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        setupNavBar()
        setupCategoryBar()
        setupCollectionView()
        setupDataSource()
        bindViewModel()
        viewModel.fetchArticles()
    }
    
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.Color.barBackground
        appearance.titleTextAttributes = [
            .foregroundColor: Theme.Color.textPrimary,
            .font: Theme.Font.medium(17)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
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

        guard !viewModel.articles.isEmpty else {
            dataSource.apply(snapshot, animatingDifferences: true)
            return
        }

        snapshot.appendSections([.hero, .articles])
        snapshot.appendItems([.hero(viewModel.articles[0])], toSection: .hero)
        snapshot.appendItems(viewModel.articles.dropFirst().map { .article($0) }, toSection: .articles)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func setupCategoryBar() {
        categoryScrollView.showsHorizontalScrollIndicator = false
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryScrollView)

        categoryStack.axis = .horizontal
        categoryStack.spacing = 8
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.distribution = .fillProportionally
        categoryScrollView.addSubview(categoryStack)

        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 44),

            categoryStack.topAnchor.constraint(equalTo: categoryScrollView.topAnchor, constant: 6),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: -6),
            categoryStack.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -16)
        ])

        for (index, category) in NewsCategory.allCases.enumerated() {
            var config = UIButton.Configuration.plain()
            config.title = category.displayName
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var updated = attributes
                updated.font = Theme.Font.categoryLabel
                return updated
            }
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            let button = UIButton(configuration: config)
            button.layer.cornerRadius = Theme.Radius.pill
            button.layer.borderWidth = 1
            button.layer.borderColor = Theme.Color.accent.cgColor
            button.clipsToBounds = true
            button.tag = index
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            updateButton(button, isSelected: index == 0)
            categoryStack.addArrangedSubview(button)
        }
    }

    private func updateButton(_ button: UIButton, isSelected: Bool) {
        button.backgroundColor = isSelected ? Theme.Color.accent : .clear
        button.configuration?.baseForegroundColor = isSelected ? .white : Theme.Color.accent
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        let category = NewsCategory.allCases[sender.tag]
        viewModel.selectCategory(category)

        categoryStack.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            updateButton(button, isSelected: index == sender.tag)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let article: Article
        switch item {
        case let .hero(a): article = a
        case let .article(a): article = a
        }
        let detail = DetailViewController(article: article)
        navigationController?.pushViewController(detail, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = Theme.Color.background
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.register(HeroArticleCell.self, forCellWithReuseIdentifier: HeroArticleCell.reuseID)
        collectionView.register(ArticleCell.self, forCellWithReuseIdentifier: ArticleCell.reuseID)
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .hero(article):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroArticleCell.reuseID, for: indexPath) as! HeroArticleCell
                cell.configure(with: article)
                return cell
            case let .article(article):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleCell.reuseID, for: indexPath) as! ArticleCell
                cell.configure(with: article)
                return cell
            }
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0: return Self.makeHeroSection()
            default: return Self.makeArticlesSection()
            }
        }
    }

    private static func makeHeroSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(240)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 12, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    private static func makeArticlesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
