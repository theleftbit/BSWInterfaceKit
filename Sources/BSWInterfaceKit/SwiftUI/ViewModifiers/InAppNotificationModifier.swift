#if canImport(UIKit.UIViewController)

import SwiftUI

@available(iOS 17, macOS 14, *)
#Preview {
    @Previewable
    @State
    var state: String? = nil
    
    Button {
        state = "HALA MADRID!"
    } label: {
        Text("Marc es muy del Madrid")
    }
    .inAppNotification(message: $state, textColor: .white, backgroundColor: .orange)
}

public extension SwiftUI.View {
    
    /// Presents an in-app notification as an overlay on the current view.
    /// The notification displays a message with customizable text color and background color.
    /// - Parameters:
    ///   - message: A binding to a string that triggers the notification when set. Setting it to `nil` dismisses the notification.
    ///   - textColor: The color of the notification's text. Defaults to `.white`.
    ///   - backgroundColor: The color of the notification's background. Defaults to `.green`.
    func inAppNotification(
        message: Binding<String?>,
        textColor: UIColor = .white,
        backgroundColor: UIColor = .green
    ) -> some View {
        self.modifier(InAppToastModifier(
            isPresented: message,
            textColor: textColor,
            backgroundColor: backgroundColor
        ))
    }
}

private struct InAppToastModifier: ViewModifier {
    
    let isPresented: Binding<String?>
    let textColor: UIColor
    let backgroundColor: UIColor
    @State private var anchorView = UIView()
    
    func body(content: Content) -> some View {
        if let value = isPresented.wrappedValue {
            presentPopover(value: value)
        }
        
        return content
            .background(InternalAnchorView(uiView: anchorView))
    }
    
    func presentPopover(value: String) {
        let view = anchorView
        guard let sourceVC = view.next() as UIViewController? else { return }
        InAppNotifications.showNotification(
            fromVC: sourceVC,
            backgroundColor: backgroundColor,
            image: nil,
            title: TextStyler.styler.attributedString(value, color: textColor),
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
