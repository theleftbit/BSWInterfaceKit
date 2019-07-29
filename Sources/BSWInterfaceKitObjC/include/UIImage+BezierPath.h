
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (BezierPath)

+ (UIImage *)imageWithBezierPathFill:(UIBezierPath *)bezierPath;
+ (UIImage *)imageWithBezierPathStroke:(UIBezierPath *)bezierPath;

@end

NS_ASSUME_NONNULL_END
