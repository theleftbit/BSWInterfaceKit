
import SwiftUI

#if canImport(Darwin)
@available(iOS 18.0, macOS 14, watchOS 10, *)
#Preview {
    
    @Previewable
    @State
    var presentSheet = false
    
    Button("Present Sheet") {
        presentSheet = true
    }
    .intrinsicHeightSheet(isPresented: $presentSheet) {
        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ac bibendum est. Donec tincidunt ligula sit amet ipsum vehicula vehicula. Vestibulum ultrices arcu sit amet aliquam dictum.")
        .padding()
    }
    .task {
        presentSheet = true
    }
}
#endif

@available(iOS 16.0, macOS 13, watchOS 9, *)
public extension View {
    
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

fileprivate struct IntrinsicHeightDetentView_ForBool<Host: View, Content: View>: View {
    
    let hostView: Host
    let contentView: () -> Content
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    
    #if canImport(Darwin)
    @State var sheetSize: CGSize = .zero
    #endif

    var body: some View {
        hostView
        .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            contentView()
                #if canImport(Darwin)
                .getCGSize($sheetSize)
                .presentationDetents([.height(sheetSize.height)])
                .fixedSize(horizontal: false, vertical: true)
                #else
                .presentationDetents([.medium])
                #endif
        }
    }
}

fileprivate struct IntrinsicHeightDetentView_ForItems<Host: View, Content: View, Item: Identifiable>: View {
    
    let hostView: Host
    let contentView: (Item) -> Content
    @Binding var isPresented: Item?
    let onDismiss: (() -> Void)?
    @State var sheetSize: CGSize = .zero

    var body: some View {
        hostView
            .sheet(item: $isPresented, onDismiss: onDismiss) { item in
                contentView(item)
                    #if canImport(Darwin)
                    .getCGSize($sheetSize)
                    .presentationDetents([.height(sheetSize.height)])
                    .fixedSize(horizontal: false, vertical: true)
                    #else
                    .presentationDetents([.medium])
                    #endif
            }
    }
}

#if canImport(Darwin)
import SwiftUI

private struct CGSizeKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue = CGSize.zero
    static func reduce (value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private extension View {
    /// Sets the `View`'s size to the passed `Binding`
    /// - Parameter viewSize: The `Binding` where to store the value
    /// - Returns: a `SwiftUI.View`.
    @available(*, deprecated, message: "Avoid using getCGSize; prefer standard presentationDetents like .medium/.large.")
    func getCGSize(_ viewSize: Binding<CGSize>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: CGSizeKey.self, value: proxy.size)
            }.onPreferenceChange(CGSizeKey.self) { value in
                viewSize.wrappedValue = value
            }
        )
    }
}
#endif
