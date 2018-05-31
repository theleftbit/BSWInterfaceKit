//
//  Created by Pierluigi Cifani on 29/05/2018.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

public class PhotoCollectionViewCell: UICollectionViewCell, ViewModelReusable {

    public let cellImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cellImageView)
        cellImageView.pinToSuperview()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func configureFor(viewModel: Photo) {
        cellImageView.setPhoto(viewModel)
    }
}
