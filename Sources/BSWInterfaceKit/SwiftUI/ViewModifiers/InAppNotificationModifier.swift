#if canImport(UIKit.UIViewController)

import SwiftUI

@available(iOS 17, macOS 14, *)
#Preview {
    @Previewable
    @State
    var state: AttributedString? = nil
    
    Button {
        state = AttributedString("Successfull")
    } label: {
        Text("Tap me")
    }
    .inAppNotification(message: $state)
}

public extension SwiftUI.View {
    
    /// Presents an in-app notification as an overlay on the current view.
    /// The notification displays a message with customizable text color and background color.
    /// - Parameters:
    ///   - message: A binding to an `AttributedString` that triggers the notification when set. Setting it to `nil` dismisses the notification.
    ///   - backgroundColor: The color of the notification's background. Defaults to `.green`.
    func inAppNotification(
        message: Binding<AttributedString?>,
        backgroundColor: UIColor = .green
    ) -> some View {
        self.modifier(InAppToastModifier(
            isPresented: message,
            backgroundColor: backgroundColor
        ))
    }
}

private struct InAppToastModifier: ViewModifier {
    
    let isPresented: Binding<AttributedString?>
    let backgroundColor: UIColor
    @State private var anchorView = UIView()
    
    func body(content: Content) -> some View {
        if let value = isPresented.wrappedValue {
            presentPopover(value: value)
        }
        
        return content
            .background(InternalAnchorView(uiView: anchorView))
    }
    
    func presentPopover(value: AttributedString) {
        let view = anchorView
        guard let sourceVC = view.next() as UIViewController? else { return }
        let nsAttributedString = NSAttributedString(value)
        
        InAppNotifications.showNotification(
            fromVC: sourceVC,
            backgroundColor: backgroundColor,
            image: nil,
            title: nsAttributedString,
            message: nil,
            dismissDelay: 2) {
                self.isPresented.wrappedValue = nil
            }
    }
    
    struct InternalAnchorView: UIViewRepresentable {
        let uiView: UIView
        
        func makeUIView(context: Self.Context) -> UIView {
            uiView
        }
        
        func updateUIView(_ uiView: UIView, context: Self.Context) { }
    }
}

#endif
