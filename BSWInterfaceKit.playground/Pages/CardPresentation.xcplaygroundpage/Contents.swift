//: [Previous](@previous)

import PlaygroundSupport
import BSWInterfaceKit
import UIKit

class RootVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

class PresentedVC: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
    }
}

extension PresentedVC: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let properties = CardPresentation.AnimationProperties(
            cardHeight: 300,
            animationDuration: 5,
            kind: .presentation
        )

        return CardPresentation.transitioningFor(properties: properties)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardPresentation.transitioningFor(kind: .dismissal)
    }
}


let rootVC = RootVC()
let presentedVC = PresentedVC()

PlaygroundPage.current.liveView = rootVC

rootVC.present(presentedVC, animated: true) {

}


//: [Next](@next)
