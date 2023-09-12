
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
    .asyncButtonLoadingMessage("Loading...")
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
    @Environment(\.asyncButtonLoadingMessage) var loadingMessage
    @Environment(\.asyncButtonLoadingStyleIsBlocking) var isBlocking

    public var body: some View {
        Button(
            action: {
                Task {
                    await performAction()
                }
            },
            label: {
                if isBlocking {
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
        if isBlocking {
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
        if isBlocking {
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
            if let loadingMessage {
                Text(loadingMessage)
            }
        }
    }
    
    @ViewBuilder
    private var hudView: some View {
        VStack(spacing: 8) {
            ProgressView()
            if let loadingMessage {
                Text(loadingMessage)
            }
        }
        .padding()
        .background(.thickMaterial)
        .cornerRadius(3.0)
        .frame(minWidth: 200, minHeight: 200)
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

public extension View {
    func asyncButtonLoadingMessage(_ message: String) -> some View {
        self.environment(\.asyncButtonLoadingMessage, message)
    }

    func asyncButtonLoadingStyle(isBlocking: Bool) -> some View {
        self.environment(\.asyncButtonLoadingStyleIsBlocking, isBlocking)
    }
}

private struct AsyncButtonLoadingStyleIsBlockingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct AsyncButtonLoadingMessageEnvironmentKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private extension EnvironmentValues {
    var asyncButtonLoadingMessage: String? {
        get { self[AsyncButtonLoadingMessageEnvironmentKey.self] }
        set { self[AsyncButtonLoadingMessageEnvironmentKey.self] = newValue }
    }
    
    var asyncButtonLoadingStyleIsBlocking: Bool {
        get { self[AsyncButtonLoadingStyleIsBlockingEnvironmentKey.self] }
        set { self[AsyncButtonLoadingStyleIsBlockingEnvironmentKey.self] = newValue }
    }
}
