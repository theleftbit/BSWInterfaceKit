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

public struct BlockingAlertConfiguration {
    let titleAlert: String
    let messageAlert: String?
    let textFieldTitle: String?
    let buttonAlert: String
    let buttonRole: ButtonRole?
    
    public init(
        titleAlert: String,
        messageAlert: String? = nil,
        textFieldTitle: String? = nil,
        buttonAlert: String = NSLocalizedString("accept", bundle: Bundle.main, comment: ""),
        buttonRole: ButtonRole? = nil
    ) {
        self.titleAlert = titleAlert
        self.messageAlert = messageAlert
        self.textFieldTitle = textFieldTitle
        self.buttonAlert = buttonAlert
        self.buttonRole = buttonRole
    }
}

public extension View {
    
    func performBlockingTask(readyToPerform: Binding<Bool>, font: Font = .body, task: @escaping BlockingTask) -> some View {
        self.modifier(PerformBlockingModifier(readyToPerform: readyToPerform, font: font, task: task))
    }
    
    func performBlockingTaskAfterConfirmation(presentingAlert: Binding<Bool>, alert: BlockingAlertConfiguration, font: Font = .body, task: @escaping BlockingReturnTask) -> some View {
        self.modifier(PerformBlockingAfterConfirmationModifier(
            presentingAlert: presentingAlert, alert: alert, font: font, task: task
        ))
    }
    
    func performBlockingTask<T: Equatable>(value: Binding<T?>, font: Font = .body, task: @escaping BlockingTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifier(value: value, font: font, task: task))
    }
    
    func performBlockingTaskAfterConfirmation<T: Equatable>(value: Binding<T?>, alert: BlockingAlertConfiguration, font: Font = .body, task: @escaping BlockingReturnTaskWithValue<T>) -> some View {
        self.modifier(PerformEquatableBlockingModifierAfterConfirmationModifier(value: value, alert: alert, font: font, task: task
        ))
    }
}

// MARK: PerformBlockingModifier

private struct PerformBlockingModifier: ViewModifier {
    
    @Binding
    var readyToPerform: Bool
    
    let font: Font
    let task: BlockingTask
    
    @State
    private var phase: Phase = .idle
    private enum Phase {
        case idle
        case loading
    }
    
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: phase) {
                guard phase == .loading else { return }
                do {
                    try await performWithHUD(task: task, font: font)
                } catch {
                    taskError = error
                }
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
    
    let font: Font
    let task: BlockingTaskWithValue<T>
    
    @State
    private var taskError: Error? = nil
    
    func body(content: Content) -> some View {
        content
            .task(id: value) {
                guard let value = self.value else { return }
                do {
                    try await performWithHUD(
                        task: { try await task(value) },
                        font: font
                    )
                } catch {
                    taskError = error
                }
                self.value = nil
            }
            .errorAlert(error: $taskError)
    }
}

// MARK: PerformBlockingAfterConfirmationModifier

private struct PerformBlockingAfterConfirmationModifier: ViewModifier {
    
    @Binding
    var presentingAlert: Bool
    
    let alert: BlockingAlertConfiguration
    let font: Font
    let task: BlockingReturnTask
    
    @State
    private var readyToPerform: Bool = false
    
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
                do {
                    try await performWithHUD(
                        task: { try await task(textFieldValue) },
                        font: font
                    )
                } catch {
                    taskError = error
                }
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
                configuration: alert,
                font: font,
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
    
    let alert: BlockingAlertConfiguration
    let font: Font
    let task: BlockingReturnTaskWithValue<T>
    
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
                do {
                    try await performWithHUD(
                        task: { try await task(.init(task: value, textFieldValue: textFieldValue)) },
                        font: font
                    )
                } catch {
                    taskError = error
                }
                readyToPerform = false
                textFieldValue = ""
                self.value = nil
            }
            .errorAlert(error: $taskError)
            .modifier(BlockingAlertView(
                configuration: alert,
                font: font,
                presentingAlert: $presentingAlert,
                readyToPerform: $readyToPerform,
                textFieldValue: $textFieldValue
            ))
    }
}

// MARK: BlockingAlertView

private struct BlockingAlertView: ViewModifier {
    
    let configuration: BlockingAlertConfiguration
    let font: Font
    
    @Binding
    var presentingAlert: Bool
    
    @Binding
    var readyToPerform: Bool
    
    @Binding
    var textFieldValue: String
    
    func body(content: Content) -> some View {
        content
            .alert(
                configuration.titleAlert,
                isPresented: $presentingAlert,
                actions: {
                    if let textFieldTitle = configuration.textFieldTitle {
                        TextField(textFieldTitle, text: $textFieldValue)
                            .font(font)
                            .foregroundStyle(Color(uiColor: .label))
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    Button("dismiss".localized, role: .cancel) { }
                    Button(configuration.buttonAlert, role: configuration.buttonRole, action: {
                        readyToPerform = true
                    })
                    .disabled({
                        if configuration.textFieldTitle != nil {
                            return textFieldValue.isEmpty
                        } else {
                            return false
                        }
                    }())
                },
                message: {
                    if let messageAlert = configuration.messageAlert {
                        Text(messageAlert)
                            .font(font)
                            .foregroundStyle(Color(uiColor: .label))
                    }
                }
            )
    }
}

// MARK: PerformWithHUD

@MainActor
func performWithHUD(task: @escaping () async throws -> Void, font: Font) async throws {
    var hudVC: UIViewController?
    hudVC = await presentHUDViewController(font: font)
    try await task()
    await hudVC?.dismiss(animated: true)
}

// MARK: PresentHUDViewController

@MainActor
private func presentHUDViewController(font: Font) async -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
          let rootVC = windowScene.keyWindow?.visibleViewController else { return nil }
    let ___hudVC = UIHostingController(
        rootView: HUDView(
            font: font
        )
    )
    ___hudVC.modalPresentationStyle = .overCurrentContext
    ___hudVC.modalTransitionStyle = .crossDissolve
    ___hudVC.view.backgroundColor = .clear
    ___hudVC.view.isOpaque = false
    await rootVC.present(___hudVC, animated: true)
    return ___hudVC
}

// MARK: HUDView

private struct HUDView: View {
    
    let font: Font
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
                .frame(width: 60, height: 60)
            
            Text("loader-message".localized)
                .font(font)
                .foregroundColor(.white)
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

#endif
