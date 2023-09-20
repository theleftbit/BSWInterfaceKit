
import SwiftUI

/// A button that performs an `async throws` operation. It will show an alert in case the operation fails.
///
/// Use this button when the action requires asynchronous work, which will be shown using a `ProgressView`.
///
/// In order to customize it's appereance, use the `.asyncButtonLoadingConfiguration` method
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
    @Environment(\.asyncButtonLoadingConfiguration) var loadingConfiguration

    public var body: some View {
        Button(
            action: {
                Task {
                    await performAction()
                }
            },
            label: {
                if loadingConfiguration.isBlocking {
                    label
                } else {
                    label
                        .opacity(state == .loading ? 0 : 1)
                        .overlay {
                            loadingView
                                .opacity(state == .loading ? 1 : 0)
                        }
                }
            }
        )
        .disabled((state == .loading) || (error != nil))
        .errorAlert(error: $error)
    }
    
    @MainActor
    private func performAction() async {
        var hudVC: UIViewController?
        if loadingConfiguration.isBlocking {
            hudVC = presentHUDViewController()
        }
        transitionToLoadingState()
        do {
            try await action()
            await dismissHUDAsync(hudVC)
            transitionToIdleState()
        } catch {
            await handleError(error, withHUD: hudVC)
        }
    }

    @MainActor
    private func dismissHUDAsync(_ hudVC: UIViewController?) async {
        await withUnsafeContinuation { continuation in
            hudVC?.dismiss(animated: true) {
                continuation.resume(returning: ())
            }
        }
    }
    
    private func transitionToLoadingState() {
        withAnimation {
            self.state = .loading
        }
    }

    private func transitionToIdleState() {
        withAnimation {
            self.state = .idle
        }
    }

    private func handleError(_ error: Error, withHUD hudVC: UIViewController?) async {
        if loadingConfiguration.isBlocking {
            await dismissHUDAsync(hudVC)
        }
        transitionToIdleState()
        self.error = error
    }
    
    @ViewBuilder
    private var loadingView: some View {
        HStack(spacing: 8) {
            ProgressView()
            if let loadingMessage = loadingConfiguration.message {
                Text(loadingMessage)
            }
        }
    }
    
    @ViewBuilder
    private var hudView: some View {
        if case .blocking(let hudFont, let dimsBackground) = loadingConfiguration.style {
            HStack {
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(Color.primary)
                    if let loadingMessage = loadingConfiguration.message {
                        Text(loadingMessage)
                    }
                }
                .font(hudFont)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if dimsBackground {
                    Color.black.opacity(0.2)
                }
            }
            .ignoresSafeArea()
        }
    }

    private func presentHUDViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.visibleViewController else { return nil }
        let ___hudVC = UIHostingController(rootView: hudView)
        ___hudVC.modalPresentationStyle = .overCurrentContext
        ___hudVC.modalTransitionStyle = .crossDissolve
        ___hudVC.view.backgroundColor = .clear
        ___hudVC.view.isOpaque = false
        rootVC.present(___hudVC, animated: true)
        return ___hudVC
    }
}

public extension AsyncButton where Label == Text {
    init(_ label: String,
         action: @escaping () async throws -> Void) {
        self.init(action: action) {
            Text(label)
        }
    }

    init(_ titleKey: LocalizedStringKey, action: @escaping () async throws -> Void) {
        self.init(action: action) {
            Text(titleKey)
        }
    }

    init<S>(_ title: S, action: @escaping () async throws -> Void) where S : StringProtocol {
        self.init(action: action) {
            Text(title)
        }
    }
}

public extension AsyncButton where Label == Image {
    init(systemImageName: String,
         action: @escaping () async throws -> Void) {
        self.init(action: action) {
            Image(systemName: systemImageName)
        }
    }
}

/// Describes how an `AsyncButton` will show it's "loading" state.
public struct AsyncButtonLoadingConfiguration {
    
    public init(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) {
        self.message = message
        self.style = style
    }
    
    /// Describes what kind of loading will be shown to the user during the "loading" state.
    public enum Style {
        /// The rest of the UI in the screen will still be interactable using this style
        case nonblocking
        /// Will show a HUD in order to let the user know that an operation is ongoing.
        case blocking(font: Font = .body, dimsBackground: Bool)
    }
    
    public let message: String?
    public let style: Style
    
    public var isBlocking: Bool {
        switch style {
        case .nonblocking:
            return false
        case .blocking:
            return true
        }
    }
}

public extension View {
    func asyncButtonLoadingConfiguration(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) -> some View {
        self.environment(\.asyncButtonLoadingConfiguration, .init(message: message, style: style))
    }
}

private struct AsyncButtonLoadingStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AsyncButtonLoadingConfiguration = .init()
}

private extension EnvironmentValues {
    
    var asyncButtonLoadingConfiguration: AsyncButtonLoadingConfiguration {
        get { self[AsyncButtonLoadingStyleEnvironmentKey.self] }
        set { self[AsyncButtonLoadingStyleEnvironmentKey.self] = newValue }
    }
}
