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
    NSLog(@"%f, %f",self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = CGRectMake(0, 0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.75 delay:0 options:0 animations:^{
        self.view.frame = CGRectMake(0, 0, 320, 460);
        
    } completion:^(BOOL finished) {

    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"dsadasd");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonAction:(id)sender
{
    /*[UIView animateWithDuration:0.75 delay:0 options:0 animations:^{
        self.view.frame = CGRectMake(0, 0, 0, 0);
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];*/
    
    /*[UIView animateWithDuration:0.75 animations:^{
        self.view.transform = CGAffineTransformRotate(self.view.transform, M_PI);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.75 animations:^{
            self.view.transform = CGAffineTransformRotate(self.view.transform, M_PI);
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
        }];
    }];*/
    
    //[self runSpinAnimationOnView:self.view duration:2.0 rotations:2 repeat:2];
[self rotationWithDuration:2 angle:M_PI * 4 options:UIViewAnimationOptionCurveEaseIn];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)rotationWithDuration:(NSTimeInterval)duration angle:(CGFloat)angle options:(UIViewAnimationOptions)options
{
    // Repeat a quarter rotation as many times as needed to complete the full rotation
    CGFloat sign = angle > 0 ? 1 : -1;
    __block NSUInteger numberRepeats = floorf(fabsf(angle) / M_PI_2);
    CGFloat quarterDuration = duration * M_PI_2 / fabs(angle);
    
    CGFloat lastRotation = angle - sign * numberRepeats * M_PI_2;
    CGFloat lastDuration = duration - quarterDuration * numberRepeats;
    
    __block UIViewAnimationOptions startOptions = UIViewAnimationOptionBeginFromCurrentState;
    UIViewAnimationOptions endOptions = UIViewAnimationOptionBeginFromCurrentState;
    
    if (options & UIViewAnimationOptionCurveEaseIn || options == UIViewAnimationOptionCurveEaseInOut) {
        startOptions |= UIViewAnimationOptionCurveEaseIn;
    } else {
        startOptions |= UIViewAnimationOptionCurveLinear;
    }
    
    if (options & UIViewAnimationOptionCurveEaseOut || options == UIViewAnimationOptionCurveEaseInOut) {
        endOptions |= UIViewAnimationOptionCurveEaseOut;
    } else {
        endOptions |= UIViewAnimationOptionCurveLinear;
    }
    
    void (^lastRotationBlock)(void) = ^ {
        [UIView animateWithDuration:lastDuration
                              delay:0
                            options:endOptions
                         animations:^{
                             self.view.transform = CGAffineTransformRotate(self.view.transform, lastRotation);
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"Animation completed");
                         }
         ];
    };
    
    if (numberRepeats) {
        __block void (^quarterSpinningBlock)(void) = ^{
            [UIView animateWithDuration:quarterDuration
                                  delay:0
                                options:startOptions
                             animations:^{
                                 self.view.transform = CGAffineTransformRotate(self.view.transform, M_PI_2);
                                 numberRepeats--;
                             }
                             completion:^(BOOL finished) {
                                 if (numberRepeats > 0) {
                                     startOptions = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear;
                                     quarterSpinningBlock();
                                 } else {
                                     lastRotationBlock();
                                 }
                                 NSLog(@"Animation completed");
                             }
             ];
            
        };
        
        quarterSpinningBlock();
    } else {
        lastRotationBlock();
    }
}



@end
