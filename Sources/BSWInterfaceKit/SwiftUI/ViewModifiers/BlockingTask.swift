//
//  Created by Michele Restuccia on 13/1/25.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @State
    @Previewable
    var perform: Int? = nil
    
    Button {
        perform = 44
    } label: {
        Text("Trigger Job")
    }
    .performBlockingTask(
        value: $perform,
        confirmationStrategy: .confirmWith(
            title: "Are you sure?",
            message: nil,
            confirmButtonTitle: "Yes I am",
            cancelButtonTitle: "Nope",
            isDestructiveAction: false
        ),
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
    
    func performBlockingTask(readyToPerform: Binding<Bool>, confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired, task: @escaping AsyncBlockingTask) -> some View {
        self.modifier(PerformBlockingModifier(readyToPerform: readyToPerform, task: task, confirmationStrategy: confirmationStrategy))
    }

    func performBlockingTask<T: Equatable>(value: Binding<T?>, confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = .notRequired, task: @escaping AsyncBlockingTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifier(value: value, task: task, confirmationStrategy: confirmationStrategy))
    }
}

// MARK: Private

private struct PerformBlockingModifier: ViewModifier {
    
    @Binding
    var readyToPerform: Bool
    
    let task: AsyncBlockingTask
            
    let confirmationStrategy: AsyncBlockingTaskConfirmationStrategy
    
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: readyToPerform) {
                guard readyToPerform else { return }
                defer {
                    self.readyToPerform = false
                }
                #if canImport(UIKit.UIViewController)
                if case .confirmWith(let title, let message, let confirmButtonTitle, let cancelButtonTitle, let isDestructiveAction) = confirmationStrategy {
                    let didConfirm = await SwiftUIAlerts.presentAlert(
                        title: title,
                        message: message,
                        cancelButtonTitle: cancelButtonTitle,
                        confirmButtonTitle: confirmButtonTitle,
                        isConfirmButtonDestructive: isDestructiveAction
                    )
                    guard didConfirm else {
                        return
                    }
                }
                async let ___vc = SwiftUIHUD.presentHUDViewController()
                #endif
                do {
                    try await task()
                } catch {
                    taskError = error
                }
                #if canImport(UIKit.UIViewController)
                let vc = await ___vc
                if let vc {
                    await SwiftUIHUD.dismissHUDViewController(hudVC: vc)
                }
                #endif
            }
            .errorAlert(error: $taskError)
    }
}

private struct PerformEquatableBlockingModifier<T: Equatable>: ViewModifier {
    
    @Binding
    var value: T?
    
    let task: AsyncBlockingTaskWithValue<T>
           
    let confirmationStrategy: AsyncBlockingTaskConfirmationStrategy

    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: value) {
                guard let value = self.value else { return }
                defer {
                    self.value = nil
                }

                #if canImport(UIKit.UIViewController)
                if case .confirmWith(let title, let message, let confirmButtonTitle, let cancelButtonTitle, let isDestructiveAction) = confirmationStrategy {
                    let didConfirm = await SwiftUIAlerts.presentAlert(
                        title: title,
                        message: message,
                        cancelButtonTitle: cancelButtonTitle,
                        confirmButtonTitle: confirmButtonTitle,
                        isConfirmButtonDestructive: isDestructiveAction
                    )
                    guard didConfirm else {
                        return
                    }
                }
                async let ___vc = SwiftUIHUD.presentHUDViewController()
                #endif
                do {
                    try await task(value)
                } catch {
                    taskError = error
                }
                #if canImport(UIKit.UIViewController)
                let vc = await ___vc
                if let vc {
                    await SwiftUIHUD.dismissHUDViewController(hudVC: vc)
                }
                #endif
            }
            .errorAlert(error: $taskError)
    }
}


private struct BlockingAlertView: ViewModifier {
    
    let title: String
    let message: String?
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    let isDestructiveAction: Bool
    
    @Binding
    var presentingAlert: Bool
    
    @Binding
    var readyToPerform: Bool
        
    func body(content: Content) -> some View {
        content
            .alert(
                title,
                isPresented: $presentingAlert,
                actions: {
                    Button(cancelButtonTitle, role: .cancel) { }
                    Button(confirmButtonTitle, role: isDestructiveAction ? .destructive : nil, action: {
                        readyToPerform = true
                    })
                },
                message: {
                    if let messageAlert = message {
                        Text(messageAlert)
                    }
                }
            )
    }
}

#endif
