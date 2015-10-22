//
//  ISSDismissalAnimator.m
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import "ISSDismissalAnimator.h"
#import "ISSViewImageViewController.h"
#import "ISSImagesCollectionViewController.h"

@implementation ISSDismissalAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .55;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    ISSViewImageViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *containerView = [transitionContext containerView];
//    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
//
//    // This one zooms into the photo before zooming the view out
////    UIView *snapshotView = [fromViewController.mainImageView resizableSnapshotViewFromRect:fromViewController.mainImageView.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
//    
//    // This one zoomes the whole view and then resizes at the end
//    UIView *snapshotView = [fromViewController.view resizableSnapshotViewFromRect:fromViewController.view.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
//    [containerView addSubview:toViewController.view];
//    [containerView addSubview:snapshotView];
//    
//    
//    [fromViewController.view removeFromSuperview];
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        snapshotView.frame = self.openingFrame;
//    } completion:^(BOOL finished) {
//        [snapshotView removeFromSuperview];
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];
    
    
    // Setup for animation transition
    ISSViewImageViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ISSImagesCollectionViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView    = [transitionContext containerView];
    //    [containerView addSubview:fromVC.view];
    //    [containerView addSubview:toVC.view];
    
    //    // Without animation when you have not confirm the protocol
    //    Protocol *animating = @protocol(RMPZoomTransitionAnimating);
    //    BOOL doesNotConfirmProtocol = ![self.sourceTransition conformsToProtocol:animating] || ![self.destinationTransition conformsToProtocol:animating];
    //    if (doesNotConfirmProtocol) {
    //        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    //        return;
    //    }
    
    // Add a alphaView To be overexposed, so background becomes dark in animation
    UIView *alphaView = [fromVC.mainImageView resizableSnapshotViewFromRect:fromVC.mainImageView.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    alphaView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:toVC.view];
    [containerView addSubview:alphaView];
    
//    // This one zoomes the whole view and then resizes at the end
//    UIView *snapshotView = [fromVC.mainImageView resizableSnapshotViewFromRect:fromVC.view.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
//    [containerView addSubview:toVC.view];
//    [containerView addSubview:snapshotView];

    [fromVC.view removeFromSuperview];

    [UIView animateWithDuration:animationDuration animations:^{
        alphaView.frame = self.openingFrame;
    } completion:^(BOOL finished) {
        [alphaView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    // Transition source of image to move me to add to the last
//    UIImageView *sourceImageView = [self.sourceTransition transitionSourceImageView];
//    [sourceImageView setFrame:[self.sourceTransition transitionDestinationImageViewFrame]];
//    [containerView addSubview:sourceImageView];
//    NSLog(@"Source: %@", sourceImageView);
//    
//    [fromVC.view setAlpha:0];
//    [toVC.view setAlpha:0];
//    [UIView animateWithDuration:kBackwardAnimationDuration
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         //                         sourceImageView.frame = [self.destinationTransition transitionDestinationImageViewFrame];
//                         sourceImageView.frame = self.openingFrame;
//                         NSLog(@"Source image view: %@", sourceImageView);
//                         alphaView.alpha = 0;
//                         [toVC.view setAlpha:1.0];
//                     }
//                     completion:^(BOOL finished) {
//                         sourceImageView.alpha = 0;
//                         [transitionContext completeTransition:YES];
//                     }];
}

@end
