//
//  HeroArticleCell.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit

final class HeroArticleCell: UICollectionViewCell {

    static let reuseID = "HeroArticleCell"

    private let imageView = UIImageView()
    private let gradientLayer = CAGradientLayer()
    private let tagLabel = PaddedLabel()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        layer.cornerRadius = Theme.Radius.lg
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Theme.Color.inputBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            Theme.Color.heroOverlay.withAlphaComponent(0.9).cgColor
        ]
        gradientLayer.locations = [0.3, 1.0]
        contentView.layer.addSublayer(gradientLayer)

        tagLabel.font = Theme.Font.tag
        tagLabel.textColor = .white
        tagLabel.backgroundColor = Theme.Color.accent
        tagLabel.layer.cornerRadius = Theme.Radius.sm
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagLabel)

        titleLabel.font = Theme.Font.heroHeadline
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        metaLabel.font = Theme.Font.metadata
        metaLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(metaLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Theme.Spacing.md),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            tagLabel.heightAnchor.constraint(equalToConstant: 22),

            metaLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Theme.Spacing.md),
            metaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            metaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md),

            titleLabel.bottomAnchor.constraint(equalTo: metaLabel.topAnchor, constant: -Theme.Spacing.xs),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Spacing.md),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Spacing.md)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    func configure(with article: Article) {
        titleLabel.text = article.title
        metaLabel.text = "\(article.source.name) · \(article.timeAgo)"
        tagLabel.text = "FEATURED"

        if let url = article.imageURL {
            Task {
                let image = await ImageLoader.shared.loadImage(from: url)
                await MainActor.run { self.imageView.image = image }
            }
        } else {
            imageView.image = nil
            imageView.backgroundColor = Theme.Color.accentDark
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
