//
//  MSEventCell.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSEventCell.h"

#define MAS_SHORTHAND
#import "Masonry.h"
#import "UIColor+HexString.h"
#import "RVCollection.h"
#import "MSDurationChangeIndicator.h"

@interface MSEventCell ()

@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIView *topBorderView;
@property (assign, nonatomic) BOOL isFake;

@end

@implementation MSEventCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.selected = true;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.shouldRasterize = YES;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.0;
        
        self.borderView = [UIView new];
        self.borderView.backgroundColor = [UIColor colorWithHexString:@"e5e5ea"];
        [self.contentView addSubview:self.borderView];
        
        self.topBorderView = [UIView new];
        self.topBorderView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.topBorderView];
        
        self.title = [UILabel new];
        self.title.numberOfLines = 0;
        self.title.backgroundColor = [UIColor clearColor];
        [self.title setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:11]];
        [self.contentView addSubview:self.title];
        
        self.location = [UILabel new];
        self.location.numberOfLines = 1;
        self.location.backgroundColor = [UIColor clearColor];
        self.location.textAlignment = NSTextAlignmentCenter;
        [self.location setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:11]];
        [self.contentView addSubview:self.location];
        
        self.countLabel = [UILabel new];
        self.countLabel.numberOfLines = 0;
        self.countLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.layer.cornerRadius = 4;
        self.countLabel.clipsToBounds = true;
        [self.countLabel setFont:[UIFont fontWithName:@"Bazzi" size:10]];
        [self.contentView addSubview:self.countLabel];
        
        [self updateColorsWithType:_event.location];
        
        CGFloat borderWidth = 2.9;
        CGFloat contentMargin = 2.0;
        UIEdgeInsets contentPadding = UIEdgeInsetsMake(4.0, (borderWidth + 4.0), 1.0, 4.0);
        CGFloat maxWidth = 46.0;
//
        [self.borderView makeConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(self.height);
            make.height.equalTo(@(self.contentView.frame.size.height));
//            make.width.equalTo(@(borderWidth));
            make.width.equalTo(@(1));
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
//            make.right.equalTo(self.right);
        }];
//
        [self.topBorderView makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(borderWidth));
            make.width.equalTo(@(self.contentView.frame.size.width));
            make.top.equalTo(self.top);
            make.left.equalTo(self.left);
            make.right.equalTo(self.right);
        }];
        
        [self.title makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBorderView.bottom).offset(3);
            make.left.equalTo(self.contentView).offset(3);
//            make.right.equalTo(self.right).offset(-contentPadding.right);
            make.width.equalTo(@(self.contentView.frame.size.width - 6));
//            make.centerX.equalTo(self.centerX);
        }];
        
        [self.location makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.title.bottom).offset(contentMargin);
            make.left.equalTo(self.contentView).offset(3);
//            make.right.equalTo(self.right).offset(-contentPadding.right);
            make.bottom.lessThanOrEqualTo(self.bottom).offset(-contentPadding.bottom);
            
            make.width.equalTo(@(self.contentView.frame.size.width - 6));

        }];
        [self.countLabel makeConstraints:^(MASConstraintMaker *make) {
//            make.top.lessThanOrEqualTo(self.location.bottom).offset(contentMargin);
            make.left.equalTo(self.contentView).offset(3);
//            make.right.equalTo(self.right).offset(-contentPadding.right);
            make.top.equalTo(self.location.bottom).offset(5);
            make.height.equalTo(@13);
            
            make.width.equalTo(@(self.contentView.frame.size.width - 6));
        }];
    }
    return self;
}

#pragma mark - UICollectionViewCell
- (void)setSelected:(BOOL)selected
{
//    if (selected && (self.selected != selected)) {
//        [UIView animateWithDuration:0.1 animations:^{
////            self.transform = CGAffineTransformMakeScale(1.025, 1.025);
////            self.layer.shadowOpacity = 0.2;
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.1 animations:^{
////                self.transform = CGAffineTransformIdentity;
//            }];
//        }];
//    } else if (selected) {
////        self.layer.shadowOpacity = 0.2;
//    } else {
//        self.layer.shadowOpacity = 0.0;
//    }
    [super setSelected:selected]; // Must be here for animation to fire
    [self updateColorsWithType:_event.location];
    [self removeIndicators];
}


#pragma mark - MSEventCell
- (void)setEvent:(MSEvent *)event
{
    _event = event;
    
    if ([event.title isEqualToString:@"temp_event"]) {
        self.isFake = true;
    } else {
        self.isFake = false;
    }
    NSArray *arr = [_event.restTime componentsSeparatedByString:@"/"];
    NSString *resttime = [arr objectAtIndex:0];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:_event.restTime];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"fd7430"] range:NSMakeRange(0, resttime.length)];
    
    //etc 이벤트일때 countLabel 숨김
    if ([event.title isEqualToString:@"etc"]) {
        self.countLabel.hidden = true;
    }else {
        self.countLabel.hidden = false;
    }
    if (event.classTime == 10) {
        self.location.hidden = true;
        self.countLabel.hidden = true;
    }else if (event.classTime < 40) {
        self.location.hidden = false;
        self.countLabel.hidden = true;
    }else {
        self.location.hidden = false;
        self.countLabel.hidden = false;
    }
//    self.title.text = _event.title;
    self.location.text = _event.location;
    self.countLabel.attributedText = attribute;
    [self updateColorsWithType:event.title];
}


- (void)updateColorsWithType:(NSString *)typeString
{
//    self.contentView.backgroundColor = [self backgroundColorHighlighted:self.selected];
    
   
//    else if ([typeString isEqualToString:@"ready"]) {
//
//    } else if ([typeString isEqualToString:@"ready"]) {
//
//    }
    
    if (self.isFake) {
        self.title.textColor = [UIColor clearColor];
        self.location.textColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.topBorderView.backgroundColor = [UIColor clearColor];
    } else {
        self.title.textColor             = [UIColor blackColor];
        self.location.textColor          = [UIColor blackColor];
        
        if ([typeString isEqualToString:@"ready"]) {
            self.contentView.backgroundColor = [UIColor colorWithHexString:@"fff4f3"];
            self.topBorderView.backgroundColor  = [UIColor colorWithHexString:@"fe7e79"];

        } else if ([typeString isEqualToString:@"attendance"]) {
            self.contentView.backgroundColor = [UIColor colorWithHexString:@"dcf7ea"];
            self.topBorderView.backgroundColor  = [UIColor colorWithHexString:@"56ce91"];

        }  else if ([typeString isEqualToString:@"complete"]) {
            self.contentView.backgroundColor = [UIColor colorWithHexString:@"fff4e6"];
            self.topBorderView.backgroundColor  = [UIColor colorWithHexString:@"ffe797"];
            
        }  else if ([typeString isEqualToString:@"etc"])  {
            self.contentView.backgroundColor = [UIColor colorWithHexString:@"ebf9ff"];
            self.topBorderView.backgroundColor  = [UIColor colorWithHexString:@"76d6ff"];
            
        }

    }
}

-(void)removeIndicators{
    [self.subviews each:^(UIView* subview) {
        if([subview isKindOfClass:MSDurationChangeIndicator.class]){
            [subview removeFromSuperview];
        }
    }];
}

- (NSDictionary *)titleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
             NSFontAttributeName : [UIFont boldSystemFontOfSize:11],
             NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
             NSParagraphStyleAttributeName : paragraphStyle
             };
}

- (NSDictionary *)subtitleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
             NSFontAttributeName : [UIFont systemFontOfSize:11],
             NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
             NSParagraphStyleAttributeName : paragraphStyle
             };
}

- (UIColor *)backgroundColorHighlighted:(BOOL)selected
{
    return selected ? [ UIColor redColor] : [UIColor orangeColor];
    //[UIColor colorWithHexString:@"35b1f1"] : [[UIColor colorWithHexString:@"35b1f1"] colorWithAlphaComponent:0.2];
}

- (UIColor *)textColorHighlighted:(BOOL)selected
{
    return selected ? [UIColor blackColor] : [UIColor colorWithHexString:@"21729c"];
}

- (UIColor *)borderColor
{
    return [[self backgroundColorHighlighted:NO] colorWithAlphaComponent:1.0];
}

@end
