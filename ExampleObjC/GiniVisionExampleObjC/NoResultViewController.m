//
//  NoResultViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 16/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "NoResultViewController.h"

@interface NoResultViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *rotateImageView;

@end

@implementation NoResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rotateImageView.image = [_rotateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (IBAction)retry:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
