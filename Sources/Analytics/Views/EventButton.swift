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
    let action: () -> Void
    @ViewBuilder var label: Label

    public init(
        category: AnalyticCategory,
        object: String,
        verb: AnalyticVerbs,
        params: [String: Any] = [:],
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.category = category
        self.verb = verb
        self.object = object
        self.action = action
        self.label = label()
        self.params = params
    }

    public var body: some View {
#if DEBUG
        let mergedDict = (["type": "event", "is_devolpment": true] as! [String: Any]).merging(params) { _, new in new }
#else
        let mergedDict = (["type": "event", "is_devolpment": false] as! [String: Any]).merging(params) { _, new in new }
#endif
        
        
        Button(action: {
            Analytics.shared.track(event: "\(category):\(object)_\(verb.rawValue)", params: mergedDict)
            Superwall.shared.register(event: "\(category):\(object)_\(verb.rawValue)", params: mergedDict) {
                DispatchQueue.main.async {
                    action()
                }
            }
        }, label: {
            label
        })
        .buttonStyle(.plain)
    }
}
