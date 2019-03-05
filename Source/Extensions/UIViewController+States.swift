//
//  UIViewController+States.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//

import UIKit


// MARK: - Error and Loading
@nonobjc
extension UIViewController {
    
    // MARK: - Loaders
    public func showLoadingView(_ loadingView: UIView, stateViewFrame: CGRect? = nil) {
        self.addStateView(loadingView, stateViewFrame: stateViewFrame)
    }
    
    public func showLoader(stateViewFrame: CGRect? = nil) {
        self.showLoadingView(LoadingView(), stateViewFrame: stateViewFrame)
    }
    
    public func hideLoader(stateViewFrame: CGRect? = nil) {
        self.removeStateView()
    }
    
    public func showErrorView(_ errorView: UIView, stateViewFrame: CGRect? = nil) {
        self.addStateView(errorView, stateViewFrame: stateViewFrame)
    }
    
    public func showErrorMessage(_ message: String, error: Error, retryButton: ButtonConfiguration? = nil, stateViewFrame: CGRect? = nil) {
        
        #if DEBUG
        let errorMessage = "\(message) \nError code: \(error.localizedDescription)"
        #else
        let errorMessage = message
        #endif
        
        let styler = TextStyler.styler
        let errorView = ErrorView(
            title: styler.attributedString("Error").bolded,
            message: styler.attributedString(errorMessage),
            buttonConfiguration: retryButton
        )
        showErrorView(errorView)
    }
    
    @objc(bsw_hideError)
    public func hideError() {
        self.removeStateView()
    }
    
    private func addStateView(_ stateView: UIView, stateViewFrame: CGRect?) {
        removeStateView()
        let stateVC = StateContainerViewController(stateView: stateView, backgroundColor: self.view.backgroundColor ?? .clear)
        addChild(stateVC)
        view.addSubview(stateVC.view)
        if let _stateViewFrame = stateViewFrame {
            stateVC.view.frame = _stateViewFrame
        } else {
            stateVC.view.pinToSuperview()
        }
        stateVC.didMove(toParent: self)
    }
    
    private func removeStateView() {
        guard let stateContainer = self.stateContainer else { return }
        stateContainer.willMove(toParent: nil)
        stateContainer.view.removeFromSuperview()
        stateContainer.removeFromParent()
    }
    
    
    private var stateContainer: StateContainerViewController? {
        return self.children.compactMap({ return $0 as? StateContainerViewController }).first
    }
}

public enum StateContainerAppereance {
    public static var padding: CGFloat = 20
}

@objc(BSWStateContainerViewController)
private class StateContainerViewController: UIViewController {
    
    let stateView: UIView
    let backgroundColor: UIColor
    init(stateView: UIView, backgroundColor: UIColor) {
        self.stateView = stateView
        self.backgroundColor = backgroundColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = self.backgroundColor
        view.addAutolayoutSubview(stateView)
        stateView.centerInSuperview()
        NSLayoutConstraint.activate([
                stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: StateContainerAppereance.padding),
                stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -StateContainerAppereance.padding),
            ])
    }
}
