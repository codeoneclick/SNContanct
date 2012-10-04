//
//  SNViewController.m
//  SNContacts
//
//  Created by Sergey Sergeev on 10/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "SNViewController.h"
#import "SNMainPresenterViewController.h"

@interface SNViewController ()

@property(nonatomic, strong) SNMainPresenterViewController* vc;

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vc = [SNMainPresenterViewController new];
    [self addChildViewController:self.vc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onButtonAction:(id)sender
{
    [self.view addSubview:self.vc.view];
}

@end
