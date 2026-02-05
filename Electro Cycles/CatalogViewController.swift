//
//  CatalogViewController.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import UIKit

final class CatalogViewController: UIViewController {

    private let collectionView: UICollectionView
    private var bikes: [Bike] = []

    init() {
        let layout = Self.createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadBikes()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Electro Cycles"
        navigationController?.navigationBar.prefersLargeTitles = true

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(showSearch)
        )
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(showWhatsNew)
        )
        navigationItem.rightBarButtonItems = [infoButton, searchButton]
    }

    private static func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                // Banner section
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(180)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(180)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 16, trailing: 20)
                return section
            } else {
                // Products grid section
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .estimated(320)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(320)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 32, trailing: 12)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(56)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]

                return section
            }
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BikeCell.self, forCellWithReuseIdentifier: BikeCell.reuseIdentifier)
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseIdentifier)
        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseIdentifier
        )

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadBikes() {
        bikes = Catalog.bikes
        collectionView.reloadData()
    }

    @objc private func showWhatsNew() {
        let whatsNewVC = WhatsNewViewController(version: "1.1")
        let navController = UINavigationController(rootViewController: whatsNewVC)
        present(navController, animated: true)
    }

    @objc private func showSearch() {
        let alert = UIAlertController(title: "Search", message: "Search functionality coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension CatalogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : bikes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BannerCell.reuseIdentifier,
                for: indexPath
            ) as? BannerCell else {
                return UICollectionViewCell()
            }
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BikeCell.reuseIdentifier,
            for: indexPath
        ) as? BikeCell else {
            return UICollectionViewCell()
        }

        let bike = bikes[indexPath.item]
        cell.configure(with: bike)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeader.reuseIdentifier,
            for: indexPath
        ) as? SectionHeader else {
            return UICollectionReusableView()
        }

        header.configure(title: "Featured E-Bikes")
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let bike = bikes[indexPath.item]
        let detailVC = BikeDetailViewController(bike: bike)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Banner Cell

final class BannerCell: UICollectionViewCell {
    static let reuseIdentifier = "BannerCell"

    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    private func setupCell() {
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        // Gradient background
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemRed.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)

        // Icon
        iconView.image = UIImage(systemName: "bicycle")
        iconView.tintColor = .white.withAlphaComponent(0.3)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconView)

        // Title
        titleLabel.text = "Spring Sale"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "Up to 20% off on select e-bikes"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 140),
            iconView.heightAnchor.constraint(equalToConstant: 140),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -16),

            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -16)
        ])
    }
}

// MARK: - Section Header

final class SectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeader"

    private let titleLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(seeAllButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            seeAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            seeAllButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Bike Cell

final class BikeCell: UICollectionViewCell {
    static let reuseIdentifier = "BikeCell"

    private let containerView = UIView()
    private let imageContainerView = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let addToCartButton = UIButton(type: .system)

    private var currentBike: Bike?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        // Container
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Image container with gradient
        imageContainerView.backgroundColor = .systemGray6
        imageContainerView.layer.cornerRadius = 16
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageContainerView)

        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.addSubview(imageView)

        // Favorite button
        favoriteButton.tintColor = .systemRed
        favoriteButton.backgroundColor = .systemBackground
        favoriteButton.layer.cornerRadius = 16
        favoriteButton.layer.shadowColor = UIColor.black.cgColor
        favoriteButton.layer.shadowOpacity = 0.1
        favoriteButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        favoriteButton.layer.shadowRadius = 4
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        containerView.addSubview(favoriteButton)

        // Name
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)

        // Description
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)

        // Price
        priceLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.textColor = .systemRed
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(priceLabel)

        // Add to cart button
        addToCartButton.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        addToCartButton.tintColor = .white
        addToCartButton.backgroundColor = .systemRed
        addToCartButton.layer.cornerRadius = 17
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        addToCartButton.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
        containerView.addSubview(addToCartButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            imageContainerView.heightAnchor.constraint(equalToConstant: 140),

            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            favoriteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),

            nameLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),

            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            addToCartButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            addToCartButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            addToCartButton.widthAnchor.constraint(equalToConstant: 34),
            addToCartButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    func configure(with bike: Bike) {
        currentBike = bike
        nameLabel.text = bike.name
        descriptionLabel.text = bike.description
        imageView.image = UIImage(systemName: bike.imageSystemName)

        if let formatted = Formatting.currency.string(from: bike.price as NSDecimalNumber) {
            priceLabel.text = formatted
        } else {
            priceLabel.text = "$\(bike.price)"
        }

        updateFavoriteButton()
    }

    private func updateFavoriteButton() {
        guard let bike = currentBike else { return }
        Task { @MainActor in
            let isFavorite = FavoritesStore.shared.isFavorite(bike.id)
            let imageName = isFavorite ? "heart.fill" : "heart"
            favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    @objc private func toggleFavorite() {
        guard let bike = currentBike else { return }
        Task { @MainActor in
            FavoritesStore.shared.toggle(bike.id)
            updateFavoriteButton()
        }
    }

    @objc private func addToCart() {
        guard let bike = currentBike else { return }
        Task { @MainActor in
            CartStore.shared.add(bike)
            // Animate button
            UIView.animate(withDuration: 0.1, animations: {
                self.addToCartButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.addToCartButton.transform = .identity
                }
            }
        }
    }
}
