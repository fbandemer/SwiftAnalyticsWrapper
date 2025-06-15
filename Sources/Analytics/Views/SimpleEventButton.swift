//
//  SimpleEventButton.swift
//  Packages
//
//  Created by Fynn Bandemer on 8/10/24.
//

import SwiftUI

public struct SimpleEventButton: View {
    public typealias AnalyticCategory = String
    public typealias AnalyticObject = String
    let category: AnalyticCategory
    let verb: AnalyticVerbs
    let object: AnalyticObject
    let params: [String: Any]
    let haptic: HapticMode
    let title: String
    let systemImage: String?
    let action: () -> Void

    public init(
        category: AnalyticCategory,
        object: String,
        verb: AnalyticVerbs,
        params: [String: Any] = [:],
        haptic: HapticMode = .none,
        title: String,
        systemImage: String? = nil,
        action: @escaping () -> Void,
    ) {
        self.category = category
        self.verb = verb
        self.object = object
        self.action = action
        self.params = params
        self.haptic = haptic
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
#if DEBUG
        let mergedDict = (["button_type": "event", "is_devolpment": true] as! [String: Any]).merging(params) { _, new in new }
#else
        let mergedDict = (["button_type": "event", "is_devolpment": false] as! [String: Any]).merging(params) { _, new in new }
#endif
        if let systemImage {
            Button(title, systemImage: systemImage) {
                haptic.play()
                Analytics.shared.track(event: "\(category):\(object)_\(verb.rawValue)", params: mergedDict)
                Superwall.shared.register(placement: "\(category):\(object)_\(verb.rawValue)", params: mergedDict) {
                    DispatchQueue.main.async {
                        action()
                    }
                }
            }
        } else {
            Button(title) {
                haptic.play()
                Analytics.shared.track(event: "\(category):\(object)_\(verb.rawValue)", params: mergedDict)
                Superwall.shared.register(placement: "\(category):\(object)_\(verb.rawValue)", params: mergedDict) {
                    DispatchQueue.main.async {
                        action()
                    }
                }
            }
        }
    }
}
