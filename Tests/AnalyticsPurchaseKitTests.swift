import XCTest
@testable import AnalyticsPurchaseKit

final class AnalyticsPurchaseKitTests: XCTestCase {
    
    func testPackageStructure() {
        // Test that the main class can be instantiated
        let analytics = AnalyticsPurchaseKit.shared
        XCTAssertNotNil(analytics)
    }
    
    func testEnvironmentEnum() {
        // Test that Environment enum works correctly
        let devEnv = AnalyticsPurchaseKit.Environment.development
        let prodEnv = AnalyticsPurchaseKit.Environment.production
        
        XCTAssertNotEqual(devEnv, prodEnv)
    }
    
    func testPaywallManagerExists() {
        // Test that PaywallManager can be accessed
        let paywallManager = PaywallManager.shared
        XCTAssertNotNil(paywallManager)
    }
    
    // Additional tests will be added as functionality is implemented
} 