//
//  BookmarksViewController.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit

final class BookmarksViewController: UIViewController {

    private let viewModel = BookmarksViewModel()
    private var tableView: UITableView!
    private let emptyStateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Color.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupTableView()
        setupEmptyState()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.load()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = Theme.Color.background
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookmarkTableCell.self, forCellReuseIdentifier: BookmarkTableCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyStateLabel.text = "No saved articles yet"
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

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            tableView.reloadData()
            emptyStateLabel.isHidden = !viewModel.articles.isEmpty
        }
    }
}

extension BookmarksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkTableCell.reuseID, for: indexPath) as! BookmarkTableCell
        let article = viewModel.articles[indexPath.row]
        cell.configure(with: article)
        cell.onUnsave = { [weak self] in
            self?.viewModel.remove(article: article)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.remove(article: viewModel.articles[indexPath.row])
    }
}

extension BookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = DetailViewController(article: viewModel.articles[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}
