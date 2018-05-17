//
//  ContactCell.m
//  KVCDemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ContactCell.h"
#import "Contact.h"

@implementation ContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configWithContact:(Contact *)contact {
    self.nameLabel.text = contact.name;
    self.nickNameLabel.text = contact.nickName;
    self.emailLabel.text = contact.email;
    self.cityLabel.text = contact.city;
}

@end
