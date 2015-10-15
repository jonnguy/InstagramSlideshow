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
    return .75;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
    UIView *snapshotView = [fromViewController.view resizableSnapshotViewFromRect:fromViewController.view.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    [containerView addSubview:toViewController.view];
    [containerView addSubview:snapshotView];
    
    [fromViewController.view removeFromSuperview];
    
    [UIView animateWithDuration:animationDuration animations:^{
        snapshotView.frame = self.openingFrame;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
