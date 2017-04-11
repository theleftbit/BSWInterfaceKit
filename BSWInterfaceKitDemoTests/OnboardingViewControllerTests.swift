//
//  Created by Pierluigi Cifani on 11/04/2017.
//

@testable import BSWInterfaceKit
import XCTest

class OnboardingViewControllerTests: BSWSnapshotTest {

    func testLayoutWithBackgroundColor() {
        let vc = OnboardingViewController()
        vc.onboardingCustomization = OnboardingCustomization(background: OnboardingCustomization.Background.color(.blue), appLogo: #imageLiteral(resourceName: "women"), appSlogan: TextStyler.styler.attributedString("Making Apps Great Again"), statusBarStyle: .lightContent)
        waitABitAndVerify(viewController: vc)
    }
}
