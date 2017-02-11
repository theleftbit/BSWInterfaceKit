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
    func configureFor(viewModel: VM)
}

public protocol ViewModelReusable: ViewModelConfigurable {
    static var reuseType: ReuseType { get }
    static var reuseIdentifier: String { get }
}

public protocol AsyncViewModelPresenter: ViewModelConfigurable {
    var dataProvider: Task<VM>! { get set }
}

open class AsyncViewModelViewController<ViewModel>: UIViewController, AsyncViewModelPresenter {

    public init(dataProvider: Task<ViewModel>) {
        self.dataProvider = dataProvider
        super.init(nibName:nil, bundle:nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var dataProvider: Task<ViewModel>!

    override open func viewDidLoad() {
        super.viewDidLoad()

        //TODO: showLoader
        
        dataProvider.upon(.main) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .failure(let error):
                strongSelf.showErrorMessage("Error fetching data", error: error)
            case .success(let viewModel):
                strongSelf.configureFor(viewModel: viewModel)
            }
        }
    }
    
    public func configureFor(viewModel: ViewModel) {
        fatalError("Implement this on Subclasses")
    }
}

//MARK:- Extensions

extension ViewModelReusable where Self: UICollectionViewCell {
    public static var reuseIdentifier: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public static var reuseType: ReuseType {
        return .classReference(Self)
    }
}

//MARK:- Types

public enum ReuseType {
    case nib(UINib)
    case classReference(AnyClass)
}

