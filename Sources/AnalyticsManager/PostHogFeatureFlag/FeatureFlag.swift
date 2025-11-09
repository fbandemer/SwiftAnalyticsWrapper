//
//  File.swift
//  Analytics
//
//  Created by Fynn Bandemer on 1/5/25.
//

import Foundation
import PostHog

final public class FeatureFlag {
    static public func isEnabled(_ feature: String) -> Bool {
        if PostHogSDK.shared.isFeatureEnabled(feature) {
            
            return true
        }
        return false
    }
    
    static public func isEnabledWithPayload(_ feature: String) -> (Bool, Any?) {
        if PostHogSDK.shared.isFeatureEnabled(feature) {
            let matchedFlagPayload = PostHogSDK.shared.getFeatureFlagPayload(feature)
            return (true, matchedFlagPayload)
        }
        return (false, nil)
    }
    
    static public func getFeatureFlag(_ feature: String) -> String? {
        PostHogSDK.shared.getFeatureFlag(feature) as? String
    }
    
    static public func isEnabledVariant(_ feature: String, variant: String) -> Bool {
        if (PostHogSDK.shared.getFeatureFlag(feature) as? String == variant) {
            return true
        }
        return false
    }
    static public func isEnabledVariantPayload(_ feature: String, variant: String) -> (Bool, Any?)  {
        if (PostHogSDK.shared.getFeatureFlag(feature) as? String == variant) {
            let matchedFlagPayload = PostHogSDK.shared.getFeatureFlagPayload(feature)
            return (true, matchedFlagPayload)
        }
        return (false, nil)
    }
}
