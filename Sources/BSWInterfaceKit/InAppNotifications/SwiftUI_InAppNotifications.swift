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
                event = .message("Forza Milan")
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
    let text: String
    let kind: Kind
    enum Kind { case message, error }
    
    public static func message(_ txt: String) -> InAppNotificationEvent {
        .init(text: txt, kind: .message)
    }
    public static func error(_ txt: String) -> InAppNotificationEvent {
        .init(text: txt, kind: .error)
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
            guard event != nil else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                isVisible = true
            }
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeIn(duration: 0.2)) {
                isVisible = false
            }
        }
    }
    
    @ViewBuilder
    private func toastView(_ event: InAppNotificationEvent) -> some View {
        Text(event.text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(event.kind.bgColor.opacity(0.85)))
            .shadow(radius: 8)
    }
}

// MARK: Extensions

private extension InAppNotificationEvent.Kind {
    
    var bgColor: Color {
        switch self {
        case .message: return .green
        case .error: return .red
        }
    }
}
