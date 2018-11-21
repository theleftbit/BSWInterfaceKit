//
//  Created by Pierluigi Cifani on 21/03/2017.
//

import BSWInterfaceKit

class ProfilePhotoPickerCollectionViewTests: BSWSnapshotTest {

    var photoPicker: ProfilePhotoPickerCollectionView!

    override func setUp() {
        super.setUp()
        agnosticOptions = [.none]

        let photosVM = PhotoPickerViewModel.createPhotoArray([Photo.emptyPhoto(), Photo.emptyPhoto()], maxPhotos: 6)
        photoPicker = ProfilePhotoPickerCollectionView(photos: photosVM)
        photoPicker.frame = CGRect(x: 0, y: 0, width: 350, height: 300)
    }

    func testLayout() {
        waitABitAndVerify(view: photoPicker)
    }
}
