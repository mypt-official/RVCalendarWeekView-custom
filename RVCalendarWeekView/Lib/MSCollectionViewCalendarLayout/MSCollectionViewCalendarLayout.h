//
//  MSCollectionViewCalendarLayout.h
//  MSCollectionViewCalendarLayout
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

extern NSString * const MSCollectionElementKindTimeRowHeader;
extern NSString * const MSCollectionElementKindDayColumnHeader;
extern NSString * const MSCollectionElementKindTimeRowHeaderBackground;
extern NSString * const MSCollectionElementKindDayColumnHeaderBackground;
extern NSString * const MSCollectionElementKindCurrentTimeIndicator;
extern NSString * const MSCollectionElementKindCurrentTimeHorizontalGridline;
extern NSString * const MSCollectionElementKindVerticalGridline;
extern NSString * const MSCollectionElementKindHorizontalGridline;
extern NSString * const MSCollectionElementKindUnavailableHour;
extern NSString * const MSCollectionElementKindWeekendBackground;

typedef NS_ENUM(NSUInteger, MSSectionLayoutType) {
    MSSectionLayoutTypeHorizontalTile,
    MSSectionLayoutTypeVerticalTile
};

typedef NS_ENUM(NSUInteger, MSHeaderLayoutType) {
    MSHeaderLayoutTypeTimeRowAboveDayColumn,
    MSHeaderLayoutTypeDayColumnAboveTimeRow
};

typedef NS_ENUM(NSUInteger, MSHourGridDivision) {
	MSHourGridDivision_NONE			= 0,
	MSHourGridDivision_05_Minutes	= 5,
	MSHourGridDivision_10_Minutes	= 10,
	MSHourGridDivision_15_Minutes	= 15,
	MSHourGridDivision_20_Minutes	= 20,
	MSHourGridDivision_30_Minutes	= 30,
};

@class MSCollectionViewCalendarLayout;
@protocol MSCollectionViewDelegateCalendarLayout;

@interface MSCollectionViewCalendarLayout : UICollectionViewLayout

@property (nonatomic, weak) id <MSCollectionViewDelegateCalendarLayout> delegate;

@property (nonatomic) BOOL show24Hours;
@property (nonatomic) CGFloat sectionWidth;
@property (nonatomic) CGFloat hourHeight;
@property (nonatomic) CGFloat dayColumnHeaderHeight;
@property (nonatomic) CGFloat timeRowHeaderWidth;
@property (nonatomic) CGSize currentTimeIndicatorSize;
@property (nonatomic) CGFloat horizontalGridlineHeight;
@property (nonatomic) CGFloat verticalGridlineWidth;
@property (nonatomic) CGFloat currentTimeHorizontalGridlineHeight;
@property (nonatomic) MSHourGridDivision hourGridDivisionValue;
@property (nonatomic) UIEdgeInsets sectionMargin;
@property (nonatomic) UIEdgeInsets contentMargin;
@property (nonatomic) UIEdgeInsets cellMargin;
@property (nonatomic) MSSectionLayoutType sectionLayoutType;
@property (nonatomic) MSHeaderLayoutType headerLayoutType;
@property (nonatomic) BOOL displayHeaderBackgroundAtOrigin;

@property (assign, nonatomic) NSInteger myEarliesHour;
@property (assign, nonatomic) NSInteger myLatestHour;

- (NSInteger)earliestHour;
- (NSInteger)latestHour;

- (NSDate *)dateForTimeRowHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollCollectionViewToClosetSectionToCurrentTimeAnimated:(BOOL)animated;
- (void)scrollCollectionViewToClosetSectionToTime:(NSDate*)time animated:(BOOL)animated;
- (void)scrollCollectionViewToCurrentTime:(BOOL)animated;

// Since a "reloadData" on the UICollectionView doesn't call "prepareForCollectionViewUpdates:", this method must be called first to flush the internal caches
- (void)invalidateLayoutCache;

@end

@protocol MSCollectionViewDelegateCalendarLayout <UICollectionViewDelegate>

@required

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout dayForSection:(NSInteger)section;
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout;
-(NSArray*)unavailableHoursPeriods:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout section:(int)section;

@end
