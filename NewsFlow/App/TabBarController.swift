//
//  TabBarController.swift
//  NewsFlow
//
//  Created by Anatolii Semenchuk on 26.04.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.Color.barBackground
        
        appearance.stackedLayoutAppearance.normal.iconColor = Theme.Color.textTertiary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: Theme.Color.textTertiary,
            .font: Theme.Font.regular(10)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = Theme.Color.accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: Theme.Color.accent,
            .font: Theme.Font.medium(10)
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTabs() {
        let feed = makeTab(root: FeedViewController(),title: "Feed", image: "newspaper", tag: 0)
        let search = makeTab(root: SearchViewController(), title: "Search", image: "magnifyingglass",    tag: 1)
        let bookmarks = makeTab(root: BookmarksViewController(), title: "Saved", image: "bookmark",           tag: 2)
        
        viewControllers = [feed, search, bookmarks]
    }
    
    private func makeTab(root: UIViewController, title: String, image: String, tag: Int) -> UINavigationController {
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            tag: tag
        )
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.tintColor = Theme.Color.accent
        return nav
    }
}
