//
//  UIViewController+States.swift
//  Created by Pierluigi Cifani on 15/09/2018.
//

import UIKit


// MARK: - Error and Loading

extension UIViewController {
    
    // MARK: - Loaders
    @objc(bsw_showLoadingView:)
    public func showLoadingView(_ loadingView: UIView) {
        self.addStateView(loadingView)
    }
    
    @objc(bsw_showLoader)
    public func showLoader() {
        self.showLoadingView(LoadingView())
    }
    
    @objc(bsw_hideLoader)
    public func hideLoader() {
        self.removeStateView()
    }
    
    @objc(bsw_showErrorView:)
    public func showErrorView(_ errorView: UIView) {
        self.addStateView(errorView)
    }
    
    public func showErrorMessage(_ message: String, error: Error, retryButton: ButtonConfiguration? = nil) {
        
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
    
    private func addStateView(_ stateView: UIView) {
        removeStateView()
        let stateVC = StateContainerViewController(stateView: stateView)
        addChild(stateVC)
        view.addAutolayoutSubview(stateVC.view)
        stateVC.view.pinToSuperview()
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
    public static var backgroundColor = UIColor.white
    public static var padding: CGFloat = 20
}

@objc(BSWStateContainerViewController)
private class StateContainerViewController: UIViewController {
    
    let stateView: UIView
    
    init(stateView: UIView) {
        self.stateView = stateView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StateContainerAppereance.backgroundColor
        view.addAutolayoutSubview(stateView)
        stateView.centerInSuperview()
        NSLayoutConstraint.activate([
                stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: StateContainerAppereance.padding),
                stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -StateContainerAppereance.padding),
            ])
    }
}
