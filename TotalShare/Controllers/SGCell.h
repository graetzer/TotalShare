//
//  SGCell.h
//  TotalShare
//
//  Created by Simon Grätzer on 28.09.12.
//  Copyright (c) 2011 Cyber:con GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *cloudSwitch;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)changeSwitch:(id)sender;

@end
