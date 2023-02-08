
import SwiftUI

@available(iOS 16.0, *)
public extension SwiftUI.View {
    
    /// Presents a sheet where the sheet's height is the contained view's intrinsic height
    /// **Note:** It doesn't work if `Content` is embedded in a `NavigationView`
    /// - Parameters:
    ///   - isPresented: the Binding that controls the presentation
    ///   - onDismiss: a callback to be called on dismissal
    ///   - content: the content to be presented
    func intrinsicHeightSheet<Content: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        IntrinsicHeightDetentView_ForBool(
            hostView: self,
            contentView: content,
            isPresented: isPresented,
            onDismiss: onDismiss
        )
    }
    
    /// Presents a sheet where the sheet's height is the contained view's intrinsic height
    /// **Note:** It doesn't work if `Content` is embedded in a `NavigationView`
    /// - Parameters:
    ///   - item: the Binding to the Item being presented
    ///   - onDismiss: a callback to be called on dismissal
    ///   - content: the content to be presented
    func intrinsicHeightSheet<Item: Identifiable, Content: View>(item: Binding<Item?>, onDismiss: (() -> Void)? = nil, content: @escaping (Item) -> Content) -> some View {
        IntrinsicHeightDetentView_ForItems(
            hostView: self,
            contentView: content,
            isPresented: item,
            onDismiss: onDismiss
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
private struct IntrinsicHeightDetentView_ForBool<Host: View, Content: View>: View {
    
    let hostView: Host
    let contentView: () -> Content
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @State private var sheetHeight: CGFloat = .zero

    var body: some View {
        hostView
        .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
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

@available(iOS 16.0, *)
private struct IntrinsicHeightDetentView_ForItems<Host: View, Content: View, Item: Identifiable>: View {
    
    let hostView: Host
    let contentView: (Item) -> Content
    @Binding var isPresented: Item?
    let onDismiss: (() -> Void)?
    @State private var sheetHeight: CGFloat = .zero

    var body: some View {
        hostView
            .sheet(item: $isPresented, onDismiss: onDismiss) { item in
                contentView(item)
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
