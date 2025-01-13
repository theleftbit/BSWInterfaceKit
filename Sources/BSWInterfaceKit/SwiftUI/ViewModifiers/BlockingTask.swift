//
//  Created by Michele Restuccia on 13/1/25.
//

#if canImport(UIKit)

import SwiftUI; import UIKit

public typealias BlockingTask = @MainActor () async throws -> ()
public typealias BlockingReturnTask = @MainActor (String) async throws -> ()
public typealias BlockingTaskWithValue<T: Equatable> = @MainActor (T) async throws -> ()
public typealias BlockingReturnTaskWithValue<T: Equatable> = @MainActor (BlockingTaskReturn<T>) async throws -> ()

public struct BlockingTaskReturn<T: Equatable> {
    public let task: T
    public let textFieldValue: String
}

public extension View {
    
    func performBlockingTask(readyToPerform: Binding<Bool>, task: @escaping BlockingTask) -> some View {
        self.modifier(PerformBlockingModifier(readyToPerform: readyToPerform, task: task))
    }
    
    func performBlockingTaskAfterConfirmation(
        presentingAlert: Binding<Bool>,
        titleAlert: String,
        messageAlert: String? = nil,
        textFieldTitle: String? = nil,
        buttonAlert: String = NSLocalizedString("accept", bundle: Bundle.main, comment: ""),
        buttonRole: ButtonRole? = nil,
        task: @escaping BlockingReturnTask) -> some View {
            self.modifier(PerformBlockingAfterConfirmationModifier(
                presentingAlert: presentingAlert,
                titleAlert: titleAlert,
                messageAlert: messageAlert,
                textFieldTitle: textFieldTitle,
                buttonAlert: buttonAlert,
                buttonRole: buttonRole,
                task: task
            ))
        }

    func performBlockingTask<T: Equatable>(value: Binding<T?>, task: @escaping BlockingTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifier(value: value, task: task))
    }
    
    func performBlockingTaskAfterConfirmation<T: Equatable>(
        value: Binding<T?>,
        titleAlert: String,
        messageAlert: String? = nil,
        textFieldTitle: String? = nil,
        buttonAlert: String = NSLocalizedString("accept", bundle: Bundle.main, comment: ""),
        buttonRole: ButtonRole? = nil,
        task: @escaping BlockingReturnTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifierAfterConfirmationModifier(
            value: value,
            titleAlert: titleAlert,
            messageAlert: messageAlert,
            textFieldTitle: textFieldTitle,
            buttonAlert: buttonAlert,
            buttonRole: buttonRole,
            task: task
        ))
    }
}

// MARK: PerformBlockingModifier

private struct PerformBlockingModifier: ViewModifier {
    
    @Binding
    var readyToPerform: Bool
    
    let task: BlockingTask
    
    private enum Phase {
        case idle
        case loading
    }
    
    @State
    private var phase: Phase = .idle
    
    @State
    private var hudVC: UIViewController?
    
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                guard phase == .loading else { return }
                hudVC = await presentHUDViewController()
                do {
                    try await task()
                } catch {
                    taskError = error
                }
                await dismissHUDViewController(hudVC: hudVC)
                readyToPerform = false
                self.phase = .idle
            }
            .onChange(of: readyToPerform) { newValue in
                if newValue {
                    self.phase = .loading
                }
            }
            .errorAlert(error: $taskError)
    }
}

// MARK: PerformEquatableBlockingModifier

private struct PerformEquatableBlockingModifier<T: Equatable>: ViewModifier {
    
    @Binding
    var value: T?
    
    let task: BlockingTaskWithValue<T>
        
    @State
    private var hudVC: UIViewController?
    
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: value) {
                guard let value = self.value else { return }
                hudVC = await presentHUDViewController()
                do {
                    try await task(value)
                } catch {
                    taskError = error
                }
                await dismissHUDViewController(hudVC: hudVC)
                self.value = nil
            }
            .errorAlert(error: $taskError)
    }
}

// MARK: PerformBlockingAfterConfirmationModifier

private struct PerformBlockingAfterConfirmationModifier: ViewModifier {
    
    @Binding
    var presentingAlert: Bool
    
    let titleAlert: String
    let messageAlert: String?
    let textFieldTitle: String?
    let buttonAlert: String
    let buttonRole: ButtonRole?
    let task: BlockingReturnTask
    
    @State
    private var readyToPerform: Bool = false
    
    @State
    private var hudVC: UIViewController?
    
    @State
    private var textFieldValue: String = ""
    
    @State
    private var phase: Phase = .idle
    private enum Phase {
        case idle, loading
    }
    
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                guard phase == .loading else { return }
                hudVC = await presentHUDViewController()
                do {
                    try await task(textFieldValue)
                } catch {
                    taskError = error
                }
                await dismissHUDViewController(hudVC: hudVC)
                readyToPerform = false
                textFieldValue = ""
                self.phase = .idle
            }
            .onChange(of: readyToPerform) { newValue in
                if newValue {
                    self.phase = .loading
                }
            }
            .errorAlert(error: $taskError)
            .modifier(BlockingAlertView(
                titleAlert: titleAlert,
                messageAlert: messageAlert,
                textFieldTitle: textFieldTitle,
                buttonAlert: buttonAlert,
                buttonRole: buttonRole,
                presentingAlert: $presentingAlert,
                readyToPerform: $readyToPerform,
                textFieldValue: $textFieldValue
            ))
    }
}

// MARK: PerformEquatableBlockingModifierAfterConfirmationModifier

private struct PerformEquatableBlockingModifierAfterConfirmationModifier<T: Equatable>: ViewModifier {
    
    @Binding
    var value: T?
    
    let titleAlert: String
    let messageAlert: String?
    let textFieldTitle: String?
    let buttonAlert: String
    let buttonRole: ButtonRole?
    let task: BlockingReturnTaskWithValue<T>
        
    @State
    private var hudVC: UIViewController?
    
    @State
    private var presentingAlert: Bool = false
    
    @State
    private var readyToPerform: Bool = false
    
    @State
    private var taskError: Error? = nil
    
    @State
    private var textFieldValue: String = ""
    
    func body(content: Content) -> some View {
        content
            .task(id: value) {
                guard let _ = self.value else { return }
                presentingAlert = true
            }
            .task(id: readyToPerform) {
                guard let value = self.value else { return }
                hudVC = await presentHUDViewController()
                do {
                    try await task(.init(task: value, textFieldValue: textFieldValue))
                } catch {
                    taskError = error
                }
                await dismissHUDViewController(hudVC: hudVC)
                readyToPerform = false
                textFieldValue = ""
                self.value = nil
            }
            .errorAlert(error: $taskError)
            .modifier(BlockingAlertView(
                titleAlert: titleAlert,
                messageAlert: messageAlert,
                textFieldTitle: textFieldTitle,
                buttonAlert: buttonAlert,
                buttonRole: buttonRole,
                presentingAlert: $presentingAlert,
                readyToPerform: $readyToPerform,
                textFieldValue: $textFieldValue
            ))
    }
}

// MARK: BlockingAlertView

private struct BlockingAlertView: ViewModifier {
    
    let titleAlert: String
    let messageAlert: String?
    let textFieldTitle: String?
    let buttonAlert: String
    let buttonRole: ButtonRole?
        
    @Binding
    var presentingAlert: Bool
    
    @Binding
    var readyToPerform: Bool
    
    @Binding
    var textFieldValue: String
    
    func body(content: Content) -> some View {
        content
            .alert(
                titleAlert,
                isPresented: $presentingAlert,
                actions: {
                    if let textFieldTitle {
                        TextField(textFieldTitle, text: $textFieldValue)
//                            .naturitasFont(forTextStyle: .footnote)
//                            .foregroundStyle(Color(.naturitasTextTitleColor))
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    Button("cancel".localized, role: .cancel) { }
                    Button(buttonAlert, role: buttonRole, action: {
                        readyToPerform = true
                    })
                    .disabled({
                        if textFieldTitle != nil {
                            return textFieldValue.isEmpty
                        } else {
                            return false
                        }
                    }())
                },
                message: {
                    if let messageAlert {
                        Text(messageAlert)
                    }
                }
            )
    }
}

// MARK: HUDView

private struct HUDView: View {
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .frame(width: 60, height: 60)
        }
        .transition(.scale.combined(with: .opacity))
        .padding()
        .frame(minWidth: 100, minHeight: 100)
        .aspectRatio(1, contentMode: .fit)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

@MainActor
private func presentHUDViewController() async -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
          let rootVC = windowScene.keyWindow?.visibleViewController else { return nil }
    let ___hudVC = UIHostingController(rootView: HUDView())
    ___hudVC.modalPresentationStyle = .overCurrentContext
    ___hudVC.modalTransitionStyle = .crossDissolve
    ___hudVC.view.backgroundColor = .clear
    ___hudVC.view.isOpaque = false
    await rootVC.present(___hudVC, animated: true)
    return ___hudVC
}

@MainActor
private func dismissHUDViewController(hudVC: UIViewController?) async {
    await hudVC?.dismiss(animated: true)
}

#endif
