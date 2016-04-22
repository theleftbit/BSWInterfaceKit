//
//  Created by Pierluigi Cifani.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

enum ColorPalette {
    case Main, Yellow, Blue, Magenta, SkyBlue, Positive, Negative
    
    enum Variant: Equatable {
        case Normal, Dark
    }
}

enum DarkPalette {
    case Black, Grey1, Grey2, Grey3, Grey4, Grey5, White
}

extension StylesheetConfigurable {
    static func color(color: ColorPalette, variant: ColorPalette.Variant = .Normal) -> UIColor {
        
        let correction = (variant == .Normal ? 0 : 16)
        
        switch color {
        case .Main:
            return UIColor(h: 173, s: 90, b: 76 - correction)
        case .Yellow:
            return UIColor(h: 51, s: 89, b: 95 - correction)
        case .Blue:
            return UIColor(h: 224, s: 67, b: 96 - correction)
        case .Magenta:
            return UIColor(h: 344, s: 64, b: 97 - correction)
        case .SkyBlue:
            return UIColor(h: 192, s: 72, b: 88 - correction)
        case .Positive:
            return UIColor(h: 146, s: 75, b: 77 - correction)
        case .Negative:
            return UIColor(h: 2, s: 59, b: 99 - correction)
        }
    }
    
    static func color(color: DarkPalette) -> UIColor {
        switch color {
        case .Black:
            return UIColor(h: 0, s: 0, b: 0)
        case .Grey1:
            return UIColor(h: 0, s: 0, b: 20)
        case .Grey2:
            return UIColor(h: 0, s: 0, b: 44)
        case .Grey3:
            return UIColor(h: 0, s: 0, b: 68)
        case .Grey4:
            return UIColor(h: 0, s: 0, b: 84)
        case .Grey5:
            return UIColor(h: 0, s: 0, b: 95)
        case .White:
            return UIColor(h: 0, s: 0, b: 100)
        }
    }
}
