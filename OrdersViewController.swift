//
//  OrdersViewController.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import UIKit

final class OrdersViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var orders: [Order] = []

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNotifications()
        loadOrders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOrders()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Orders"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllOrders)
        )
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ordersDidChange),
            name: OrdersStore.didChange,
            object: nil
        )
    }

    @objc private func ordersDidChange() {
        loadOrders()
    }

    private func loadOrders() {
        Task { @MainActor in
            orders = OrdersStore.shared.recentOrders
            tableView.reloadData()
            updateEmptyState()
        }
    }

    private func updateEmptyState() {
        if orders.isEmpty {
            tableView.backgroundView = createEmptyStateView()
        } else {
            tableView.backgroundView = nil
        }
    }

    private func createEmptyStateView() -> UIView {
        let containerView = UIView()

        let imageView = UIImageView(image: UIImage(systemName: "shippingbox"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "No Orders Yet"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your order history will appear here after you complete a purchase"
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

    @objc private func clearAllOrders() {
        let alert = UIAlertController(
            title: "Clear Order History",
            message: "Are you sure you want to remove all orders from your history?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            Task { @MainActor in
                OrdersStore.shared.clear()
                self?.loadOrders()
            }
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension OrdersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseIdentifier, for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }

        let order = orders[indexPath.row]
        cell.configure(with: order, dateFormatter: dateFormatter)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension OrdersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let order = orders[indexPath.row]
        let detailVC = OrderDetailViewController(order: order)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let order = orders[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            Task { @MainActor in
                OrdersStore.shared.remove(order.id)
                self?.loadOrders()
                completion(true)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Order Cell

final class OrderCell: UITableViewCell {
    static let reuseIdentifier = "OrderCell"

    private let orderIdLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    private let totalLabel = UILabel()
    private let itemCountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        accessoryType = .disclosureIndicator

        orderIdLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        orderIdLabel.textColor = .label

        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel

        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .right

        totalLabel.font = .systemFont(ofSize: 16, weight: .bold)
        totalLabel.textColor = .systemGreen
        totalLabel.textAlignment = .right

        itemCountLabel.font = .systemFont(ofSize: 13)
        itemCountLabel.textColor = .secondaryLabel

        let leftStack = UIStackView(arrangedSubviews: [orderIdLabel, dateLabel, itemCountLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let rightStack = UIStackView(arrangedSubviews: [totalLabel, statusLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.distribution = .equalSpacing
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with order: Order, dateFormatter: DateFormatter) {
        let shortId = order.id.uuidString.prefix(8)
        orderIdLabel.text = "Order #\(shortId)"
        dateLabel.text = dateFormatter.string(from: order.orderDate)

        let itemCount = order.items.reduce(0) { $0 + $1.quantity }
        itemCountLabel.text = "\(itemCount) item\(itemCount == 1 ? "" : "s")"

        if let formattedPrice = Formatting.currency.string(from: order.totalPrice as NSDecimalNumber) {
            totalLabel.text = formattedPrice
        } else {
            totalLabel.text = "$\(order.totalPrice)"
        }

        statusLabel.text = order.status.rawValue
        statusLabel.textColor = statusColor(for: order.status)
    }

    private func statusColor(for status: OrderStatus) -> UIColor {
        switch status {
        case .confirmed: return .systemBlue
        case .processing: return .systemOrange
        case .shipped: return .systemPurple
        case .delivered: return .systemGreen
        case .cancelled: return .systemRed
        }
    }
}

// MARK: - Order Detail View Controller

final class OrderDetailViewController: UIViewController {

    private let order: Order
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    init(order: Order) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        let shortId = order.id.uuidString.prefix(8)
        title = "Order #\(shortId)"
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Order Detail Data Source

extension OrderDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3 // Status, Date, Total
        case 1: return order.items.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Order Info"
        case 1: return "Items"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.selectionStyle = .none

        var config = cell.defaultContentConfiguration()

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                config.text = "Status"
                config.secondaryText = order.status.rawValue
            case 1:
                config.text = "Date"
                config.secondaryText = dateFormatter.string(from: order.orderDate)
            case 2:
                config.text = "Total"
                if let formatted = Formatting.currency.string(from: order.totalPrice as NSDecimalNumber) {
                    config.secondaryText = formatted
                } else {
                    config.secondaryText = "$\(order.totalPrice)"
                }
            default: break
            }

        case 1:
            let item = order.items[indexPath.row]
            config.text = item.bike.name
            config.secondaryText = "Qty: \(item.quantity)"
            config.image = UIImage(systemName: item.bike.imageSystemName)

        default: break
        }

        cell.contentConfiguration = config
        return cell
    }
}
