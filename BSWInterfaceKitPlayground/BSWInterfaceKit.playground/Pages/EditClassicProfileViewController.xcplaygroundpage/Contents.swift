//: [Previous](@previous)

import XCPlayground
import BSWInterfaceKit

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let viewModel = ClassicProfileViewModel.buffon()
let editProfileVC = EditClassicProfileViewController(profile: viewModel)
let navController = UINavigationController(rootViewController: editProfileVC)

XCPlaygroundPage.currentPage.liveView = navController



//: [Next](@next)
