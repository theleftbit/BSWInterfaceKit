
import UIKit
import BSWInterfaceKit
import Testing

class ShadowTests: BSWSnapshotTest {
    
    @Test
    func layout() async {
        let vc = ViewController()
        await verify(viewController: vc, testDarkMode: false)
    }
}

private class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let sampleView = UIView()
        sampleView.backgroundColor = .systemRed
        sampleView.addShadow(opacity: 0.5, radius: 10, offset: CGSize(width: 0, height: 1))
        sampleView.roundCorners()
        view.addAutolayoutSubview(sampleView)
        NSLayoutConstraint.activate([
            sampleView.heightAnchor.constraint(equalToConstant: 200),
            sampleView.widthAnchor.constraint(equalToConstant: 200),
            sampleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sampleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
