//
//  HBStoreCalendarScrollView.m
//  store
//
//  Created by 梁天 on 16/11/21.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "HBStoreCalendarScrollView.h"

#import "NSDate+GFCalendar.h"
#import "HBCalendarMonthViewModel.h"
#import "HBStoreCalendarCollectionViewCell.h"

@interface HBStoreCalendarScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UILabel *monthLabelLL;
@property (nonatomic, strong) UILabel *monthLabelL;
@property (nonatomic, strong) UILabel *monthLabelM;
@property (nonatomic, strong) UILabel *monthLabelR;
@property (nonatomic, strong) UILabel *monthLabelRR;

@property (nonatomic, strong) UICollectionView *collectionViewL;
@property (nonatomic, strong) UICollectionView *collectionViewM;
@property (nonatomic, strong) UICollectionView *collectionViewR;

@property (nonatomic, strong) NSDate *currentMonthDate;
@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, strong) NSMutableArray *monthTextArray;

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDate *begin_time;
@property (nonatomic, strong) NSDate *end_time;
@property (nonatomic, strong) NSDate *active_date;
@property (nonatomic, strong) NSDate *current_date;
@property (nonatomic, assign) NSInteger dayCount;

@end

@implementation HBStoreCalendarScrollView

#define kCalendarBasicColor [UIColor colorWithRed:231.0 / 255.0 green:85.0 / 255.0 blue:85.0 / 255.0 alpha:1.0]

static NSString *const kCellIdentifier = @"HBStoreCalendarCollectionViewCell";

#pragma mark - Initialiaztion

- (instancetype)initWithActiveDate:(NSDate *)active_date current_date:(NSDate *)current_date {
    if (self = [super init]) {
        self.backgroundColor = RGBColor(237, 239, 240);
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        self.contentSize = CGSizeMake(3 * UIScreenSize.width, 6*42);
        [self setContentOffset:CGPointMake(UIScreenSize.width, 0.0) animated:NO];
        
        NSDate *current = [NSDate date];
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
        NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:current];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:current];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        self.currentMonthDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:current];
        self.active_date = active_date;
        self.current_date = current_date;
        
        [self setupViews];
    }
    return self;
}

- (NSNumber *)previousMonthDaysForPreviousDate:(NSDate *)date {
    return [[NSNumber alloc] initWithInteger:[[date previousMonthDate] totalDaysInMonth]];
}

- (void)setupViews {
    CGFloat selfWidth = UIScreenSize.width;
    CGFloat selfHeight = (selfWidth - 40)/670*504;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (selfWidth-40)/7.0;
    CGFloat itemH = selfHeight/6.0;
    flowLayout.itemSize = CGSizeMake(itemW, itemH);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    _monthLabelLL = [[UILabel alloc]initWithFrame:CGRectMake(selfWidth/3*2, 0, selfWidth/3, 58)];
    _monthLabelLL.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_monthLabelLL];
    
    _monthLabelL = [[UILabel alloc]initWithFrame:CGRectMake(selfWidth, 0, selfWidth/3, 58)];
    _monthLabelL.textAlignment = NSTextAlignmentCenter;
    [_monthLabelL addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftMonthLabelGesture:)];
        tap;
    })];
    _monthLabelL.userInteractionEnabled = YES;
    [self addSubview:_monthLabelL];
    
    _monthLabelM = [[UILabel alloc]initWithFrame:CGRectMake(selfWidth/3*4, 0, selfWidth/3, 58)];
    _monthLabelM.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_monthLabelM];
    
    _monthLabelR = [[UILabel alloc]initWithFrame:CGRectMake(selfWidth/3*5, 0, selfWidth/3, 58)];
    _monthLabelR.textAlignment = NSTextAlignmentCenter;
    [_monthLabelR addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightMonthLabelGesture:)];
        tap;
    })];
    _monthLabelR.userInteractionEnabled = YES;
    [self addSubview:_monthLabelR];
    
    _monthLabelRR = [[UILabel alloc]initWithFrame:CGRectMake(selfWidth*2, 0, selfWidth/3, 58)];
    _monthLabelRR.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_monthLabelRR];
    
    [self setupMonthLabelTexts];
    
    _collectionViewL = [[UICollectionView alloc] initWithFrame:CGRectMake(20, 98, selfWidth-40, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewL.dataSource = self;
    _collectionViewL.delegate = self;
    _collectionViewL.backgroundColor = [UIColor clearColor];
    [_collectionViewL registerNib:[UINib nibWithNibName:@"HBStoreCalendarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewL];
    
    _collectionViewM = [[UICollectionView alloc] initWithFrame:CGRectMake(selfWidth+20, 98, selfWidth-40, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewM.dataSource = self;
    _collectionViewM.delegate = self;
    _collectionViewM.backgroundColor = [UIColor clearColor];
    [_collectionViewM registerNib:[UINib nibWithNibName:@"HBStoreCalendarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewM];
    
    _collectionViewR = [[UICollectionView alloc] initWithFrame:CGRectMake(2 * selfWidth+20, 98, selfWidth-40, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewR.dataSource = self;
    _collectionViewR.delegate = self;
    _collectionViewR.backgroundColor = [UIColor clearColor];
    [_collectionViewR registerNib:[UINib nibWithNibName:@"HBStoreCalendarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewR];
}

- (void)setupMonthLabelTexts {
    self.monthLabelLL.text = self.monthTextArray[0];
    self.monthLabelL.text = self.monthTextArray[1];
    self.monthLabelM.text = self.monthTextArray[2];
    self.monthLabelR.text = self.monthTextArray[3];
    self.monthLabelRR.text = self.monthTextArray[4];
    
    self.monthLabelLL.font = [UIFont systemFontOfSize:17];
    self.monthLabelLL.textColor = RGBAColor(29, 34, 38, 0.3);
    self.monthLabelL.font = [UIFont systemFontOfSize:17];
    self.monthLabelL.textColor = RGBAColor(29, 34, 38, 0.3);
    self.monthLabelM.font = [UIFont systemFontOfSize:19];
    self.monthLabelM.textColor = RGBAColor(29, 34, 38, 1.0);
    self.monthLabelR.font = [UIFont systemFontOfSize:17];
    self.monthLabelR.textColor = RGBAColor(29, 34, 38, 0.3);
    self.monthLabelRR.font = [UIFont systemFontOfSize:17];
    self.monthLabelRR.textColor = RGBAColor(29, 34, 38, 0.3);
}

#pragma mark - Event Action

- (void)leftMonthLabelGesture:(UITapGestureRecognizer *)sender{
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)rightMonthLabelGesture:(UITapGestureRecognizer *)sender{
    [self setContentOffset:CGPointMake(UIScreenSize.width*2, 0) animated:YES];
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42; // 7 * 6
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HBStoreCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (collectionView == _collectionViewL) {
        
        HBCalendarMonthViewModel *monthInfo = self.monthArray[0];
        [self configCollectionViewCellWithCell:cell indexPath:indexPath monthInfo:(HBCalendarMonthViewModel *)monthInfo];
    }
    else if (collectionView == _collectionViewM) {
        
        HBCalendarMonthViewModel *monthInfo = self.monthArray[1];
        [self configCollectionViewCellWithCell:cell indexPath:indexPath monthInfo:(HBCalendarMonthViewModel *)monthInfo];
    }
    else if (collectionView == _collectionViewR) {
        
        HBCalendarMonthViewModel *monthInfo = self.monthArray[2];
        [self configCollectionViewCellWithCell:cell indexPath:indexPath monthInfo:(HBCalendarMonthViewModel *)monthInfo];
    }
    return cell;
}

- (void)configCollectionViewCellWithCell:(HBStoreCalendarCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath monthInfo:(HBCalendarMonthViewModel *)monthInfo {
    NSInteger firstWeekday = monthInfo.firstWeekday;
    NSInteger totalDays = monthInfo.totalDays;
    NSInteger day = indexPath.row - firstWeekday + 1;
    NSString *text = [NSString stringWithFormat:@"%ld",day];
    //本月内
    if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
        NSDate *cellDate = [NSDate dateWithYear:monthInfo.year month:monthInfo.month day:day hour:8 minute:0 second:0];
        cell.date = cellDate;
        //边缘cell的判断
        NSInteger edge = 0;
        //每个月第一天一定是左边缘
        if (day == 1) {
            edge = 1;
        }else if (day == totalDays) {
            //每个月最后一天一定是右边缘
            edge = 2;
        }else if (indexPath.item%7 == 0) {
            //周日一定是左边缘
            edge = 1;
        }else if (indexPath.item%7 == 6) {
            //周六一定是右边缘
            edge = 2;
        }
        //如果在可选范围之外则state=6
        if ([cellDate isEarlierThan:self.active_date] || [cellDate isLaterThan:self.current_date]) {
            [cell setupViewsWithText:text state:6 edge:edge index:-1 total:0];
        }else if (!self.begin_time && !self.end_time) {
            //如果还没有起止日期则state=0
            [cell setupViewsWithText:text state:0 edge:edge index:-1 total:0];
        }else {
            //有终止日期
            if (self.end_time) {
                //如果在起止日期范围之外state=0
                if ([cellDate isEarlierThan:self.begin_time] || [cellDate isLaterThan:self.end_time]) {
                    [cell setupViewsWithText:text state:0 edge:edge index:-1 total:0];
                    //是终止日期state=2
                }else if ([cellDate isSameDay:self.end_time]) {
                    [cell setupViewsWithText:text state:2 edge:edge index:self.dayCount-1 total:self.dayCount];
                    //如果是起始日期state=1
                }else if ([cellDate isSameDay:self.begin_time]) {
                    [cell setupViewsWithText:text state:1 edge:edge index:0 total:self.dayCount];
                    //否则是中间的日期,state=3
                }else {
                    [cell setupViewsWithText:text state:3 edge:edge index:[cellDate daysLaterThan:self.begin_time] total:self.dayCount];
                }
                //如果无终止日期只有起始日期,起始日期state=4,否则state=0
            }else {
                if ([cellDate isSameDay:self.begin_time]) {
                    [cell setupViewsWithText:text state:4 edge:edge index:0 total:1];
                }else {
                    [cell setupViewsWithText:text state:0 edge:edge index:-1 total:0];
                }
            }
        }
    }else {
        //不是本月内不显示,edge也不需要管
        [cell setupViewsWithText:nil state:5 edge:0 index:-1 total:0];
    }
}

#pragma mark - UICollectionViewDeleagate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HBStoreCalendarCollectionViewCell *cell = (HBStoreCalendarCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSDate *currentDate = [cell date];
    
    //有起止时间再点击则重新选择
    if (self.end_time) {
        self.begin_time = nil;
        self.end_time = nil;
    }else if (self.begin_time){
        //只有起始时间,是同一天则取消选择起始时间，否则选择结束时间并自动比较日期大小更换起止时间顺序
        if ([currentDate isSameDay:self.begin_time]) {
            self.begin_time = nil;
        }else if ([currentDate isLaterThan:self.begin_time]) {
            self.end_time = currentDate;
        }else  {
            self.end_time = self.begin_time;
            self.begin_time = currentDate;
        }
        //起止时间都没有选择过
    }else {
        self.begin_time = currentDate;
    }
    
    if (self.didSelectedTime) {
        self.didSelectedTime(self.begin_time,self.end_time); // 回调
    }
    
    if (!self.begin_time && !self.end_time) {
        self.dayCount = 0;
    } else if (self.end_time) {
        self.dayCount = [self.end_time daysLaterThan:self.begin_time]+1;
    }else {
        self.dayCount = 1;
    }
    
    [self.collectionViewL reloadData];
    [self.collectionViewM reloadData];
    [self.collectionViewR reloadData];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x - UIScreenSize.width;
    //修改偏移值减小移动幅度
    self.monthLabelLL.transform = CGAffineTransformMakeTranslation(offsetX*0.666, 0);
    self.monthLabelL.transform = CGAffineTransformMakeTranslation(offsetX*0.666, 0);
    self.monthLabelM.transform = CGAffineTransformMakeTranslation(offsetX*0.666, 0);
    self.monthLabelR.transform = CGAffineTransformMakeTranslation(offsetX*0.666, 0);
    self.monthLabelRR.transform = CGAffineTransformMakeTranslation(offsetX*0.666, 0);
    
    CGFloat scale = offsetX/UIScreenSize.width;
    if (offsetX < 0) {
        self.monthLabelL.font = [UIFont systemFontOfSize:17-scale*2];
        self.monthLabelL.textColor = RGBAColor(29, 34, 38, 0.3-scale*0.7);
        self.monthLabelM.font = [UIFont systemFontOfSize:19+scale*2];
        self.monthLabelM.textColor = RGBAColor(29, 34, 38, 1.0+scale*0.7);
    }else {
        self.monthLabelR.font = [UIFont systemFontOfSize:17+scale*2];
        self.monthLabelR.textColor = RGBAColor(29, 34, 38, 0.3+scale*0.7);
        self.monthLabelM.font = [UIFont systemFontOfSize:19-scale*2];
        self.monthLabelM.textColor = RGBAColor(29, 34, 38, 1.0-scale*0.7);
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self) {
        return;
    }
    // 向右滑动
    if (scrollView.contentOffset.x < self.bounds.size.width) {
        _currentMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *previousDate = [_currentMonthDate previousMonthDate];
        NSDate *prepreDate = previousDate.previousMonthDate;
        
        [self.monthTextArray removeObjectAtIndex:4];
        [self.monthTextArray insertObject:[NSString stringWithFormat:@"%zd年%02zd月",prepreDate.dateYear,prepreDate.dateMonth] atIndex:0];
        
        // 数组中最左边的月份现在作为中间的月份，中间的作为右边的月份，新的左边的需要重新获取
        HBCalendarMonthViewModel *currentMothInfo = self.monthArray[0];
        HBCalendarMonthViewModel *nextMonthInfo = self.monthArray[1];
        HBCalendarMonthViewModel *olderNextMonthInfo = self.monthArray[2];
        
        // 复用 HBCalendarMonthViewModel 对象
        olderNextMonthInfo.totalDays = [previousDate totalDaysInMonth];
        olderNextMonthInfo.firstWeekday = [previousDate firstWeekDayInMonth];
        olderNextMonthInfo.year = [previousDate dateYear];
        olderNextMonthInfo.month = [previousDate dateMonth];
        HBCalendarMonthViewModel *previousMonthInfo = olderNextMonthInfo;
        
//        NSNumber *prePreviousMonthDays = [self previousMonthDaysForPreviousDate:[_currentMonthDate previousMonthDate]];
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
//        [self.monthArray addObject:prePreviousMonthDays];
        
    }
    // 向左滑动
    else if (scrollView.contentOffset.x > self.bounds.size.width) {
        _currentMonthDate = [_currentMonthDate nextMonthDate];
        NSDate *nextDate = [_currentMonthDate nextMonthDate];
        NSDate *nextnextDate = nextDate.nextMonthDate;
        
        [self.monthTextArray removeObjectAtIndex:0];
        [self.monthTextArray addObject:[NSString stringWithFormat:@"%zd年%02zd月",nextnextDate.dateYear,nextnextDate.dateMonth]];
        
        // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
        HBCalendarMonthViewModel *previousMonthInfo = self.monthArray[1];
        HBCalendarMonthViewModel *currentMothInfo = self.monthArray[2];
        HBCalendarMonthViewModel *olderPreviousMonthInfo = self.monthArray[0];
        
//        NSNumber *prePreviousMonthDays = [[NSNumber alloc] initWithInteger:olderPreviousMonthInfo.totalDays]; // 先保存 olderPreviousMonthInfo 的月天数
        
        // 复用 HBCalendarMonthViewModel 对象
        olderPreviousMonthInfo.totalDays = [nextDate totalDaysInMonth];
        olderPreviousMonthInfo.firstWeekday = [nextDate firstWeekDayInMonth];
        olderPreviousMonthInfo.year = [nextDate dateYear];
        olderPreviousMonthInfo.month = [nextDate dateMonth];
        HBCalendarMonthViewModel *nextMonthInfo = olderPreviousMonthInfo;
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
//        [self.monthArray addObject:prePreviousMonthDays];
        
    }

    [_collectionViewM reloadData]; // 中间的 collectionView 先刷新数据
    [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO]; // 然后变换位置
    [self setupMonthLabelTexts];
    [_collectionViewL reloadData]; // 最后两边的 collectionView 也刷新数据
    [_collectionViewR reloadData];
}

#pragma mark - Getter/Setter

- (NSMutableArray *)monthArray {
    if (_monthArray == nil) {
        _monthArray = [NSMutableArray arrayWithCapacity:4];
        
        NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
        
        [_monthArray addObject:[[HBCalendarMonthViewModel alloc] initWithDate:previousMonthDate]];
        [_monthArray addObject:[[HBCalendarMonthViewModel alloc] initWithDate:_currentMonthDate]];
        [_monthArray addObject:[[HBCalendarMonthViewModel alloc] initWithDate:nextMonthDate]];
        [_monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]]; // 存储左边的月份的前一个月份的天数，用来填充左边月份的首部
    }
    return _monthArray;
}

- (NSMutableArray *)monthTextArray {
    if (_monthTextArray == nil) {
        _monthTextArray = [NSMutableArray array];
        [_monthTextArray addObject:[NSString stringWithFormat:@"%zd年%02zd月",self.currentMonthDate.previousMonthDate.previousMonthDate.dateYear,self.currentMonthDate.previousMonthDate.previousMonthDate.dateMonth]];
        [_monthTextArray addObject:[NSString stringWithFormat:@"%zd年%02zd月",self.currentMonthDate.previousMonthDate.dateYear,self.currentMonthDate.previousMonthDate.dateMonth]];
        [_monthTextArray addObject:[NSString stringWithFormat:@"%zd年%02zd月",self.currentMonthDate.dateYear,self.currentMonthDate.dateMonth]];
        [_monthTextArray addObject:[NSString stringWithFormat:@"%zd年%02zd月",self.currentMonthDate.nextMonthDate.dateYear,self.currentMonthDate.nextMonthDate.dateMonth]];
        [_monthTextArray addObject:[NSString stringWithFormat:@"%zd年%02zd月",self.currentMonthDate.nextMonthDate.nextMonthDate.dateYear,self.currentMonthDate.nextMonthDate.nextMonthDate.dateMonth]];
    }
    return _monthTextArray;
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy-MM-dd";
    }
    return _formatter;
}

@end
