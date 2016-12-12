//
//  UIColor+HBColor.m
//  LTCalendar
//
//  Created by 梁天 on 16/12/12.
//  Copyright © 2016年 lator. All rights reserved.
//

#import "UIColor+HBColor.h"

@implementation UIColor (HBColor)

+ (UIImage *)hb_imageWithColor:(UIColor *)color size:(CGSize)size{
    NSParameterAssert(color != nil);
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
