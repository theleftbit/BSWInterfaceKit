#if canImport(UIKit)

import BSWInterfaceKit
import Testing
import UIKit

class AvatarViewTests: BSWSnapshotTest {

    @Test
    func layoutHuge() {
        verifyAvatarForSize(.huge)
    }

    @Test
    func layoutNormal() {
        verifyAvatarForSize(.normal)
    }

    @Test
    func layoutWithCameraHuge() {
        let avatarView = AvatarView(size: .huge, photo: Photo.emptyPhoto())
        avatarView.onTapOnAvatar = { avatarIn in
            
        }
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        verify(view: avatarView)
    }

    @MainActor
    private func verifyAvatarForSize(_ size: AvatarView.Size, file: StaticString = #filePath, testName: String = #function) {
        let avatarView = AvatarView(size: size, photo: Photo.emptyPhoto())
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        verify(view: avatarView, file: file, testName: testName)
    }
}

#endif
