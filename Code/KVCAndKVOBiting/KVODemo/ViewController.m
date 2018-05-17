//
//  ViewController.m
//  KVODemo
//
//  Created by Hisen on 10/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ViewController.h"
#import "RGBColor.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@property (weak, nonatomic) IBOutlet UILabel *RLabel;
@property (weak, nonatomic) IBOutlet UILabel *GLabel;
@property (weak, nonatomic) IBOutlet UILabel *BLabel;
@property (weak, nonatomic) IBOutlet UILabel *RValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *GValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *BValueLabel;

@property (strong, nonatomic) RGBColor *rgbColor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.rgbColor = [RGBColor new];
}

- (void)dealloc {
    [self.rgbColor removeObserver:self forKeyPath:@"color"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - private
- (void)setRgbColor:(RGBColor *)rgbColor {
    _rgbColor = rgbColor;
    [self configTintColor];
    self.view.backgroundColor = self.rgbColor.color;
    self.redSlider.value = self.rgbColor.redComponent;
    self.greenSlider.value = self.rgbColor.greenComponent;
    self.blueSlider.value = self.rgbColor.blueComponent;
    [self.rgbColor addObserver:self
                    forKeyPath:@"color"
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                       context:nil];
}

- (void)configTintColor {
    if (self.rgbColor.redComponent + self.rgbColor.greenComponent + self.rgbColor.blueComponent >= 1.5) {
        for (NSString *key in @[@"R", @"G", @"B"]) {
            [[self valueForKey:[key stringByAppendingString:@"Label"]] setValue:[UIColor blackColor] forKey:@"textColor"];
            [[self valueForKey:[key stringByAppendingString:@"ValueLabel"]] setValue:[UIColor blackColor] forKey:@"textColor"];
        }
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    } else {
        for (NSString *key in @[@"R", @"G", @"B"]) {
            [[self valueForKey:[key stringByAppendingString:@"Label"]] setValue:[UIColor whiteColor] forKey:@"textColor"];
            [[self valueForKey:[key stringByAppendingString:@"ValueLabel"]] setValue:[UIColor whiteColor] forKey:@"textColor"];
        }
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}

# pragma mark - observer notification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    self.view.backgroundColor = self.rgbColor.color;
    [self configTintColor];
}

#pragma mark - IBActions
- (IBAction)updateRedComponent:(UISlider *)sender {
    self.rgbColor.redComponent = sender.value;
    self.RValueLabel.text = [NSString stringWithFormat:@"%.f", sender.value * 255];
}

- (IBAction)updateGreenComponent:(UISlider *)sender {
    self.rgbColor.greenComponent = sender.value;
    self.GValueLabel.text = [NSString stringWithFormat:@"%.f", sender.value * 255];
}

- (IBAction)updateBlueComponent:(UISlider *)sender {
    self.rgbColor.blueComponent = sender.value;
    self.BValueLabel.text = [NSString stringWithFormat:@"%.f", sender.value * 255];
}

@end
