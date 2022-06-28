//
//  MSWeekViewDecoratorDragable.m
//  RVCalendarWeekView
//
//  Created by Jordi Puigdellívol on 1/9/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import "MSWeekViewDecoratorDragable.h"
#import "NSDate+Easy.h"
#import "RVCollection.h"
#import "NSDate+DateTools.h"

@interface MSWeekViewDecoratorDragable () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) MSEvent *draggedEvent;
@end

@implementation MSWeekViewDecoratorDragable

+(__kindof MSWeekView*)makeWith:(MSWeekView*)weekView andDelegate:(id<MSWeekViewDragableDelegate>)delegate{
    MSWeekViewDecoratorDragable * weekViewDecorator = [super makeWith:weekView];
    weekViewDecorator.dragDelegate = delegate;
    return weekViewDecorator;
}

//=========================================================
#pragma mark - Collection view datasource
//=========================================================
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSEventCell *cell                   = (MSEventCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if(![self isGestureAlreadyAdded:cell]){
        UILongPressGestureRecognizer* lpgr  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onEventCellLongPress:)];
        lpgr.delegate                       = self;
        [cell addGestureRecognizer:lpgr];
    }
    
    return cell;
}

//=========================================================
#pragma mark - Gesture recognizer delegate
//=========================================================
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    MSEventCell* eventCell = (MSEventCell*)gestureRecognizer.view;
    return [self.dragDelegate weekView:self.weekView canStartMovingEvent:eventCell.event];
}

//=========================================================
#pragma mark - Drag & Drop
//=========================================================
-(void)onEventCellLongPress:(UILongPressGestureRecognizer*)gestureRecognizer{
    MSEventCell* eventCell = (MSEventCell*)gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Star drag: %@",eventCell.event.title);
        
        self.draggedEvent = eventCell.event;
        
        CGPoint touchOffsetInCell = [gestureRecognizer locationInView:gestureRecognizer.view];
        mDragableEvent = [MSDragableEvent makeWithEventCell:eventCell andOffset:self.weekView.collectionView.contentOffset touchOffset:touchOffsetInCell];
        [self.baseWeekView addSubview:mDragableEvent];
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        NSLog(@"during drag: %@",eventCell.event.title);
        NSLog(@"during drag: %@",self.draggedEvent.title);

        CGPoint cp = [gestureRecognizer locationInView:self.baseWeekView];
        
        CGPoint newOrigin;
        
        float xOffset = fmod(self.collectionView.contentOffset.x , self.weekFlowLayout.sectionWidth) - self.weekFlowLayout.sectionWidth;
//        float xOffset   = (self.collectionView.contentOffset.x % self.weekFlowLayout.sectionWidth) - self.weekFlowLayout.timeRowHeaderWidth;
        cp.x           += xOffset;
        float x         = [self round:cp.x toLowest:self.weekFlowLayout.sectionWidth] - xOffset;
//        
//        if (self.weekFlowLayout.sectionWidth > 100) {
//            x = [UIScreen mainScreen].bounds.size.width / 8 - xOffset;
//        }
        newOrigin       = CGPointMake(x, cp.y);
        newOrigin       = CGPointMake(newOrigin.x/* + mDragableEvent.touchOffset.x*/,
                                      newOrigin.y - mDragableEvent.touchOffset.y);

    
        static CGFloat newOriginY;
        
        CGFloat originX = self.collectionView.contentOffset.x;
        CGFloat originY = self.collectionView.contentOffset.y;
        
//        if (newOrigin.y < newOriginY) {
//            originY -= ;
//        } else if (newOrigin.y > newOriginY){
//            originY += 2;
//        } else {
//
//        }
        
        if (newOriginY < 100) {
            originY -= 7;
        } else if (newOriginY > self.collectionView.frame.size.height - 120) {
            originY += 7;
        }
        
        if (originY > (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
            originY = (self.collectionView.contentSize.height - self.collectionView.frame.size.height);
        }
        
        if (originY < 0.0) {
            originY = 0.0;
        }
        
        if (newOrigin.y < self.weekFlowLayout.dayColumnHeaderHeight) {
            newOrigin.y = self.weekFlowLayout.dayColumnHeaderHeight;
        }
        
        newOriginY = newOrigin.y;

        [self.collectionView setContentOffset:CGPointMake(originX, originY) animated:false];

        
        [UIView animateWithDuration:0.1 animations:^{
            mDragableEvent.frame = (CGRect) { .origin = newOrigin, .size = mDragableEvent.frame.size };
        }];
        
        NSDate* date                  = [self dateForDragable];
        mDragableEvent.timeLabel.text = [date format:@"HH:mm" timezone:@"UTC"];
                
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //NSLog(@"Long press ended: %@",eventCell.akEvent.title);
        [self onDragEnded:eventCell];
    }
}

-(void)onDragEnded:(MSEventCell*)eventCell{
    
    NSDate* newStartDate = [self dateForDragable];
    
    if([self canMoveToNewDate:self.draggedEvent newDate:newStartDate]){
        int duration = eventCell.event.durationInSeconds;
        eventCell.event.StartDate = newStartDate;
        eventCell.event.EndDate = [eventCell.event.StartDate dateByAddingSeconds:duration];
        [self.baseWeekView forceReload:YES];
        if(self.dragDelegate){
            [self.dragDelegate weekView:self.baseWeekView event:self.draggedEvent moved:newStartDate];
        }
    }
    
    [mDragableEvent removeFromSuperview];
    mDragableEvent = nil;
}


-(NSDate*)dateForDragable{
    CGPoint dropPoint = CGPointMake(mDragableEvent.frame.origin.x + mDragableEvent.touchOffset.x,
                                    mDragableEvent.frame.origin.y);
    return [self dateForPoint:dropPoint];
}

//=========================================================
#pragma mark - Can move to new date?
//=========================================================
-(BOOL)canMoveToNewDate:(MSEvent*)event newDate:(NSDate*)newDate{
    if (! self.dragDelegate) return true;
    
//    [self.baseWeekView setMoveTargetDate:newDate];
    return [self.dragDelegate weekView:self canMoveEvent:event to:newDate];
}

-(BOOL)isPortrait{
    return (UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait || UIDevice.currentDevice.orientation == UIDeviceOrientationFaceUp);
}

//=========================================================
#pragma mark - Gesture Recongnizer Delegate
//=========================================================
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer  shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer  *)otherGestureRecognizer
{
    return otherGestureRecognizer.view == gestureRecognizer.view;
}

@end
