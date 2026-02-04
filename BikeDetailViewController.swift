//
//  BikeDetailViewController.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import UIKit
import PassKit

final class BikeDetailViewController: UIViewController {

    private let bike: Bike
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let quantityStepper = UIStepper()
    private let quantityLabel = UILabel()
    private let addToCartButton = UIButton(type: .system)
    private var applePayButton: PKPaymentButton?

    private var quantity: Int = 1

    init(bike: Bike) {
        self.bike = bike
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        configureContent()
    }

    private func setupNavigationBar() {
        title = bike.name

        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        navigationItem.rightBarButtonItem = favoriteButton
        updateFavoriteButton()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // Name
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        // Price
        priceLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        priceLabel.textColor = .systemGreen
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)

        // Description
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // Quantity section
        let quantityContainer = UIView()
        quantityContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityContainer)

        let quantityTitleLabel = UILabel()
        quantityTitleLabel.text = "Quantity"
        quantityTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        quantityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityContainer.addSubview(quantityTitleLabel)

        quantityLabel.text = "1"
        quantityLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityContainer.addSubview(quantityLabel)

        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityStepper.addTarget(self, action: #selector(quantityChanged), for: .valueChanged)
        quantityStepper.translatesAutoresizingMaskIntoConstraints = false
        quantityContainer.addSubview(quantityStepper)

        // Add to cart button
        addToCartButton.setTitle("Add to Cart", for: .normal)
        addToCartButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        addToCartButton.backgroundColor = .systemRed
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.layer.cornerRadius = 12
        addToCartButton.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addToCartButton)

        // Apple Pay button
        if ApplePayManager.canMakePayments {
            let payButton = ApplePayManager.createApplePayButton(type: .buy, style: .automatic)
            payButton.addTarget(self, action: #selector(buyWithApplePay), for: .touchUpInside)
            payButton.translatesAutoresizingMaskIntoConstraints = false
            payButton.layer.cornerRadius = 12
            payButton.clipsToBounds = true
            contentView.addSubview(payButton)
            applePayButton = payButton
        }

        // Layout
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            quantityContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            quantityContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quantityContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quantityContainer.heightAnchor.constraint(equalToConstant: 44),

            quantityTitleLabel.leadingAnchor.constraint(equalTo: quantityContainer.leadingAnchor),
            quantityTitleLabel.centerYAnchor.constraint(equalTo: quantityContainer.centerYAnchor),

            quantityStepper.trailingAnchor.constraint(equalTo: quantityContainer.trailingAnchor),
            quantityStepper.centerYAnchor.constraint(equalTo: quantityContainer.centerYAnchor),

            quantityLabel.trailingAnchor.constraint(equalTo: quantityStepper.leadingAnchor, constant: -12),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityContainer.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 30),

            addToCartButton.topAnchor.constraint(equalTo: quantityContainer.bottomAnchor, constant: 32),
            addToCartButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addToCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addToCartButton.heightAnchor.constraint(equalToConstant: 54)
        ])

        if let applePayButton = applePayButton {
            NSLayoutConstraint.activate([
                applePayButton.topAnchor.constraint(equalTo: addToCartButton.bottomAnchor, constant: 12),
                applePayButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                applePayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                applePayButton.heightAnchor.constraint(equalToConstant: 54),
                applePayButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
            ])
        } else {
            addToCartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32).isActive = true
        }
    }

    private func configureContent() {
        imageView.image = UIImage(systemName: bike.imageSystemName)
        nameLabel.text = bike.name
        descriptionLabel.text = bike.description

        if let formatted = Formatting.currency.string(from: bike.price as NSDecimalNumber) {
            priceLabel.text = formatted
        } else {
            priceLabel.text = "$\(bike.price)"
        }
    }

    @objc private func quantityChanged() {
        quantity = Int(quantityStepper.value)
        quantityLabel.text = "\(quantity)"
    }

    @objc private func addToCart() {
        Task { @MainActor in
            CartStore.shared.add(bike, quantity: quantity)

            // Show confirmation
            let alert = UIAlertController(
                title: "Added to Cart",
                message: "\(quantity) x \(bike.name) added to your cart.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Continue Shopping", style: .default))
            alert.addAction(UIAlertAction(title: "View Cart", style: .cancel) { [weak self] _ in
                self?.tabBarController?.selectedIndex = 2
            })
            present(alert, animated: true)
        }
    }

    @objc private func buyWithApplePay() {
        let cartItem = CartItem(bike: bike, quantity: quantity)
        ApplePayManager.shared.startPayment(for: [cartItem], from: self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let order):
                let alert = UIAlertController(
                    title: "Order Placed",
                    message: "Your order #\(order.id.uuidString.prefix(8)) has been placed successfully.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "View Orders", style: .default) { _ in
                    self.tabBarController?.selectedIndex = 3
                })
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)

            case .cancelled:
                break

            case .failed(let error):
                let alert = UIAlertController(
                    title: "Payment Failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    @objc private func toggleFavorite() {
        Task { @MainActor in
            FavoritesStore.shared.toggle(bike.id)
            updateFavoriteButton()
        }
    }

    private func updateFavoriteButton() {
        Task { @MainActor in
            let isFavorite = FavoritesStore.shared.isFavorite(bike.id)
            let imageName = isFavorite ? "heart.fill" : "heart"
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
        }
    }
}
