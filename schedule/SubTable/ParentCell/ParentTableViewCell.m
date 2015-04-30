//
//  ParentTableViewCell.m
//  SubTableExample
//
//  Created by Alex Koshy on 7/16/14.
//  Copyright (c) 2014 ajkoshy7. All rights reserved.
//

#import "ParentTableViewCell.h"
#import "AppDelegate.h"

@implementation ParentTableViewCell
@synthesize parentIndex;
@synthesize titleLabel;
@synthesize subtitleLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier; {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (!self) {
        return self;
    }
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    float yPos = appDelegate.cellSize/2 - 8;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, yPos, 200, 16)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.opaque = NO;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont fontWithName:@"ProximaNova-SemiBold" size:18];
    [self.contentView addSubview:titleLabel];
    
    [self.contentView setAutoresizesSubviews:YES];
    
    return self;
}

- (void)setCellForegroundColor:(UIColor *)foregroundColor {
    self.titleLabel.textColor = foregroundColor;
}
- (void)setCellBackgroundColor:(UIColor *)backgroundColor {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float yPos = appDelegate.cellSize/2 - 8;
    [self.titleLabel setFrame:CGRectMake(32, yPos, 200, 16)];
    
    self.contentView.backgroundColor = backgroundColor;
}

@end
