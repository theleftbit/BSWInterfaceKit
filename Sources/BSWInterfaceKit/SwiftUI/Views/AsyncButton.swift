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
        throw SomeError()
    } label: {
        Label(
            title: { Text("Touch Me") },
            icon: { Image(systemName: "42.circle") }
        )
        .frame(maxWidth: .infinity)
    }
    .asyncButtonProgressView { style in
        ProgressView()
            .tint(.red)
            .scaleEffect(1.5)
    }
    .asyncButtonLoadingConfiguration(
        message: "Loading...",
        style: .blocking(
            font: .headline,
            dimsBackground: true,
            successMessage: .init(message: "Done!")
        )
    )
    .buttonStyle(.borderedProminent)
    .padding()
    .font(.headline)
}
#endif

// MARK: - Default progress view (no Environment needed)
public struct DefaultAsyncButtonProgressView: View {
    public init(style: AsyncButtonLoadingConfiguration.Style) {
        self.style = style
    }

    let style: AsyncButtonLoadingConfiguration.Style

    public var body: some View {
        ProgressView()
            .tint({
                switch style {
                case .inline(let tint): return tint
                case .blocking: return nil
                }
            }())
            #if canImport(AppKit)
            .scaleEffect(x: 0.5, y: 0.5)
            #endif
    }
}

// MARK: - AsyncButton
public struct AsyncButton<Label: View, Progress: View>: View {

    public typealias Action = () async throws -> Void

    public let action: Action
    public let label: Label

    private let progressViewProvider: (_ style: AsyncButtonLoadingConfiguration.Style) -> Progress

    public init(
        action: @escaping Action,
        label: Label,
        progressViewProvider: @escaping (_ style: AsyncButtonLoadingConfiguration.Style) -> Progress
    ) {
        self.action = action
        self.label = label
        self.progressViewProvider = progressViewProvider
    }

    enum ButtonState: Equatable { case idle, loading }

    @State var state: ButtonState = .idle
    @State var error: Swift.Error?

    @Environment(\.asyncButtonLoadingConfiguration)
    var loadingConfiguration

    @State var hudState = HUDState.none

    public var body: some View {
        Button(
            action: {
                withAnimation { self.state = .loading }
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
        ) {
            progressViewProvider(loadingConfiguration.style)
        }
        .disabled((state == .loading) || (error != nil))
        .errorAlert(error: $error)
        .task(id: state) {
            if state == .loading { await performAction() }
        }
    }

    @MainActor
    private func performAction() async {

        if let hudLoadingConfiguration {
            self.hudState = hudLoadingConfiguration
        }

        let result: Result<Void, Swift.Error> = await {
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
                try? await Task.sleep(for: .seconds(hudConfiguration.successMessageInterval))
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

        withAnimation { self.state = .idle }
    }

    @ViewBuilder
    private var loadingView: some View {
        HStack(spacing: 8) {
            progressViewProvider(loadingConfiguration.style)
            if let loadingMessage = loadingConfiguration.message {
                Text(loadingMessage)
            }
        }
    }

    @Environment(\.asyncButtonOperationIdentifierKey)
    var operationKey

    private var operation: AsyncOperationTracer.Operation? {
        guard let operationKey else { return nil }
        return .init(kind: .buttonAction, id: operationKey)
    }

    private var hudLoadingConfiguration: HUDState? {
        switch loadingConfiguration.style {
        case .blocking:
            return .loading(loadingConfiguration.message)
        case .inline:
            return nil
        }
    }

    private var hudSuccessConfiguration: HUDState? {
        switch loadingConfiguration.style {
        case .blocking(let config):
            guard let successMessage = config.successMessage else { return nil }
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

// MARK: - Public default init
public extension AsyncButton where Progress == DefaultAsyncButtonProgressView {

    init(action: @escaping Action, label: @escaping () -> Label) {
        self.init(
            action: action,
            label: label(),
            progressViewProvider: { style in
                DefaultAsyncButtonProgressView(style: style)
            }
        )
    }
}

// MARK: - Custom loader modifier
public extension AsyncButton {

    func asyncButtonProgressView<CustomProgress: View>(
        @ViewBuilder _ builder: @escaping (_ style: AsyncButtonLoadingConfiguration.Style) -> CustomProgress
    ) -> AsyncButton<Label, CustomProgress> {
        .init(
            action: action,
            label: label,
            progressViewProvider: builder
        )
    }
}

// MARK: - Convenience inits
public extension AsyncButton where Label == Text, Progress == DefaultAsyncButtonProgressView {
    init(_ label: String, action: @escaping Action) {
        self.init(action: action) { Text(label) }
    }

    init(_ titleKey: LocalizedStringKey, action: @escaping Action) {
        self.init(action: action) { Text(titleKey) }
    }

    init<S>(_ title: S, action: @escaping Action) where S: StringProtocol {
        self.init(action: action) { Text(title) }
    }
}

public extension AsyncButton where Label == Image, Progress == DefaultAsyncButtonProgressView {
    init(systemImageName: String, action: @escaping Action) {
        self.init(action: action) { Image(systemName: systemImageName) }
    }
}

// MARK: - AsyncButtonLoadingConfiguration
public struct AsyncButtonLoadingConfiguration {

    public init(message: String? = nil, style: AsyncButtonLoadingConfiguration.Style = .nonblocking) {
        self.message = message
        self.style = style
    }

    public enum Style {
        case inline(tint: Color? = nil)
        case blocking(BlockingConfiguration)

        @usableFromInline
        static var nonblocking: Style { .inline(tint: nil) }

        @usableFromInline
        static func blocking(
            font: Font = .headline,
            dimsBackground: Bool = false,
            successMessage: BlockingSuccessMessage? = nil
        ) -> Style {
            .blocking(.init(font: font, dimsBackground: dimsBackground, successMessage: successMessage))
        }

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
        case .inline: return false
        case .blocking: return true
        }
    }
}

public extension View {

    func asyncButtonLoadingConfiguration(
        message: String? = nil,
        style: AsyncButtonLoadingConfiguration.Style = .nonblocking
    ) -> some View {
        self.environment(\.asyncButtonLoadingConfiguration, .init(message: message, style: style))
    }

    func asyncButtonOperationIdentifierKey(_ key: String) -> some View {
        self.environment(\.asyncButtonOperationIdentifierKey, key)
    }
}

#if canImport(Darwin)
extension EnvironmentValues {
    @Entry var asyncButtonLoadingConfiguration = AsyncButtonLoadingConfiguration()
    @Entry var asyncButtonOperationIdentifierKey: String? = nil
}
#else
private struct AsyncButtonLoadingConfigurationKey: EnvironmentKey {
    static let defaultValue = AsyncButtonLoadingConfiguration()
}

private struct AsyncButtonOperationIdentifierKey: EnvironmentKey {
    static let defaultValue: String? = nil
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
}
#endif

extension AsyncButtonLoadingConfiguration: Sendable {}
extension AsyncButtonLoadingConfiguration.Style: Sendable {}
extension AsyncButtonLoadingConfiguration.Style.BlockingConfiguration: Sendable {}
extension AsyncButtonLoadingConfiguration.Style.BlockingSuccessMessage: Sendable {}
