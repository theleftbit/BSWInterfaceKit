import SwiftUI

@available(iOS 17, macOS 14, watchOS 9, *)
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

public extension View {
    func hud(hudState: Binding<HUDState>, configuration: HUDConfiguration? = nil) -> some View {
        modifier(HUDModifier(hudState: hudState, configuration: configuration ?? .init()))
    }
}

public enum HUDState: Equatable {
    case none
    case loading(String? = nil)
    case success(String?)
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

struct HUDModifier: ViewModifier {

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
            .onChange(of: hudState) { newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                switch newValue {
                case .loading:
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                case .none:
                    if #available(iOS 17.0, *) {
                        withAnimation(completionCriteria: .removed) {
                            animatedValue = false
                        } completion: {
                            withTransaction(transaction) {
                                showFullScreenCover = false
                            }
                        }
                    } else {
                        let duration: TimeInterval = 0.2
                        let animation: Animation = .easeOut(duration: duration)
                        withAnimation(animation) {
                            animatedValue = false
                        }
                        Task {
                            try await Task.sleep(for: .seconds(duration))
                            withTransaction(transaction) {
                                showFullScreenCover = false
                            }
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

    struct HUDView: View {

        let state: HUDState

        @ScaledMetric
        private var hudImageSize = 60.0
        
        @ScaledMetric
        private var hudContentSize = 120.0

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
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
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
                ProgressView()
                    .tint(.primary)
                    .scaleEffect(1.5)
            case .success:
                Image(systemName: "checkmark")
                    .font(.largeTitle)
            }
        }
    }
}

private extension View {
    
    @ViewBuilder
    func backwards_presentationBackground<T: View>(alignment: Alignment = .center, @ViewBuilder content:  () -> T) -> some View {
        if #available(iOS 16.4, *) {
            self
                .presentationBackground(alignment: alignment, content: content)
        } else {
            self
        }
    }
}
