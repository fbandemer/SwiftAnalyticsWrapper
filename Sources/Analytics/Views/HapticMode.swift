//
//  File.swift
//  Analytics
//
//  Created by Fynn Bandemer on 1/25/25.
//

import Foundation
import UIKit

public enum HapticMode {
    case none
    case light
    case medium
    case heavy
}

extension HapticMode {
    @MainActor
    func play() {
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
    }
}
