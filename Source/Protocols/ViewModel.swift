//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import BSWFoundation
import Deferred

//MARK:- Protocols

public protocol ViewModelConfigurable {
    associatedtype VM
    func configureFor(viewModel viewModel: VM)
}

public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
}

public protocol AsyncViewModelPresenter: ViewModelConfigurable {
    var dataProvider: Future<Result<VM>>! { get set }
}

extension AsyncViewModelPresenter where Self: UIViewController {
    
    public init(dataProvider: Future<Result<VM>>) {
        self.init(nibName: nil, bundle: nil)
        self.dataProvider = dataProvider

        dataProvider.uponMainQueue { [weak self] result in            
            guard let strongSelf = self else { return }
            switch result {
            case .Failure(let error):
                strongSelf.showErrorMessage("WTF", error: error)
            case .Success(let viewModel):
                guard let _ = strongSelf.view else { return }
                strongSelf.configureFor(viewModel: viewModel)
            }
        }
    }
}

//MARK:- Extensions

extension ViewModelReusable where Self: UICollectionViewCell {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public static var reuseType: ReuseType {
        return .ClassReference(Self)
    }
}

//MARK:- Types

public enum ReuseType {
    case NIB(UINib)
    case ClassReference(AnyClass)
}

