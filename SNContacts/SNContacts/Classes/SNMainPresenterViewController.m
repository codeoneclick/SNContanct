//
//  SNMainPresenterViewController.m
//  SNContacts
//
//  Created by Sergey Sergeev on 10/3/12.
//  Copyright (c) 2012 Sergey Sergeev. All rights reserved.
//

#import "SNMainPresenterViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SNMainPresenterViewController ()

@end

@implementation SNMainPresenterViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setAlpha:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self rotateView:self.view withDuration:2.0 angle:M_PI * 4 withAlpha:1 completion:^{

    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onButtonAction:(id)sender
{
    [self rotateView:self.view withDuration:2.0 angle:-M_PI * 4 withAlpha:0 completion:^{
        [self.view removeFromSuperview];
    }];
}

- (void)rotateView:(UIView*)view withDuration:(NSTimeInterval)duration angle:(CGFloat)angle withAlpha:(CGFloat)alpha completion:(void (^)(void))completion
{
    CGFloat sign = angle > 0 ? 1 : -1;
    __block NSUInteger repeats = floorf(fabsf(angle) / M_PI_2);
    CGFloat loopDuration = duration * M_PI_2 / fabs(angle);
    
    CGFloat endRotation = angle - sign * repeats * M_PI_2;
    CGFloat endDuration = duration - loopDuration * repeats;

    [UIView animateWithDuration:duration delay:0 options:0 animations:^{
        [view setAlpha:alpha];
    }
    completion:^(BOOL finished){
                     }];


    void (^endRotationBlock)(void) = ^ {
        [UIView animateWithDuration:endDuration delay:0 options:0 animations:^{
                             view.transform = CGAffineTransformRotate(view.transform, endRotation);
                         }
                         completion:^(BOOL finished) {
                             completion();
                         }
         ];
    };

    if (repeats > 0)
    {
        __block void (^loopRotationBlock)(void) = ^{
            [UIView animateWithDuration:loopDuration  delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
                                 view.transform = CGAffineTransformRotate(view.transform, M_PI_2);
                                 repeats--;
                             }
                             completion:^(BOOL finished) {
                                 if (repeats > 0)
                                 {
                                     loopRotationBlock();
                                 } else {
                                     endRotationBlock();
                                 }
                             }
             ];
        };
        loopRotationBlock();
    }
    else
    {
        endRotationBlock();
    }
}



@end
