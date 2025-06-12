import XCTest
@testable import AnalyticsPurchaseKit

final class AnalyticsPurchaseKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Reset configuration state before each test
        // Note: In a real implementation, we might need a reset method for testing
    }
    
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
        XCTAssertTrue(devEnv.isDebug)
        XCTAssertFalse(prodEnv.isDebug)
        XCTAssertEqual(devEnv.rawValue, "development")
        XCTAssertEqual(prodEnv.rawValue, "production")
    }
    
    func testPaywallManagerExists() {
        // Test that PaywallManager can be accessed
        let paywallManager = PaywallManager.shared
        XCTAssertNotNil(paywallManager)
    }
    
    func testConfigurationValidation() {
        let analytics = AnalyticsPurchaseKit.shared
        
        // Test that configuration fails with invalid keys
        XCTAssertThrowsError(try analytics.configure(
            posthogKey: "", // Empty key should fail
            mixpanelKey: "valid_mixpanel_key_12345",
            telemetryDeckAppID: "12345678-1234-1234-1234-123456789012",
            sentryDSN: "https://example@sentry.io/123456",
            revenueCatAPIKey: "valid_revenuecat_key_12345"
        )) { error in
            XCTAssertTrue(error is AnalyticsPurchaseKit.ConfigurationError)
        }
        
        // Test that configuration fails with invalid Sentry DSN
        XCTAssertThrowsError(try analytics.configure(
            posthogKey: "valid_posthog_key_12345",
            mixpanelKey: "valid_mixpanel_key_12345", 
            telemetryDeckAppID: "12345678-1234-1234-1234-123456789012",
            sentryDSN: "invalid_sentry_dsn", // Should start with https://
            revenueCatAPIKey: "valid_revenuecat_key_12345"
        )) { error in
            XCTAssertTrue(error is AnalyticsPurchaseKit.ConfigurationError)
        }
        
        // Test that configuration fails with invalid TelemetryDeck UUID
        XCTAssertThrowsError(try analytics.configure(
            posthogKey: "valid_posthog_key_12345",
            mixpanelKey: "valid_mixpanel_key_12345",
            telemetryDeckAppID: "invalid_uuid", // Should be valid UUID
            sentryDSN: "https://example@sentry.io/123456",
            revenueCatAPIKey: "valid_revenuecat_key_12345"
        )) { error in
            XCTAssertTrue(error is AnalyticsPurchaseKit.ConfigurationError)
        }
    }
    
    func testConfigurationState() {
        let analytics = AnalyticsPurchaseKit.shared
        
        // Initially should not be configured
        XCTAssertFalse(analytics.configured)
        XCTAssertNil(analytics.currentEnvironment)
    }
    
    func testPaywallManagerRequiresConfiguration() {
        let paywallManager = PaywallManager.shared
        
        // Should throw error when not configured
        XCTAssertThrowsError(try paywallManager.presentIfNeeded()) { error in
            XCTAssertTrue(error is AnalyticsPurchaseKit.ConfigurationError)
        }
        
        XCTAssertThrowsError(try paywallManager.present()) { error in
            XCTAssertTrue(error is AnalyticsPurchaseKit.ConfigurationError)
        }
    }
    
    func testPaywallManagerAvailability() {
        let paywallManager = PaywallManager.shared
        
        #if os(iOS)
        // On iOS, availability depends on configuration and Superwall key
        // Since we're not configured, it should be false
        XCTAssertFalse(paywallManager.isAvailable)
        #elseif os(macOS)
        // On macOS, should always be false
        XCTAssertFalse(paywallManager.isAvailable)
        #endif
    }
    
    func testConfigurationErrorDescriptions() {
        let alreadyConfiguredError = AnalyticsPurchaseKit.ConfigurationError.alreadyConfigured
        let invalidKeyError = AnalyticsPurchaseKit.ConfigurationError.invalidAPIKey(service: "TestService")
        let missingKeyError = AnalyticsPurchaseKit.ConfigurationError.missingRequiredKey(service: "TestService")
        let configFailedError = AnalyticsPurchaseKit.ConfigurationError.configurationFailed(service: "TestService", reason: "Test reason")
        
        XCTAssertNotNil(alreadyConfiguredError.errorDescription)
        XCTAssertNotNil(invalidKeyError.errorDescription)
        XCTAssertNotNil(missingKeyError.errorDescription)
        XCTAssertNotNil(configFailedError.errorDescription)
        
        XCTAssertTrue(alreadyConfiguredError.errorDescription!.contains("already been configured"))
        XCTAssertTrue(invalidKeyError.errorDescription!.contains("TestService"))
        XCTAssertTrue(missingKeyError.errorDescription!.contains("TestService"))
        XCTAssertTrue(configFailedError.errorDescription!.contains("TestService"))
        XCTAssertTrue(configFailedError.errorDescription!.contains("Test reason"))
    }
    
    // Additional tests will be added as functionality is implemented
} 