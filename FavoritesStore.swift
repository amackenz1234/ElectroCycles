//
//  FavoritesStore.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//

import Foundation
import Combine

public extension Notification.Name {
    static let favoritesStoreDidChange = Notification.Name("FavoritesStore.didChange")
}

@MainActor
public final class ElectroCyclesFavoritesStore: ObservableObject {
    public static let shared = ElectroCyclesFavoritesStore()
    
    public static let didChange = Notification.Name.favoritesStoreDidChange
    
    private let storageKey = "favorites.store.bikeIds"
    
    @Published private var bikeIds: Set<UUID> = []
    
    private init() {
        Task {
            await load()
        }
    }
    
    // MARK: - Public Interface
    
    public var count: Int {
        return bikeIds.count
    }
    
    public var isEmpty: Bool {
        return bikeIds.isEmpty
    }
    
    public var favoriteIds: Set<UUID> {
        return bikeIds
    }
    
    public var favoriteBikes: [Bike] {
        return Catalog.bikes.filter { bikeIds.contains($0.id) }
    }
    
    public func isFavorite(_ bikeId: UUID) -> Bool {
        return bikeIds.contains(bikeId)
    }
    
    public func isFavorite(_ bike: Bike) -> Bool {
        return bikeIds.contains(bike.id)
    }
    
    public func add(_ bikeId: UUID) {
        bikeIds.insert(bikeId)
        Task {
            await save()
        }
    }
    
    public func add(_ bike: Bike) {
        add(bike.id)
    }
    
    public func remove(_ bikeId: UUID) {
        bikeIds.remove(bikeId)
        Task {
            await save()
        }
    }
    
    public func remove(_ bike: Bike) {
        remove(bike.id)
    }
    
    public func toggle(_ bikeId: UUID) {
        if bikeIds.contains(bikeId) {
            remove(bikeId)
        } else {
            add(bikeId)
        }
    }
    
    public func toggle(_ bike: Bike) {
        toggle(bike.id)
    }
    
    public func clear() {
        bikeIds.removeAll()
        Task {
            await save()
        }
    }
    
    // MARK: - Persistence
    
    private func load() async {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: storageKey) {
            do {
                let decoded = try JSONDecoder().decode(Set<UUID>.self, from: data)
                self.bikeIds = decoded
            } catch {
                #if DEBUG
                print("⚠️ Failed to decode favorite bike IDs: \(error)")
                #endif
                self.bikeIds = []
            }
        }
    }
    
    private func save() async {
        if let data = try? JSONEncoder().encode(bikeIds) {
            UserDefaults.standard.set(data, forKey: storageKey)
            
            // Ensure notification is posted on main thread
            await MainActor.run {
                NotificationCenter.default.post(name: Self.didChange, object: self)
            }
        }
    }
}

// MARK: - Backward Compatibility
public typealias FavoritesStore = ElectroCyclesFavoritesStore