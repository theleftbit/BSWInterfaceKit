
#import "UIImage+BezierPath.h"

@implementation UIImage (BezierPath)

+ (UIImage *)imageWithBezierPathFill:(UIBezierPath *)bezierPath
{
    return [self imageWithBezierPath:bezierPath
                                fill:YES
                              stroke:NO
                               scale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)imageWithBezierPathStroke:(UIBezierPath *)bezierPath
{
    return [self imageWithBezierPath:bezierPath
                                fill:NO
                              stroke:YES
                               scale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)bezierPath
                            fill:(BOOL)fill
                          stroke:(BOOL)stroke
                           scale:(CGFloat)scale
{
    UIImage *image = nil;
    if (bezierPath) {
        UIGraphicsBeginImageContextWithOptions(bezierPath.bounds.size, NO, scale);
        if (fill) {
            [bezierPath fill];
        }
        if (stroke) {
            [bezierPath stroke];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

@end
