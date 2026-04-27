//
//  BookmarkTableCell.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 27.04.2026.
//

import UIKit

final class BookmarkTableCell: UITableViewCell {

    static let reuseID = "BookmarkTableCell"

    private let thumbnailView = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let bookmarkButton = UIButton()
    private var article: Article?

    var onUnsave: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = Theme.Color.background
        selectionStyle = .none

        let separator = UIView()
        separator.backgroundColor = Theme.Color.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)

        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = Theme.Radius.sm
        thumbnailView.backgroundColor = Theme.Color.inputBackground
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnailView)

        titleLabel.font = Theme.Font.rowTitle
        titleLabel.textColor = Theme.Color.textPrimary
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        metaLabel.font = Theme.Font.metadata
        metaLabel.textColor = Theme.Color.textTertiary
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(metaLabel)

        bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        bookmarkButton.tintColor = Theme.Color.accent
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bookmarkButton)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: contentView.topAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailView.heightAnchor.constraint(equalToConstant: 80),

            bookmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),
            bookmarkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 24),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: thumbnailView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: Theme.Spacing.sm),
            titleLabel.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -Theme.Spacing.sm),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Theme.Spacing.xs),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    func configure(with article: Article) {
        self.article = article
        titleLabel.text = article.title
        metaLabel.text = "\(article.source.name) · \(article.timeAgo)"

        thumbnailView.image = nil
        thumbnailView.backgroundColor = Theme.Color.accentDark
        if let url = article.imageURL {
            Task {
                let image = await ImageLoader.shared.loadImage(from: url)
                await MainActor.run { self.thumbnailView.image = image }
            }
        }
    }

    @objc private func bookmarkTapped() {
        guard let article else { return }
        article.unsave()
        onUnsave?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = nil
        titleLabel.text = nil
        metaLabel.text = nil
        onUnsave = nil
    }
}
