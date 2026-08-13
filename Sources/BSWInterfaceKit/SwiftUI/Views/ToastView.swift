//
//  Created by Michele Restuccia on 12/1/26.
//

import SwiftUI

#if canImport(Darwin)

// MARK: Previews

#Preview() {
    SampleView()
}

private struct SampleView: View {
    
    @State
    var event: InAppNotificationEvent?
    
    @State
    var count: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Show Message") {
                event = .message(
                    "Forza Milan",
                    message: "Forza lotta vincerai, non ti lasceremo mai",
                    icon: Image(systemName: "star.circle.fill"),
                    backgroundColor: .green,
                    dismissDelay: 5
                )
            }
            Button("Show Error") {
                count += 1
                event = .error("Error #\(count)")
            }
        }
        .showInAppNotification($event)
    }
}

#endif

// MARK: Extensions

public extension View {
    
    func showInAppNotification(_ event: Binding<InAppNotificationEvent?>) -> some View {
        modifier(ToastView(event: event))
    }
}

// MARK: InAppNotificationEvent

public struct InAppNotificationEvent: Equatable, Identifiable {
    public let id = UUID()
    let title: String
    let message: String?
    let icon: Image?
    let backgroundColor: Color
    let dismissDelay: TimeInterval
    
    let kind: Kind
    enum Kind { case message, error }
    
    /// Creates an in-app notification event to inform the user about
    /// a non-critical action or state change.
    ///
    /// - Parameters:
    ///   - title: The main title displayed in the notification.
    ///   - message: An optional message providing additional context.
    ///   - icon: An optional icon displayed next to the title.
    ///   - backgroundColor: The background color of the notification.
    ///   - dismissDelay: The amount of time (in seconds) before the notification is automatically dismissed.
    /// - Returns: An in-app notification event configured as a message.
    public static func message(
        _ title: String,
        message: String? = nil,
        icon: Image? = nil,
        backgroundColor: Color = .green,
        dismissDelay: TimeInterval = 2
    ) -> InAppNotificationEvent {
        .init(
            title: title,
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            dismissDelay: dismissDelay,
            kind: .message
        )
    }
    
    /// Creates an in-app notification event to inform the user about
    /// an error or a failed operation.
    ///
    /// - Parameters:
    ///   - title: The main title describing the error.
    ///   - message: An optional message with additional details.
    ///   - icon: An optional icon displayed next to the title.
    ///   - backgroundColor: The background color of the notification.
    ///   - dismissDelay: The amount of time (in seconds) before the notification is automatically dismissed.
    /// - Returns: An in-app notification event configured as an error.
    public static func error(
        _ title: String,
        message: String? = nil,
        icon: Image? = nil,
        backgroundColor: Color = .red,
        dismissDelay: TimeInterval = 2
    ) -> InAppNotificationEvent {
        .init(
            title: title,
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            dismissDelay: dismissDelay,
            kind: .error
        )
    }
}

// MARK: ToastView

struct ToastView: ViewModifier {
    
    @Binding
    var event: InAppNotificationEvent?
    
    @State
    var isVisible = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let event {
                toastView(event)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(16)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -40)
                    #if canImport(Darwin)
                    .allowsHitTesting(false)
                    #endif
            }
        }
        .task(id: event?.id) {
            guard let event else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                isVisible = true
            }
            try? await Task.sleep(for: .seconds(event.dismissDelay))
            withAnimation(.easeIn(duration: 0.2)) {
                isVisible = false
            }
        }
    }
    
    @ViewBuilder
    private func toastView(_ event: InAppNotificationEvent) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                if let icon = event.icon {
                    icon
                }
                Text(event.title)
            }
            if let message = event.message {
                Text(message)
            }
        }
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(event.backgroundColor.opacity(0.85)))
        .shadow(radius: 8)
    }
}
