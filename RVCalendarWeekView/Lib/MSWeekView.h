//
//  RVWeekView.h
//  RVCalendarWeekView
//
//  Created by Badchoice on 22/8/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCollectionViewCalendarLayout.h"
#import "MSDragableEvent.h"
#import "MSEvent.h"


@protocol MSWeekViewDelegate <NSObject>
-(void)weekView:(id)sender eventSelected:(MSEventCell*)eventCell;

@optional
/**
 * Should Return an array of MSHourPerdiod ex:(00:00,10:00) 
 */
-(NSArray*)weekView:(id)sender unavailableHoursPeriods:(NSDate*)date;
@end

@interface MSWeekView : UIView <UICollectionViewDataSource, UICollectionViewDelegate,MSCollectionViewDelegateCalendarLayout, UIGestureRecognizerDelegate>
{
    NSArray             * mEvents;
    NSDate              * selectedDate;
    NSDate              * startDate;
}

@property(strong,nonatomic) UICollectionView* collectionView;
@property(strong,nonatomic) MSCollectionViewCalendarLayout* weekFlowLayout;

//@property(nonatomic) NSDate *selectedDate;
@property(nonatomic) int daysToShowOnScreen;
@property(nonatomic) int daysToShow;
@property(strong,nonatomic) NSArray* events;
@property (nonatomic) CGFloat lastContentOffset;
@property(assign, nonatomic) BOOL scrollLeft;
@property(weak,nonatomic) id<MSWeekViewDelegate> delegate;

@property(assign, nonatomic) BOOL isFirst;

/** Base property for storing each even on its sections, by default the key is the day
  but you can customize to put anything there*/
@property(strong,nonatomic) NSMutableDictionary* eventsBySection;

/**
 * Changes these in subclass's registerClasses before calling [super registerClasses];
 */
@property(nonatomic) Class eventCellClass;
@property(nonatomic) Class dayColumnHeaderClass;
@property(nonatomic) Class timeRowHeaderClass;

/**
 * These are optional. If you don't want any of the decoration views, just set them to nil.
 */
@property(nonatomic) Class currentTimeIndicatorClass;
@property(nonatomic) Class currentTimeGridlineClass;
@property(nonatomic) Class verticalGridlineClass;
@property(nonatomic) Class horizontalGridlineClass;
@property(nonatomic) Class timeRowHeaderBackgroundClass;
@property(nonatomic) Class dayColumnHeaderBackgroundClass;
@property(nonatomic) Class unavailableHourClass;
@property(nonatomic) Class weekendBackgroundClass;


-(void)updateSelectedDate:(NSDate *)date;
-(void)updateStartdate:(NSDate *)date;
/**
 * Override this function to customize the views you want to use
 * Just change the classes that you will use
 */
-(void)setupSupplementaryViewClasses;

/**
 * Call this function to reload (when
 */
-(void)forceReload:(BOOL)reloadEvents;

-(void)addEvent   :(MSEvent*)event;
-(void)addEvents  :(NSArray*)events;
-(void)removeEvent:(MSEvent*)event;

-(NSDate *)getDateOfCurrentOffset;

-(NSDate*)firstDay;

@end
