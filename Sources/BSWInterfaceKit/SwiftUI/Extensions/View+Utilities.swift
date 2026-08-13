//
//  Created by Michele Restuccia on 25/2/26.
//

import SwiftUI

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

#if canImport(UIKit.UIViewController)

import UIKit

@MainActor
public extension SwiftUI.View {
    /// Generates a `UIViewController` from this `SwiftUI.View`
    func asViewController() -> UIViewController {
        return UIHostingController(rootView: self)
    }
}

#endif

public extension View {
    
    /// Expands the hit-testing area of a `Button` to the full view on iOS.
    /// Not required on Android, where the default behavior already covers the whole view.
    @ViewBuilder
    func contentRectangleShape() -> some View {
        #if canImport(Darwin)
        self.contentShape(Rectangle())
        #else
        self
        #endif
    }
}

public extension View {
    func errorAlert(error: Binding<Error?>) -> some View {
        modifier(ErrorAwareView(errorBinding: error))
    }
    
    func isRunningInPreview() -> Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

struct ErrorAwareView: ViewModifier {
    
    let errorBinding: Binding<Error?>
    
    func body(content: Content) -> some View {
        content
            .alert(
                "error".localized,
                isPresented: .init(get: {
                    errorBinding.wrappedValue != nil
                }, set: { value in
                    if value == false {
                        withAnimation {
                            errorBinding.wrappedValue = nil
                        }
                    }
                }),
                presenting: errorBinding.wrappedValue,
                actions: { error in
                    Button("dismiss".localized, action: { })
                }, message: {
                    if let localizedError = $0 as? LocalizedError,
                       let failureReason = localizedError.errorDescription {
                        Text(failureReason)
                    } else {
                        Text("Something went wrong")
                    }
                }
            )
    }
}
