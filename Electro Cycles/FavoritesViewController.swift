//
//  FavoritesViewController.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//

import UIKit

final class FavoritesViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var favoriteBikes: [Bike] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        
        // Add navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllFavorites)
        )
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadFavorites() {
        Task { @MainActor in
            favoriteBikes = FavoritesStore.shared.favoriteBikes
            tableView.reloadData()
            updateEmptyState()
        }
    }
    
    private func updateEmptyState() {
        if favoriteBikes.isEmpty {
            let emptyView = createEmptyStateView()
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func createEmptyStateView() -> UIView {
        let containerView = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "No Favorites Yet"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Tap the heart icon on any bike to add it to your favorites"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    @objc private func clearAllFavorites() {
        let alert = UIAlertController(
            title: "Clear All Favorites",
            message: "Are you sure you want to remove all bikes from your favorites?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            Task { @MainActor in
                FavoritesStore.shared.clear()
                self?.loadFavorites()
            }
        })

        present(alert, animated: true)
    }

    private func toggleFavorite(for bike: Bike) {
        Task { @MainActor in
            FavoritesStore.shared.toggle(bike)
            loadFavorites()
        }
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteBikes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let bike = favoriteBikes[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = bike.name
        config.secondaryText = Formatting.currency.string(from: bike.price as NSDecimalNumber)
        config.image = UIImage(systemName: bike.imageSystemName)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let bike = favoriteBikes[indexPath.row]
        let detailVC = BikeDetailViewController(bike: bike)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bike = favoriteBikes[indexPath.row]
        
        let removeAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            self?.toggleFavorite(for: bike)
            completion(true)
        }
        removeAction.image = UIImage(systemName: "heart.slash")
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}