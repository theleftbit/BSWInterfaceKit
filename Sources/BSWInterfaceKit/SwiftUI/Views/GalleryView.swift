//
//  Created by Michele Restuccia on 21/7/26.
//

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

#if canImport(Darwin)
#Preview {
    GalleryView(
        urls: [
            URL(string: "https://picsum.photos/id/237/1200/1200")!,
            URL(string: "https://picsum.photos/id/1025/1200/1200")!
        ],
        currentPhotoSelectedIndex: .constant(0)
    )
}
#endif

public struct GalleryView: View {

    @Binding
    var currentPhotoSelectedIndex: Int

    @Environment(\.dismiss)
    var dismiss
    
    private var pageIDs: [String] {
        urls.indices.map(String.init)
    }

    #if canImport(Darwin)
    @State
    var scale: CGFloat = 1
    
    @GestureState
    var magnification: CGFloat = 1

    private var displayScale: CGFloat {
        min(max(scale * magnification, 1), 3.5)
    }

    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .updating($magnification) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                scale = min(max(scale * value.magnification, 1), 3.5)
            }
    }
    #endif

    private let urls: [URL]
    
    public init(
        urls: [URL],
        currentPhotoSelectedIndex: Binding<Int>
    ) {
        self.urls = urls
        self._currentPhotoSelectedIndex = currentPhotoSelectedIndex
    }

    public var body: some View {
        NavigationStack {
            TabView(selection: $currentPhotoSelectedIndex) {
                ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                    cell(url, index: index)
                }
            }
            .toolbar { toolbarContent }
            .overlay(alignment: .bottom) {
                PageIndicator(
                    itemIDs: pageIDs,
                    selectedID: String(currentPhotoSelectedIndex),
                )
                .padding(.bottom, 16)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            #if os(Android)
            /// SkipUI renders page-style TabView as a Compose HorizontalPager,
            /// which cannot be measured intrinsically. A fixed height prevents Compose
            /// from crashing while measuring the full-screen gallery.
            .frame(height: 520)
            #endif
        }
    }

    @ViewBuilder
    private func cell(_ url: URL, index: Int) -> some View {
        PhotoView(
            photo: .init(url: url),
            configuration: .init(placeholder: .init(shape: .rectangle, color: .clear))
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tag(index)
        #if canImport(Darwin)
        .scaleEffect(displayScale)
        .gesture(magnificationGesture)
        .onTapGesture(count: 2) {
            withAnimation { scale = scale == 1 ? 3.5 : 1 }
        }
        #endif
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            #if canImport(Darwin)
            if #available(iOS 26.0, *) {
                Button(
                    role: .close,
                    action: dismiss.callAsFunction
                )
            } else {
                fallbackButton
            }
            #else
            fallbackButton
            #endif
        }
    }
    
    @ViewBuilder
    private var fallbackButton: some View {
        Button(action: dismiss.callAsFunction) {
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundStyle(.primary)
        }
    }
}
