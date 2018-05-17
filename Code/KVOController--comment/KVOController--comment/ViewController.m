//
//  ViewController.m
//  KVOController--comment
//
//  Created by Hisen on 12/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ViewController.h"
#import "KVOObject.h"
#import "NSObject+FBKVOController.h"

@interface ViewController ()

@property (nonatomic, strong) KVOObject *kvoObj;
@property (weak, nonatomic) IBOutlet UIButton *countBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.kvoObj = [KVOObject new];
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.kvoObj
                        keyPath:@"count"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
                              NSLog(@"%ld", [change[NSKeyValueChangeNewKey] integerValue]);
                              [weakSelf.countBtn setTitle:[NSString stringWithFormat:@"%@", change[NSKeyValueChangeNewKey]] forState:UIControlStateNormal];
                          }];
    
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - IBActions
- (IBAction)plusBtnClicked:(id)sender {
    self.kvoObj.count += 1;
}

@end
