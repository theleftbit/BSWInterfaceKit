
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
    .inAppNotification(message: $state)
}

public extension SwiftUI.View {
    
    /// Presents a sheet where the sheet's height is the contained view's intrinsic height
    /// **Note:** It doesn't work if `Content` is embedded in a `NavigationView`
    /// - Parameters:
    ///   - isPresented: the Binding that controls the presentation
    ///   - onDismiss: a callback to be called on dismissal
    ///   - content: the content to be presented
    func inAppNotification(message: Binding<String?>) -> some View {
        self.modifier(InAppToastModifier(isPresented: message))
    }
}

private struct InAppToastModifier: ViewModifier {
    
    let isPresented: Binding<String?>
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
            backgroundColor: .green,
            image: nil,
            title: TextStyler.styler.attributedString(value),
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
