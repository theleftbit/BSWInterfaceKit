//
//  Created by Michele Restuccia on 22/10/2019.
//
#if canImport(UIKit)
#if canImport(Testing)

import BSWInterfaceKit
import Testing
import UIKit

class RoundLayerTests: BSWSnapshotTest {
    
    @Test
    func layout() {
        let sut = RoundView()
        verify(view: sut)
    }
    
    class RoundView: UIView {
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            let label = UILabel()
            label.text = "3"
            label.textAlignment = .center
            label.backgroundColor = .red
            addAutolayoutSubview(label)
            label.pinToSuperview()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override class var layerClass: AnyClass {
            return RoundLayer.self
        }
        
        override var intrinsicContentSize: CGSize {
            return CGSize(
                width: 18,
                height: 18
            )
        }
    }
}

#endif
#endif
