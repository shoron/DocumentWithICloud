//
//  DetailViewController.m
//  TinyPix
//
//  Created by shoron on 15/12/9.
//  Copyright © 2015年 com. All rights reserved.
//

#import "DetailViewController.h"
#import "TinyPixView.h"

#import "SRConstants.h"
#import "TinyPixUtils.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet TinyPixView *tinyPixView;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
        [self updateTintColor];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.tinyPixView.document = self.detailItem;
        [self.tinyPixView setNeedsDisplay];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self updateTintColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultSettingChanged) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [(UIDocument *)self.detailItem closeWithCompletionHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTintColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedColorIndex = [userDefaults integerForKey:kUserDefaultsKeySelectedColorIndex];
    UIColor *tintColor = [TinyPixUtils getTintColorForIndex:selectedColorIndex];
    self.tinyPixView.tintColor = tintColor;
    [self.tinyPixView setNeedsDisplay];
}

#pragma mark - Notification

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)userDefaultSettingChanged {
    [self updateTintColor];
}

@end
