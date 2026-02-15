//
//  CartViewController.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import UIKit
import PassKit

final class CartViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let footerView = CartFooterView()
    private var cartItems: [CartItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupFooter()
        setupNotifications()
        loadCart()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCart()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Cart"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearCart)
        )
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupFooter() {
        view.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.delegate = self

        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: CartStore.didChange,
            object: nil
        )
    }

    @objc private func cartDidChange() {
        loadCart()
    }

    private func loadCart() {
        Task { @MainActor in
            cartItems = CartStore.shared.allItems
            tableView.reloadData()
            updateEmptyState()
            footerView.updateTotal(CartStore.shared.totalPrice)
            footerView.isHidden = cartItems.isEmpty
            navigationItem.rightBarButtonItem?.isEnabled = !cartItems.isEmpty
        }
    }

    private func updateEmptyState() {
        if cartItems.isEmpty {
            tableView.backgroundView = createEmptyStateView()
        } else {
            tableView.backgroundView = nil
        }
    }

    private func createEmptyStateView() -> UIView {
        let containerView = UIView()

        let imageView = UIImageView(image: UIImage(systemName: "cart"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Your Cart is Empty"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Browse our catalog and add some bikes!"
        subtitleLabel.font = .systemFont(ofSize: 16)
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

    @objc private func clearCart() {
        let alert = UIAlertController(
            title: "Clear Cart",
            message: "Are you sure you want to remove all items from your cart?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            Task { @MainActor in
                CartStore.shared.clear()
            }
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartItemCell.reuseIdentifier,
            for: indexPath
        ) as? CartItemCell else {
            return UITableViewCell()
        }

        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = cartItems[indexPath.row]
        let detailVC = BikeDetailViewController(bike: item.bike)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = cartItems[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { _, _, completion in
            Task { @MainActor in
                CartStore.shared.remove(item.bike.id)
                completion(true)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - CartItemCellDelegate

extension CartViewController: CartItemCellDelegate {
    func cartItemCell(_ cell: CartItemCell, didUpdateQuantity quantity: Int, for bikeId: UUID) {
        Task { @MainActor in
            CartStore.shared.updateQuantity(for: bikeId, to: quantity)
        }
    }
}

// MARK: - CartFooterViewDelegate

extension CartViewController: CartFooterViewDelegate {
    func cartFooterViewDidTapCheckout(_ view: CartFooterView) {
        ApplePayManager.shared.startPaymentFromCart(from: self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let order):
                let alert = UIAlertController(
                    title: "Order Placed!",
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
}

// MARK: - Cart Item Cell

protocol CartItemCellDelegate: AnyObject {
    func cartItemCell(_ cell: CartItemCell, didUpdateQuantity quantity: Int, for bikeId: UUID)
}

final class CartItemCell: UITableViewCell {
    static let reuseIdentifier = "CartItemCell"

    weak var delegate: CartItemCellDelegate?

    private let bikeImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let quantityStepper = UIStepper()
    private let quantityLabel = UILabel()

    private var currentItem: CartItem?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        accessoryType = .disclosureIndicator

        bikeImageView.contentMode = .scaleAspectFit
        bikeImageView.tintColor = .systemRed
        bikeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bikeImageView)

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .systemGreen
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)

        quantityLabel.font = .systemFont(ofSize: 14, weight: .medium)
        quantityLabel.textAlignment = .center
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityLabel)

        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.addTarget(self, action: #selector(quantityChanged), for: .valueChanged)
        quantityStepper.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityStepper)

        NSLayoutConstraint.activate([
            bikeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bikeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bikeImageView.widthAnchor.constraint(equalToConstant: 60),
            bikeImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: bikeImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: quantityStepper.leadingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: bikeImageView.trailingAnchor, constant: 12),

            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quantityLabel.leadingAnchor.constraint(equalTo: bikeImageView.trailingAnchor, constant: 12),

            quantityStepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quantityStepper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    func configure(with item: CartItem) {
        currentItem = item
        nameLabel.text = item.bike.name
        bikeImageView.image = UIImage(systemName: item.bike.imageSystemName)
        quantityStepper.value = Double(item.quantity)
        quantityLabel.text = "Qty: \(item.quantity)"

        let total = item.bike.price * Decimal(item.quantity)
        if let formatted = Formatting.currency.string(from: total as NSDecimalNumber) {
            priceLabel.text = formatted
        } else {
            priceLabel.text = "$\(total)"
        }
    }

    @objc private func quantityChanged() {
        guard let item = currentItem else { return }
        let quantity = Int(quantityStepper.value)
        quantityLabel.text = "Qty: \(quantity)"
        delegate?.cartItemCell(self, didUpdateQuantity: quantity, for: item.bike.id)
    }
}

// MARK: - Cart Footer View

protocol CartFooterViewDelegate: AnyObject {
    func cartFooterViewDidTapCheckout(_ view: CartFooterView)
}

final class CartFooterView: UIView {

    weak var delegate: CartFooterViewDelegate?

    private let totalLabel = UILabel()
    private let totalAmountLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    private var applePayButton: PKPaymentButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemBackground
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 4

        totalLabel.text = "Total"
        totalLabel.font = .systemFont(ofSize: 16)
        totalLabel.textColor = .secondaryLabel
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalLabel)

        totalAmountLabel.font = .systemFont(ofSize: 24, weight: .bold)
        totalAmountLabel.textColor = .label
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalAmountLabel)

        if ApplePayManager.canMakePayments {
            let payButton = ApplePayManager.createApplePayButton(type: .checkout, style: .automatic)
            payButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
            payButton.translatesAutoresizingMaskIntoConstraints = false
            payButton.layer.cornerRadius = 12
            payButton.clipsToBounds = true
            addSubview(payButton)
            applePayButton = payButton

            NSLayoutConstraint.activate([
                totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

                totalAmountLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 4),
                totalAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

                payButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                payButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                payButton.widthAnchor.constraint(equalToConstant: 150),
                payButton.heightAnchor.constraint(equalToConstant: 50),
                payButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ])
        } else {
            checkoutButton.setTitle("Checkout", for: .normal)
            checkoutButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            checkoutButton.backgroundColor = .systemRed
            checkoutButton.setTitleColor(.white, for: .normal)
            checkoutButton.layer.cornerRadius = 12
            checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
            checkoutButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(checkoutButton)

            NSLayoutConstraint.activate([
                totalLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                totalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

                totalAmountLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 4),
                totalAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

                checkoutButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                checkoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                checkoutButton.widthAnchor.constraint(equalToConstant: 150),
                checkoutButton.heightAnchor.constraint(equalToConstant: 50),
                checkoutButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
            ])
        }
    }

    func updateTotal(_ total: Decimal) {
        if let formatted = Formatting.currency.string(from: total as NSDecimalNumber) {
            totalAmountLabel.text = formatted
        } else {
            totalAmountLabel.text = "$\(total)"
        }
    }

    @objc private func checkoutTapped() {
        delegate?.cartFooterViewDidTapCheckout(self)
    }
}
