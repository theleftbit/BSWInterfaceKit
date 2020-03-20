//
//  Created by Pierluigi Cifani on 18/04/2019.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutManager (BSWUtilities)

- (NSInteger)numberOfLines;

@end

NS_ASSUME_NONNULL_END

#endif
