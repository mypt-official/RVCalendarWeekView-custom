//
//  MSDayColumnHeader.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSDayColumnHeader.h"
#define MAS_SHORTHAND
#import "Masonry.h"
#import "UIColor+HexString.h"

@interface MSDayColumnHeader ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *titleBackground;
@property (nonatomic, strong) UIImageView *todayLabel;
@property (nonatomic, strong) UIButton *headerButton;

@end

@implementation MSDayColumnHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f] CGColor];
//        self.layer.shadowOffset = CGSizeMake(0.0, 2.0f);
//
//        self.layer.shadowRadius = 2.0f;
//        self.layer.shadowOpacity = 1.0f;
//        self.layer.masksToBounds = NO;
        self.clipsToBounds = true;
        
        self.titleBackground                    = [UIView new];
        self.titleBackground.frame = CGRectMake(0, 0, 44.0, self.frame.size.height);
        self.titleBackground.center = self.center;
        self.titleBackground.backgroundColor = [UIColor clearColor];
        self.titleBackground.layer.cornerRadius = 4.0f;
        self.titleBackground.clipsToBounds = true;
        
        [self addSubview:self.titleBackground];
        
        self.backgroundColor        = [UIColor clearColor];
        self.title                  = [UILabel new];
        self.title.numberOfLines = 0;
        
        [self.title setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12]];
        [self.title setTextColor:[UIColor colorWithHexString:@"a0a0a0"]];
        self.title.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.title];
        
        [self.titleBackground makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 3, 0, 3));
        }];
        
        
        [self.title makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleBackground);
        }];
        
        self.todayLabel = [UIImageView new];
        self.todayLabel.image = [UIImage imageNamed:@"combinedShape"];
        
        [self addSubview:self.todayLabel];
        
        [self.todayLabel makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.titleBackground);
            make.width.equalTo(@6.0);
            make.height.equalTo(@3.0);
            make.centerX.equalTo(self.titleBackground.centerX);
            
        }];
        
        self.headerButton = [UIButton new];
        [self.headerButton addTarget:self action:@selector(didTouchHeaderView) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.headerButton];
        
        [self.headerButton makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleBackground);
        }];
        
    }
    return self;
}

- (void)didTouchHeaderView {
    NSLog(@"didTouchHeaderView %@", self.day);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didTouchHeaderView" object:nil userInfo:@{@"date": self.day}];
}

- (void)setDay:(NSDate *)day
{
    _day = day ;
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        //dateFormatter.dateFormat = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"EEE MMM d" : @"EEEE MMMM d, YYYY");
        dateFormatter.dateFormat =  @"EEE d";
        
    }
    
    NSString *dayString = [dateFormatter stringFromDate:day];
    
    NSArray *temp = [dayString componentsSeparatedByString:@" "];
//    self.title.text = [dateFormatter stringFromDate:day];
    
    NSDictionary *dayDic = @{ @"Mon" : @"월", @"Tue" : @"화", @"Wed" : @"수" , @"Thu": @"목",  @"Fri" : @"금", @"Sat" : @"토" , @"Sun" : @"일" };

    NSString *dayOfWeek = [dayDic objectForKey:temp[0]];
    NSString *dayInt = temp[1];
    
    NSString *tempString = [NSString stringWithFormat:@"%@\n%@",dayOfWeek,dayInt];
    
    NSMutableAttributedString *attrsString =  [[NSMutableAttributedString alloc] initWithString:tempString];
    NSRange dayRange = [tempString rangeOfString:dayOfWeek];
    NSRange range = [tempString rangeOfString:dayInt];
    
    if (range.location != NSNotFound) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
          paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 4;
        if ([dayOfWeek isEqual: @"일"]) {
            [attrsString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString: @"#fe7e79"] range:dayRange];
            [attrsString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString: @"#fe7e79"] range:range];
        }else if ([dayOfWeek isEqual: @"토"]) {
            [attrsString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString: @"#76d6ff"] range:dayRange];
            [attrsString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString: @"#76d6ff"] range:range];
        }else {
            [attrsString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
        }
        
        [attrsString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:range];
        [attrsString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[tempString rangeOfString:tempString]];
    }

    self.title.attributedText = attrsString;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    formatter.dateFormat = @"yyyy.MM.dd";
    
    NSString *dateString = [formatter stringFromDate:day];
    NSString *todayString = [formatter stringFromDate:[NSDate date]];
    
    if ([dateString isEqualToString:todayString]) {
        self.todayLabel.hidden = false;
        NSLog(@"today");
        
    } else {
        self.todayLabel.hidden = true;
    }
    
    [self setNeedsLayout];
}

- (void)setCurrentDay:(BOOL)currentDay
{
    _currentDay = currentDay;
    
//    if (currentDay) {
//        self.title.textColor                    = [UIColor whiteColor];
//        self.title.font                         = [UIFont boldSystemFontOfSize:16.0];
//        self.titleBackground.backgroundColor    = [UIColor colorWithHexString:@"fd3935"];
//    } else {
//        self.title.font                         = [UIFont systemFontOfSize:16.0];
//        self.title.textColor                    = [UIColor blackColor];
//        self.titleBackground.backgroundColor    = [UIColor clearColor];
//    }
}

@end
