//
//  ViewController.m
//  LTCalendar
//
//  Created by 梁天 on 16/12/12.
//  Copyright © 2016年 lator. All rights reserved.
//

#import "ViewController.h"
#import "HBStoreStatisticsCalendarController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)pushCalendar:(UIButton *)sender {
    HBStoreStatisticsCalendarController *calendar = [[HBStoreStatisticsCalendarController alloc]initWithActiveDate:[self.formatter dateFromString:@"2016-05-05"] current_date:[self.formatter dateFromString:@"2017-02-05"]];
    
    __weak typeof(self)weakself = self;
    calendar.didClickConfirmButton = ^(NSDate *begin_time, NSDate *end_time){
        weakself.startTimeLabel.text = begin_time ? [weakself.formatter stringFromDate:begin_time]:@"...";
        weakself.endTimeLabel.text = end_time ? [weakself.formatter stringFromDate:end_time]:@"...";
        [weakself.startTimeLabel sizeToFit];
        [weakself.endTimeLabel sizeToFit];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:calendar] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDateFormatter *)formatter {
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc]init];
        _formatter.dateFormat = @"yyyy-MM-dd";
    }
    return _formatter;
}

@end
