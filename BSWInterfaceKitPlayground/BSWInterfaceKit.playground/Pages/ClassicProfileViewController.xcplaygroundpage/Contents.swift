//: [Previous](@previous)

//: Please build the scheme 'BSWInterfaceKitPlayground' first
import XCPlayground
import BSWInterfaceKit
import BSWFoundation
import Deferred

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let viewModel = ClassicProfileViewModel.buffon()

let dataProvider = Future(Deferred(value: Result(viewModel)))
let detailVC = ClassicProfileViewController(dataProvider: dataProvider)
let navController = UINavigationController(rootViewController: detailVC)

XCPlaygroundPage.currentPage.liveView = navController

//: [Next](@next)
