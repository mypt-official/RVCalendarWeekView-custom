//
//  MSDayColumnHeaderBackground.m
//  Example
//
//  Created by Eric Horacek on 2/28/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSDayColumnHeaderBackground.h"
#import "UIColor+HexString.h"

#define BOTTOM_BORDER_WIDTH 4

@implementation MSDayColumnHeaderBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.underLineView = [UIView new];
        self.underLineView.frame = CGRectMake(0, 65, self.frame.size.width , 5);
    //    self.underLineView.center = self.center;
        self.underLineView.backgroundColor = [UIColor colorWithHexString:@"f8f8f8"];
        self.underLineView.clipsToBounds = true;
        [self addSubview:self.underLineView];
        //Until sticky headers without bounce.. we can't to that
        /*self.backgroundColor = UIColor.whiteColor;
        UIView* bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-BOTTOM_BORDER_WIDTH, self.frame.size.width, BOTTOM_BORDER_WIDTH)];
        bottomBorder.backgroundColor = [UIColor colorWithHexString:@"d7d7d7"];
        [self addSubview:bottomBorder];*/

    }
    return self;
}

@end
