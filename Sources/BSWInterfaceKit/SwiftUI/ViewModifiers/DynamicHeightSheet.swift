
import SwiftUI

@available(iOS 16.0, *)
public extension SwiftUI.View {
    func dynamicHeightSheet<Content: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        IntrinsicHeightDetentView(
            hostView: self,
            contentView: content,
            presentSheet: isPresented
        )
    }
}

@available(iOS 16.0, *)
private struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

@available(iOS 16.0, *)
private struct IntrinsicHeightDetentView<Host: View, Content: View>: View {
    
    let hostView: Host
    let contentView: () -> Content
    @Binding var presentSheet: Bool
    @State private var sheetHeight: CGFloat = .zero

    var body: some View {
        hostView
        .sheet(isPresented: $presentSheet) {
            contentView()
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                    }
                }
                .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                    sheetHeight = newHeight
                }
                .presentationDetents([.height(sheetHeight)])
        }
    }
}
