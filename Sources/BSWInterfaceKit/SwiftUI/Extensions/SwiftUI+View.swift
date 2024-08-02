
import SwiftUI

#if canImport(UIKit)

import UIKit

@MainActor
public extension SwiftUI.View {
    /// Generates a `UIViewController` from this `SwiftUI.View`
    func asViewController() -> UIViewController {
        return UIHostingController(rootView: self)
    }
}

#endif

import SwiftUI

public extension View {
    func errorAlert(error: Binding<Error?>) -> some View {
        modifier(ErrorAwareView(errorBinding: error))
    }
    
    func isRunningInPreview() -> Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

private struct ErrorAwareView: ViewModifier {
    
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
