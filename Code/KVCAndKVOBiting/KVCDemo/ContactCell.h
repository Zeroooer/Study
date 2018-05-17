//
//  ContactCell.h
//  KVCDemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;

@interface ContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

- (void)configWithContact:(Contact *)contact;

@end
