//
//  AsyncViewModelPresenter.swift
//  Pods
//
//  Created by Pierluigi Cifani on 12/02/2017.
//
//

import UIKit
import Deferred
import BSWFoundation

open class AsyncViewModelViewController<ViewModel>: UIViewController, AsyncViewModelPresenter {

    public init(dataProvider: Task<ViewModel>) {
        self.dataProvider = dataProvider
        super.init(nibName:nil, bundle:nil)
    }

    public init(viewModel: ViewModel) {
        self.dataProvider = Task(success: viewModel)
        super.init(nibName:nil, bundle:nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var dataProvider: Task<ViewModel>!

    override open func viewDidLoad() {
        super.viewDidLoad()
        showLoader()
        dataProvider.upon(.main) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.hideLoader()
            switch result {
            case .failure(let error):
                strongSelf.showErrorMessage("Error fetching data", error: error)
            case .success(let viewModel):
                strongSelf.configureFor(viewModel: viewModel)
            }
        }
    }

    open func configureFor(viewModel: ViewModel) {
        fatalError("Implement this on Subclasses")
    }
}

