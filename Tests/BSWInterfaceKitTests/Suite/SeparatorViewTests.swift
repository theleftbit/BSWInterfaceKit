#if canImport(Testing)

import BSWInterfaceKit
import Testing
import UIKit

class SeparatorViewTests: BSWSnapshotTest {
    
    @Test
    func layout() throws {
        let separatorView = SeparatorView()
        let contentView = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        contentView.backgroundColor = .white
        contentView.addAutolayoutSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
        verify(view: contentView)
    }
}

#endif
