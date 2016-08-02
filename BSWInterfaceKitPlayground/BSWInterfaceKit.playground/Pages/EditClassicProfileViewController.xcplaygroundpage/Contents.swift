//: [Previous](@previous)

import XCPlayground
import BSWInterfaceKit

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let viewModel = ClassicProfileViewModel(
    photos: [
        Photo(kind: Photo.Kind.URL(NSURL(string: "http://ow.ly/ZHvD302NKEF")!))
    ],
    titleInfo: TextStyler.styler.attributedString("Gianluigi Buffon", forStyle: .Title),
    detailsInfo: TextStyler.styler.attributedString("The best keeper of football history", forStyle: .Body),
    extraInfo: [
        TextStyler.styler.attributedString("1 World Cup 2006", forStyle: .Body),
        TextStyler.styler.attributedString("7 Serie A titles", forStyle: .Body),
        TextStyler.styler.attributedString("3 Coppa Italia", forStyle: .Body),
        TextStyler.styler.attributedString("1 Uefa Cup", forStyle: .Body)
    ]
)

let editProfileVC = EditClassicProfileViewController(profile: viewModel)
let navController = UINavigationController(rootViewController: editProfileVC)

XCPlaygroundPage.currentPage.liveView = navController



//: [Next](@next)
