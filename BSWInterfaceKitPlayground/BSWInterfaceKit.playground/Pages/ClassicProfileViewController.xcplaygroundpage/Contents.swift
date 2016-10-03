//: [Previous](@previous)

//: Please build the scheme 'BSWInterfaceKitPlayground' first
import PlaygroundSupport
import BSWInterfaceKit
import BSWFoundation
import Deferred

PlaygroundPage.current.needsIndefiniteExecution = true

let viewModel = ClassicProfileViewModel.buffon()

let dataProvider = Future(Deferred(filledWith: Result(viewModel)))
let detailVC = ClassicProfileViewController(dataProvider: dataProvider)
let navController = UINavigationController(rootViewController: detailVC)

PlaygroundPage.current.liveView = navController

//: [Next](@next)
