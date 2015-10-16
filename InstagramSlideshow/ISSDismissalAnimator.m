//
//  ISSDismissalAnimator.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSDismissalAnimator.h"
#import "ISSViewImageViewController.h"

@implementation ISSDismissalAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .55;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    ISSViewImageViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
    // This one zooms into the photo before zooming the view out
//    UIView *snapshotView = [fromViewController.mainImageView resizableSnapshotViewFromRect:fromViewController.mainImageView.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    // This one zoomes the whole view and then resizes at the end
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
