//
//  RVWeekView.m
//  RVCalendarWeekView
//
//  Created by Badchoice on 22/8/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import "MSWeekView.h"
#import "Util.h"
#import "NSDate+Easy.h"
#import "RVCollection.h"

#define MAS_SHORTHAND
#import "Masonry.h"

// Collection View Reusable Views
#import "MSGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "MSEventCell.h"
#import "MSDayColumnHeader.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"
#import "MSUnavailableHour.h"
#import "MSWeekendBackground.h"

#define MSEventCellReuseIdentifier        @"MSEventCellReuseIdentifier"
#define MSDayColumnHeaderReuseIdentifier  @"MSDayColumnHeaderReuseIdentifier"
#define MSTimeRowHeaderReuseIdentifier    @"MSTimeRowHeaderReuseIdentifier"

@implementation MSWeekView

//================================================
#pragma mark - Init
//================================================
-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup{
    
    self.isFirst = true;
    [Util sharedInstance].nowLoading = false;
    
    self.daysToShowOnScreen = 7;
    self.daysToShow         = 7;
    self.weekFlowLayout     = [MSCollectionViewCalendarLayout new];
    
    self.weekFlowLayout.delegate = self;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.weekFlowLayout];
    self.collectionView.dataSource                      = self;
    self.collectionView.delegate                        = self;
    self.collectionView.directionalLockEnabled          = YES;
    self.collectionView.showsVerticalScrollIndicator    = NO;
    self.collectionView.showsHorizontalScrollIndicator  = NO;
    /*if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
    }*/
    
    [Util sharedInstance].scrollDisable = false;
//    self.collectionView.pagingEnabled = YES;
        
    
    [self addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.height);
        
//        make.width.equalTo(@([UIScreen mainScreen].bounds.size.width/8*7));
        
        make.left.equalTo(self.left);
        make.top.equalTo(self.top);
        make.right.equalTo(self.right);
    }];
    
    self.weekFlowLayout.sectionLayoutType = MSSectionLayoutTypeHorizontalTile;
    self.collectionView.backgroundColor   = [UIColor whiteColor];
    
    [self setupSupplementaryViewClasses];
    [self registerSupplementaryViewClasses];
    
    selectedDate = NSDate.today;
        
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipeLeft)];
    leftGesture.delegate = self;
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:leftGesture];
    
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipeRight)];
    rightGesture.delegate = self;
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.collectionView addGestureRecognizer:rightGesture];

}

-(void)didSwipeLeft {
    NSLog(@"didSwipeLeft");
    
    [Util sharedInstance].scrollDisable = false;
    [Util sharedInstance].pageXValue = [Util sharedInstance].pageXValue + self.bounds.size.width ;
    
    if ([Util sharedInstance].pageXValue == self.collectionView.contentSize.width - self.bounds.size.width) {
    }
    
    float yValue = self.collectionView.contentOffset.y;
    
    
//    [self.collectionView setContentOffset:CGPointMake([Util sharedInstance].pageXValue, yValue) animated:false];
    
    NSDate *newDay = [self getDateOfCurrentOffset];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dateUpdatedOnScroll" object:nil userInfo:@{@"date": newDay}];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeLeft" object:nil userInfo:@{@"date": newDay}];

    [Util sharedInstance].scrollDisable = true;
}

-(void)didSwipeRight {
    NSLog(@"didSwipeRight");
    
    [Util sharedInstance].scrollDisable = false;
    [Util sharedInstance].pageXValue = [Util sharedInstance].pageXValue - self.bounds.size.width ;

    if ([Util sharedInstance].pageXValue == 0.0) {
    }
    
    float yValue = self.collectionView.contentOffset.y;
    
//    [self.collectionView setContentOffset:CGPointMake([Util sharedInstance].pageXValue, yValue) animated:false];
    
    NSDate *newDay = [self getDateOfCurrentOffset];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dateUpdatedOnScroll" object:nil userInfo:@{@"date": newDay}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeRight" object:nil userInfo:@{@"date": newDay}];


    
    [Util sharedInstance].scrollDisable = true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

-(void)setupSupplementaryViewClasses{
    self.eventCellClass                 = MSEventCell.class;
    self.dayColumnHeaderClass           = MSDayColumnHeader.class;
    self.timeRowHeaderClass             = MSTimeRowHeader.class;
    
    self.currentTimeIndicatorClass      = MSCurrentTimeIndicator.class;
    self.currentTimeGridlineClass       = MSCurrentTimeGridline.class;
    self.verticalGridlineClass          = MSGridline.class;
    self.horizontalGridlineClass        = MSGridline.class;
    self.timeRowHeaderBackgroundClass   = MSTimeRowHeaderBackground.class;
    self.dayColumnHeaderBackgroundClass = MSDayColumnHeaderBackground.class;
    self.unavailableHourClass           = MSUnavailableHour.class;
    self.weekendBackgroundClass         = MSWeekendBackground.class;
}

-(void)registerSupplementaryViewClasses{
    [self.collectionView registerClass:self.eventCellClass forCellWithReuseIdentifier:MSEventCellReuseIdentifier];
    [self.collectionView registerClass:self.dayColumnHeaderClass forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:self.timeRowHeaderClass forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.weekFlowLayout registerClass:self.currentTimeIndicatorClass       forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.weekFlowLayout registerClass:self.currentTimeGridlineClass        forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.weekFlowLayout registerClass:self.verticalGridlineClass           forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.weekFlowLayout registerClass:self.horizontalGridlineClass         forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.weekFlowLayout registerClass:self.timeRowHeaderBackgroundClass    forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.weekFlowLayout registerClass:self.dayColumnHeaderBackgroundClass  forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
    
    [self.weekFlowLayout registerClass:self.unavailableHourClass            forDecorationViewOfKind:MSCollectionElementKindUnavailableHour];
    [self.weekFlowLayout registerClass:self.weekendBackgroundClass          forDecorationViewOfKind:MSCollectionElementKindWeekendBackground];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.weekFlowLayout.sectionWidth = self.layoutSectionWidth;
}

-(void)forceReload:(BOOL)reloadEvents{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(reloadEvents)
            [self groupEventsBySection];
        [self.weekFlowLayout invalidateLayoutCache];
        [self.collectionView reloadData];
        
        [Util sharedInstance].scrollDisable = true;

    });
}

- (CGFloat)layoutSectionWidth{
    
    if (self.daysToShowOnScreen == 1) {
        return self.frame.size.width;
    }
    
    return (self.frame.size.width - 0) / (self.daysToShowOnScreen);
}

-(NSDate*)firstDay{
    return [self.weekFlowLayout dateForDayColumnHeaderAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

//================================================
#pragma mark - Set Events
//================================================
-(void)setEvents:(NSArray *)events{
    mEvents = events;
 
    [Util sharedInstance].nowLoading = true;

    [self forceReload:YES];
}

-(void)addEvent:(MSEvent *)event{
    [self addEvents:@[event]];
}

-(void)addEvents:(NSArray*)events{
    self.events = [mEvents arrayByAddingObjectsFromArray:events];
    [self forceReload:YES];
}

-(void)removeEvent:(MSEvent*)event{
    self.events = [mEvents reject:^BOOL(MSEvent* arrayEvent) {
        return [arrayEvent isEqual:event];;
    }];
    [self forceReload:YES];
}

-(void)updateSelectedDate:(NSDate *)date {
    selectedDate = date;
}

-(void)updateStartdate:(NSDate *)date {

    NSDate *newStartDate = date;
    newStartDate = [newStartDate withHour:0];
    newStartDate = [newStartDate withMinute:0];
    
    startDate = newStartDate;
}

/**
 * Note that in the standard calendar, each section is a day"
 */
-(void)groupEventsBySection{
    
    if (startDate == nil) {
        startDate = [NSDate today];
    }
    
    NSDate *date = startDate;

//    NSDate* date = [NSDate parse:NSDate.today.toDateTimeString timezone:@"device"];  //If it crashes here, comment the previous line and uncomment this one
    
    _eventsBySection = NSMutableDictionary.new;

    
//    if(self.daysToShow == 1 && _eventsBySection.count == 1){
//        date = [NSDate parse:_eventsBySection.allKeys.firstObject];
//    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"YYYY-MM-dd";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSLog(@"daysToShow: %zd, startDate %@", self.daysToShow, [formatter stringFromDate:startDate]);

    for (int i = 0; i < self.daysToShow; i++) {
        NSArray *eventsByDate = [self eventsByDate:date];
        _eventsBySection[date.toDeviceTimezoneString] = [self eventsByDate:date];
        date = [date addDay];
    }
    
//    for(int i = 0; i< self.daysToShow; i++){
//        if(![_eventsBySection.allKeys containsObject:date.toDeviceTimezoneDateString]){
//            [_eventsBySection setObject:@[] forKey:date.toDeviceTimezoneDateString];
//        }
//        date = [date addDay];
//    }
}
//
//- (NSArray *)eventsByDate:(NSDate *)date {
//
//    NSMutableArray *result = [NSMutableArray array];
//
//        NSDateComponents *newComp = [NSDateComponents new];
//        newComp.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//        newComp.hour = -9;
//    //
//        NSDate *newdate = [[NSCalendar currentCalendar] dateByAddingComponents:newComp toDate:date options:0];
//
//    for (MSEvent *event in mEvents) {
////        NSLog(@"date %@, startDate : %@, date: %@, endDate: %@", newdate, event.StartDate, [date addDay], event.EndDate );
//        if (event.StartDate >= newdate && event.EndDate < [newdate addDay]) {
//            [result addObject:event];
//        }
//    }
//
//    return result;
    //}

- (NSArray *)eventsByDate:(NSDate *)date {
    NSMutableArray *filtedEvents = [NSMutableArray.alloc init];
    
    NSString *dateString = [self dateStringWithOutTime:date];
    
    for (MSEvent* event in mEvents) {
//        NSDate *eventSDate = [self dateWithOutTime: event.StartDate];//.dateWithOutTime;
//        NSDate *eventEDate = [self dateWithOutTime: event.EndDate];//.dateWithOutTime;
        NSString *eventSDate = [self dateStringWithOutTime: event.StartDate];//.dateWithOutTime;
        NSString *eventEDate = [self dateStringWithOutTime: event.EndDate];//.dateWithOutTime;

//        if (eventSDate == dateString || eventEDate == dateString  || ((eventSDate < date) && (eventEDate > date))){
//            [filtedEvents addObject:event];
//        }
        
        NSString *eventETime = [self onlyTime: event.EndDate];

        
        if ([eventSDate isEqualToString:dateString]) {
            [filtedEvents addObject:event];
        } else if ([eventEDate isEqualToString:dateString] && ![eventETime isEqualToString:@"00:00"]) {
            [filtedEvents addObject:event];
        }
    }
    
    // filtedEvents = [mEvents filter_:@selector(isInDay:) withObject:date];
    return filtedEvents;
}

- (NSString *)dateStringWithOutTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.timeZone = [[NSTimeZone alloc]initWithName:@"UTC"];
    formatter.dateFormat = @"YYYY-MM-dd";
    
    NSString *temp = [formatter stringFromDate:date];
        
//    NSLog(@"dateWithOutTime: %@", temp);
    
    return temp;
    
}

- (NSString *)onlyTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.timeZone = [[NSTimeZone alloc]initWithName:@"UTC"];
    formatter.dateFormat = @"HH:mm";
    
    NSString *temp = [formatter stringFromDate:date];
        
//    NSLog(@"dateWithOutTime: %@", temp);
    
    return temp;
    
}


//- (NSArray *)eventsByDate:(NSDate *)date {
//    return [mEvents filter_:@selector(isInDay:) withObject:date];
//}

//================================================
#pragma mark - CollectionView Datasource
//================================================
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{   
    return _eventsBySection.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString* day = [_eventsBySection.allKeys.sort objectAtIndex:section];
    return [_eventsBySection[day] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSEventCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:MSEventCellReuseIdentifier forIndexPath:indexPath];
    NSString* day      = [_eventsBySection.allKeys.sort objectAtIndex:indexPath.section];
    cell.event         = [_eventsBySection[day] objectAtIndex:indexPath.row];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day                 = [self.weekFlowLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay          = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.weekFlowLayout];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

        NSDate *startOfDay          = [calendar startOfDayForDate:day];
        NSDate *startOfCurrentDay   = [calendar startOfDayForDate:currentDay];
        
        dayColumnHeader.day         = [day addHours:9];
        dayColumnHeader.currentDay  = [startOfDay isEqualToDate:startOfCurrentDay];
        view = dayColumnHeader;
                
        
        if ([[Util sharedInstance] nowLoading] == false) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dateUpdated" object:nil userInfo:@{@"date": day}];
        }
        
         
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.weekFlowLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    }
    return view;
}

//================================================
#pragma mark - Week Flow Delegate
//================================================
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section
{
    NSString* day = [_eventsBySection.allKeys.sort objectAtIndex:section];
    return [NSDate parse:day timezone:@"UTC"];
}

//- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *day = _eventsBySection.allKeys.sort[indexPath.section];
//    MSEvent *ev = _eventsBySection[day][indexPath.row];
//
//    if ([ev.StartDate.toDeviceTimezoneString isEqualToString:day])
//        return ev.StartDate;
//
//    else return [NSDate parse:str(@"%@ 00:00:00", day) timezone:@"UTC"];
//}
//
//- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *day = _eventsBySection.allKeys.sort[indexPath.section];
//    MSEvent *ev = _eventsBySection[day][indexPath.row];
//
//    if ([ev.EndDate.toDeviceTimezoneString isEqualToString:day])
//        return ev.EndDate;
//
//    else return [NSDate parse:str(@"%@ 23:59:59", day) timezone:@"UTC"];
//}


- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* day   = [_eventsBySection.allKeys.sort objectAtIndex:indexPath.section];
    MSEvent* ev     = [_eventsBySection[day] objectAtIndex:indexPath.row];
    return ev.StartDate;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* day   = [_eventsBySection.allKeys.sort objectAtIndex:indexPath.section];
    MSEvent* ev     = [_eventsBySection[day] objectAtIndex:indexPath.row];
    return ev.EndDate;
}

-(NSArray*)unavailableHoursPeriods:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout section:(int)section{
    if([self.delegate respondsToSelector:@selector(weekView:unavailableHoursPeriods:)]){
        NSDate* date = [self collectionView:collectionView layout:collectionViewLayout dayForSection:section];
        return [self.delegate weekView:self unavailableHoursPeriods:date];
    }
    return @[];
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return NSDate.date;
}


//================================================
#pragma mark - Collection view delegate
//================================================
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate){
        MSEventCell* cell = (MSEventCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [self.delegate weekView:self eventSelected:cell];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    @try {
//        NSInteger currentIndex = self.collectionView.contentOffset.x / (self.collectionView.frame.size.width - self.collectionView.frame.size.width/8);
//        NSDate *day                 = [self.weekFlowLayout dateForDayColumnHeaderAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:currentIndex]];

//        NSDate *newDay = [self getDateOfCurrentOffset];
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"dateUpdatedOnScroll" object:nil userInfo:@{@"date": newDay}];

    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    } @finally {
        
    }
}

- (NSDate *)getDateOfCurrentOffset {
    
    CGFloat xPoint = self.collectionView.contentOffset.x;
    
    int dayCount = xPoint / self.weekFlowLayout.sectionWidth;
    
    NSDate *newDay = [self.firstDay addDays:dayCount];

    return [newDay addHours:9];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yValue = scrollView.contentOffset.y;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTimePoint" object:nil userInfo:@{@"yValue": @(yValue)}];
    
    if ([Util sharedInstance].scrollDisable) {
        self.collectionView.contentOffset = CGPointMake(0, yValue);
    }
    
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
//    CGPoint fixedOffset = *targetContentOffset;
//
//    *targetContentOffset = CGPointMake(fixedOffset.x - 30, fixedOffset.y);
    
    //CGPointMake(scrollView.contentOffset.x - self.collectionView.frame.size.width/8 , scrollView.contentOffset.y);
    
//    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + self.collectionView.frame.size.width/8, self.collectionView.contentOffset.y) animated:true];

//    NSInteger currentIndex = self.collectionView.contentOffset.x / ;
//
//    NSLog(@"currentIndex: %zd", currentIndex);
//    if (currentIndex % 7 != 0) {
//        currentIndex = currentIndex / 7 + + (7 -currentIndex % 7);
//    }
//
//    NSLog(@"fixed currentIndex: %zd", currentIndex);
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:currentIndex] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}


//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//
//
//
//
//    if (self.scrollLeft) {
//        targetX += width;
//    } else {
//        targetX -= width;
//    }
//
//
//}

//
//    targetContentOffset.pointee = scrollView.contentOffset
//    let indexOfMajorCell = self.indexOfMajorCell()
//    let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
//    delegate.didSelectTicket(index: indexOfMajorCell)
//
//    ticketCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//}
//
//private func indexOfMajorCell() -> Int {
//
//    let collectionViewLayout = ticketCollectionView.collectionViewLayout
//
//    let itemWidth = CGFloat(310)
//    let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
//    let index = Int(round(proportionalOffset))
//    let safeIndex = max(0, min(ticketList.count - 1, index))
//    return safeIndex
//}



//================================================
#pragma mark - Dealloc
//================================================
-(void)dealloc{
    self.collectionView.dataSource  = nil;
    self.collectionView.delegate    = nil;
    self.collectionView             = nil;
    self.weekFlowLayout.delegate    = nil;
    self.weekFlowLayout             = nil;
    _eventsBySection                = nil;
}

@end
