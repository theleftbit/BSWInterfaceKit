//
//  Created by Pierluigi Cifani on 18/04/2019.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BSWShadowInformation;

@interface UIView (Utilities)

- (void)bsw_layoutSubviews;
- (void)bsw_addShadowWithOpacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;
- (void)bsw_removeShadow;

@property (nonatomic, nullable) BSWShadowInformation *bsw_shadowInfo;

@end

@interface BSWShadowInformation: NSObject
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGSize offset;
@property (nonatomic, assign) BOOL isEmpty;
@end

NS_ASSUME_NONNULL_END

#endif
