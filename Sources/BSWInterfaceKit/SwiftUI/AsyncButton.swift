
import SwiftUI

#if compiler(>=5.9)
#Preview {
    AsyncButton {
        if #available(iOS 16.0, *) {
            try await Task.sleep(for: .seconds(3))
        }
        struct SomeError: Swift.Error {}
//        throw SomeError()
    } label: {
        Label(
            title: { Text("Touch Me") },
            icon: { Image(systemName: "42.circle") }
        )
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .frame(width: 320)
    .font(.headline)
    .loadingMessage("Loading...")
}
#endif

public struct AsyncButton<Label: View>: View {
    
    public init(action: @escaping () async throws -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public let action: () async throws -> Void
    public let label: Label
        
    private enum ButtonState: Equatable {
        case idle
        case loading
    }
    
    @State private var state: ButtonState = .idle
    @State private var error: Swift.Error?
    @State private var size: CGSize = .zero
    @Environment(\.loadingMessage) var loadingMessage

    public var body: some View {
        Button(
            action: {
                Task { @MainActor in
                    await performAction()
                }
            },
            label: {
                switch state {
                case .idle:
                    label
                        .getCGSize($size)
                case .loading:
                    loadingView
                        .frame(width: size.width, height: size.height)
                }
            }
        )
        .disabled(state == .loading)
        .errorAlert(error: $error)
    }
    
    private func performAction() async {
        withAnimation {
            self.state = .loading
        }
        do {
            try await action()
        } catch {
            self.error = error
        }
        withAnimation {
            self.state = .idle
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        if let loadingMessage {
            HStack(spacing: 8) {
                ProgressView()
                Text(loadingMessage)
            }
        } else {
            ProgressView()
        }
    }
}

public extension View {
    func loadingMessage(_ message: String) -> some View {
        self.environment(\.loadingMessage, message)
    }
}

private struct LoadingMessageEnvironmentKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private extension EnvironmentValues {
    var loadingMessage: String? {
        get { self[LoadingMessageEnvironmentKey.self] }
        set { self[LoadingMessageEnvironmentKey.self] = newValue }
    }
}
