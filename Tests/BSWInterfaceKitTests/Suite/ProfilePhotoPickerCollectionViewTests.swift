//
//  Created by Pierluigi Cifani on 21/03/2017.
//

#if canImport(UIKit)

import BSWInterfaceKit
import UIKit

@available(iOS 13, *)
class ProfilePhotoPickerCollectionViewTests: BSWSnapshotTest {

    var photoPicker: ProfilePhotoPickerCollectionView!

    override func setUp() {
        super.setUp()
        let photosVM = PhotoPickerViewModel.createPhotoArray([Photo.emptyPhoto(), Photo.emptyPhoto()], maxPhotos: 6)
        photoPicker = ProfilePhotoPickerCollectionView(photos: photosVM)
        photoPicker.frame = CGRect(x: 0, y: 0, width: 350, height: 300)
    }

    func testLayout() {
        verify(view: photoPicker)
    }
}

#endif
