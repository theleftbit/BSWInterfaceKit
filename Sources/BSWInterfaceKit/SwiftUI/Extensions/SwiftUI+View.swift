
import SwiftUI

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
                }, message: { err in
                    if ModuleDependencies.enhancedErrorLogs {
                        Text("Something went wrong")
                    } else {
                        if let localizedError = err as? LocalizedError,
                           let failureReason = localizedError.errorDescription {
                            if !ModuleDependencies.enhancedErrorLogs, let range = failureReason.range(of: #"\"message\":\"([^\"]+)\""#, options: .regularExpression) {
                                let extractedMessage = String(failureReason[range])
                                    .replacingOccurrences(of: "\"message\":\"", with: "")
                                    .replacingOccurrences(of: "\"", with: "")
                                Text(extractedMessage)
                            } else {
                                Text(failureReason)
                            }
                        } else {
                            Text("Something went wrong")
                        }
                    }
                }
            )
    }
}

public enum ModuleDependencies {
    public static nonisolated(unsafe) var enhancedErrorLogs: Bool = true
}
