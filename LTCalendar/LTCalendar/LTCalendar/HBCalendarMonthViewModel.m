//
//  HBCalendarMonthViewModel.m
//  store
//
//  Created by 梁天 on 16/11/21.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "HBCalendarMonthViewModel.h"
#import "NSDate+GFCalendar.h"

@implementation HBCalendarMonthViewModel

- (instancetype)initWithDate:(NSDate *)date {
    
    if (self = [super init]) {
        _monthDate = date;
        _totalDays = [self setupTotalDays];
        _firstWeekday = [self setupFirstWeekday];
        _year = [self setupYear];
        _month = [self setupMonth];
    }
    return self;
}

- (NSInteger)setupTotalDays {
    return [_monthDate totalDaysInMonth];
}

- (NSInteger)setupFirstWeekday {
    return [_monthDate firstWeekDayInMonth];
}

- (NSInteger)setupYear {
    return [_monthDate dateYear];
}

- (NSInteger)setupMonth {
    return [_monthDate dateMonth];
}

@end
