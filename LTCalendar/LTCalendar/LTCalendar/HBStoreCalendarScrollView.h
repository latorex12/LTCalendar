//
//  HBStoreCalendarScrollView.h
//  store
//
//  Created by 梁天 on 16/11/21.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBStoreCalendarScrollView : UIScrollView

@property (nonatomic, copy) void (^didSelectedTime)(NSDate *begin_time, NSDate *end_time);
@property (nonatomic, copy) void (^didViewScroll)(CGFloat offset,CGFloat width);

/**
 初始化日历ScrollView

 @param active_date 有效起始时间
 @param current_date 有效结束时间
 @return self
 */
- (instancetype)initWithActiveDate:(NSDate *)active_date current_date:(NSDate *)current_date;

@end
