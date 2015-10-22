//
//  ISSPresentationAnimator.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSPresentationAnimator.h"
#import "ISSImagesCollectionViewController.h"
#import "ISSViewImageViewController.h"

@implementation ISSPresentationAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
        return 2.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    ISSImagesCollectionViewController *fromViewController = (ISSImagesCollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ISSViewImageViewController *toViewController = (ISSViewImageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
//    [containerView addSubview:fromViewController.view];
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    
//    CGRect fromViewFrame = [fromViewController.view frame];
//    UIGraphicsBeginImageContext(fromViewFrame.size);
//    [fromViewController.view drawViewHierarchyInRect:fromViewFrame afterScreenUpdates:YES];
//    UIGraphicsEndImageContext();
    
//    UIView *snapshotView = [toViewController.view resizableSnapshotViewFromRect:toViewController.view.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
//    UIView *snapshotView = [toViewController.mainImageView resizableSnapshotViewFromRect:toViewController.mainImageView.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
//    UIView *snapshotView = [toViewController.mainImageView snapshotViewAfterScreenUpdates:YES];
//    snapshotView.frame = self.openingFrame;
//    [containerView addSubview:snapshotView];
//    [toViewController.view setAlpha:0.0];
////    [toViewController.view setBackgroundColor:[UIColor clearColor]];
//    [containerView addSubview:toViewController.view];
    
    
    // Transition source of image to move me to add to the last
    UIImageView *sourceImageView = [fromViewController transitionSourceImageView];
    [containerView addSubview:sourceImageView];
    
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
        sourceImageView.frame = [toViewController transitionDestinationImageViewFrame];
    } completion:^(BOOL finished) {
        [sourceImageView removeFromSuperview];
        [toViewController.view setAlpha:1.0];
        [toViewController.view setBackgroundColor:[UIColor whiteColor]];
        
        [transitionContext completeTransition:finished];
    }];
}

@end
