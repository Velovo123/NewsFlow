//
//  DetailViewController.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit
import SafariServices

final class DetailViewController: UIViewController {

    private let article: Article
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let tagLabel = PaddedLabel()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let readButton = UIButton()
    private let backButton = UIButton()

    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        setupScrollView()
        setupImageView()
        setupLabels()
        setupReadButton()
        setupBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Theme.Color.accentDark
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 380)
        ])

        if let url = article.imageURL {
            Task {
                let image = await ImageLoader.shared.loadImage(from: url)
                await MainActor.run { self.imageView.image = image }
            }
        }
    }

    private func setupLabels() {
        
        tagLabel.font = Theme.Font.tag
        tagLabel.textColor = UIColor.white
        tagLabel.backgroundColor = Theme.Color.accent
        tagLabel.layer.cornerRadius = Theme.Radius.sm
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = NSTextAlignment.center
        tagLabel.text = article.source.name.uppercased()
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagLabel)

        titleLabel.font = Theme.Font.detailTitle
        titleLabel.textColor = Theme.Color.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.text = article.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        authorLabel.font = Theme.Font.medium(13)
        authorLabel.textColor = Theme.Color.textSecondary
        authorLabel.text = article.author ?? "Unknown author"
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(authorLabel)

        dateLabel.font = Theme.Font.metadata
        dateLabel.textColor = Theme.Color.textTertiary
        dateLabel.text = article.formattedDate
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        descriptionLabel.font = Theme.Font.detailBody
        descriptionLabel.textColor = Theme.Color.textPrimary
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = article.description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Theme.Spacing.lg),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            tagLabel.heightAnchor.constraint(equalToConstant: 26),

            titleLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: Theme.Spacing.sm),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.md),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),

            dateLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),

            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: Theme.Spacing.lg),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg)
        ])
    }

    private func setupReadButton() {
        var config = UIButton.Configuration.filled()
        config.title = "Read Full Article"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = Theme.Color.accent
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        readButton.configuration = config
        readButton.layer.cornerRadius = Theme.Radius.md
        readButton.clipsToBounds = true
        readButton.addTarget(self, action: #selector(readButtonTapped), for: .touchUpInside)
        readButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(readButton)

        NSLayoutConstraint.activate([
            readButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Theme.Spacing.xl),
            readButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.lg),
            readButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.lg),
            readButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.xl)
        ])
    }

    private func setupBackButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.baseForegroundColor = .white
        backButton.configuration = config
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backButton.layer.cornerRadius = 20
        backButton.clipsToBounds = true
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(backButton)
        view.bringSubviewToFront(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func readButtonTapped() {
        guard let url = article.articleURL else { return }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}
