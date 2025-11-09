import SwiftUI
import RevenueCatUI

struct CustomerCenterContainerView: View {
    var body: some View {
#if canImport(RevenueCatUI)
        CustomerCenterView()
#else
        EmptyView()
#endif
    }
}


