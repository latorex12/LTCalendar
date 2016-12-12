//
//  HBStoreStatisticsCalendarController.h
//  store
//
//  Created by 梁天 on 16/11/16.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBStoreStatisticsCalendarController : UIViewController

@property (nonatomic, copy) void (^didClickConfirmButton)(NSDate *begin_time, NSDate *end_time);

- (instancetype)initWithActiveDate:(NSDate *)active_date current_date:(NSDate *)current_date;

@end
