//
//  RCPurchaseController.swift
//  
//
//  Created by Fynn Bandemer on 24.02.24.
//

import SuperwallKit
import RevenueCat
import StoreKit

enum PurchasingError: LocalizedError {
  case sk2ProductNotFound

  var errorDescription: String? {
    switch self {
    case .sk2ProductNotFound:
      return "Superwall didn't pass a StoreKit 2 product to purchase. Are you sure you're not "
        + "configuring Superwall with a SuperwallOption to use StoreKit 1?"
    }
  }
}

final class RCPurchaseController: PurchaseController {
    var userDefault: UserDefaults
    let isProUDKey: String = "isPro"
    
    init(userDefault: UserDefaults) {
        self.userDefault = userDefault
    }
    
    
  // MARK: Sync Subscription Status
  /// Makes sure that Superwall knows the customer's entitlements by
  /// changing `Superwall.shared.entitlements`
  func syncSubscriptionStatus() {
    assert(Purchases.isConfigured, "You must configure RevenueCat before calling this method.")
    Task {

      for await customerInfo in Purchases.shared.customerInfoStream {
        // Gets called whenever new CustomerInfo is available
        let superwallEntitlements = customerInfo.entitlements.activeInCurrentEnvironment.keys.map {
          Entitlement(id: $0)
        }
        await MainActor.run { [superwallEntitlements] in
          Superwall.shared.subscriptionStatus = .active(Set(superwallEntitlements))
        }
      }
    }
  }

  // MARK: Handle Purchases
  /// Makes a purchase with RevenueCat and returns its result. This gets called when
  /// someone tries to purchase a product on one of your paywalls.
  func purchase(product: SuperwallKit.StoreProduct) async -> PurchaseResult {
    do {
      guard let sk2Product = product.sk2Product else {
        throw PurchasingError.sk2ProductNotFound
      }
      let storeProduct = RevenueCat.StoreProduct(sk2Product: sk2Product)
      let revenueCatResult = try await Purchases.shared.purchase(product: storeProduct)
      if revenueCatResult.userCancelled {
          userDefault.set(false, forKey: isProUDKey)
        return .cancelled
      } else {
          userDefault.set(true, forKey: isProUDKey)
        return .purchased
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
