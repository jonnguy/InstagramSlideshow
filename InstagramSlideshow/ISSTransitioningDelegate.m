//
//  ISSTransitioningDelegate.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSTransitioningDelegate.h"
#import "ISSDismissalAnimator.h"
#import "ISSPresentationAnimator.h"

@implementation ISSTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ISSPresentationAnimator *animator = [[ISSPresentationAnimator alloc] init];
    animator.openingFrame = self.openingFrame;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ISSDismissalAnimator *animator = [[ISSDismissalAnimator alloc] init];
    animator.openingFrame = self.openingFrame;
    return animator;
}

@end
