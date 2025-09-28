//
//  CartStore.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//

import Foundation
import Combine

public extension Notification.Name {
    static let cartStoreDidChange = Notification.Name("CartStore.didChange")
}

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

@MainActor
public final class ElectroCyclesCartStore: ObservableObject {
    public static let shared = ElectroCyclesCartStore()
    
    public static let didChange = Notification.Name.cartStoreDidChange
    
    private let storageKey = "cart.store.items"
    
    @Published private var items: [CartItem] = []
    
    private init() {
        Task {
            await load()
        }
    }
    
    // MARK: - Public Interface
    
    public var allItems: [CartItem] {
        return items
    }
    
    public var isEmpty: Bool {
        return items.isEmpty
    }
    
    public var totalPrice: Decimal {
        return items.reduce(0) { total, item in
            total + (item.bike.price * Decimal(item.quantity))
        }
    }
    
    public func add(_ bike: Bike, quantity: Int = 1) {
        if let existingIndex = items.firstIndex(where: { $0.bike.id == bike.id }) {
            items[existingIndex].quantity += quantity
        } else {
            let newItem = CartItem(bike: bike, quantity: quantity)
            items.append(newItem)
        }
        
        Task {
            await save()
        }
    }
    
    public func remove(_ bikeId: UUID) {
        items.removeAll { $0.bike.id == bikeId }
        Task {
            await save()
        }
    }
    
    public func updateQuantity(for bikeId: UUID, to quantity: Int) {
        if quantity <= 0 {
            remove(bikeId)
            return
        }
        
        if let index = items.firstIndex(where: { $0.bike.id == bikeId }) {
            items[index].quantity = quantity
            Task {
                await save()
            }
        }
    }
    
    public func clear() {
        items.removeAll()
        Task {
            await save()
        }
    }
    
    public func quantity(for bikeId: UUID) -> Int {
        return items.first { $0.bike.id == bikeId }?.quantity ?? 0
    }
    
    // MARK: - Persistence
    
    private func load() async {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: storageKey) {
            do {
                let decoded = try JSONDecoder().decode([CartItem].self, from: data)
                self.items = decoded
            } catch {
                #if DEBUG
                print("⚠️ Failed to decode cart items: \(error)")
                #endif
                self.items = []
            }
        }
    }
    
    private func save() async {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
            
            // Ensure notification is posted on main thread
            await MainActor.run {
                NotificationCenter.default.post(name: Self.didChange, object: self)
            }
        }
    }
}

// MARK: - Backward Compatibility
public typealias CartStore = ElectroCyclesCartStore