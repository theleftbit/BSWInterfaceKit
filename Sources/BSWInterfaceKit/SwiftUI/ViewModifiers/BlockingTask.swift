//
//  Created by Michele Restuccia on 13/1/25.
//

#if canImport(SwiftUI)

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
        value: $perform,
        confirmationStrategy: .confirmWith(title: "Are you sure?", message: "This will block the main thread for 2 seconds.", confirmButtonTitle: "Yes", cancelButtonTitle: "No"),
        task: { _ in
            try await Task.sleep(for: .seconds(2))
        }
    )
}

public typealias AsyncBlockingTask = @MainActor () async throws -> ()
public typealias AsyncBlockingTaskWithValue<T: Equatable> = @MainActor (T) async throws -> ()
public enum AsyncBlockingTaskConfirmationStrategy {
    case notRequired
    case confirmWith(title: String, message: String?, confirmButtonTitle: String, cancelButtonTitle: String, isDestructiveAction: Bool = false)
}

public extension View {
    
    func performBlockingTask<T: Equatable>(value: Binding<T?>, confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired, task: @escaping AsyncBlockingTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifier(value: value, task: task, confirmationStrategy: confirmationStrategy))
    }

    func performBlockingTask(value: Binding<Bool>, confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired, task: @escaping AsyncBlockingTaskWithValue<Bool>) -> some View {
        self.modifier(
            PerformEquatableBlockingModifier(
                value: .init(
                    get: {
                        value.wrappedValue ? true : nil
                    },
                    set: {
                        if let _ = $0 {
                            value.wrappedValue = true
                        } else {
                            value.wrappedValue = false
                        }
                    }),
                task: task,
                confirmationStrategy: confirmationStrategy
            )
        )
    }
}

// MARK: Private

private struct PerformEquatableBlockingModifier<T: Equatable>: ViewModifier {
    
    @Binding
    var value: T?
    
    let task: AsyncBlockingTaskWithValue<T>
    
    let confirmationStrategy: AsyncBlockingTaskConfirmationStrategy
    
    @State
    private var taskError: Error? = nil
    
    @State
    private var hudState = HUDState.none
    
    @State private var isShowingConfirmation: Bool = false
    @State private var confirmationContinuation: CheckedContinuation<Bool, Never>? = nil
    @State private var confirmationTitle: String = ""
    @State private var confirmationMessage: String? = nil
    @State private var confirmationConfirmButtonTitle: String = ""
    @State private var confirmationCancelButtonTitle: String = ""
    @State private var isConfirmationDestructive: Bool = false
    
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
