//: [Previous](@previous)

//: Please build the scheme 'BSWInterfaceKitPlayground' first
import XCPlayground
import BSWInterfaceKit
import BSWFoundation
import Deferred

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let viewModel = ClassicProfileViewModel(
    photos: [
        Photo(kind: Photo.Kind.URL(NSURL(string: "http://ow.ly/ZHvD302NKEF")!))
    ],
    titleInfo: TextStyler.styler.attributedString("Gianluigi Buffon", forStyle: .Title),
    detailsInfo: TextStyler.styler.attributedString("The best keeper of footbal history", forStyle: .Body),
    extraInfo: [
        TextStyler.styler.attributedString("7 Serie A titles", forStyle: .Body),
        TextStyler.styler.attributedString("1 World Cup 200", forStyle: .Body),
        TextStyler.styler.attributedString("3 Coppa Italia", forStyle: .Body),
        TextStyler.styler.attributedString("1 Uefa Cup", forStyle: .Body)
    ]
)

let dataProvider = Future(Deferred(value: Result(viewModel)))
let detailVC = ClassicProfileViewController(dataProvider: dataProvider)
detailVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)

XCPlaygroundPage.currentPage.liveView = detailVC.view

let whatsGoingOn = XCPlaygroundPage.currentPage.liveView

XCPlaygroundPage.currentPage.finishExecution()

//: [Next](@next)
