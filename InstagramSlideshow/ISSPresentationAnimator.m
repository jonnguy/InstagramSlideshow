//
//  ISSPresentationAnimator.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSPresentationAnimator.h"

@implementation ISSPresentationAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
        return .55;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
//    CGRect fromViewFrame = [fromViewController.view frame];
//    UIGraphicsBeginImageContext(fromViewFrame.size);
//    [fromViewController.view drawViewHierarchyInRect:fromViewFrame afterScreenUpdates:YES];
//    UIGraphicsEndImageContext();
    
    UIView *snapshotView = [toViewController.view resizableSnapshotViewFromRect:toViewController.view.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    snapshotView.frame = self.openingFrame;
    [containerView addSubview:snapshotView];
    [toViewController.view setAlpha:0.0];
    [containerView addSubview:fromViewController.view];
//    [toViewController.view setBackgroundColor:[UIColor clearColor]];
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
        snapshotView.frame = fromViewController.view.frame;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
        [toViewController.view setAlpha:1.0];
        [toViewController.view setBackgroundColor:[UIColor whiteColor]];
        
        [transitionContext completeTransition:finished];
    }];
}

@end
