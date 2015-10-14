//
//  ISSDismissalAnimator.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSDismissalAnimator.h"

@implementation ISSDismissalAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 2.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]; // Not used
    UIView *containerView = [transitionContext containerView];
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
    UIView *snapshotView = [fromViewController.view resizableSnapshotViewFromRect:fromViewController.view.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    [containerView addSubview:snapshotView];
    
    [fromViewController.view setAlpha:0.0];
    
    [UIView animateWithDuration:animationDuration animations:^{
        snapshotView.frame = self.openingFrame;
        snapshotView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
