import UIKit
import BSWInterfaceKit
import Task

public class ListViewController: UITableViewController {
    
    public enum Factory {
        public static func viewController() -> UIViewController {
            return BottomContainerViewController(containedViewController: ListViewController(style: .plain), bottomViewController: AddToCartViewController())
        }
    }

    private override init(style: UITableView.Style) {
        super.init(style: style)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ID")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID")!
        cell.textLabel?.text = Date().description
        return cell
    }
}

extension ListViewController {

    class AddToCartViewController: UIViewController {
        
        let cartButton: UIButton = {
            let b = UIButton()
            b.heightAnchor.constraint(equalToConstant: 40).isActive
                = true
            b.backgroundColor = UIColor.systemBlue
            b.setTitle("Add to Cart", for: .normal)
            return b
        }()
        
        override func loadView() {
            view = UIView()
            view.backgroundColor = UIColor.white
            let stackView = UIStackView(arrangedSubviews: [cartButton])
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = .init(uniform: 12)
            stackView.axis = .horizontal
            view.addSubview(stackView)
            stackView.pinToSuperview()
            view.layer.addShadow(opacity: 0.2, shadowRadius: 5)
        }
    }
}


