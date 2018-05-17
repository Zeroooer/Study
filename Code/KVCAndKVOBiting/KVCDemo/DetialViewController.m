//
//  DetialViewController.m
//  KVCDemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "DetialViewController.h"
#import "Contact.h"

@interface DetialViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;


@end

@implementation DetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTextFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - private
- (NSArray *)contactKeys {
    return @[@"name", @"nickName", @"email", @"city"];
}

- (UITextField *)textFieldForKey:(NSString *)key {
    return [self valueForKey:[key stringByAppendingString:@"Field"]];
}

- (void)updateTextFields {
    for (NSString *key in [self contactKeys]) {
        [self textFieldForKey:key].text = [self.contact valueForKey:key];
    }
}

#pragma mark - IBActions
- (IBAction)fieldEditingDidEnd:(UITextField *)sender {
    for (NSString *key in [self contactKeys]) {
        UITextField *textField = [self textFieldForKey:key];
        if (textField == sender) {
            id value = sender.text;
            if ([value isEqualToString:[self.contact valueForKey:key]]) {
                break;
            }
            NSError *error = nil;
            if ([self.contact validateValue:&value forKey:key error:&error]) {
                [self.contact setValue:value forKey:key];
                sender.text = value;
            } else {
                sender.text = [self.contact valueForKey:key];
            }
            break;
        }
    }
}

@end
