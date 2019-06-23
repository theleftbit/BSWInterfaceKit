//
//  File.swift
//  Created by Pierluigi Cifani on 20/06/2019.
//

import SwiftUI

@available(iOS 13.0, *)
public struct Loading: UIViewRepresentable {
    
    private let loadingMessage: NSAttributedString?
    private let activityIndicatorStyle: UIActivityIndicatorView.Style
    
    public init(loadingMessage: NSAttributedString? = nil, activityIndicatorStyle: UIActivityIndicatorView.Style = .medium) {
        self.loadingMessage = loadingMessage
        self.activityIndicatorStyle = activityIndicatorStyle
    }
    
    public func makeUIView(context: Self.Context) -> LoadingView {
        return LoadingView(loadingMessage: loadingMessage, activityIndicatorStyle: activityIndicatorStyle)
    }
    public func updateUIView(_ uiView: LoadingView, context: Self.Context) {}
}
