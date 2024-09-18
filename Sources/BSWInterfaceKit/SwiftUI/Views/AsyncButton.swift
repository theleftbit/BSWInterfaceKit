
import SwiftUI

/// A button that performs an `async throws` operation. It will show an alert in case the operation fails.
///
/// Use this button when the action requires asynchronous work, which will be shown using a `ProgressView`.
///
/// In order to customize it's appereance, use the `.asyncButtonLoadingConfiguration` method
public struct AsyncButton<Label: View>: View {
    
    public init(action: @escaping Action, label: @escaping () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public typealias Action = () async throws -> Void
    public let action: Action
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
                withAnimation {
                    self.state = .loading
                }
            },
            label: {
                label
                    .opacity(state == .loading ? 0 : 1)
                    .overlay {
                        if loadingConfiguration.isBlocking == false, state == .loading {
                            loadingView
                        }
                    }
            }
        )
        .disabled((state == .loading) || (error != nil))
        .errorAlert(error: $error)
        .task(id: state) {
            if state == .loading {
                await performAction()
            }
        }
    }
    
    @MainActor
    private func performAction() async {
        
        #if canImport(UIKit.UIViewController)
        var hudVC: UIViewController?
        if loadingConfiguration.isBlocking {
            hudVC = await presentHUDViewController()
        }
        #endif
        let result: Swift.Result<Void, Swift.Error> = await {
            if let operation = operation {
                await AsyncOperationTracer.operationDidBegin(operation)
            }
            do {
                try await action()
                if let operation = operation {
                    await AsyncOperationTracer.operationDidEnd(operation)
                }
                return .success(())
            } catch {
                if let operation = operation {
                    await AsyncOperationTracer.operationDidEnd(operation)
                    await AsyncOperationTracer.operationDidFail(operation, error)
                }
                return .failure(error)
            }
        }()

        #if canImport(UIKit.UIViewController)
        if loadingConfiguration.isBlocking {
            await hudVC?.dismiss(animated: true)
        }
        #endif

        switch result {
        case .success:
            break
        case .failure(let failure):
            self.error = failure
        }
        
        withAnimation {
            self.state = .idle
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .tint({
                    switch loadingConfiguration.style {
                    case .inline(let tint): return tint
                    case .blocking: return nil
                    }
                }())
                #if canImport(AppKit)
                .scaleEffect(x: 0.5, y: 0.5)
                #endif
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
    
    @Environment(\.asyncButtonOperationIdentifierKey)
    private var operationKey

    private var operation: AsyncOperationTracer.Operation? {
        guard let operationKey else {
            return nil
        }
        return .init(kind: .buttonAction, id: operationKey)
    }

#if canImport(UIKit.UIViewController)
    @MainActor
    private func presentHUDViewController() async -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.visibleViewController else { return nil }
        let ___hudVC = UIHostingController(rootView: hudView)
        ___hudVC.modalPresentationStyle = .overCurrentContext
        ___hudVC.modalTransitionStyle = .crossDissolve
        ___hudVC.view.backgroundColor = .clear
        ___hudVC.view.isOpaque = false
        await rootVC.present(___hudVC, animated: true)
        return ___hudVC
    }
#endif
}

public extension AsyncButton where Label == Text {
    init(_ label: String,
         action: @escaping Action) {
        self.init(action: action) {
            Text(label)
        }
    }

    init(_ titleKey: LocalizedStringKey, action: @escaping Action) {
        self.init(action: action) {
            Text(titleKey)
        }
    }

    init<S>(_ title: S, action: @escaping Action) where S : StringProtocol {
        self.init(action: action) {
            Text(title)
        }
    }
}

public extension AsyncButton where Label == Image {
    init(systemImageName: String,
         action: @escaping Action) {
        self.init(action: action) {
            Image(systemName: systemImageName)
        }
    }
}

/// Describes how an `AsyncButton` will show it's "loading" state.
public struct AsyncButtonLoadingConfiguration: Sendable {
    
    public init(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) {
        self.message = message
        self.style = style
    }
    
    /// Describes what kind of loading will be shown to the user during the "loading" state.
    public enum Style: Sendable {
        /// The rest of the UI in the screen will still be interactable using this style
        case inline(tint: Color? = nil)
        /// Will show a HUD in order to let the user know that an operation is ongoing.
        case blocking(font: Font = .body, dimsBackground: Bool)

        @usableFromInline
        static var nonblocking: Style { .inline(tint: nil) }
    }
    
    public let message: String?
    public let style: Style
    
    public var isBlocking: Bool {
        switch style {
        case .inline:
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

    func asyncButtonOperationIdentifierKey(_ key: String) -> some View {
        self.environment(\.asyncButtonOperationIdentifierKey, key)
    }
}

private struct AsyncButtonLoadingStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AsyncButtonLoadingConfiguration = .init()
}

private struct AsyncButtonOperationIdentifierKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private extension EnvironmentValues {
    
    var asyncButtonLoadingConfiguration: AsyncButtonLoadingConfiguration {
        get { self[AsyncButtonLoadingStyleEnvironmentKey.self] }
        set { self[AsyncButtonLoadingStyleEnvironmentKey.self] = newValue }
    }

    var asyncButtonOperationIdentifierKey: String? {
        get { self[AsyncButtonOperationIdentifierKey.self] }
        set { self[AsyncButtonOperationIdentifierKey.self] = newValue }
    }
}

private extension Swift.Result where Failure == Error {
    init(catching body: () async throws -> Success) async {
        do {
            let result = try await body()
            self = .success(result)
        } catch {
            self = .failure(error)
        }
    }
}
