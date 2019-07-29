//
//  ViewController.swift
//  BSWInterfaceKitDemo
//
//  Created by Pierluigi Cifani on 12/02/2017.
//
//

import UIKit
import BSWInterfaceKit

class FeaturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum Features: String, CaseIterable {
        case profileViewController = "ProfileViewController"
        case asyncViewModelController = "AsyncViewModelController"
        case asyncViewSwiftUI = "AsyncViewSwiftUI"
        case collectionViewDataSource = "CollectionViewDataSource"
        case facebookLogin = "FacebookLogin"
        case alertOperations = "AlertOperations"
    }

    let featuresTableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feature Showcase"
        view.addSubview(featuresTableView)
        featuresTableView.pinToSuperview()
        featuresTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseID")
        featuresTableView.estimatedRowHeight = 44
        featuresTableView.rowHeight = UITableView.automaticDimension
        featuresTableView.delegate = self
        featuresTableView.dataSource = self
    }


    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Features.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseID") else { fatalError() }
        let feature = Features.allCases[indexPath.row]
        cell.textLabel?.text = feature.rawValue
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let feature = Features.allCases[indexPath.row]
        let vc: UIViewController = {
            switch feature {
            case .alertOperations:
                return AlertOperationViewController()
            case .asyncViewModelController:
                return StrawberryViewController(dataProvider: StrawberryInteractor.dataProvider())
            case .asyncViewSwiftUI:
                if #available(iOS 13.0.0, *) {
                    return ToDoList.Factory.todoListAsUIKit()
                } else {
                    return UIViewController()
                }
            case .collectionViewDataSource:
                return AzzurriViewController()
            case .facebookLogin:
                return FacebookLoginViewController()
            case .profileViewController:
                let viewModel = ClassicProfileViewModel.buffon()
                return ClassicProfileViewController(viewModel: viewModel)
            }
        }()
        show(vc, sender: self)
    }
}

