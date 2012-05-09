//
//  SGCell.m
//  TotalShare
//
//  Created by Simon Grätzer on 28.09.12.
//  Copyright (c) 2011 Cyber:con GmbH. All rights reserved.
//

#import "SGCell.h"
#import "SGAppDelegate.h"

@implementation SGCell

@synthesize cloudSwitch = _cloudSwitch;
@synthesize titleLabel = _titleLabel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeSwitch:(id)sender; {
    [appDelegate updateURL:[appDelegate.documentURLs objectAtIndex:0] setUbiquitous:self.cloudSwitch.on];
}

@end
