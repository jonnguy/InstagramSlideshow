//  Copyright (c) 2015 Recruit Marketing Partners Co.,Ltd. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RMPZoomTransitionAnimator.h"
#import "ISSViewImageViewController.h"
#import "ISSImagesCollectionViewController.h"

@implementation RMPZoomTransitionAnimator

// constants for transition animation
static const NSTimeInterval kForwardAnimationDuration         = 0.55;
static const NSTimeInterval kBackwardAnimationDuration        = 0.55;

#pragma mark - <UIViewControllerAnimatedTransitioning>

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.goingForward) {
        return kForwardAnimationDuration ;
    } else {
        return kBackwardAnimationDuration ;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.goingForward) {
        [self zoomInWithContext:transitionContext];
    } else {
        [self zoomOutWithContext:transitionContext];
    }
}

- (void)zoomInWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Setup for animation transition
    ISSImagesCollectionViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ISSViewImageViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView    = [transitionContext containerView];
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];
    
    // Without animation when you have not confirm the protocol
    Protocol *animating = @protocol(RMPZoomTransitionAnimating);
    BOOL doesNotConfirmProtocol = ![self.sourceTransition conformsToProtocol:animating] || ![self.destinationTransition conformsToProtocol:animating];
    if (doesNotConfirmProtocol) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        return;
    }
    
    // Add a alphaView To be overexposed, so background becomes dark in animation
    UIView *alphaView = [[UIView alloc] initWithFrame:[transitionContext finalFrameForViewController:toVC]];
    alphaView.backgroundColor = [self.sourceTransition transitionSourceBackgroundColor];
    [containerView addSubview:alphaView];
    
    // Transition source of image to move me to add to the last
    UIImageView *sourceImageView = [self.sourceTransition transitionSourceImageView];
    [containerView addSubview:sourceImageView];
    
    [toVC.view setAlpha:0];
    [toVC.mainImageView setHidden:YES];
        [UIView animateWithDuration:kForwardAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             sourceImageView.frame = [self.destinationTransition transitionDestinationImageViewFrame];
                             
                             [toVC.view setAlpha:1];
                             alphaView.alpha = 0.9;
                         }
                         completion:^(BOOL finished) {
                             alphaView.alpha = 0;
                             sourceImageView.alpha = 0;
                              [toVC.mainImageView setHidden:NO];
                             
                             [transitionContext completeTransition:YES];
                         }];

}

- (void)zoomOutWithContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    ISSViewImageViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ISSImagesCollectionViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    // Add a alphaView To be overexposed, so background becomes dark in animation
    UIView *alphaView = [fromVC.mainImageView resizableSnapshotViewFromRect:fromVC.mainImageView.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    [alphaView setFrame:[self.sourceTransition transitionDestinationImageViewFrame]];
    alphaView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:toVC.view];
    [containerView addSubview:alphaView];
    
    [fromVC.view setAlpha:1];
    [fromVC.mainImageView setHidden:YES];
    [toVC.view setAlpha:0];
    
    [UIView animateWithDuration:kBackwardAnimationDuration animations:^{
        alphaView.frame = self.openingFrame;
//        [fromVC.view setAlpha:0];
        [toVC.view setAlpha:1];
    } completion:^(BOOL finished) {
        [alphaView removeFromSuperview];
        [fromVC.mainImageView setHidden:NO];
        
        if ([self.destinationTransition conformsToProtocol:@protocol(RMPZoomTransitionAnimating)] &&
            [self.destinationTransition respondsToSelector:@selector(zoomTransitionAnimator:didCompleteTransition:)]) {
            [self.destinationTransition zoomTransitionAnimator:self
                                         didCompleteTransition:![transitionContext transitionWasCancelled]];
        }
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    
    [UIView animateWithDuration:0.40 animations:^{
        [fromVC.view setAlpha:0];
    } completion:^(BOOL finished) {
    }];
}

@end
