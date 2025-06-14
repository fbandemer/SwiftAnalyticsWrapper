//
//  EventButton.swift
//  Packages
//
//  Created by Fynn Bandemer on 8/10/24.
//

import SwiftUI

public struct EventButton<Label: View>: View {
    public typealias AnalyticCategory = String
    public typealias AnalyticObject = String
    let category: AnalyticCategory
    let verb: AnalyticVerbs
    let object: AnalyticObject
    let params: [String: Any]
    let haptic: HapticMode
    let action: () -> Void
    @ViewBuilder var label: Label

    public init(
        category: AnalyticCategory,
        object: String,
        verb: AnalyticVerbs,
        params: [String: Any] = [:],
        haptic: HapticMode = .none,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.category = category
        self.verb = verb
        self.object = object
        self.action = action
        self.label = label()
        self.params = params
        self.haptic = haptic
    }

    public var body: some View {
#if DEBUG
        let mergedDict = (["button_type": "event", "is_devolpment": true] as! [String: Any]).merging(params) { _, new in new }
#else
        let mergedDict = (["button_type": "event", "is_devolpment": false] as! [String: Any]).merging(params) { _, new in new }
#endif
        Button(action: {
            haptic.play()
            Analytics.shared.track(event: "\(category):\(object)_\(verb.rawValue)", params: mergedDict)
            Superwall.shared.register(placement: "\(category):\(object)_\(verb.rawValue)", params: mergedDict) {
                DispatchQueue.main.async {
                    action()
                }
            }
        }, label: {
            label
        })
    }
}
