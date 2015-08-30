//
//  SubTableViewCell.m
//  SubTableExample
//
//  Created by Alex Koshy on 7/16/14.
//  Copyright (c) 2014 ajkoshy7. All rights reserved.
//

#import "SubTableViewCell.h"

@implementation SubTableViewCell
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize timeLabel;
@synthesize durationLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (!self)
        return self;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.opaque = NO;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.opaque = NO;
    subtitleLabel.textColor = [UIColor blackColor];
    subtitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:subtitleLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel.backgroundColor = titleLabel.textColor;
    timeLabel.opaque = YES;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:timeLabel];
    
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    durationLabel.backgroundColor = [UIColor clearColor];
    durationLabel.opaque = YES;
    durationLabel.textColor = [UIColor lightGrayColor];
    durationLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:durationLabel];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupDisplay];
}

- (void)setupDisplay {
    [self.contentView setAutoresizesSubviews:YES];
    
    self.titleLabel.frame = CGRectMake(118, 15, (self.contentView.frame.size.width-138), 24);
    self.subtitleLabel.frame = CGRectMake(118, 40, (self.contentView.frame.size.width-138), 20);
    self.timeLabel.frame = CGRectMake(32, 19, 60, 24);
    self.durationLabel.frame = CGRectMake(32, 44, 60, 16);
    
    self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:17];
    self.timeLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:17];
    self.subtitleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    self.durationLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:10];
}

- (void)setCellForegroundColor:(UIColor *)foregroundColor {
    titleLabel.textColor = timeLabel.backgroundColor = foregroundColor;
    subtitleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
}

- (void)setCellBackgroundColor:(UIColor *) backgroundColor {
    self.contentView.backgroundColor = [UIColor whiteColor];
}

@end
