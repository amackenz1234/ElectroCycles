//
//  MainTabBarController.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupCartBadge()
    }

    private func setupTabs() {
        // Catalog Tab
        let catalogVC = CatalogViewController()
        let catalogNav = UINavigationController(rootViewController: catalogVC)
        catalogNav.tabBarItem = UITabBarItem(
            title: "Shop",
            image: UIImage(systemName: "bicycle"),
            selectedImage: UIImage(systemName: "bicycle.circle.fill")
        )

        // Favorites Tab
        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        // Cart Tab
        let cartVC = CartViewController()
        let cartNav = UINavigationController(rootViewController: cartVC)
        cartNav.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )

        // Orders Tab
        let ordersVC = OrdersViewController()
        let ordersNav = UINavigationController(rootViewController: ordersVC)
        ordersNav.tabBarItem = UITabBarItem(
            title: "Orders",
            image: UIImage(systemName: "shippingbox"),
            selectedImage: UIImage(systemName: "shippingbox.fill")
        )

        viewControllers = [catalogNav, favoritesNav, cartNav, ordersNav]
    }

    private func setupCartBadge() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCartBadge),
            name: CartStore.didChange,
            object: nil
        )
        updateCartBadge()
    }

    @objc private func updateCartBadge() {
        Task { @MainActor in
            let count = CartStore.shared.allItems.reduce(0) { $0 + $1.quantity }
            viewControllers?[2].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
        }
    }
}
