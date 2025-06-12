//
//  ScreenCaptureModifier.swift
//  Analytics
//
//  Created by Fynn Bandemer on 1/25/25.
//

import PostHog
import SwiftUI

struct ScreenCaptureModifier: ViewModifier {
    let title: String
    func body(content: Content) -> some View {
        content
            .postHogScreenView(title)
    }
}

public extension View {
    func tagScreenTitle(_ title: String) -> some View {
        modifier(ScreenCaptureModifier(title: title))
    }
}
