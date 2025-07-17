//
//  Created by Michele Restuccia on 13/1/25.
//

#if canImport(Darwin)
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
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
            try await Task.sleep(for: .seconds(2))
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
    
    func performBlockingTask<T: Equatable>(value: Binding<T?>, confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired, task: @escaping AsyncBlockingTaskWithValue<T>) -> some View {
        #if canImport(Darwin)
        self.modifier(PerformEquatableBlockingModifier(value: value, task: task, confirmationStrategy: confirmationStrategy))
        #else
        self
        #endif
    }

    func performBlockingTask(readyToPerform: Binding<Bool>, confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired, task: @escaping AsyncBlockingTask) -> some View {
        #if canImport(Darwin)
        self.modifier(
            PerformEquatableBlockingModifier(
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
                    }),
                task: { _ in try await task() },
                confirmationStrategy: confirmationStrategy
            )
        )
        #else
        self
        #endif
    }
}

// MARK: Private

#if canImport(Darwin)
/// Not available on Android until https://github.com/skiptools/skip/issues/466 is addressed
struct PerformEquatableBlockingModifier<T: Equatable>: ViewModifier {
    
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
    
    func body(content: Content) -> some View {
        content
            .task(id: value) {
                guard let value = self.value else { return }
                defer {
                    self.value = nil
                }
                
                switch confirmationStrategy {
                case .notRequired:
                    break
                case .confirmWith(let title, let message, let confirmButtonTitle, let cancelButtonTitle, let isDestructiveAction):
                    let didConfirm = await confirmAction(confirmationTitle: title, confirmationMessage: message, confirmationConfirmButtonTitle: confirmButtonTitle, confirmationCancelButtonTitle: cancelButtonTitle, isConfirmationDestructive: isDestructiveAction)
                    if didConfirm == false {
                        return
                    }
                }

                self.hudState = .loading()
                
                do {
                    try await task(value)
                } catch {
                    taskError = error
                }
                self.hudState = .none
            }
            .errorAlert(error: $taskError)
            .hud(hudState: $hudState)
            .alert(confirmationTitle, isPresented: $isShowingConfirmation) {
                Button(role: isConfirmationDestructive ? .destructive : nil) {
                    handleConfirmation(true)
                } label: {
                    Text(confirmationConfirmButtonTitle)
                }
                Button(role: .cancel) {
                    handleConfirmation(false)
                } label: {
                    Text(confirmationCancelButtonTitle)
                }
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
#endif
