//
//  ElectroCyclesTypes.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//  Consolidated type definitions to fix scope issues
//

import Foundation
import UIKit
import Combine

// Re-export all the main types to ensure they're visible across the module
@_exported import Foundation

// Ensure all main app types are accessible
public typealias AppCartStore = ElectroCyclesCartStore
public typealias AppFavoritesStore = ElectroCyclesFavoritesStore
public typealias AppBike = Bike
public typealias AppCartItem = CartItem

