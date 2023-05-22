import SwiftUI

private struct CGSizeKey: PreferenceKey {
    static var defaultValue = CGSize.zero
    static func reduce (value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
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
