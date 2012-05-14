/*
 * This file is part of the JTGestureBasedTableView package.
 * (c) James Tang <mystcolor@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSObject+JTGestureBasedTableViewHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIColor (JTGestureBasedTableViewHelper)
- (UIColor *)colorWithBrightness:(CGFloat)brightnessComponent {
    
    UIColor *newColor = nil;
    if ( ! newColor) {
        CGFloat hue, saturation, brightness, alpha;
        if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
            newColor = [UIColor colorWithHue:hue
                                  saturation:saturation
                                  brightness:brightness * brightnessComponent
                                       alpha:alpha];
        }
    }
    
    if ( ! newColor) {
        CGFloat red, green, blue, alpha;
        if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
            newColor = [UIColor colorWithRed:red*brightnessComponent
                                       green:green*brightnessComponent
                                        blue:blue*brightnessComponent
                                       alpha:alpha];
        }
    }
    
    if ( ! newColor) {
        CGFloat white, alpha;
        if ([self getWhite:&white alpha:&alpha]) {
            newColor = [UIColor colorWithWhite:white * brightnessComponent alpha:alpha];
        }
    }
    
    return newColor;
}

- (UIColor *)colorWithHueOffset:(CGFloat)hueOffset {
    UIColor *newColor = nil;
    if ( ! newColor) {
        CGFloat hue, saturation, brightness, alpha;
        if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
            // We wants the hue value to be between 0 - 1 after appending the offset
            CGFloat newHue = fmodf((hue + hueOffset), 1);
            newColor = [UIColor colorWithHue:newHue
                                  saturation:saturation
                                  brightness:brightness
                                       alpha:alpha];
        }
    }
    return newColor;
}
@end


@implementation UIView (JTGestureBasedTableViewHelper)

- (UIImage *)snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


@implementation UIGestureRecognizer (JTGestureBasedTableViewHelper)

- (CGPoint)topPoint {
    if ([self numberOfTouches] < 2) {
        return [self locationInView:nil];
    } else {
        CGPoint upperPoint = CGPointMake(0, NSIntegerMax);
        for (int i = 0; i < [self numberOfTouches]; i++) {
            CGPoint location = [self locationOfTouch:i inView:self.view];
            if (location.y <= upperPoint.y) {
                upperPoint = location;
            }
        }
        return upperPoint;
    }
}

- (CGPoint)bottomPoint {
    if ([self numberOfTouches] < 2) {
        return [self locationInView:nil];
    } else {
        CGPoint bottomPoint = CGPointMake(0, 0);
        for (int i = 0; i < [self numberOfTouches]; i++) {
            CGPoint location = [self locationOfTouch:i inView:self.view];
            if (location.y >= bottomPoint.y) {
                bottomPoint = location;
            }
        }
        return bottomPoint;
    }
}

@end