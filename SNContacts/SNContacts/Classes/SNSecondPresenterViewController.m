//
//  SNSecondPresenterViewController.m
//  SNContacts
//
//  Created by Sergey Sergeev on 11/1/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "SNSecondPresenterViewController.h"

@interface SNSecondPresenterViewController ()

@end

@implementation SNSecondPresenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
