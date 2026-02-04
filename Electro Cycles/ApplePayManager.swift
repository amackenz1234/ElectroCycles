//
//  ApplePayManager.swift
//  Electro Cycles
//
//  Created by Assistant on 2026-02-04.
//

import Foundation
import PassKit
import UIKit

// MARK: - Apple Pay Configuration

public enum ApplePayConfiguration {
    static let merchantIdentifier = "merchant.com.electrocycles.app"
    static let countryCode = "US"
    static let currencyCode = "USD"

    static let supportedNetworks: [PKPaymentNetwork] = [
        .visa,
        .masterCard,
        .amex,
        .discover
    ]

    static let merchantCapabilities: PKMerchantCapability = [
        .capability3DS,
        .capabilityDebit,
        .capabilityCredit
    ]
}

// MARK: - Apple Pay Result

public enum ApplePayResult {
    case success(order: Order)
    case cancelled
    case failed(Error)
}

// MARK: - Apple Pay Error

public enum ApplePayError: LocalizedError {
    case notAvailable
    case noPaymentMethods
    case emptyCart
    case paymentFailed(String)

    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Pay is not available on this device."
        case .noPaymentMethods:
            return "No payment methods are configured. Please add a card in Wallet."
        case .emptyCart:
            return "Your cart is empty."
        case .paymentFailed(let reason):
            return "Payment failed: \(reason)"
        }
    }
}

// MARK: - Apple Pay Manager

@MainActor
public final class ApplePayManager: NSObject, ObservableObject {
    public static let shared = ApplePayManager()

    @Published public private(set) var isProcessing = false

    private var paymentCompletion: ((ApplePayResult) -> Void)?
    private var currentCartItems: [CartItem] = []

    private override init() {
        super.init()
    }

    // MARK: - Availability Check

    public static var isApplePayAvailable: Bool {
        return PKPaymentAuthorizationViewController.canMakePayments()
    }

    public static var canMakePayments: Bool {
        return PKPaymentAuthorizationViewController.canMakePayments(
            usingNetworks: ApplePayConfiguration.supportedNetworks,
            capabilities: ApplePayConfiguration.merchantCapabilities
        )
    }

    public static var availabilityStatus: String {
        if !isApplePayAvailable {
            return "Apple Pay is not supported on this device"
        }
        if !canMakePayments {
            return "No payment cards configured"
        }
        return "Ready"
    }

    // MARK: - Payment Request

    public func startPayment(
        for cartItems: [CartItem],
        from viewController: UIViewController,
        completion: @escaping (ApplePayResult) -> Void
    ) {
        guard Self.isApplePayAvailable else {
            completion(.failed(ApplePayError.notAvailable))
            return
        }

        guard !cartItems.isEmpty else {
            completion(.failed(ApplePayError.emptyCart))
            return
        }

        self.paymentCompletion = completion
        self.currentCartItems = cartItems

        let request = createPaymentRequest(for: cartItems)

        guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            completion(.failed(ApplePayError.notAvailable))
            return
        }

        paymentVC.delegate = self
        isProcessing = true
        viewController.present(paymentVC, animated: true)
    }

    public func startPaymentFromCart(
        from viewController: UIViewController,
        completion: @escaping (ApplePayResult) -> Void
    ) {
        let cartItems = CartStore.shared.allItems
        startPayment(for: cartItems, from: viewController, completion: completion)
    }

    // MARK: - Payment Request Creation

    private func createPaymentRequest(for cartItems: [CartItem]) -> PKPaymentRequest {
        let request = PKPaymentRequest()

        request.merchantIdentifier = ApplePayConfiguration.merchantIdentifier
        request.countryCode = ApplePayConfiguration.countryCode
        request.currencyCode = ApplePayConfiguration.currencyCode
        request.supportedNetworks = ApplePayConfiguration.supportedNetworks
        request.merchantCapabilities = ApplePayConfiguration.merchantCapabilities

        // Create payment summary items
        var summaryItems: [PKPaymentSummaryItem] = []

        for item in cartItems {
            let itemTotal = item.bike.price * Decimal(item.quantity)
            let label = item.quantity > 1 ? "\(item.bike.name) x\(item.quantity)" : item.bike.name
            let summaryItem = PKPaymentSummaryItem(
                label: label,
                amount: NSDecimalNumber(decimal: itemTotal)
            )
            summaryItems.append(summaryItem)
        }

        // Calculate subtotal
        let subtotal = cartItems.reduce(Decimal(0)) { $0 + ($1.bike.price * Decimal($1.quantity)) }

        // Add shipping (free for now)
        let shipping = PKPaymentSummaryItem(
            label: "Shipping",
            amount: NSDecimalNumber(decimal: 0)
        )
        summaryItems.append(shipping)

        // Add tax (estimated at 8%)
        let taxRate = Decimal(0.08)
        let tax = subtotal * taxRate
        let taxItem = PKPaymentSummaryItem(
            label: "Estimated Tax",
            amount: NSDecimalNumber(decimal: tax)
        )
        summaryItems.append(taxItem)

        // Final total
        let total = subtotal + tax
        let totalItem = PKPaymentSummaryItem(
            label: "Electro Cycles",
            amount: NSDecimalNumber(decimal: total),
            type: .final
        )
        summaryItems.append(totalItem)

        request.paymentSummaryItems = summaryItems

        // Require shipping address for bike delivery
        request.requiredShippingContactFields = [
            .name,
            .postalAddress,
            .emailAddress,
            .phoneNumber
        ]

        // Require billing address
        request.requiredBillingContactFields = [
            .name,
            .postalAddress
        ]

        // Shipping methods
        request.shippingMethods = createShippingMethods()
        request.shippingType = .delivery

        return request
    }

    private func createShippingMethods() -> [PKShippingMethod] {
        let standard = PKShippingMethod(
            label: "Standard Delivery",
            amount: NSDecimalNumber(decimal: 0)
        )
        standard.identifier = "standard"
        standard.detail = "Delivery in 5-7 business days"

        let express = PKShippingMethod(
            label: "Express Delivery",
            amount: NSDecimalNumber(decimal: 49.99)
        )
        express.identifier = "express"
        express.detail = "Delivery in 2-3 business days"

        let premium = PKShippingMethod(
            label: "Premium Delivery",
            amount: NSDecimalNumber(decimal: 99.99)
        )
        premium.identifier = "premium"
        premium.detail = "Next business day delivery"

        return [standard, express, premium]
    }

    // MARK: - Process Payment

    private func processPayment(_ payment: PKPayment) async -> Bool {
        // Simulate payment processing
        // In production, send payment.token to your payment processor
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 second delay

        // Payment token data would be sent to server
        let _ = payment.token.paymentData

        // For demo purposes, always succeed
        return true
    }

    private func completeOrder() -> Order {
        let order = OrdersStore.shared.placeOrder(from: currentCartItems)
        CartStore.shared.clear()
        return order
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension ApplePayManager: PKPaymentAuthorizationViewControllerDelegate {

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        Task { @MainActor in
            let success = await processPayment(payment)

            if success {
                let order = completeOrder()
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))

                // Store completion to call after dismissal
                let storedCompletion = paymentCompletion
                paymentCompletion = { _ in
                    storedCompletion?(.success(order: order))
                }
            } else {
                let error = ApplePayError.paymentFailed("Transaction could not be completed")
                completion(PKPaymentAuthorizationResult(
                    status: .failure,
                    errors: [error]
                ))
            }
        }
    }

    public func paymentAuthorizationViewControllerDidFinish(
        _ controller: PKPaymentAuthorizationViewController
    ) {
        isProcessing = false
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            if let completion = self.paymentCompletion {
                // If we haven't already called completion with success,
                // the user cancelled
                completion(.cancelled)
            }

            self.paymentCompletion = nil
            self.currentCartItems = []
        }
    }

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelectShippingMethod shippingMethod: PKShippingMethod,
        handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
    ) {
        // Recalculate total with new shipping
        var items = createPaymentRequest(for: currentCartItems).paymentSummaryItems

        // Update the total to include shipping
        if let lastIndex = items.indices.last,
           let subtotalIndex = items.indices.dropLast().last {

            let subtotal = items[subtotalIndex].amount.decimalValue
            let shippingCost = shippingMethod.amount.decimalValue
            let newTotal = subtotal + shippingCost

            items[lastIndex] = PKPaymentSummaryItem(
                label: "Electro Cycles",
                amount: NSDecimalNumber(decimal: newTotal),
                type: .final
            )
        }

        let update = PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: items)
        completion(update)
    }
}

// MARK: - Apple Pay Button Helper

public extension ApplePayManager {

    static func createApplePayButton(
        type: PKPaymentButtonType = .buy,
        style: PKPaymentButtonStyle = .automatic
    ) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: type, paymentButtonStyle: style)
    }

    static func createSetupButton(
        style: PKPaymentButtonStyle = .automatic
    ) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: style)
    }
}
