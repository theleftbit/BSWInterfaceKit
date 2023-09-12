
import SwiftUI

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
        withAnimation {
            self.state = .loading
        }

        do {
            try await action()
        } catch {
            self.error = error
        }
        if loadingConfiguration.isBlocking {
            hudVC?.dismiss(animated: true)
        }
        withAnimation {
            self.state = .idle
        }
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
        if case .blocking(let hudFont) = loadingConfiguration.style {
            VStack(spacing: 8) {
                ProgressView()
                if let loadingMessage = loadingConfiguration.message {
                    Text(loadingMessage)
                }
            }
            .font(hudFont)
            .padding()
            .background(.thickMaterial)
            .cornerRadius(3.0)
        }
    }

    private func presentHUDViewController() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, let rootVC = windowScene.keyWindow?.rootViewController {
            let ___hudVC = UIHostingController(rootView: hudView)
            ___hudVC.modalPresentationStyle = .overCurrentContext
            ___hudVC.modalTransitionStyle = .crossDissolve
            ___hudVC.view.backgroundColor = .clear
            ___hudVC.view.isOpaque = false
            rootVC.present(___hudVC, animated: true)
            return ___hudVC
        } else {
            return nil
        }
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

public struct AsyncButtonLoadingConfiguration {
    
    public init(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) {
        self.message = message
        self.style = style
    }
    
    public enum Style {
        case nonblocking
        case blocking(Font = .body)
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
    func asyncButtonLoadingConfiguration(_ config: AsyncButtonLoadingConfiguration) -> some View {
        self.environment(\.asyncButtonLoadingConfiguration, config)
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
