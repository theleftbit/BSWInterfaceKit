//
//  File.swift
//  BSWInterfaceKitDemoTests
//
//  Created by Pierluigi Cifani on 12/07/2018.
//

import BSWInterfaceKit
import XCTest

class AvatarViewTests: BSWSnapshotTest {
        
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
        verify(view: avatarView)
    }

    private func verifyAvatarForSize(_ size: AvatarView.Size, file: StaticString = #file, testName: String = #function) {
        let avatarView = AvatarView(size: size, photo: Photo.emptyPhoto())
        avatarView.frame = CGRect(origin: .zero, size: avatarView.intrinsicContentSize)
        verify(view: avatarView, file: file, testName: testName)
    }
}
