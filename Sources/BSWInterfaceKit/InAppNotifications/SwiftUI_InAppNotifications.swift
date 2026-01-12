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
    var message: String?
    
    @State
    var kind: ToastView.Kind = .message

    var body: some View {
        VStack(spacing: 16) {
            Button("Show Message") {
                kind = .message
                message = "Forza Milan"
            }
            Button("Show Error") {
                kind = .error
                message = "Something went wrong"
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(ToastView(message: $message, kind: kind))
    }
}

#endif

// MARK: Extensions

public extension View {
    
    func showNotification(message: Binding<String?>) -> some View {
        modifier(ToastView(message: message, kind: .message))
    }
    
    func showNotificationError(message: Binding<String?>) -> some View {
        modifier(ToastView(message: message, kind: .error))
    }
}

// MARK: ToastView

struct ToastView: ViewModifier {

    let message: Binding<String?>
    
    let kind: Kind
    enum Kind {
        case message, error
        
        var bgColor: Color {
            switch self {
            case .message: return .green
            case .error: return .red
            }
        }
    }

    @State
    var isVisible: Bool = false
    
    @State
    var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let message = message.wrappedValue {
                toastView(message)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )
                    .padding(16)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -40)
                    #if canImport(Darwin)
                    .allowsHitTesting(false)
                    #endif
                    .onAppear { scheduleDismiss() }
            }
        }
    }
    
    // MARK: ViewBuilders

    @ViewBuilder
    private func toastView(_ message: String) -> some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(kind.bgColor.opacity(0.85))
            )
            .shadow(radius: 8)
    }
        
    private func scheduleDismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            isVisible = true
        }
        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeIn(duration: 0.2)) {
                isVisible = false
            }
            try? await Task.sleep(for: .seconds(2))
            message.wrappedValue = nil
        }
    }
}
