import XCTest
@testable import AnalyticsPurchaseKit
@testable import Core

final class AnalyticsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Configure AnalyticsPurchaseKit for testing with valid test keys
        try? AnalyticsPurchaseKit.shared.configureDevelopment(
            posthogKey: "phc_test_key_1234567890",
            mixpanelKey: "test_mixpanel_token_1234567890",
            telemetryDeckAppID: "12345678-1234-1234-1234-123456789012",
            sentryDSN: "https://test@sentry.io/1234567",
            revenueCatAPIKey: "test_revenuecat_key_1234567890"
        )
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAnalyticsExists() {
        let analytics = Analytics.shared
        XCTAssertNotNil(analytics)
    }
    
    func testEventVerbCases() {
        // Test that all event verbs are available
        XCTAssertEqual(EventVerb.viewed.rawValue, "viewed")
        XCTAssertEqual(EventVerb.tapped.rawValue, "tapped")
        XCTAssertEqual(EventVerb.purchased.rawValue, "purchased")
        XCTAssertEqual(EventVerb.cancelled.rawValue, "cancelled")
        
        // Test that we have a reasonable number of verbs
        XCTAssertGreaterThan(EventVerb.allCases.count, 20)
    }
    
    func testValidEventTracking() throws {
        // Test valid event tracking
        try Analytics.shared.track(
            category: "user",
            object: "profile",
            verb: .viewed,
            params: ["user_id": "123"]
        )
        
        // Test with underscores in category and object
        try Analytics.shared.track(
            category: "user_action",
            object: "profile_page",
            verb: .tapped,
            params: ["section": "header"]
        )
    }
    
    func testInvalidCategoryValidation() {
        // Test empty category
        XCTAssertThrowsError(try Analytics.shared.track(
            category: "",
            object: "profile",
            verb: .viewed
        )) { error in
            XCTAssertTrue(error is AnalyticsError)
            if case .invalidCategory = error as? AnalyticsError {
                // Expected error type
            } else {
                XCTFail("Expected invalidCategory error")
            }
        }
        
        // Test category with special characters
        XCTAssertThrowsError(try Analytics.shared.track(
            category: "user-action",
            object: "profile",
            verb: .viewed
        )) { error in
            XCTAssertTrue(error is AnalyticsError)
        }
    }
    
    func testInvalidObjectValidation() {
        // Test empty object
        XCTAssertThrowsError(try Analytics.shared.track(
            category: "user",
            object: "",
            verb: .viewed
        )) { error in
            XCTAssertTrue(error is AnalyticsError)
            if case .invalidObject = error as? AnalyticsError {
                // Expected error type
            } else {
                XCTFail("Expected invalidObject error")
            }
        }
        
        // Test object with special characters
        XCTAssertThrowsError(try Analytics.shared.track(
            category: "user",
            object: "profile-page",
            verb: .viewed
        )) { error in
            XCTAssertTrue(error is AnalyticsError)
        }
    }
    
    func testCustomEventValidation() throws {
        // Test valid custom event
        try Analytics.shared.trackCustom(
            eventName: "user:profile_viewed",
            params: ["user_id": "123"]
        )
        
        // Test invalid format (missing colon)
        XCTAssertThrowsError(try Analytics.shared.trackCustom(
            eventName: "user_profile_viewed"
        )) { error in
            XCTAssertTrue(error is AnalyticsError)
            if case .invalidEventName = error as? AnalyticsError {
                // Expected error type
            } else {
                XCTFail("Expected invalidEventName error")
            }
        }
        
        // Test invalid format (missing action)
        XCTAssertThrowsError(try Analytics.shared.trackCustom(
            eventName: "user:profile"
        )) { error in
            XCTAssertTrue(error is AnalyticsError)
        }
    }
    
    func testConvenienceMethods() throws {
        // Test screen view tracking
        try Analytics.shared.trackScreenView("home", params: ["source": "navigation"])
        
        // Test button tap tracking
        try Analytics.shared.trackButtonTap("login", params: ["location": "header"])
        
        // Test purchase tracking
        try Analytics.shared.trackPurchase("premium_subscription", params: [
            "price": 9.99,
            "currency": "USD"
        ])
        
        // Test registration tracking
        try Analytics.shared.trackRegistration("email", params: ["source": "landing_page"])
        
        // Test search tracking
        try Analytics.shared.trackSearch("analytics SDK", params: ["category": "development"])
    }
    
    func testThreadSafety() {
        let expectation = XCTestExpectation(description: "Concurrent tracking")
        expectation.expectedFulfillmentCount = 10
        
        // Test concurrent event tracking
        for i in 0..<10 {
            DispatchQueue.global().async {
                do {
                    try Analytics.shared.track(
                        category: "test",
                        object: "concurrent_\(i)",
                        verb: .viewed,
                        params: ["thread": i]
                    )
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent tracking failed: \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFlushMethod() {
        // Test that flush method doesn't crash (it's now a no-op)
        Analytics.shared.flush()
        
        // Should be able to call multiple times
        Analytics.shared.flush()
        Analytics.shared.flush()
    }
} 