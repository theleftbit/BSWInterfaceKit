
import SwiftUI

#if canImport(UIKit.UIViewController)

import UIKit

enum SwiftUIHUD {
    
    @MainActor
    static func presentHUDViewController(_ stateWrapper: HUDView.StateWrapper? = nil, configuration: HUDView.Configuration = .init()) async -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.visibleViewController else { return nil }
        let ___hudVC = UIHostingController(
            rootView: HUDView(
                stateWrapper: stateWrapper ?? .init(isSuccess: false),
                configuration: configuration
            )
            .environment(\.colorScheme, rootVC.traitCollection.userInterfaceStyle == .light ? .dark : .light)
        )
        ___hudVC.modalPresentationStyle = .overFullScreen
        ___hudVC.modalTransitionStyle = .crossDissolve
        ___hudVC.view.backgroundColor = .clear
        ___hudVC.view.isOpaque = false
        await rootVC.present(___hudVC, animated: true)
        return ___hudVC
    }
    
    @MainActor
    static func dismissHUDViewController(hudVC: UIViewController?, stateWrapper: HUDView.StateWrapper? = nil, configuration: HUDView.Configuration = .init()) async {
        guard let successMessage = configuration.successMessage else {
            await hudVC?.dismiss(animated: true)
            return
        }
        withAnimation {
            stateWrapper?.isSuccess = true
        }
        try? await Task.sleep(nanoseconds: UInt64(successMessage.timeInterval) * 1_000_000_000)
        await hudVC?.dismiss(animated: true)
        stateWrapper?.isSuccess = false
    }
}
#endif

struct HUDView: View {
    
    class StateWrapper: ObservableObject {
        init(isSuccess: Bool) {
            self.isSuccess = isSuccess
        }
        
        @Published
        var isSuccess: Bool
    }

    struct Configuration: Sendable {
        
        init(font: Font = .body, dimsBackground: Bool = false, loadingMessage: String? = nil, successMessage: SuccessMessage? = nil) {
            self.loadingMessage = loadingMessage
            self.dimsBackground = dimsBackground
            self.font = font
            self.successMessage = successMessage
        }
        
        let loadingMessage: String?
        let font: Font
        let dimsBackground: Bool
        let successMessage: SuccessMessage?
        
        struct SuccessMessage: Sendable {
            public init(message: String, timeInterval: TimeInterval = 3) {
                self.message = message
                self.timeInterval = timeInterval
            }
            
            let message: String
            let timeInterval: TimeInterval
        }
    }

    @ObservedObject
    var stateWrapper: StateWrapper
    
    let configuration: Configuration
    
    @ScaledMetric
    private var hudImageSize = 60.0
    
    @ScaledMetric
    private var hudContentSize = 120.0
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            hudImage
                .frame(width: hudImageSize, height: hudImageSize)
            if let textMessage {
                Text(textMessage)
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.default, value: stateWrapper.isSuccess)
        .font(configuration.font)
        .padding()
        .frame(minWidth: hudContentSize, minHeight: hudContentSize)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if configuration.dimsBackground {
                Color.black.opacity(0.2)
            }
        }
        .ignoresSafeArea()
    }
    
    private var textMessage: String? {
        if stateWrapper.isSuccess, let successMessage = configuration.successMessage {
            return successMessage.message
        } else if let loadingMessage = configuration.loadingMessage {
            return loadingMessage
        } else {
            return nil
        }
    }
    
    @ViewBuilder
    private var hudImage: some View {
        if stateWrapper.isSuccess {
            Image(systemName: "checkmark")
                .font(.largeTitle)
        } else {
            ProgressView()
                .tint(.primary)
                .scaleEffect(1.5)
        }
    }
}
