//
//  OrdersStore.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import Foundation
import Combine

// MARK: - Order Model

public struct Order: Codable, Hashable, Identifiable {
    public let id: UUID
    public let items: [OrderItem]
    public let totalPrice: Decimal
    public let orderDate: Date
    public var status: OrderStatus

    public init(id: UUID = UUID(), items: [OrderItem], totalPrice: Decimal, orderDate: Date = Date(), status: OrderStatus = .confirmed) {
        self.id = id
        self.items = items
        self.totalPrice = totalPrice
        self.orderDate = orderDate
        self.status = status
    }

    public static func fromCart(_ cartItems: [CartItem]) -> Order {
        let orderItems = cartItems.map { OrderItem(bike: $0.bike, quantity: $0.quantity) }
        let total = cartItems.reduce(Decimal(0)) { $0 + ($1.bike.price * Decimal($1.quantity)) }
        return Order(items: orderItems, totalPrice: total)
    }
}

public struct OrderItem: Codable, Hashable, Identifiable {
    public let id: UUID
    public let bike: Bike
    public let quantity: Int

    public init(id: UUID = UUID(), bike: Bike, quantity: Int) {
        self.id = id
        self.bike = bike
        self.quantity = quantity
    }
}

public enum OrderStatus: String, Codable, CaseIterable {
    case confirmed = "Confirmed"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}

// MARK: - Notification

public extension Notification.Name {
    static let ordersStoreDidChange = Notification.Name("OrdersStore.didChange")
}

// MARK: - Orders Store

@MainActor
public final class OrdersStore: ObservableObject {
    public static let shared = OrdersStore()
    public static let didChange = Notification.Name.ordersStoreDidChange

    private let storageKey = "orders.store.items"
    @Published private var orders: [Order] = []

    private init() {
        Task { await load() }
    }

    // MARK: - Public Interface

    public var allOrders: [Order] { orders }
    public var isEmpty: Bool { orders.isEmpty }
    public var count: Int { orders.count }

    public var recentOrders: [Order] {
        orders.sorted { $0.orderDate > $1.orderDate }
    }

    public func order(withId id: UUID) -> Order? {
        orders.first { $0.id == id }
    }

    public func placeOrder(from cartItems: [CartItem]) -> Order {
        let order = Order.fromCart(cartItems)
        orders.append(order)
        Task { await save() }
        return order
    }

    public func add(_ order: Order) {
        orders.append(order)
        Task { await save() }
    }

    public func updateStatus(for orderId: UUID, to status: OrderStatus) {
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            orders[index].status = status
            Task { await save() }
        }
    }

    public func cancel(_ orderId: UUID) {
        updateStatus(for: orderId, to: .cancelled)
    }

    public func remove(_ orderId: UUID) {
        orders.removeAll { $0.id == orderId }
        Task { await save() }
    }

    public func clear() {
        orders.removeAll()
        Task { await save() }
    }

    // MARK: - Persistence

    private func load() async {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            orders = decoded
        }
    }

    private func save() async {
        if let data = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(data, forKey: storageKey)
            await MainActor.run {
                NotificationCenter.default.post(name: Self.didChange, object: self)
            }
        }
    }
}
