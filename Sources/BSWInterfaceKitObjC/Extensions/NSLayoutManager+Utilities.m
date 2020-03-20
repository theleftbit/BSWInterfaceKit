//
//  UIViewController+Utilities.m
//  Created by Pierluigi Cifani on 18/04/2019.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS

#import "NSLayoutManager+Utilities.h"

@implementation NSLayoutManager (BSWUtilities)

/// Based on https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
- (NSInteger)numberOfLines {
    NSLayoutManager *layoutManager = self;
    NSUInteger numberOfLines, index, numberOfGlyphs =
            [layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
        (void) [layoutManager lineFragmentRectForGlyphAtIndex:index
                effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    return numberOfLines;
}

@end

#endif
