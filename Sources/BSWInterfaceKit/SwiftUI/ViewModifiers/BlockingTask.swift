//
//  Created by Michele Restuccia on 13/1/25.
//

#if canImport(Darwin)
import SwiftUI

#Preview {
    @State
    @Previewable
    var perform: Bool = false
    
    Button {
        perform = true
    } label: {
        Text("Trigger job")
    }
    .performBlockingTask(
        readyToPerform: $perform,
        confirmationStrategy: .confirmWith(title: "Are you sure?", message: "This will block the main thread for 2 seconds.", confirmButtonTitle: "Yes", cancelButtonTitle: "No"),
        task: {
            struct SomeError: Swift.Error {}
            try await Task.sleep(for: .seconds(1))
            throw SomeError()
        }
    )
}
#else
import SkipFuseUI
#endif

public typealias AsyncBlockingTask = @MainActor () async throws -> ()
public typealias AsyncBlockingTaskWithValue<T: Equatable> = @MainActor (T) async throws -> ()
public enum AsyncBlockingTaskConfirmationStrategy {
    case notRequired
    case confirmWith(title: String, message: String?, confirmButtonTitle: String, cancelButtonTitle: String, isDestructiveAction: Bool = false)
}

public extension View {

    func performBlockingTask<T: Equatable>(
        value: Binding<T?>,
        confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired,
        loadingMessage: String? = nil,
        successMessage: String? = nil,
        successDisplaySeconds: TimeInterval = 1.0,
        task: @escaping AsyncBlockingTaskWithValue<T>
    ) -> some View {
        PerformEquatableBlockingView(
            content: self,
            value: value,
            task: task,
            confirmationStrategy: confirmationStrategy,
            loadingMessage: loadingMessage,
            successMessage: successMessage,
            successDisplaySeconds: successDisplaySeconds
        )
    }

    func performBlockingTask(
        readyToPerform: Binding<Bool>,
        confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired,
        loadingMessage: String? = nil,
        successMessage: String? = nil,
        successDisplaySeconds: TimeInterval = 1.0,
        task: @escaping AsyncBlockingTask
    ) -> some View {
        PerformEquatableBlockingView(
            content: self,
            value: .init(
                get: {
                    readyToPerform.wrappedValue ? true : nil
                },
                set: {
                    if let _ = $0 {
                        readyToPerform.wrappedValue = true
                    } else {
                        readyToPerform.wrappedValue = false
                    }
                }
            ),
            task: { _ in try await task() },
            confirmationStrategy: confirmationStrategy,
            loadingMessage: loadingMessage,
            successMessage: successMessage,
            successDisplaySeconds: successDisplaySeconds
        )
    }
}
// MARK: Private

struct PerformEquatableBlockingView<T: Equatable, V: View>: View {
    
    let content: V
    
    @Binding
    var value: T?
    
    let task: AsyncBlockingTaskWithValue<T>
    
    let confirmationStrategy: AsyncBlockingTaskConfirmationStrategy
    
    @State
    var taskError: Error? = nil
    
    @State
    var hudState = HUDState.none
    
    @State
    var isShowingConfirmation: Bool = false
    
    @State
    var confirmationContinuation: CheckedContinuation<Bool, Never>? = nil
    
    @State
    var confirmationTitle: String = ""
    
    @State
    var confirmationMessage: String? = nil
    
    @State
    var confirmationConfirmButtonTitle: String = ""
    
    @State
    var confirmationCancelButtonTitle: String = ""
    
    @State
    var isConfirmationDestructive: Bool = false
    
    let loadingMessage: String?
    let successMessage: String?
    let successDisplaySeconds: TimeInterval
    
    var body: some View {
        content
            .task(id: value) {
                guard let value = self.value else { return }
                defer { self.value = nil }
                
                switch confirmationStrategy {
                case .notRequired: break
                case .confirmWith(let title, let message, let confirm, let cancel, let destructive):
                    let didConfirm = await confirmAction(
                        confirmationTitle: title,
                        confirmationMessage: message,
                        confirmationConfirmButtonTitle: confirm,
                        confirmationCancelButtonTitle: cancel,
                        isConfirmationDestructive: destructive
                    )
                    if !didConfirm { return }
                }
                
                self.hudState = .loading(loadingMessage)
                
                do {
                    try await task(value)
                    self.hudState = .success(successMessage)
                    try? await Task.sleep(for: .seconds(successDisplaySeconds))
                    self.hudState = .none
                } catch {
                    withAnimation {
                        self.hudState = .none
                    } completion: {
                        taskError = error
                    }
                }
            }
            .errorAlert(error: $taskError)
            .hud(hudState: $hudState)
            .alert(confirmationTitle, isPresented: $isShowingConfirmation) {
                Button(role: isConfirmationDestructive ? .destructive : nil) {
                    handleConfirmation(true)
                } label: { Text(confirmationConfirmButtonTitle) }
                Button(role: .cancel) {
                    handleConfirmation(false)
                } label: { Text(confirmationCancelButtonTitle) }
            } message: {
                if let confirmationMessage {
                    Text(confirmationMessage)
                }
            }
    }
    
    @MainActor
    private func confirmAction(confirmationTitle: String, confirmationMessage: String?, confirmationConfirmButtonTitle: String, confirmationCancelButtonTitle: String, isConfirmationDestructive: Bool) async -> Bool {
        self.confirmationTitle = confirmationTitle
        self.confirmationMessage = confirmationMessage
        self.confirmationConfirmButtonTitle = confirmationConfirmButtonTitle
        self.confirmationCancelButtonTitle = confirmationCancelButtonTitle
        self.isConfirmationDestructive = isConfirmationDestructive
        return await withCheckedContinuation { continuation in
            confirmationContinuation = continuation
            isShowingConfirmation = true
        }
    }
    
    private func handleConfirmation(_ didConfirm: Bool) {
        isShowingConfirmation = false
        confirmationContinuation?.resume(returning: didConfirm)
        confirmationContinuation = nil
    }
}
