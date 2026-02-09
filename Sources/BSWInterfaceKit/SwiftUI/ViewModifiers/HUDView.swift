#if canImport(Darwin)
#Preview {
    @Previewable
    @State
    var state = HUDState.none

    VStack {
        Spacer()
        AsyncButton {
            state = .loading("Loading...")
            try await Task.sleep(for: .seconds(1))
            state = .success("Success!")
            try await Task.sleep(for: .seconds(1))
            state = .none
        } label: {
            Label(
                title: { Text("Let's go") },
                icon: { Image(systemName: "42.circle") }
            )
            .frame(maxWidth: .infinity)
        }
        .padding()
        .font(.headline)
        .buttonStyle(BorderedProminentButtonStyle())
        .hud(hudState: $state, configuration: .init(dimsBackground: true))
    }
}
#endif

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

public extension View {
    func hud(hudState: Binding<HUDState>, configuration: HUDConfiguration? = nil) -> some View {
        #if os(iOS)
        modifier(iOSHUDModifier(hudState: hudState, configuration: configuration ?? .init()))
        #elseif os(Android)
        modifier(AndroidHUDModifier(hudState: hudState, configuration: configuration ?? .init()))
        #else
        modifier(MacHUDModifier(hudState: hudState, configuration: configuration ?? .init()))
        #endif
    }
}

public enum HUDState: Equatable, Sendable {
    case none
    case loading(String? = nil)
    case success(String?)

    var shouldShow: Bool {
        switch self {
        case .none:
            return false
        case .loading:
            return true
        case .success:
            return true
        }
    }

    var isSuccess: Bool {
        switch self {
        case .none:
            return false
        case .loading:
            return false
        case .success:
            return true
        }
    }

    var text: String? {
        switch self {
        case .none:
            return nil
        case .loading(let string):
            return string ?? ""
        case .success(let string):
            return string ?? ""
        }
    }
}

public struct HUDConfiguration: Sendable {

    public init(font: Font = .body, dimsBackground: Bool = false, successMessageInterval: TimeInterval = 3) {
        self.dimsBackground = dimsBackground
        self.font = font
        self.successMessageInterval = successMessageInterval
    }

    let font: Font
    let dimsBackground: Bool
    let successMessageInterval: TimeInterval
}

#if os(iOS)
struct iOSHUDModifier: ViewModifier {

    @Binding
    var hudState: HUDState

    let configuration: HUDConfiguration

    @State
    var showFullScreenCover = false

    @State
    var animatedValue = false

    @Environment(\.colorScheme)
    var colorScheme

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showFullScreenCover) {
                HUDView(state: hudState)
                    .font(configuration.font)
                    .opacity(animatedValue ? 1 : 0)
                    .backwards_presentationBackground {
                        if configuration.dimsBackground {
                            backgroundColor
                                .opacity(animatedValue ? 0.25 : 0)
                        }
                    }
                    .preferredColorScheme(.light)
                    .task {
                        try? await Task.sleep(for: .seconds(0.1))
                        withAnimation {
                            animatedValue = true
                        }
                    }
            }
            .onChange(of: hudState) { _, newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                switch newValue {
                case .loading:
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                case .none:
                    withAnimation(completionCriteria: .removed) {
                        animatedValue = false
                    } completion: {
                        withTransaction(transaction) {
                            showFullScreenCover = false
                        }
                    }
                case .success:
                    break
                }
            }
    }

    var backgroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

private extension View {

    @ViewBuilder
    func backwards_presentationBackground<T: View>(alignment: Alignment = .center, @ViewBuilder content:  () -> T) -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            self
                .presentationBackground(alignment: alignment, content: content)
        } else {
            self
        }
    }
}
#elseif os(Android)
struct AndroidHUDModifier: ViewModifier {
    @Binding
    var hudState: HUDState

    let configuration: HUDConfiguration

    func body(content: Content) -> some View {
        content.overlay {
            ComposeView {
                AndroidHUD(visible: hudState.shouldShow, text: hudState.text, isSuccess: hudState.isSuccess)
            }
        }
    }

    #if SKIP
    struct AndroidHUD: ContentComposer {
        let visible: Bool
        let text: String?
        let isSuccess: Bool

        @Composable
        func Compose(context: ComposeContext) {
            bswinterface.kit.BlockingHudDialog(
                visible: visible,
                text: text,
                isSuccess: isSuccess
            )
        }
    }
    #endif
}
#else
/// This kind of sucks, so please fix
struct MacHUDModifier: ViewModifier {
    @Binding
    var hudState: HUDState

    let configuration: HUDConfiguration

    func body(content: Content) -> some View {
        ZStack {
            content

            if hudState != .none {
                ZStack {
                    if configuration.dimsBackground {
                        Color.black
                            .opacity(0.2)
                            .ignoresSafeArea()
                            .transition(.opacity)
                    }

                    HUDView(state: hudState)
                        .transition(.opacity)
                        .font(configuration.font)
                }
            }
        }
    }
}
#endif

#if canImport(Darwin)
struct HUDView: View {

    init(state: HUDState) {
        self.state = state
    }

    let state: HUDState

    @ScaledMetric
    private var hudImageSize = 60.0
    @ScaledMetric
    private var hudContentSize = 120.0
    private let backgroundColor = Material.regularMaterial

    #if os(iOS)
    @Environment(\.asyncButtonProgressViewProvider)
    private var progressViewProvider
    #endif

    var body: some View {
        VStack(alignment: .center) {
            hudImage
                .frame(width: hudImageSize, height: hudImageSize)
            if let textMessage {
                Text(textMessage)
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.default, value: state)
        .padding()
        .frame(minWidth: hudContentSize, minHeight: hudContentSize)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
    }

    private var textMessage: String? {
        switch state {
        case .none:
            return nil
        case .loading(let loadingMessage):
            return loadingMessage
        case .success(let successMessage):
            return successMessage
        }
    }

    @ViewBuilder
    private var hudImage: some View {
        switch state {
        case .none:
            EmptyView()
        case .loading:
            hudLoadingSpinner
        case .success:
            Image(systemName: "checkmark")
                .font(.largeTitle)
        }
    }

    @ViewBuilder
    private var hudLoadingSpinner: some View {
        #if os(iOS)
        if let progressViewProvider {
            progressViewProvider(.blocking(.init()))
        } else {
            defaultHUDProgressView
        }
        #else
        defaultHUDProgressView
        #endif
    }

    @ViewBuilder
    private var defaultHUDProgressView: some View {
        ProgressView()
            .tint(.primary)
            .scaleEffect(1.5)
    }
}
#endif
