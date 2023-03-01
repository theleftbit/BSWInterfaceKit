//
//  Created by Pierluigi Cifani on 09/09/2019.
//  Copyright © 2019 The Left Bit. All rights reserved.
//
#if canImport(UIKit)

import BSWInterfaceKit
import UIKit

class CardPresentationViewControllerTests: BSWSnapshotTest {

    func _testSampleLayout() {
        let navVC = UINavigationController(rootViewController: SampleVC())
        debug(viewController: navVC)
    }
}

private class SampleVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let button: UIButton = {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = TextStyler.styler.attributedStringConfiguration("Try Me")
            config.contentInsets = .init(uniform: 5)
            return .init(configuration: config, primaryAction: UIAction(handler: { action in
                let vc = FooVC()
                vc.transitioningDelegate = self
                self.present(vc, animated: true, completion: nil)
            }))
        }()
        view.addAutolayoutSubview(button)
        button.centerInSuperview()
    }
}

private class FooVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        let someView = UIView()
        someView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        view.addAutolayoutSubview(someView)
        someView.pinToSuperview()
    }
}

extension SampleVC: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let properties = CardPresentation.AnimationProperties(
            kind: .presentation(position: .top),
            animationDuration: 2,
            presentationInsideSafeArea: true,
            backgroundColor: .clear,
            shouldAnimateNewVCAlpha: false
        )
        return CardPresentation.transitioningFor(properties: properties)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let properties = CardPresentation.AnimationProperties(
            kind: .dismissal,
            animationDuration: 2,
            presentationInsideSafeArea: true,
            backgroundColor: .clear,
            shouldAnimateNewVCAlpha: false
        )
        return CardPresentation.transitioningFor(properties: properties)
    }
}

#endif
