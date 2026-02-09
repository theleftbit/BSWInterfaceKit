#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

#if canImport(Darwin)
#Preview {
    AsyncButton {
        try await Task.sleep(for: .seconds(1.5))
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
    .padding()
    .font(.headline)
    .asyncButtonLoadingConfiguration(
        message: "Loading...",
//        style: .inline(tint: .red)

        style: .blocking(
            font: .headline,
            dimsBackground: true,
            successMessage: .init(message: "Done!")
        )
    )
//    .asyncButtonProgressView { style in
//        ProgressView().scaleEffect(1.2)
//    }
}
#endif

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
    
    enum ButtonState: Equatable {
        case idle
        case loading
    }
    
    @State
    var state: ButtonState = .idle
    
    @State
    var error: Swift.Error?
    
    @Environment(\.asyncButtonLoadingConfiguration)
    var loadingConfiguration

    @State
    var hudState = HUDState.none

    @Environment(\.asyncButtonProgressViewProvider)
    var progressViewProvider

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
        .hud(
            hudState: $hudState,
            configuration: hudConfiguration
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
        
        if let hudLoadingConfiguration {
            self.hudState = hudLoadingConfiguration
        }

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

        switch result {
        case .success:
            if let hudSuccessConfiguration, let hudConfiguration {
                self.hudState = hudSuccessConfiguration
                try? await Task.sleep(for: .seconds(hudConfiguration.successMessageInterval) )
            }
            self.hudState = .none
        case .failure(let failure):
            #if canImport(Darwin)
            withAnimation {
                self.hudState = .none
            } completion: {
                error = failure
            }
            #else
            self.hudState = .none
            try? await Task.sleep(for: .milliseconds(300))
            error = failure
            #endif
        }

        withAnimation {
            self.state = .idle
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        if let progressViewProvider {
            progressViewProvider(loadingConfiguration.style)
        } else {
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
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        HStack(spacing: 8) {
            // CHANGED: only ProgressView() -> progressView
            progressView

            if let loadingMessage = loadingConfiguration.message {
                Text(loadingMessage)
            }
        }
    }
    
    @Environment(\.asyncButtonOperationIdentifierKey)
    var operationKey
    
    private var operation: AsyncOperationTracer.Operation? {
        guard let operationKey else {
            return nil
        }
        return .init(kind: .buttonAction, id: operationKey)
    }
    
    private var hudLoadingConfiguration: HUDState? {
        switch loadingConfiguration.style {
        case .blocking:
            return .loading( loadingConfiguration.message)
        case .inline:
            return nil
        }
    }
    
    private var hudSuccessConfiguration: HUDState? {
        switch loadingConfiguration.style {
        case .blocking(let config):
            guard let successMessage = config.successMessage else {
                return nil
            }
            return .success(successMessage.message)
        case .inline:
            return nil
        }
    }

    private var hudConfiguration: HUDConfiguration? {
        switch loadingConfiguration.style {
        case .blocking(let config):
            return .init(font: config.font, dimsBackground: config.dimsBackground)
        case .inline:
            return nil
        }
    }
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
public struct AsyncButtonLoadingConfiguration {
    
    public init(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) {
        self.message = message
        self.style = style
    }
    
    /// Describes what kind of loading will be shown to the user during the "loading" state.
    public enum Style {
        /// The rest of the UI in the screen will still be interactable using this style
        case inline(tint: Color? = nil)
        /// Will show a HUD in order to let the user know that an operation is ongoing.
        case blocking(BlockingConfiguration)
        
        @usableFromInline
        static var nonblocking: Style { .inline(tint: nil) }
        
        @usableFromInline
        static func blocking(font: Font = .headline, dimsBackground: Bool = false, successMessage: BlockingSuccessMessage? = nil) -> Style { .blocking(.init(font: font, dimsBackground: dimsBackground, successMessage: successMessage)) }
        
        public struct BlockingConfiguration {
            public init(font: Font = .body, dimsBackground: Bool = false, successMessage: BlockingSuccessMessage? = nil) {
                self.dimsBackground = dimsBackground
                self.font = font
                self.successMessage = successMessage
            }
            
            let font: Font
            let dimsBackground: Bool
            let successMessage: BlockingSuccessMessage?
        }
        
        public struct BlockingSuccessMessage {
            public init(message: String, timeInterval: TimeInterval = 2) {
                self.message = message
                self.timeInterval = timeInterval
            }
            
            let message: String
            let timeInterval: TimeInterval
        }
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

public typealias AsyncButtonProgressViewProvider = @Sendable (_ style: AsyncButtonLoadingConfiguration.Style) -> AnyView

public extension View {
    func asyncButtonLoadingConfiguration(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) -> some View {
        self.environment(\.asyncButtonLoadingConfiguration, .init(message: message, style: style))
    }
    
    func asyncButtonOperationIdentifierKey(_ key: String) -> some View {
        self.environment(\.asyncButtonOperationIdentifierKey, key)
    }

    func asyncButtonProgressView(_ provider: @escaping AsyncButtonProgressViewProvider) -> some View {
        self.environment(\.asyncButtonProgressViewProvider, provider)
    }

    func asyncButtonProgressView<Content: View>(
        @ViewBuilder _ content: @escaping (_ style: AsyncButtonLoadingConfiguration.Style) -> Content
    ) -> some View {
        self.environment(\.asyncButtonProgressViewProvider) { style in
            AnyView(content(style))
        }
    }
}

#if canImport(Darwin)
private extension EnvironmentValues {
    @Entry var asyncButtonLoadingConfiguration = AsyncButtonLoadingConfiguration()
    @Entry var asyncButtonOperationIdentifierKey: String? = nil
    @Entry var asyncButtonProgressViewProvider: AsyncButtonProgressViewProvider? = nil
}
#else
private struct AsyncButtonLoadingConfigurationKey: EnvironmentKey {
    static let defaultValue = AsyncButtonLoadingConfiguration()
}

private struct AsyncButtonOperationIdentifierKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct AsyncButtonProgressViewProviderKey: EnvironmentKey {
    static let defaultValue: AsyncButtonProgressViewProvider? = nil
}

extension EnvironmentValues {
    var asyncButtonLoadingConfiguration: AsyncButtonLoadingConfiguration {
        get { self[AsyncButtonLoadingConfigurationKey.self] }
        set { self[AsyncButtonLoadingConfigurationKey.self] = newValue }
    }

    var asyncButtonOperationIdentifierKey: String? {
        get { self[AsyncButtonOperationIdentifierKey.self] }
        set { self[AsyncButtonOperationIdentifierKey.self] = newValue }
    }

    var asyncButtonProgressViewProvider: AsyncButtonProgressViewProvider? {
        get { self[AsyncButtonProgressViewProviderKey.self] }
        set { self[AsyncButtonProgressViewProviderKey.self] = newValue }
    }
}
#endif

private extension Swift.Result {
    var isError: Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
        }
    }
}

extension AsyncButtonLoadingConfiguration: Sendable {}
extension AsyncButtonLoadingConfiguration.Style: Sendable {}
extension AsyncButtonLoadingConfiguration.Style.BlockingConfiguration: Sendable {}
extension AsyncButtonLoadingConfiguration.Style.BlockingSuccessMessage: Sendable {}
