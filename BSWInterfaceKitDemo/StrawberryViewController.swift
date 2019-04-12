//
//  Created by Pierluigi Cifani on 17/03/2017.
//

import BSWInterfaceKit
import BSWFoundation
import Deferred

struct StrawberryViewModel {
    var title: String { return "🍓🍓🍓" }
}

class StrawberryInteractor {
    static func dataProvider() -> Task<StrawberryViewModel> {
        let deferred = Deferred<Task<StrawberryViewModel>.Result>()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            deferred.fill(with: .success(StrawberryViewModel()))
        }
        return Task(Future(deferred))
    }
}

class StrawberryViewController: AsyncViewModelViewController<StrawberryViewModel> {

    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(label)
        label.centerInSuperview()
    }

    override func configureFor(viewModel: StrawberryViewModel) {
        
        label.text = viewModel.title
    }

}
