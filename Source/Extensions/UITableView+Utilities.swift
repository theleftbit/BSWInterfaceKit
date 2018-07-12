//
//  Created by Pierluigi Cifani on 12/07/2018.
//

import UIKit

extension UITableView {
    public func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: ViewModelReusable {
        switch T.reuseType {
        case .classReference(let className):
            self.register(className, forCellReuseIdentifier: T.reuseIdentifier)
        case .nib(let nib):
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: ViewModelReusable {
                guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Did you register this cell?")
        }
        return cell
    }
}
