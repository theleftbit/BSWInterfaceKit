#if canImport(UIKit)

import BSWInterfaceKit
import XCTest

class AvatarViewTests: BSWSnapshotTest {

    @MainActor
    func testLayoutHuge() {
        verifyAvatarForSize(.huge)
    }

    @MainActor
    func testLayoutNormal() {
        verifyAvatarForSize(.normal)
    }

    @MainActor
    func testLayoutWithCameraHuge() {
        let avatarView = AvatarView(size: .huge, photo: Photo.emptyPhoto())
        avatarView.onTapOnAvatar = { avatarIn in
            
        }
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        verify(view: avatarView)
    }

    @MainActor
    private func verifyAvatarForSize(_ size: AvatarView.Size, file: StaticString = #file, testName: String = #function) {
        let avatarView = AvatarView(size: size, photo: Photo.emptyPhoto())
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        verify(view: avatarView, file: file, testName: testName)
    }
}

#endif
