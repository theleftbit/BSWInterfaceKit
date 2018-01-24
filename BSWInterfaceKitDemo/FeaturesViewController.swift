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

    enum Features: String {
        case scrollableStackView = "ScrollableStackView"
        case asyncViewModelController = "AsyncViewModelController"
        case collectionViewDataSource = "CollectionViewDataSource"

        static var allFeatures: [Features] {
            return [.scrollableStackView, .asyncViewModelController, .collectionViewDataSource]
        }
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
        featuresTableView.rowHeight = UITableViewAutomaticDimension
        featuresTableView.delegate = self
        featuresTableView.dataSource = self
    }


    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Features.allFeatures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseID") else { fatalError() }
        let feature = Features.allFeatures[indexPath.row]
        cell.textLabel?.text = feature.rawValue
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let feature = Features.allFeatures[indexPath.row]
        switch feature {
        case .asyncViewModelController:
            let vc = StrawberryViewController(dataProvider: StrawberryInteractor.dataProvider())
            navigationController?.pushViewController(vc, animated: true)
        case .collectionViewDataSource:
            let vc = FruitViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

