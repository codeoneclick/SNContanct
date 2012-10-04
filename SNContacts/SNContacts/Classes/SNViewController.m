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

@end

@implementation SNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //SNMainPresenterViewController* vc = [SNMainPresenterViewController new];
    //[self addChildViewController:vc];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonAction:(id)sender
{
    SNMainPresenterViewController* vc = [SNMainPresenterViewController new];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    //[self didMoveToParentViewController:vc];
    //[self presentModalViewController:vc animated:YES];
    //[self addChildViewController:vc];
    //[self transitionFromViewController:self toViewController:vc duration:0.5 options:0 animations:^{
        
    //} completion:^(BOOL finished) {
        
    //}];
    //[self presentViewController:vc animated:YES completion:^{
        
    //}];
    /*[UIView animateWithDuration:0.75 delay:0 options:0 animations:^{
        self.view.frame = CGRectMake(0, 0, 0, 0);
        //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        //[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];

    } completion:^(BOOL finished) {
        [self presentViewController:vc animated:NO completion:^{
            
        }];
    }];*/
}


- (BOOL)isBeingPresented
{
    NSLog(@"dsadasd");
    return YES;
}

- (BOOL)isBeingDismissed
{
    NSLog(@"dsadasd");
    return YES;
}

@end
