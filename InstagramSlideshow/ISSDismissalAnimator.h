//
//  ISSDismissalAnimator.h
//  InstagramSlideshow
//
//  Created by Jon Nguy on 10/13/15.
//  Copyright © 2015 Jon Nguy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISSDismissalAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGRect openingFrame;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
