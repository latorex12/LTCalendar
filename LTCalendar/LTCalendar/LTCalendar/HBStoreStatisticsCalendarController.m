//
//  HBStoreStatisticsCalendarController.m
//  store
//
//  Created by 梁天 on 16/11/16.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "HBStoreStatisticsCalendarController.h"
#import "HBStoreCalendarScrollView.h"

@interface HBStoreStatisticsCalendarController ()

@property (weak, nonatomic) IBOutlet UIView *weekView;
@property (weak, nonatomic) IBOutlet UIView *dayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel2;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (nonatomic, strong) HBStoreCalendarScrollView *calendarView;

@property (nonatomic, copy) NSDate *begin_time;
@property (nonatomic, copy) NSDate *end_time;

@property (nonatomic, strong) NSDate *active_date;
@property (nonatomic, strong) NSDate *current_date;

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation HBStoreStatisticsCalendarController

-(instancetype)init {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"HBStoreStatisticStoryboard" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"HBStoreStatisticsCalendarController"];
}

- (instancetype)initWithActiveDate:(NSDate *)active_date current_date:(NSDate *)current_date {
    if (self = [self init]) {
        self.active_date = active_date;
        self.current_date = current_date;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews {
    self.view.backgroundColor = RGBColor(237, 239, 240);
    self.dayViewHeight.constant = (UIScreenSize.width-40)/670*504+98;
    
    [self setupWeekView];
    
    self.calendarView = [[HBStoreCalendarScrollView alloc]initWithActiveDate:self.active_date current_date:self.current_date];
    __weak typeof(self)weakself = self;
    self.calendarView.didSelectedTime = ^ (NSDate *begin_time, NSDate *end_time) {
        if (!begin_time && !end_time) {
            weakself.begin_time = nil;
            weakself.end_time = nil;
            weakself.dateLabel.text = @"请选择日期";
            weakself.countLabel.hidden = YES;
            weakself.textLabel.hidden = YES;
            weakself.textLabel2.hidden = YES;
            weakself.confirmButton.enabled = NO;
        }else if (end_time) {
            weakself.begin_time = begin_time;
            weakself.end_time = end_time;
            weakself.dateLabel.text = [NSString stringWithFormat:@"%@-%@",[weakself.formatter stringFromDate:begin_time],[weakself.formatter stringFromDate:end_time]];
            weakself.countLabel.text = [NSString stringWithFormat:@"%ld",[end_time daysLaterThan:begin_time]+1];
            weakself.countLabel.hidden = NO;
            weakself.textLabel.hidden = NO;
            weakself.textLabel2.hidden = NO;
            weakself.confirmButton.enabled = YES;
        }else {
            weakself.begin_time = begin_time;
            weakself.end_time = nil;
            weakself.dateLabel.text = [NSString stringWithFormat:@"%@",[weakself.formatter stringFromDate:begin_time]];
            weakself.countLabel.text = @"1";
            weakself.countLabel.hidden = NO;
            weakself.textLabel.hidden = NO;
            weakself.textLabel2.hidden = NO;
            weakself.confirmButton.enabled = YES;
        }
    };
    [self.dayView addSubview:self.calendarView];
    [self.calendarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dayView);
        make.left.equalTo(self.dayView);
        make.right.equalTo(self.dayView);
        make.bottom.equalTo(self.dayView);
    }];
    
    self.confirmButton.layer.cornerRadius = 21.5f;
    self.confirmButton.layer.masksToBounds = YES;
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundImage:[UIColor hb_imageWithColor:RGBColor(0, 185, 251) size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:RGBColor(187, 187, 187) forState:UIControlStateDisabled];
    [self.confirmButton setBackgroundImage:[UIColor hb_imageWithColor:RGBColor(221, 221, 221) size:CGSizeMake(1, 1)] forState:UIControlStateDisabled];
}

- (void)setupWeekView {
    CGFloat edgeMargin = 20;
    CGFloat width = (UIScreenSize.width - 2*edgeMargin)/7;
    NSArray *week = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i < week.count; ++i) {
        UILabel *weekLabel = [[UILabel alloc]initWithFrame:CGRectMake(20+i*width, 0, width, 28)];
        weekLabel.font = [UIFont systemFontOfSize:18];
        weekLabel.text = week[i];
        weekLabel.textColor = RGBColor(122, 122, 122);
        weekLabel.textAlignment = NSTextAlignmentCenter;
        [self.weekView addSubview:weekLabel];
    }
}

- (IBAction)didClickConfirmButton:(UIButton *)sender {
    if (self.didClickConfirmButton) {
        self.didClickConfirmButton(self.begin_time,self.end_time);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy年MM月dd日";
    }
    return _formatter;
}

@end
