//
//  File.swift
//  Analytics
//
//  Created by Fynn Bandemer on 1/25/25.
//

import Foundation
#if os(iOS)
import UIKit
#endif

public enum HapticMode {
    case none
    case light
    case medium
    case heavy
}

extension HapticMode {
    func play() {
        #if os(iOS)
        switch self {
        case .none:
            return
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        #else
        // Haptic feedback is not available on macOS
        return
        #endif
    }
}
