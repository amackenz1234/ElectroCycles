//
//  AppModels.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//  Shared models and catalog data
//

import Foundation
import UIKit

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