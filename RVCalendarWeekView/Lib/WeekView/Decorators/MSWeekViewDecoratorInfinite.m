//
//  MSWeekViewDecoratorInfinite.m
//  RVCalendarWeekView
//
//  Created by Badchoice on 1/9/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import "MSWeekViewDecoratorInfinite.h"
#import "NSDate+Easy.h"
#import "Util.h"

#define DAYS_TO_LOAD 7
@interface MSWeekView()
    -(void)groupEventsByDays;
@end

@implementation MSWeekViewDecoratorInfinite

+(__kindof MSWeekView*)makeWith:(MSWeekView*)weekView andDelegate:(id<MSWeekViewInfiniteDelegate>)delegate{
    MSWeekViewDecoratorInfinite * weekViewDecorator = [super makeWith:weekView];
    weekViewDecorator.infiniteDelegate = delegate;
    return weekViewDecorator;
}

//======================================================
#pragma mark - INFINITE SCROLL
//======================================================
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];

    NSInteger currentOffset = scrollView.contentOffset.x;
    NSInteger maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width;
    
    // Change 10.0 to adjust the distance from side
//    if (maximumOffset - currentOffset <= 10.0 && !mLoading  && [Util sharedInstance].nowLoading == false/*&& mShouldLoadMore*/) {
////    if (currentOffset == maximumOffset && !mLoading  && [Util sharedInstance].nowLoading == false) {
//
//        //NSLog(@"Load more if necessary");
//        [Util sharedInstance].nowLoading = true;
//        [self loadNextDays];
//    } else if (currentOffset == 0 && !mLoading && [Util sharedInstance].nowLoading == false) {
//        [Util sharedInstance].nowLoading = true;
//        [self loadPrevDays];
//    }


}

-(void)loadPrevDays{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLoading" object:nil];

    mLoading = true;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate * startDate  = [self.baseWeekView.firstDay   addDays:-DAYS_TO_LOAD ];
        NSDate * endDate    = [startDate                    addDays:DAYS_TO_LOAD];
        
        self.baseWeekView.daysToShow += DAYS_TO_LOAD;
        if(self.infiniteDelegate){
            if(![self.infiniteDelegate weekView:self.baseWeekView newDaysLoaded:startDate to:endDate]){
                
            }
            
            [self.baseWeekView forceReload:YES];
        }
        else{
            [self.baseWeekView forceReload:YES];
        }
        
        mLoading = false;
    });

}

-(void)loadNextDays{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLoading" object:nil];

    mLoading = true;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate * startDate  = [self.baseWeekView.firstDay   addDays:DAYS_TO_LOAD];
        NSDate * endDate    = [startDate                    addDays:DAYS_TO_LOAD            ];
        
        self.baseWeekView.daysToShow += DAYS_TO_LOAD;
        if(self.infiniteDelegate){
            if(![self.infiniteDelegate weekView:self.baseWeekView newDaysLoaded:startDate to:endDate]){
                [self.baseWeekView forceReload:YES];
            }
        }
        else{
            [self.baseWeekView forceReload:YES];
        }
        
        mLoading = false;
    });    
}


@end
