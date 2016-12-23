//
//  HBStoreCalendarCollectionViewCell.h
//  store
//
//  Created by 梁天 on 16/11/21.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBStoreCalendarCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign, readonly) NSInteger state;
@property (weak, nonatomic, readonly) UILabel *timeLabel;
@property (nonatomic, strong) NSDate *date;

/**
 调整cell的UI
 
 @param text  日期
 @param state cell的状态，0-未选，1-begin，2-end，3-中间的日期,4-只有begin,5-空白,6-不可选
 @param edge  cell的状态，0-非边缘，1-左边缘，2-右边缘，3-左右边缘
 @param index cell在选中时间段的index,小于0则不设置渐变色
 @param total 选中时间段共几天
 */
- (void)setupViewsWithText:(NSString *)text state:(NSInteger)state edge:(NSInteger)edge index:(NSInteger)index total:(NSInteger)total;

@end
