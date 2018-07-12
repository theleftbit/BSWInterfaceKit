//
//  File.swift
//  BSWInterfaceKitDemoTests
//
//  Created by Pierluigi Cifani on 12/07/2018.
//

import BSWInterfaceKit
import XCTest

class AvatarViewTests: BSWSnapshotTest {
    
    override func setUp() {
        super.setUp()
        isDeviceAgnostic = false
    }
    
    func testLayoutHuge() {
        verifyAvatarForSize(.huge)
    }

    func testLayoutNormal() {
        verifyAvatarForSize(.normal)
    }

    func testLayoutWithCameraHuge() {
        let avatarView = AvatarView(size: .huge, photo: Photo.emptyPhoto())
        avatarView.onTapOnAvatar = { avatarIn in
            
        }
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        waitABitAndVerify(view: avatarView)
    }

    private func verifyAvatarForSize(_ size: AvatarView.Size) {
        let avatarView = AvatarView(size: size, photo: Photo.emptyPhoto())
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        waitABitAndVerify(view: avatarView)
    }
}
