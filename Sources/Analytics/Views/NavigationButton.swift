//
//  NavigationButton.swift
//  Packages
//
//  Created by Fynn Bandemer on 8/10/24.
//

import SwiftUI

public struct AnalyticsNavigationButton<Label: View>: View {
    public typealias AnalyticCategory = String
    public typealias AnalyticObject = String
    let category: AnalyticCategory
    let verb: AnalyticVerbs
    let object: AnalyticObject
    let params: [String: Any]
    let rowAlignment: VerticalAlignment
    let action: () -> Void
    @ViewBuilder var label: Label

    public init(
        category: AnalyticCategory,
        object: String,
        verb: AnalyticVerbs,
        params: [String: Any] = [:],
        rowAlignment: VerticalAlignment = .center,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.category = category
        self.verb = verb
        self.object = object
        self.action = action
        self.label = label()
        self.params = params
        self.rowAlignment = rowAlignment
    }

    public var body: some View {
        #if DEBUG
            let mergedDict = (["button_type": "navigation", "is_devolpment": true] as! [String: Any]).merging(params) { _, new in new }
        #else
            let mergedDict = (["button_type": "navigation", "is_devolpment": false] as! [String: Any]).merging(params) { _, new in new }
        #endif
        let placement = "\(category):\(object)_\(verb.rawValue)"
        Button(action: {
            Analytics.shared.track(event: placement, params: mergedDict)
            #if canImport(SuperwallKit)
                if Analytics.shared.isSuperwallEnabled {
                    Superwall.shared.register(placement: placement, params: mergedDict) {
                        DispatchQueue.main.async {
                            action()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        action()
                    }
                }
            #else
                DispatchQueue.main.async {
                    action()
                }
            #endif
        }, label: {
            HStack(alignment: rowAlignment) {
                label
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.system(.footnote).weight(.bold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .contentShape(.rect)
        })
    }
}
