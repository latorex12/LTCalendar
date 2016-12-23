//
//  HBStoreCalendarCollectionViewCell.m
//  store
//
//  Created by 梁天 on 16/11/21.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "HBStoreCalendarCollectionViewCell.h"

@interface HBStoreCalendarCollectionViewCell ()

@property (nonatomic, assign) NSInteger state;
/**
 镂空imageView，实现圆角效果
 */
@property (weak, nonatomic) IBOutlet UIImageView *midImageView;
@property (weak, nonatomic) IBOutlet UIView *begin_icon;
@property (weak, nonatomic) IBOutlet UIView *end_icon;
@property (weak, nonatomic) IBOutlet UIView *mid_icon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) CAGradientLayer *gLayer;

@end

@implementation HBStoreCalendarCollectionViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = RGBColor(237, 239, 240);
    self.state = 5;
    [self bringSubviewToFront:self.timeLabel];
    self.timeLabel.hidden = YES;
    self.begin_icon.hidden = YES;
    CGFloat cornerRadius = (UIScreenSize.width - 40)/670*504/6*105/294;
    self.begin_icon.layer.cornerRadius = cornerRadius;
    self.begin_icon.layer.shadowColor = [UIColor blackColor].CGColor;
    self.begin_icon.layer.shadowOffset = CGSizeMake(0, 0);
    self.begin_icon.layer.shadowRadius = 3;
    self.begin_icon.layer.shadowOpacity = 0.2;
    self.end_icon.hidden = YES;
    self.end_icon.layer.cornerRadius = cornerRadius;
    self.end_icon.layer.shadowColor = [UIColor blackColor].CGColor;
    self.end_icon.layer.shadowOffset = CGSizeMake(0, 0);
    self.end_icon.layer.shadowRadius = 3;
    self.end_icon.layer.shadowOpacity = 0.2;
    self.midImageView.hidden = YES;
    self.mid_icon.hidden = YES;
}

/**
 设置颜色渐变

 @param index 选中的第几天
 @param total 共选中多少天
 */
- (void)setupGradientLayerWithIndex:(NSInteger)index total:(NSInteger)total {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.mid_icon.bounds;
    NSMutableArray *colorArray = [NSMutableArray array];
    [colorArray addObject:(id)[UIColor colorWithHue:(160+36.0*index/total)/360.0 saturation:1.0 brightness:0.77+0.21*index/total alpha:1].CGColor];
    [colorArray addObject:(id)[UIColor colorWithHue:(160+36.0*(index+1)/total)/360.0 saturation:1.0 brightness:0.77+0.21*(index+1)/total alpha:1].CGColor];
    //此处要给CGColor
    layer.colors = colorArray;
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 0);
    [self.mid_icon.layer addSublayer:layer];
    [self.gLayer removeFromSuperlayer];
    self.gLayer = layer;
}

- (void)setupViewsWithText:(NSString *)text state:(NSInteger)state edge:(NSInteger)edge index:(NSInteger)index total:(NSInteger)total{
    if (text) {
        self.timeLabel.text = text;
    }
    self.timeLabel.textColor = state ? [UIColor whiteColor]:RGBColor(29, 34, 38);
    switch (state) {
        case 0:
            self.timeLabel.hidden = NO;
            self.begin_icon.hidden = YES;
            self.end_icon.hidden = YES;
            self.mid_icon.hidden = YES;
            self.midImageView.image = nil;
            self.timeLabel.textColor = RGBColor(29, 34, 38);
            self.userInteractionEnabled = YES;
            break;
        case 1:
            self.timeLabel.hidden = NO;
            self.begin_icon.hidden = NO;
            self.end_icon.hidden = YES;
            self.mid_icon.hidden = NO;
            self.midImageView.image = [UIImage imageNamed:edge & 2 ?  @"store-statistic-oval-right-3":@"store-statistic-oval-left"];
            self.timeLabel.textColor = [UIColor whiteColor];
            self.userInteractionEnabled = YES;
            break;
        case 2:
            self.timeLabel.hidden = NO;
            self.begin_icon.hidden = YES;
            self.end_icon.hidden = NO;
            self.mid_icon.hidden = NO;
            self.midImageView.image = [UIImage imageNamed:edge & 1 ? @"store-statistic-oval-left-3":@"store-statistic-oval-right"];
            self.timeLabel.textColor = [UIColor whiteColor];
            self.userInteractionEnabled = YES;
            break;
        case 3:
            self.timeLabel.hidden = NO;
            self.begin_icon.hidden = YES;
            self.end_icon.hidden = YES;
            self.mid_icon.hidden = NO;
            self.midImageView.image = [UIImage imageNamed: edge == 3 ? @"store-statistic-oval-both":(edge-1 ? @"store-statistic-oval-right2":@"store-statistic-oval-left2")];
            self.timeLabel.textColor = [UIColor whiteColor];
            self.userInteractionEnabled = YES;
            break;
        case 4:
            self.timeLabel.hidden = NO;
            self.begin_icon.hidden = NO;
            self.end_icon.hidden = YES;
            self.mid_icon.hidden = YES;
            self.midImageView.image = nil;
            self.timeLabel.textColor = [UIColor whiteColor];
            self.userInteractionEnabled = YES;
            break;
        case 5:
            self.timeLabel.hidden = YES;
            self.begin_icon.hidden = YES;
            self.end_icon.hidden = YES;
            self.mid_icon.hidden = YES;
            self.midImageView.image = nil;
            self.userInteractionEnabled = NO;
            break;
        case 6:
            self.timeLabel.hidden = NO;
            self.begin_icon.hidden = YES;
            self.end_icon.hidden = YES;
            self.mid_icon.hidden = YES;
            self.midImageView.image = nil;
            self.timeLabel.textColor = RGBColor(179, 189, 194);
            self.userInteractionEnabled = NO;
            break;
        default:
            break;
    }
    switch (edge) {
        case 0:
            self.midImageView.hidden = state != 1 && state != 2;
            break;
        case 1:
            self.midImageView.hidden = NO;
            break;
        case 2:
            self.midImageView.hidden = NO;
            break;
        case 3:
            self.midImageView.hidden = NO;
            break;
        default:
            break;
    }
    
    if (index >= 0) {
        [self setupGradientLayerWithIndex:index total:total];
    }
}

- (CAGradientLayer *)gLayer {
    if (_gLayer == nil) {
        _gLayer = [CAGradientLayer layer];
        _gLayer.frame = self.mid_icon.bounds;
        [self.mid_icon.layer addSublayer:_gLayer];
    }
    return _gLayer;
}

@end
