import SwiftUI

@available(iOS 17, *)
#Preview {
    @Previewable
    @State
    var state = HUDState.none
    
    AsyncButton {
        state = .loading("Loading...")
        try await Task.sleep(for: .seconds(3))
        state = .success("Success!")
        try await Task.sleep(for: .seconds(3))
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hudState)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
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
