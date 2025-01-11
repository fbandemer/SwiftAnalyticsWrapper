//
//  RCPurchaseController.swift
//  
//
//  Created by Fynn Bandemer on 24.02.24.
//

import SuperwallKit
import RevenueCat
import StoreKit

enum PurchasingError: Error {
  case productNotFound
}

final class RCPurchaseController: PurchaseController {
    var userDefault: UserDefaults
    let isProUDKey: String = "isPro"
    
    init(userDefault: UserDefaults) {
        self.userDefault = userDefault
    }
    
    // MARK: Sync Subscription Status
    /// Makes sure that Superwall knows the customers subscription status by
    /// changing `Superwall.shared.subscriptionStatus`
    func syncSubscriptionStatus() {
        assert(Purchases.isConfigured, "You must configure RevenueCat before calling this method.")
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                // Gets called whenever new CustomerInfo is available
                let hasActiveSubscription = !customerInfo.entitlements.active.isEmpty // Why? -> https://www.revenuecat.com/docs/entitlements#entitlements
                if hasActiveSubscription {
                    Superwall.shared.subscriptionStatus = .active
                    userDefault.set(true, forKey: isProUDKey)
                    
                } else {
                    Superwall.shared.subscriptionStatus = .inactive
                    userDefault.set(false, forKey: isProUDKey)
                }
            }
        }
    }
    
    // MARK: Handle Purchases
    /// Makes a purchase with RevenueCat and returns its result. This gets called when
    /// someone tries to purchase a product on one of your paywalls.
    func purchase(product: SKProduct) async -> PurchaseResult {
        do {
          guard let storeProduct = await Purchases.shared.products([product.productIdentifier]).first else {
            throw PurchasingError.productNotFound
          }
          // This must be initialized before initiating the purchase.
          let purchaseDate = Date()
          let revenueCatResult = try await Purchases.shared.purchase(product: storeProduct)
          if revenueCatResult.userCancelled {
            return .cancelled
          } else {
            if let transaction = revenueCatResult.transaction,
               purchaseDate > transaction.purchaseDate {
              return .restored
            } else {
              return .purchased
            }
          }
        } catch let error as ErrorCode {
          if error == .paymentPendingError {
            return .pending
          } else {
            return .failed(error)
          }
        } catch {
          return .failed(error)
        }
      }
    
    // MARK: Handle Restores
    /// Makes a restore with RevenueCat and returns `.restored`, unless an error is thrown.
    /// This gets called when someone tries to restore purchases on one of your paywalls.
    func restorePurchases() async -> RestorationResult {
        do {
            _ = try await Purchases.shared.restorePurchases()
            return .restored
        } catch let error {
            return .failed(error)
        }
    }
}
