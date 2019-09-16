//
//  Created by Pierluigi Cifani on 06/03/2019.
//

import BSWInterfaceKit
import UIKit

class AlertOperationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let singleAlertButton = UIButton(buttonConfiguration: {
            return ButtonConfiguration(title: "Show Error", titleColor: self.view.tintColor) { [weak self] in
                guard let `self` = self else { return }
                self.showErrorAlert("Hello, it's me", error: SomeError())
            }
        }())

        let multipleAlertButton = UIButton(buttonConfiguration: {
            return ButtonConfiguration(title: "Show Multiple Errors", titleColor: self.view.tintColor) { [weak self] in
                guard let `self` = self else { return }
                self.showErrorAlert("Hello, it's me v1", error: SomeError())
                self.showErrorAlert("Hello, it's me v2", error: SomeError())
            }
        }())

        let dismissAndShowAlertButton = UIButton(buttonConfiguration: {
            return ButtonConfiguration(title: "Dismiss and present error", titleColor: self.view.tintColor) { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popViewController(animated: true)
                self.showErrorAlert("Hello, it's me!", error: SomeError())
            }
        }())

        let stackView = UIStackView(arrangedSubviews: [singleAlertButton, multipleAlertButton, dismissAndShowAlertButton])
        stackView.spacing = 5
        stackView.axis = .vertical
        view.addAutolayoutSubview(stackView)
        stackView.centerInSuperview()
    }
}

struct SomeError: Swift.Error {}
