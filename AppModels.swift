//
//  AppModels.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//  All app models and stores in one file to avoid scope issues
//

import Foundation
import UIKit
import Combine

// MARK: - Bike Model
public struct Bike: Hashable, Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    public var price: Decimal
    public var imageSystemName: String
    public var assetImageName: String?

    public init(id: UUID = UUID(), name: String, description: String, price: Decimal, imageSystemName: String, assetImageName: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageSystemName = imageSystemName
        self.assetImageName = assetImageName
    }
}

// MARK: - Cart Item
public struct CartItem: Codable, Hashable, Identifiable {
    public let id: UUID
    public let bike: Bike
    public var quantity: Int
    
    public init(bike: Bike, quantity: Int = 1) {
        self.id = UUID()
        self.bike = bike
        self.quantity = quantity
    }
}

// MARK: - Notifications
public extension Notification.Name {
    static let cartStoreDidChange = Notification.Name("CartStore.didChange")
    static let favoritesStoreDidChange = Notification.Name("FavoritesStore.didChange")
}

// MARK: - Cart Store
@MainActor
public final class CartStore: ObservableObject {
    public static let shared = CartStore()
    public static let didChange = Notification.Name.cartStoreDidChange
    
    private let storageKey = "cart.store.items"
    @Published private var items: [CartItem] = []
    
    private init() {
        Task { await load() }
    }
    
    public var allItems: [CartItem] { items }
    public var isEmpty: Bool { items.isEmpty }
    public var totalPrice: Decimal {
        items.reduce(0) { total, item in
            total + (item.bike.price * Decimal(item.quantity))
        }
    }
    
    public func add(_ bike: Bike, quantity: Int = 1) {
        if let existingIndex = items.firstIndex(where: { $0.bike.id == bike.id }) {
            items[existingIndex].quantity += quantity
        } else {
            items.append(CartItem(bike: bike, quantity: quantity))
        }
        Task { await save() }
    }
    
    public func remove(_ bikeId: UUID) {
        items.removeAll { $0.bike.id == bikeId }
        Task { await save() }
    }
    
    public func updateQuantity(for bikeId: UUID, to quantity: Int) {
        if quantity <= 0 {
            remove(bikeId)
            return
        }
        if let index = items.firstIndex(where: { $0.bike.id == bikeId }) {
            items[index].quantity = quantity
            Task { await save() }
        }
    }
    
    public func clear() {
        items.removeAll()
        Task { await save() }
    }
    
    public func quantity(for bikeId: UUID) -> Int {
        items.first { $0.bike.id == bikeId }?.quantity ?? 0
    }
    
    private func load() async {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = decoded
        }
    }
    
    private func save() async {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
            await MainActor.run {
                NotificationCenter.default.post(name: Self.didChange, object: self)
            }
        }
    }
}

// MARK: - Favorites Store
@MainActor
public final class FavoritesStore: ObservableObject {
    public static let shared = FavoritesStore()
    public static let didChange = Notification.Name.favoritesStoreDidChange
    
    private let storageKey = "favorites.store.bikeIds"
    @Published private var bikeIds: Set<UUID> = []
    
    private init() {
        Task { await load() }
    }
    
    public var count: Int { bikeIds.count }
    public var isEmpty: Bool { bikeIds.isEmpty }
    public var favoriteIds: Set<UUID> { bikeIds }
    public var favoriteBikes: [Bike] {
        Catalog.bikes.filter { bikeIds.contains($0.id) }
    }
    
    public func isFavorite(_ bikeId: UUID) -> Bool { bikeIds.contains(bikeId) }
    public func isFavorite(_ bike: Bike) -> Bool { bikeIds.contains(bike.id) }
    
    public func add(_ bikeId: UUID) {
        bikeIds.insert(bikeId)
        Task { await save() }
    }
    
    public func add(_ bike: Bike) { add(bike.id) }
    
    public func remove(_ bikeId: UUID) {
        bikeIds.remove(bikeId)
        Task { await save() }
    }
    
    public func remove(_ bike: Bike) { remove(bike.id) }
    
    public func toggle(_ bikeId: UUID) {
        if bikeIds.contains(bikeId) { remove(bikeId) } else { add(bikeId) }
    }
    
    public func toggle(_ bike: Bike) { toggle(bike.id) }
    
    public func clear() {
        bikeIds.removeAll()
        Task { await save() }
    }
    
    private func load() async {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            bikeIds = decoded
        }
    }
    
    private func save() async {
        if let data = try? JSONEncoder().encode(bikeIds) {
            UserDefaults.standard.set(data, forKey: storageKey)
            await MainActor.run {
                NotificationCenter.default.post(name: Self.didChange, object: self)
            }
        }
    }
}

// MARK: - Catalog
public enum Catalog {
    private static let _bikes: [Bike] = [
        Bike(
            id: UUID(uuidString: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11") ?? UUID(),
            name: "Evoque Atom",
            description: "72V powerhouse built for raw power and smooth handling.",
            price: 1999,
            imageSystemName: "bicycle",
            assetImageName: "evoque_atom"
        ),
        Bike(
            id: UUID(uuidString: "B1FFCD99-9D1C-5EF9-CC7E-7CC0CE491B22") ?? UUID(),
            name: "Lightning Bolt", 
            description: "Engineered for speed and efficiency with aerodynamic design.",
            price: 1599,
            imageSystemName: "bolt.circle",
            assetImageName: nil
        ),
        Bike(
            id: UUID(uuidString: "C2FFDE99-9E2D-6EF0-DD8F-8DD1DF502C33") ?? UUID(),
            name: "Urban Cruiser",
            description: "Perfect for leisurely city rides with comfort and style.",
            price: 1299,
            imageSystemName: "bicycle.circle",
            assetImageName: nil
        ),
        Bike(
            id: UUID(uuidString: "D3EEEF99-9F3E-7EE1-EE9F-9EE2EF613D44") ?? UUID(),
            name: "Mountain Explorer",
            description: "Rugged e-bike with all-terrain capabilities and full suspension.",
            price: 2299,
            imageSystemName: "mountain.2",
            assetImageName: nil
        )
    ]
    
    public static var bikes: [Bike] { _bikes }
}

// MARK: - Formatting
enum Formatting {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        return f
    }()
}