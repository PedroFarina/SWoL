//
//  IAPManager.swift
//  Swol
//
//  Created by Pedro Giuliano Farina on 28/12/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import StoreKit
import SwolBackEnd

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

open class IAPHelper: NSObject  {

    private let productIdentifiers: Set<ProductIdentifier>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    public static let shared = IAPHelper(productIds: ["SwolDevCoffee"])
    private init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        super.init()

        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API

extension IAPHelper {

    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    public func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction)
            case .failed:
                completeTransaction(transaction)
            case .restored:
                completeTransaction(transaction)
            default:
                break
            }
        }
    }
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
           transactionError.code != SKError.paymentCancelled.rawValue {
            DataManager.shared(with: iCloudAccessManager.permission).conflictHandler.errDidOccur(err: transactionError)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
