//
//  SNViewController.m
//  SNContacts
//
//  Created by Sergey Sergeev on 10/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "SNViewController.h"
#import "SNMainPresenterViewController.h"
#import "SNSecondPresenterViewController.h"

@interface SNViewController ()

@property(nonatomic, strong) SNMainPresenterViewController* vc_01;
@property(nonatomic, strong) SNSecondPresenterViewController* vc_02;

@end

@implementation _injectable(SNViewController)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vc_01 = [SNMainPresenterViewController new];
    self.vc_02 = [SNSecondPresenterViewController new];
    [self addChildViewController:self.vc_01];
    [self addChildViewController:self.vc_02];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onButtonAction:(id)sender
{
    [self.view addSubview:self.vc_01.view];
    //[self.view addSubview:self.vc_02.view];
}

@end
