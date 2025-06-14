//
//  NavigationButton.swift
//  Packages
//
//  Created by Fynn Bandemer on 8/10/24.
//

import SwiftUI

public struct NavigationButton<Label: View>: View {
    public typealias AnalyticCategory = String
    public typealias AnalyticObject = String
    let category: AnalyticCategory
    let verb: AnalyticVerbs
    let object: AnalyticObject
    let params: [String: Any]
    let rowAlignment: VerticalAlignment
    let buttonStyle: any ButtonStyle
    let action: () -> Void
    @ViewBuilder var label: Label

    public init(
        category: AnalyticCategory,
        object: String,
        verb: AnalyticVerbs,
        params: [String: Any] = [:],
        rowAlignment: VerticalAlignment = .center,
        buttonStyle: any ButtonStyle = .plain,
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
        self.buttonStyle = buttonStyle
    }

    public var body: some View {
#if DEBUG
        let mergedDict = (["button_type": "navigation", "is_devolpment": true] as! [String: Any]).merging(params) { _, new in new }
#else
        let mergedDict = (["button_type": "navigation", "is_devolpment": false] as! [String: Any]).merging(params) { _, new in new }
#endif
        Button(action: {
            Analytics.shared.track(event: "\(category):\(object)_\(verb.rawValue)", params: mergedDict)
            Superwall.shared.register(placement: "\(category):\(object)_\(verb.rawValue)", params: mergedDict) {
                DispatchQueue.main.async {
                    action()
                }
            }
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
        .buttonStyle(buttonStyle)
    }
}
