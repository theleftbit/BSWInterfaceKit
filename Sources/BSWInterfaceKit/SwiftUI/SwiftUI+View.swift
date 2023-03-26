
#if canImport(UIKit)

import SwiftUI

public extension SwiftUI.View {
    func asViewController() -> UIViewController {
        return UIHostingController(rootView: self)
    }
}

#endif

extension View {
    func errorAlert(error: Binding<Error?>) -> some View {
        ErrorAwareView(errorBinding: error, content: self)
    }
}

private struct ErrorAwareView<T: View>: View {
    
    let errorBinding: Binding<Error?>
    let content: T

    var body: some View {
        content
            .alert(
                "error".localized,
                isPresented: .init(get: {
                    errorBinding.wrappedValue != nil
                }, set: { value in
                    if value == false {
                        errorBinding.wrappedValue = nil
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
