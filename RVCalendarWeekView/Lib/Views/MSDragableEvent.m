//
//  MSDragableEvent.m
//  RVCalendarWeekView
//
//  Created by Jordi Puigdellívol on 23/8/16.
//  Copyright © 2016 revo. All rights reserved.
//

#import "MSDragableEvent.h"

#define MAS_SHORTHAND
#import "Masonry.h"


@interface MSEventCell ()
- (UIColor *)textColorHighlighted:(BOOL)selected;
@end


@implementation MSDragableEvent

+(MSDragableEvent*)makeWithEventCell:(MSEventCell*)eventCell andOffset:(CGPoint)offset touchOffset:(CGPoint)touchOffset{
    
//    CGFloat width = [UIScreen mainScreen].bounds.size.width / 8;
    
    CGRect  newFrame = CGRectMake(eventCell.frame.origin.x - offset.x,
                                  eventCell.frame.origin.y - offset.y,
                                  eventCell.frame.size.width, eventCell.frame.size.height);
    
    MSDragableEvent *dragCell   = [[MSDragableEvent alloc] initWithFrame:newFrame];
    dragCell.touchOffset        = touchOffset;
    dragCell.event              = eventCell.event;
//    dragCell.backgroundColor    = [eventCell backgroundColorHighlighted:YES];    
//    dragCell.title.textColor    = [eventCell textColorHighlighted:YES];
//    dragCell.location.textColor = [eventCell textColorHighlighted:YES];
    
    return dragCell;
}

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        CGFloat borderWidth = 2.0;
        UIEdgeInsets contentPadding = UIEdgeInsetsMake(1.0, (borderWidth + 4.0), 1.0, 4.0);
        
        self.timeLabel                  = [UILabel new];
        self.timeLabel.font             = [UIFont systemFontOfSize:11];
//        self.timeLabel.textColor        = UIColor.blackColor;
        self.timeLabel.textColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
        self.timeLabel.textAlignment    = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        [self.timeLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo    (self.top)  .offset(-15);
            make.left.equalTo   (self.left) .offset(contentPadding.left);
            make.right.equalTo  (self.right).offset(-contentPadding.right);
        }];
        
        self.timeLabel.text = @"--";
    }
    return self;
}


@end
